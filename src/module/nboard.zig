const std = @import("std");
const builtin = @import("builtin");
const atomic = std.atomic;
const Futex = std.Thread.Futex;
const windows = std.os.windows;

extern "kernel32" fn TerminateThread(hThread: windows.HANDLE, dwExitCode: windows.DWORD) callconv(windows.WINAPI) windows.BOOL;
extern "kernel32" fn FreeLibrary(hLibModule: windows.HMODULE) callconv(windows.WINAPI) windows.BOOL;

const dyn = @import("../lib/dyn.zig");
const interop = @import("../lib/interop.zig");
const nboard = @import("../lib/nboard.zig");
const sym = @import("../lib/sym.zig");
const getWindow = @import("../module/webui.zig").getWindow;

// Nboard Thread

const PinMode = enum(u8) {
  NONE,
  OUTPUT,
  INPUT_PULL_UP,
  INPUT_PULL_DOWN,
  INPUT_PULL_NONE,
  PWM,
};

const BUILD_NBOARD_FLAG = 1 << 0;
const RUN_NBOARD_FLAG = 1 << 1;
const STOP_NBOARD_FLAG = 1 << 2;

pub const NboardContextStatic = extern struct {
  pins: [256]u8,
  anain: [8]f32,
  anaout: f32,
  jog: u8,
  cod: i8,
  lcd: [32]u8,
  bargraph: [10]u8,
};

const NboardContext = struct {
  flags: atomic.Value(u32),
  pinModes: [256]atomic.Value(PinMode),
  pins: [256]atomic.Value(u8),
  pwms: [4]PWM,
  anain: [8]atomic.Value(f32),
  anaout: atomic.Value(f32),

  jog: atomic.Value(u8),
  cod: atomic.Value(i8),

  ihmMutex: std.Thread.Mutex,
  lcd: [32]u8,
  bargraph: [10]u8,

  fn init() NboardContext {
    @setEvalBranchQuota(10000);

    var c = std.mem.zeroInit(NboardContext, .{
      .flags = atomic.Value(u32).init(0),
      .jog = atomic.Value(u8).init(0),
      .cod = atomic.Value(i8).init(0),
      .anaout = atomic.Value(f32).init(0),
      .ihmMutex = std.Thread.Mutex{},
    });

    for(&c.pinModes) |*pinMode| {
      pinMode.* = atomic.Value(PinMode).init(PinMode.NONE);
    }

    for(&c.pins) |*pin| {
      pin.* = atomic.Value(u8).init(0);
    }

    c.pwms[0] = PWM.init(interop.PA_1);
    c.pwms[1] = PWM.init(interop.PA_3);
    c.pwms[2] = PWM.init(interop.PA_6);
    c.pwms[3] = PWM.init(interop.PA_7);

    for(&c.anain) |*anain| {
      anain.* = atomic.Value(f32).init(0);
    }

    for(&c.lcd) |*char| {
      char.* = ' ';
    }

    for(&c.bargraph) |*led| {
      led.* = 0;
    }

    return c;
  }

  fn restore(self: *NboardContext) void {
    @setEvalBranchQuota(10000);

    self.anaout.store(0, .seq_cst);

    for(&self.pwms) |*pwm| {
      pwm.*.period.store(0, .seq_cst);
      pwm.*.periodUp.store(0, .seq_cst);
      pwm.*.periodDown.store(0, .seq_cst);
    }

    for(&self.pinModes) |*pinMode| {
      pinMode.*.store(PinMode.NONE, .seq_cst);
    }

    for(&self.pins) |*pin| {
      pin.*.store(0, .seq_cst);
    }

    for(0..6) |i| { // Don't restore input analogs
      self.anain[i].store(0, .seq_cst);
    }
    
    for(&self.lcd) |*char| {
      char.* = ' ';
    }

    for(&self.bargraph) |*led| {
      led.* = 0;
    }

    // As the Nboard Thread is killed, the mutex can be in lock state if it was writing to the CAN so we unlock it
    _ = self.ihmMutex.tryLock();
    
    if(builtin.mode == .Debug)
      self.ihmMutex.impl.locking_thread.store(std.Thread.getCurrentId(), .seq_cst);
    
    self.ihmMutex.unlock();
  }

  pub fn static(self: *NboardContext) NboardContextStatic {
    var s = std.mem.zeroes(NboardContextStatic);

    for(0..256) |i| {
      s.pins[i] = self.pins[i].load(.seq_cst);
    }

    for(0..8) |i| {
      s.anain[i] = self.anain[i].load(.seq_cst);
    }

    s.anaout = self.anaout.load(.seq_cst);

    s.jog = self.jog.load(.seq_cst);
    s.cod = self.cod.load(.seq_cst);

    self.ihmMutex.lock();
    @memcpy(s.lcd[0..32], self.lcd[0..32]);
    @memcpy(s.bargraph[0..10], self.bargraph[0..10]);
    self.ihmMutex.unlock();

    return s;
  }
};

