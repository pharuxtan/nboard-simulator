const std = @import("std");
const child = @import("./child.zig");
const getWindow = @import("../module/webui.zig").getWindow;
const builtin = @import("builtin");

pub fn build() !bool {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  defer _ = gpa.deinit();

  var nboard_dir = try std.fs.cwd().openDir("resources/nboard", .{ .iterate = true });
  defer nboard_dir.close();

  var nboardWalker = try nboard_dir.walk(allocator);
  defer nboardWalker.deinit();

  var includeFolders = std.ArrayList([]u8).init(allocator);
  defer includeFolders.deinit();
  
  var sourceFiles = std.ArrayList([]u8).init(allocator);
  defer sourceFiles.deinit();

  const realpathA = try nboard_dir.realpathAlloc(allocator, ".");
  defer allocator.free(realpathA);

  const realpath = try concat(allocator, realpathA, "\\");
  defer allocator.free(realpath);

  while(try nboardWalker.next()) |entry| {
    if(entry.kind == .directory or std.mem.eql(u8, entry.path, entry.basename)) continue;

    if(endsWith(entry.path, ".h") or endsWith(entry.path, ".hpp") or endsWith(entry.path, ".hh")){
      const preDirpath = try getDir(allocator, entry.path, entry.basename);
      defer allocator.free(preDirpath);

      const dirPath = try concat(allocator, "resources\\nboard\\", preDirpath);

      var addInclude = true;
      for(0..includeFolders.items.len) |i| {
        if(std.mem.eql(u8, dirPath, includeFolders.items[i])) addInclude = false;
      }
      if(addInclude){
        try includeFolders.append(dirPath);
      } else allocator.free(dirPath);
    } else if(endsWith(entry.path, ".c") or endsWith(entry.path, ".cpp") or endsWith(entry.path, ".cc")){
      const filePath = try concat(allocator, realpath, entry.path);
      try sourceFiles.append(filePath);
    }
  }

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();

  const arenaAllocator = arena.allocator();

  var free = std.ArrayList([]const u8).init(arenaAllocator);
  defer {
    for(0..free.items.len) |i| {
      allocator.free(free.items[i]);
    }
    free.deinit();
  }

  var argv = std.ArrayList([]const u8).init(arenaAllocator);
  errdefer argv.deinit();

  const realpathCwd = try std.fs.cwd().realpathAlloc(allocator, ".");
  defer allocator.free(realpathCwd);
  const command = try concat(allocator, realpathCwd, "\\resources\\clang\\clang-cl.exe");
  try argv.append(command);
  try free.append(command);

  for(0..includeFolders.items.len) |i| {
    const include = try concat(allocator, "-I", includeFolders.items[i]);
    allocator.free(includeFolders.items[i]);
    try argv.append(include);
    try free.append(include);
  }

  try argv.append("-winsysroot");
  try argv.append("resources\\clang\\assets");

  try argv.append("-shared");
  try argv.append("-flto");
  try argv.append("-fms-compatibility");
  try argv.append("-fuse-ld=lld");
  try argv.append("-g");
  try argv.append("-o");
  try argv.append("resources\\build\\nboard.dll");

  for(0..sourceFiles.items.len) |i| {
    try argv.append(sourceFiles.items[i]);
    try free.append(sourceFiles.items[i]);
  }

  std.fs.cwd().makeDir("resources/build") catch {};
  
  const res = try child.init(try argv.toOwnedSlice(), arenaAllocator);
  defer arenaAllocator.free(res.stdout);
  defer arenaAllocator.free(res.stderr);

  sendToWindow(allocator, res.exitCode, res.stdout, res.stderr);

  return res.exitCode != 0;
}

fn sendToWindow(allocator: std.mem.Allocator, exitCode: u8, rawStdout: []const u8, rawStderr: []const u8) void {
  const window = getWindow();
  if(window) |win| {
    const sizeStdout = std.mem.replacementSize(u8, rawStdout, "\\", "\\\\");
    const sizeStderr = std.mem.replacementSize(u8, rawStderr, "\\", "\\\\");
    
    const stdout = allocator.alloc(u8, sizeStdout) catch return;
    defer allocator.free(stdout);
    
    const stderr = allocator.alloc(u8, sizeStderr) catch return;
    defer allocator.free(stderr);

    _ = std.mem.replace(u8, rawStdout, "\\", "\\\\", stdout);
    _ = std.mem.replace(u8, rawStderr, "\\", "\\\\", stderr);

    const script = std.fmt.allocPrintZ(allocator, "receiveBuildInfo({}, `{s}`, `{s}`)", .{ exitCode, stdout, stderr }) catch return;
    defer allocator.free(script);

    win.run(script);
  }
}

fn endsWith(path: []const u8, end: []const u8) bool {
  return std.mem.endsWith(u8, path, end);
}

fn replace(allocator: std.mem.Allocator, str: []const u8, needle: []const u8, replacement: []const u8) ![]u8 {
  var new_str = try std.ArrayList(u8).initCapacity(allocator, str.len);
  _ = try new_str.addManyAt(0, str.len);
  _ = std.mem.replace(u8, str, needle, replacement, new_str.items);
  return try new_str.toOwnedSlice();
}

fn getDir(allocator: std.mem.Allocator, str: []const u8, basename: []const u8) ![]u8 {
  var new_str = std.ArrayList(u8).init(allocator);
  try new_str.appendSlice(str);
  try new_str.resize(str.len - basename.len - 1);
  return new_str.toOwnedSlice();
}

fn concat(allocator: std.mem.Allocator, start: []const u8, end: []const u8) ![]u8 {
  var str = std.ArrayList(u8).init(allocator);
  try str.appendSlice(start);
  try str.appendSlice(end);
  return str.toOwnedSlice();
}
