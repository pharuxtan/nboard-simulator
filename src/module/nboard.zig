const std = @import("std");
const atomic = std.atomic;
const Futex = std.Thread.Futex;
const windows = std.os.windows;

extern "kernel32" fn TerminateThread(hThread: windows.HANDLE, dwExitCode: windows.DWORD) callconv(windows.WINAPI) windows.BOOL;

const dyn = @import("../lib/dyn.zig");
const interop = @import("../lib/interop.zig");
const nboard = @import("../lib/nboard.zig");

const PinName = interop.PinName;

// Nboard Thread

const BUILD_NBOARD_FLAG = 1 << 0;
const RUN_NBOARD_FLAG = 1 << 1;
const STOP_NBOARD_FLAG = 1 << 2;

pub const NboardContextStatic = extern struct {
  pins: [256]u8,
  anain: [8]f32,
  jog: u8,
  cod: u8,
  lcd: [32]u8,
  bargraph: [10]u8,
};

const NboardContext = struct {
  flags: atomic.Value(u32),
  pins: [256]atomic.Value(u8),
  pwms: [4]PWM,
  anain: [8]atomic.Value(f32),

  jog: atomic.Value(u8),
  cod: atomic.Value(u8),

  ihmMutex: std.Thread.Mutex,
  lcd: [32]u8,
  bargraph: [10]u8,

  fn init() NboardContext {
    var c = std.mem.zeroInit(NboardContext, .{
      .flags = atomic.Value(u32).init(0),
      .jog = atomic.Value(u8).init(0),
      .cod = atomic.Value(u8).init(0),
      .ihmMutex = std.Thread.Mutex{},
    });

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
    for(&self.pwms) |*pwm| {
      pwm.*.period.store(0, .seq_cst);
      pwm.*.periodUp.store(0, .seq_cst);
      pwm.*.periodDown.store(0, .seq_cst);
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
  }

  pub fn static(self: *NboardContext) NboardContextStatic {
    var s = std.mem.zeroes(NboardContextStatic);

    for(0..256) |i| {
      s.pins[i] = self.pins[i].load(.seq_cst);
    }

    for(0..8) |i| {
      s.anain[i] = self.anain[i].load(.seq_cst);
    }

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

      context.restore();

      optLib = optLib orelse dyn.loadLibrary("./resources/build/nboard.dll") catch continue;

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
  if(optLib.*) |lib| {
    std.DynLib.close(@constCast(&lib));
    optLib.* = null;
  }
}

fn nboardThread(main: dyn.funcType("internal_main")) void {
  main(&simulatorFuncs);
}

// PWM Threads

const PWM = struct {
  period: atomic.Value(i32),
  periodUp: atomic.Value(i32),
  periodDown: atomic.Value(i32),
  pin: PinName,

  fn init(pin: PinName) PWM {
    return .{
      .period = atomic.Value(i32).init(0),
      .periodUp = atomic.Value(i32).init(0),
      .periodDown = atomic.Value(i32).init(0),
      .pin = pin
    };
  }

  fn setPeriod(self: *PWM, period: i32) void {
    const p: f64 = @floatFromInt(self.period.load(.seq_cst));
    self.period.store(0, .seq_cst);
    if(p != 0){
      const p_up: f64 = @floatFromInt(self.periodUp.load(.seq_cst));
      const p_down: f64 = @floatFromInt(self.periodDown.load(.seq_cst));
      self.periodUp.store(@intFromFloat(p_up * @as(f64, @floatFromInt(period)) / p), .seq_cst);
      self.periodDown.store(@intFromFloat(p_down * @as(f64, @floatFromInt(period)) / p), .seq_cst);
    }
    self.period.store(period, .seq_cst);
  }

  fn setRcy(self: *PWM, rcy: f32) void {
    const r: f64 = @floatCast(std.math.clamp(rcy, 0, 1));
    const period: f64 = @floatFromInt(self.period.load(.seq_cst));
    self.periodUp.store(@intFromFloat(period * r), .seq_cst);
    self.periodDown.store(@intFromFloat(period * (1.0 - r)), .seq_cst);
  }

  fn setPulse(self: *PWM, pulse: i32) void {
    const period: f64 = @floatFromInt(self.period.load(.seq_cst));
    const p: i32 = std.math.clamp(pulse, 0, self.period.load(.seq_cst));
    self.periodUp.store(p, .seq_cst);
    self.periodDown.store(@intFromFloat(period - @as(f64, @floatFromInt(p))), .seq_cst);
  }

  fn setPin(self: *PWM, state: u8) void {
    context.pins[@intCast(self.pin)].store(state, .seq_cst);
  }
};

fn pwmThread(pwm_index: usize) void {
  while(true)
  {
    var pwm = context.pwms[pwm_index];
    const period = pwm.period.load(.seq_cst);
    const periodUp = pwm.periodUp.load(.seq_cst);
    const periodDown = pwm.periodDown.load(.seq_cst);
    if(period == 0 or (periodUp == 0 and periodDown == 0) or !is_running.load(.acquire)){
      std.time.sleep(1e6);
      continue;
    }

    if(periodUp == period){
      if(is_running.load(.acquire)) pwm.setPin(1) else continue;
      std.time.sleep(@intCast(period * 1000));
    } else if(periodDown == period){
      if(is_running.load(.acquire)) pwm.setPin(0) else continue;
      std.time.sleep(@intCast(period * 1000));
    } else {
      if(is_running.load(.acquire)) pwm.setPin(1) else continue;
      std.time.sleep(@intCast(periodUp * 1000));
      if(is_running.load(.acquire)) pwm.setPin(0) else continue;
      std.time.sleep(@intCast(periodDown * 1000));
    }
  }
}

// Simulator Funcs

var simulatorFuncs = interop.SimulatorFuncs{
  .debug = @ptrCast(&debug),
  .wait = @ptrCast(&wait),
  .wait_ms = @ptrCast(&wait_ms),
  .wait_us = @ptrCast(&wait_us),
  .get_current_time = @ptrCast(&get_current_time),
  .set_signal =  @ptrCast(&set_signal),
  .read_signal = @ptrCast(&read_signal),
  .set_bus = @ptrCast(&set_bus),
  .read_bus = @ptrCast(&read_bus),
  .pwm_period = @ptrCast(&pwm_period),
  .pwm_rcy = @ptrCast(&pwm_rcy),
  .pwm_pulse = @ptrCast(&pwm_pulse),
  .read_ana = @ptrCast(&read_ana),
  .readu16_ana = @ptrCast(&readu16_ana),
  .get_jog = @ptrCast(&get_jog),
  .get_cod = @ptrCast(&get_cod),
  .can_write = @ptrCast(&can_write),
};

fn debug(v: *anyopaque) ?*anyopaque {
  _ = v;
  context.ihmMutex.lock();
  std.debug.print("{s}\n", .{ context.lcd });
  context.ihmMutex.unlock();
  return null;
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

fn set_signal(pin: PinName, signal: u8) void {
  context.pins[@intCast(pin)].store(signal, .seq_cst);
}

fn read_signal(pin: PinName) u8 {
  return context.pins[@intCast(pin)].load(.seq_cst);
}

fn set_bus(pins: [*c]PinName, signal: u16) void {
  for(0..16, pins) |i, pin| {
    if(pin == interop.NC) continue;
    context.pins[@intCast(pin)].store(@intCast((signal >> @intCast(i)) & 1), .seq_cst);
  }
}

fn read_bus(pins: [*c]PinName) u16 {
  var signal: u16 = 0;
  for(0..16, pins) |i, pin| {
    if(pin == interop.NC) continue;
    signal |= context.pins[@intCast(pin)].load(.seq_cst) << @intCast(i);
  }
  return signal;
}

fn pwm_period(pin: PinName, period: i32) void {
  for(0..4) |i| {
    if(context.pwms[i].pin != pin) continue;
    context.pwms[i].setPeriod(period);
  }
}

fn pwm_rcy(pin: PinName, rcy: f32) void {
  for(0..4) |i| {
    if(context.pwms[i].pin != pin) continue;
    context.pwms[i].setRcy(rcy);
  }
}

fn pwm_pulse(pin: PinName, pulse: i32) void {
  for(0..4) |i| {
    if(context.pwms[i].pin != pin) continue;
    context.pwms[i].setPulse(pulse);
  }
}

fn read_ana() f32 {
  const S2 = context.pins[interop.PF_0].load(.seq_cst);
  const S1 = context.pins[interop.PF_1].load(.seq_cst);
  const S0 = context.pins[interop.PA_8].load(.seq_cst);
  return context.anain[(S2 << 2) | (S1 << 1) | S0].load(.seq_cst);
}

fn readu16_ana() u16 {
  const ana: u16 = @intFromFloat(std.math.round(read_ana() * 4095.0));
  return (ana << 4) | ((ana >> 8) & 0xF);
}

fn get_jog() u8 {
  return context.jog.load(.seq_cst);
}

fn get_cod() u8 {
  return context.cod.load(.seq_cst);
}

const LCD_CHAR0 = 0x700;
const LCD_CHAR1 = 0x701;
const LCD_CHAR2 = 0x702;
const LCD_CHAR3 = 0x703;
const LCD_CLEAR = 0x77F;
const BAR_SET = 0x7B0;

fn can_write(msg: *interop.CAN_Message) void {
  context.ihmMutex.lock();
  switch(msg.id){
    LCD_CHAR0,
    LCD_CHAR1,
    LCD_CHAR2,
    LCD_CHAR3 => {
      const offset = ((msg.id & 0x7F) * 8);
      for(0..8) |i| {
        context.lcd[i + offset] = if(msg.data[i] > 0x20) msg.data[i] else ' ';
      }
    },
    LCD_CLEAR => { for(0..32) |i| context.lcd[i] = ' '; },
    BAR_SET => {
      for(0..2) |i| context.bargraph[9-i] = (msg.data[0] >> (1 - @as(u3, @intCast(i)))) & 1;
      for(0..8) |i| context.bargraph[7-i] = (msg.data[1] >> (7 - @as(u3, @intCast(i)))) & 1;
    },
    else => {}
  }
  context.ihmMutex.unlock();
}