pub var context = NboardContext.init();

var is_building = atomic.Value(bool).init(false);

var is_running = atomic.Value(bool).init(false);

pub fn init() !void {
  var thread = try std.Thread.spawn(.{}, managerThread, .{});
  thread.detach();

  for(0..context.pwms.len) |i| {
    var t = try std.Thread.spawn(.{}, pwmThread, .{ i });
    t.detach();
  }
}

pub fn run() void {
  flagSet(RUN_NBOARD_FLAG);
}

pub fn stop() void {
  flagSet(STOP_NBOARD_FLAG);
}

pub fn build() void {
  is_building.store(true, .release);
  flagSet(STOP_NBOARD_FLAG | BUILD_NBOARD_FLAG);
}

pub fn buildAndRun() void {
  is_building.store(true, .release);
  flagSet(STOP_NBOARD_FLAG | BUILD_NBOARD_FLAG | RUN_NBOARD_FLAG);
}

pub fn reset() void {
  flagSet(STOP_NBOARD_FLAG | RUN_NBOARD_FLAG);
}

pub fn isBuilding() bool {
  return is_building.load(.acquire);
}

pub fn isRunning() bool {
  return is_running.load(.acquire);
}

pub fn flagSet(flag: u32) void {
  _ = context.flags.fetchOr(flag, .release);
  Futex.wake(&context.flags, 1);
}

pub fn flagReset(flag: u32) void {
  _ = context.flags.fetchAnd(~flag, .release);
}

pub fn flagWait() u32 {
  Futex.wait(&context.flags, 0x0);
  return context.flags.load(.acquire);
}

pub fn flagCheck(flags: u32, flag: u32) bool {
  return (flags & flag) != 0;
}

fn managerThread() void {
  var flags: u32 = 0;
  var optThread: ?std.Thread = null;
  var optLib: ?std.DynLib = null;

  while(true){
    flags = flagWait();
    flagReset(flags);

    if(flagCheck(flags, STOP_NBOARD_FLAG)){
      stopNboardThread(&optThread, &optLib);
    }

    if(flagCheck(flags, BUILD_NBOARD_FLAG)){
      if(is_running.load(.acquire)) continue;

      is_building.store(true, .release);

      const hasFailed = nboard.build() catch true;

      is_building.store(false, .release);

      flagReset(BUILD_NBOARD_FLAG);

      if(hasFailed) continue; // Don't run if it fail
    }

    if(flagCheck(flags, RUN_NBOARD_FLAG)){
      if(optThread) |_| continue;

      if(optLib == null){
        optLib = dyn.loadLibrary("./resources/build/nboard.dll") catch continue;
        sym.loadNboardSymbols();
      }

      if(optLib) |*lib| {
        const main = dyn.lookup(lib, "internal_main");
        optThread = std.Thread.spawn(.{}, nboardThread, .{ main }) catch unreachable;
        is_running.store(true, .release);
      }
    }
  }
}

