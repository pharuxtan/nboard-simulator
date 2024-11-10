const std = @import("std");
const dyn = @import("../lib/dyn.zig");
const child = @import("../lib/child.zig");
const dpi = @import("../lib/dpi.zig");

const webui = @import("webui");
const Event = webui.Event;

const nboard = @import("./nboard.zig");

const allocator = std.heap.c_allocator;

var window: ?webui = undefined;

pub fn getWindow() ?webui {
  return window;
}

fn setPin(e: *Event) void {
  const pin = e.getIntAt(0);
  const state = e.getIntAt(1);

  nboard.context.pins[@intCast(pin)].store(@intCast(state), .seq_cst);
}

fn setAnain(e: *Event) void {
  const index = e.getIntAt(0);
  const state = e.getFloatAt(1);

  nboard.context.anain[@intCast(index)].store(@floatCast(state), .seq_cst);
}

fn stopNboard(e: *Event) void {
  _ = e;

  nboard.stop();
}

fn runNboard(e: *Event) void {
  _ = e;

  nboard.run();
}

fn buildAndRunNboard(e: *Event) void {
  _ = e;

  nboard.buildAndRun();
}

fn buildNboard(e: *Event) void {
  _ = e;

  nboard.build();
}

fn resetNboard(e: *Event) void {
  _ = e;

  nboard.reset();
}

fn isBuilding(e: *Event) void {
  const is_building = nboard.isBuilding();
  e.returnBool(is_building);
}

fn isRunning(e: *Event) void {
  const is_running = nboard.isRunning();
  e.returnBool(is_running);
}

fn updateContext(e: *Event) void {
  const jog = e.getIntAt(0);
  const cod = e.getIntAt(1);

  nboard.context.jog.store(@intCast(jog), .seq_cst);
  nboard.context.cod.store(@intCast(cod), .seq_cst);

  const staticContext = nboard.context.static();

  var byte_buf = std.ArrayList(u8).init(allocator);
  defer byte_buf.deinit();

  var byte_writer = byte_buf.writer();
  byte_writer.writeStruct(staticContext) catch return;

  var script = std.ArrayList(u8).init(allocator);

  script.appendSlice("receiveContext([") catch return;

  for (0..byte_buf.items.len) |i| {
      const str = std.fmt.allocPrint(allocator, "{},", .{byte_buf.items[i]}) catch return;
      script.appendSlice(str) catch return;
      allocator.free(str);
  }

  script.appendSlice("0])") catch return;

  const slice = script.toOwnedSlice() catch return;
  defer allocator.free(slice);

  const zero_terminated: [:0]u8 = std.fmt.allocPrintZ(allocator, "{s}", .{slice}) catch return;
  defer allocator.free(zero_terminated);

  e.runClient(zero_terminated);
}

fn readFile(e: *Event) void {
  const file_path = e.getString();
  var file = std.fs.cwd().openFile(file_path, .{ .mode = .read_only }) catch return;
  defer file.close();

  const buf = file.readToEndAlloc(allocator, 0xFFFFFF) catch return;
  defer allocator.free(buf);

  const bufZ = std.fmt.allocPrintZ(allocator, "{s}", .{buf}) catch return;
  defer allocator.free(bufZ);

  e.returnString(bufZ);
}

fn saveFile(e: *Event) void {
  const file_path = e.getStringAt(0);
  var file = std.fs.cwd().createFile(file_path, .{ .truncate = true }) catch return;
  defer file.close();

  const buf = e.getStringAt(1);

  file.writeAll(buf) catch return;
}

fn openVSC(e: *Event) void {
  _ = e;

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();

  const arenaAllocator = arena.allocator();

  const dir = std.fs.cwd().openDir("resources/nboard", .{}) catch return;

  const path = dir.realpathAlloc(allocator, ".") catch return;
  defer allocator.free(path);

  const main = dir.realpathAlloc(allocator, "src/main.c") catch return;
  defer allocator.free(main);

  const argv = [_][]const u8{ "C:\\Windows\\System32\\cmd.exe", "/c", "code", "-g", main, path };

  const res = child.init(&argv, arenaAllocator) catch return;
  arenaAllocator.free(res.stdout);
  arenaAllocator.free(res.stderr);
}

pub fn start() void {
  const width: u32 = 1000;
  const height: u32 = 750;

  _ = dyn.loadLibrary("./resources/webview/WebView2Loader.dll") catch {};

  dpi.fix();

  webui.setTimeout(10);

  window = webui.newWindow();
  if (window) |win| {
    _ = win.setRootFolder("resources");

    // Non-blocking events create a lot of threads as we create a lot of them
    // Also, it can sometime assign same event id for two of them that cause double-free (SEGFAULT freeing NULL ptr)
    // And we don't need non-blocking events
    win.setEventBlocking(true);
    win.setSize(width, height);
    win.setMinimumSize(width, height);

    _ = win.bind("setPin", setPin);
    _ = win.bind("setAnain", setAnain);
    _ = win.bind("stopNboard", stopNboard);
    _ = win.bind("buildNboard", buildNboard);
    _ = win.bind("runNboard", runNboard);
    _ = win.bind("buildAndRunNboard", buildAndRunNboard);
    _ = win.bind("resetNboard", resetNboard);
    _ = win.bind("updateContext", updateContext);
    _ = win.bind("isBuilding", isBuilding);
    _ = win.bind("isRunning", isRunning);
    _ = win.bind("readFile", readFile);
    _ = win.bind("saveFile", saveFile);
    _ = win.bind("openVSC", openVSC);

    _ = win.show("index.html");
    webui.wait();
    webui.clean();
  }
}