fn stopNboardThread(optThread: *?std.Thread, optLib: *?std.DynLib) void {
  if(optThread.*) |zigThread| {
    var thread = zigThread.impl.thread;
    _ = TerminateThread(thread.thread_handle, 0);
    _ = windows.kernel32.WaitForSingleObject(thread.thread_handle, windows.INFINITE);
    _ = windows.kernel32.CloseHandle(thread.thread_handle);
    thread.completion.store(.completed, .seq_cst);
    _ = windows.kernel32.HeapFree(thread.heap_handle, 0, thread.heap_ptr);
    is_running.store(false, .release);
    context.restore();
    optThread.* = null;
  }
  if(optLib.*) |*lib| {
    while(FreeLibrary(lib.inner.dll) != 0){} // Be sure that the DLL is fully unloaded
    sym.unloadNboardSymbols();
    optLib.* = null;
  }
}

fn nboardThread(main: dyn.funcType("internal_main")) !void {
  main(&simulatorFuncs);
}

fn checkMode(pin: u8, mode: PinMode) bool {
  const m = context.pinModes[@intCast(pin)].load(.seq_cst);
  return m == mode;
}

fn getStackTrace(allocator: std.mem.Allocator) []const u8 {
  const ret_addr = @returnAddress();
  var stacktrace = std.ArrayList(u8).init(allocator);
  errdefer stacktrace.deinit();
  const writer = stacktrace.writer();
  const debug_info = std.debug.getSelfDebugInfo() catch {
    return "null";
  };
  std.debug.writeCurrentStackTrace(writer, debug_info, .no_color, ret_addr) catch {
    return "null";
  };
  return stacktrace.toOwnedSlice() catch "null";
}

fn failStop(msg: [*:0]const u8) noreturn {
  const allocator = std.heap.c_allocator;

  const window = getWindow();
  if(window) |win| blk: {
    const rawTrace = getStackTrace(allocator);

    const sizeTrace = std.mem.replacementSize(u8, rawTrace, "\\", "\\\\");
    
    const trace = allocator.alloc(u8, sizeTrace) catch break :blk;
    defer allocator.free(trace);

    _ = std.mem.replace(u8, rawTrace, "\\", "\\\\", trace);

    if(!std.mem.eql(u8, rawTrace, "null"))
      allocator.free(rawTrace);

    const script = std.fmt.allocPrintZ(allocator, "failLog(`{s}`,`{s}`)", .{ msg, trace }) catch break :blk;
    defer allocator.free(script);

    win.run(script);
  }
  
  stop();

  while(true){
    std.time.sleep(1e6);
  }
}

// PWM Threads

const PWM = struct {
  period: atomic.Value(f32),
  periodUp: atomic.Value(f32),
  periodDown: atomic.Value(f32),
  pin: u8,

  fn init(pin: u8) PWM {
    return .{
      .period = atomic.Value(f32).init(0),
      .periodUp = atomic.Value(f32).init(0),
      .periodDown = atomic.Value(f32).init(0),
      .pin = pin
    };
  }

  fn setFreq(self: *PWM, period: f32) void {
    const p: f32 = self.period.load(.seq_cst);
    self.period.store(0, .seq_cst);
    if(p != 0){
      const p_up: f32 = self.periodUp.load(.seq_cst);
      const p_down: f32 = self.periodDown.load(.seq_cst);
      self.periodUp.store(p_up * period / p, .seq_cst);
      self.periodDown.store(p_down * period / p, .seq_cst);
    }
    self.period.store(period, .seq_cst);
  }

  fn setRcy(self: *PWM, rcy: f32) void {
    const r: f32 = std.math.clamp(rcy, 0, 1);
    const period: f32 = self.period.load(.seq_cst);
    if(r == 1){
      self.periodUp.store(period, .seq_cst);
      self.periodDown.store(0, .seq_cst);
    } else if(r == 0){
      self.periodUp.store(0, .seq_cst);
      self.periodDown.store(period, .seq_cst);
    } else {
      self.periodUp.store(period / r, .seq_cst);
      self.periodDown.store(period / (1.0 - r), .seq_cst);
    }
  }

  fn setPin(self: *PWM, state: u8) void {
    context.pins[@intCast(self.pin)].store(state, .seq_cst);
  }
};

fn pwmThread(pwm_index: usize) void {
  while(true)
  {
    var pwm = context.pwms[pwm_index];
    const period: f32 = pwm.period.load(.seq_cst);
    const periodUp: f32 = pwm.periodUp.load(.seq_cst);
    const periodDown: f32 = pwm.periodDown.load(.seq_cst);
    if(!checkMode(pwm.pin, PinMode.PWM) or period == 0 or (periodUp == 0 and periodDown == 0) or !is_running.load(.acquire)){
      std.time.sleep(1e6);
      continue;
    }

    if(periodUp == period){
      if(is_running.load(.acquire)) pwm.setPin(1) else continue;
      std.time.sleep(@intFromFloat(1.0e9 / period));
    } else if(periodDown == period){
      if(is_running.load(.acquire)) pwm.setPin(0) else continue;
      std.time.sleep(@intFromFloat(1.0e9 / period));
    } else {
      if(is_running.load(.acquire)) pwm.setPin(1) else continue;
      std.time.sleep(@intFromFloat(1.0e9 / periodUp));
      if(is_running.load(.acquire)) pwm.setPin(0) else continue;
      std.time.sleep(@intFromFloat(1.0e9 / periodDown));
    }
  }
}

// Simulator Funcs

var simulatorFuncs = interop.SimulatorFuncs{
  .pin_mode = @ptrCast(&pin_mode),
  .@"error" = @ptrCast(&_error),
  .wait = @ptrCast(&wait),
  .wait_ms = @ptrCast(&wait_ms),
  .wait_us = @ptrCast(&wait_us),
  .get_current_time = @ptrCast(&get_current_time),
  .set_pin = @ptrCast(&set_pin),
  .toggle_pin = @ptrCast(&toggle_pin),
  .read_pin = @ptrCast(&read_pin),
  .set_bus = @ptrCast(&set_bus),
  .pwm_freq = @ptrCast(&pwm_freq),
  .pwm_rcy = @ptrCast(&pwm_rcy),
  .read_ana = @ptrCast(&read_ana),
  .write_ana = @ptrCast(&write_ana),
  .get_jog = @ptrCast(&get_jog),
  .get_cod = @ptrCast(&get_cod),
  .can_write = @ptrCast(&can_write),
};

fn pin_mode(pin: u8, mode: PinMode) void {
  const actual = context.pinModes[@intCast(pin)].load(.seq_cst);
  if(actual == PinMode.PWM and mode != PinMode.PWM){
    failStop("Vous ne pouvez pas changer de mode après avoir mit une broche en mode PWM");
  } else if(mode == PinMode.PWM){
    switch(pin){
      interop.PA_2 => failStop("Vous ne pouvez pas mettre la led 7 en mode PWM"),
      interop.PA_5 => failStop("Vous ne pouvez pas mettre la led 3 en mode PWM"),
      interop.PA_0 => failStop("Vous ne pouvez pas mettre la led 6 en mode PWM"),
      interop.PB_3 => failStop("Vous ne pouvez pas mettre la led 0 en mode PWM"),
      else => {}
    }
  }
  context.pinModes[@intCast(pin)].store(mode, .seq_cst);
}

fn _error(msg: [*c]const u8) void {
  failStop(msg);
}

fn wait(s: f32) void {
  std.time.sleep(@intFromFloat(s * 1.0e9));
}

fn wait_ms(ms: i32) void {
  std.time.sleep(@intCast(ms * 1000000));
}

fn wait_us(us: i32) void {
  std.time.sleep(@intCast(us * 1000));
}

fn get_current_time() u64 {
  const now = std.time.Instant.now() catch unreachable;
  return now.timestamp / 10;
}

fn set_pin(pin: u8, signal: u8) void {
  if(!checkMode(pin, PinMode.OUTPUT)){
    failStop("Une broche que vous essayez de changer n'est pas en mode output");
  }
  context.pins[@intCast(pin)].store(@intFromBool(signal != 0), .seq_cst);
}

fn toggle_pin(pin: u8) void {
  if(!checkMode(pin, PinMode.OUTPUT)){
    failStop("Une broche que vous essayez de changer n'est pas en mode output");
  }
  const state = context.pins[@intCast(pin)].load(.seq_cst);
  context.pins[@intCast(pin)].store(@intFromBool(state == 0), .seq_cst);
}

fn read_pin(pin: u8) u8 {
  if(checkMode(pin, PinMode.INPUT_PULL_UP)){
    return @intFromBool(context.pins[@intCast(pin)].load(.seq_cst) == 0);
  } else if(checkMode(pin, PinMode.INPUT_PULL_DOWN) or checkMode(pin, PinMode.INPUT_PULL_NONE)){
    // CHECK BP
    if(pin == interop.PA_9 or
       pin == interop.PA_10 or
       pin == interop.PB_0 or
       pin == interop.PB_7){
      failStop("Vous essayez de lire un bouton poussoir en pull down/pull none, ce qui n'est pas possible");
    }
    return @intFromBool(context.pins[@intCast(pin)].load(.seq_cst) != 0);
  } else {
    failStop("Une broche n'est pas en mode pull up/down/none");
  }
}

fn set_bus(pins: [*c]u8, signal: u16) void {
  for(0..16, pins) |i, pin| {
    if(pin == interop.NC) continue;
    if(!checkMode(pin, PinMode.OUTPUT)){
      failStop("Une broche que vous essayez de changer dans le bus n'est pas en mode output");
    }
    context.pins[@intCast(pin)].store(@intCast((signal >> @intCast(i)) & 1), .seq_cst);
  }
}

fn pwm_freq(pin: u8, freq: f32) void {
  if(!checkMode(pin, PinMode.PWM)){
    failStop("Une broche n'est pas en mode PWM");
  }
  for(0..4) |i| {
    if(context.pwms[i].pin != pin) continue;
    context.pwms[i].setFreq(freq);
  }
}

fn pwm_rcy(pin: u8, rcy: f32) void {
  if(!checkMode(pin, PinMode.PWM)){
    failStop("Une broche n'est pas en mode PWM");
  }
  for(0..4) |i| {
    if(context.pwms[i].pin != pin) continue;
    context.pwms[i].setRcy(rcy);
  }
}

fn read_ana(pin: u8) u16 {
  if(pin != interop.PB_1){
    failStop("Vous ne pouvez pas lire en mode analogique sur une autre broche que PB_1");
  }
  const S2: u8 = context.pins[interop.PF_0].load(.seq_cst);
  const S1: u8 = context.pins[interop.PF_1].load(.seq_cst);
  const S0: u8 = context.pins[interop.PA_8].load(.seq_cst);
  const ana: f32 = context.anain[(S2 << 2) | (S1 << 1) | S0].load(.seq_cst);
  return @intFromFloat(std.math.round(ana * 4095.0));
}

fn write_ana(pin: u8, value: u16) void {
  if(pin != interop.PA_4){
    failStop("Vous ne pouvez pas écrire en mode analogique sur une autre broche que PA_4");
  }
  context.anaout.store(@as(f32, @floatFromInt(value & 0xFFF)) / 4095.0, .seq_cst);
}

fn get_jog() u8 {
  return context.jog.load(.seq_cst);
}

fn get_cod() i8 {
  return context.cod.load(.seq_cst);
}

fn can_write(ident: u16, size: u8, tab_data: [*c]u8) void {
  context.ihmMutex.lock();
  switch(ident){
    interop.LCD_CHAR0,
    interop.LCD_CHAR1,
    interop.LCD_CHAR2,
    interop.LCD_CHAR3 => {
      const data = tab_data[0..size];
      const offset = (ident & 0x7F) * 8;
      for(0..8) |i| {
        context.lcd[i + offset] = if(data[i] > 0x20) data[i] else ' ';
      }
    },
    interop.LCD_CLEAR => { for(0..32) |i| context.lcd[i] = ' '; },
    interop.BAR_WRITE => {
      const data = tab_data[0..size];
      for(0..2) |i| context.bargraph[9-i] = (data[0] >> (1 - @as(u3, @intCast(i)))) & 1;
      for(0..8) |i| context.bargraph[7-i] = (data[1] >> (7 - @as(u3, @intCast(i)))) & 1;
    },
    else => {}
  }
  context.ihmMutex.unlock();
}
