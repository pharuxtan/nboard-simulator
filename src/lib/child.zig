// Reimplementation of std.process.Child to add custom dwCreationFlags

const std = @import("std");
const windows = std.os.windows;

const ExitInfo = struct {
  stdout: []u8,
  stderr: []u8,
  exitCode: u8,
};

pub fn init(argv: []const []const u8, allocator: std.mem.Allocator) !ExitInfo {
  var saAttr = windows.SECURITY_ATTRIBUTES{
    .nLength = @sizeOf(windows.SECURITY_ATTRIBUTES),
    .bInheritHandle = windows.TRUE,
    .lpSecurityDescriptor = null,
  };

  const nullHandle = windows.OpenFile(&[_]u16{ '\\', 'D', 'e', 'v', 'i', 'c', 'e', '\\', 'N', 'u', 'l', 'l' }, .{
    .access_mask = windows.GENERIC_READ | windows.GENERIC_WRITE | windows.SYNCHRONIZE,
    .share_access = windows.FILE_SHARE_READ | windows.FILE_SHARE_WRITE | windows.FILE_SHARE_DELETE,
    .sa = &saAttr,
    .creation = windows.OPEN_EXISTING,
  }) catch |err| switch (err) {
    else => |e| return e,
  };
  defer std.posix.close(nullHandle);

  var childStdOutRd: ?windows.HANDLE = null;
  var childStdOutWr: ?windows.HANDLE = null;

  try windowsMakeAsyncPipe(&childStdOutRd, &childStdOutWr, &saAttr);
  defer std.posix.close(childStdOutRd.?);

  var childStdErrRd: ?windows.HANDLE = null;
  var childStdErrWr: ?windows.HANDLE = null;

  try windowsMakeAsyncPipe(&childStdErrRd, &childStdErrWr, &saAttr);
  defer std.posix.close(childStdErrRd.?);

  var stdoutFile: ?std.fs.File = null;
  var stderrFile: ?std.fs.File = null;

  var si = std.mem.zeroInit(windows.STARTUPINFOW, .{
    .cb = @sizeOf(windows.STARTUPINFOW),
    .hStdError = childStdErrWr,
    .hStdOutput = childStdOutWr,
    .hStdInput = nullHandle,
    .dwFlags = windows.STARTF_USESTDHANDLES,
  });

  var pi = std.mem.zeroes(windows.PROCESS_INFORMATION);

  const app_name = try std.unicode.wtf8ToWtf16LeAllocZ(allocator, argv[0]);
  defer allocator.free(app_name);
  
  var cmd_line_cache = WindowsCommandLineCache.init(allocator, argv);
  defer cmd_line_cache.deinit();
  const cmd_line = try cmd_line_cache.commandLine();

  const CREATE_NO_WINDOW: u32 = 0x08000000; // Don't open Command Prompt at start

  try windows.CreateProcessW(
    app_name,
    cmd_line,
    null,
    null,
    windows.TRUE,
    windows.CREATE_UNICODE_ENVIRONMENT | CREATE_NO_WINDOW,
    null,
    null,
    &si,
    &pi,
  );

  stdoutFile = std.fs.File{ .handle = childStdOutRd.? };
  stderrFile = std.fs.File{ .handle = childStdErrRd.? };

  std.posix.close(childStdErrWr.?);
  std.posix.close(childStdOutWr.?);

  var poller = std.io.poll(allocator, enum { stdout, stderr }, .{
    .stdout = stdoutFile.?,
    .stderr = stderrFile.?,
  });
  defer poller.deinit();

  while(try poller.poll()) {}

  const stdout = try fifoToOwnedSlice(poller.fifo(.stdout));
  const stderr = try fifoToOwnedSlice(poller.fifo(.stderr));
  errdefer allocator.free(stdout);
  errdefer allocator.free(stderr);

  try windows.WaitForSingleObjectEx(pi.hProcess, windows.INFINITE, false);

  var win_exit_code: windows.DWORD = undefined;
  _ = windows.kernel32.GetExitCodeProcess(pi.hProcess, &win_exit_code);
  const exitCode = @as(u8, @truncate(win_exit_code));

  std.posix.close(pi.hProcess);
  std.posix.close(pi.hThread);

  return ExitInfo{
    .stdout = stdout,
    .stderr = stderr,
    .exitCode = exitCode
  };
}

fn fifoToOwnedSlice(fifo: *std.io.PollFifo) ![]u8 {
  if (fifo.head > 0) {
    @memcpy(fifo.buf[0..fifo.count], fifo.buf[fifo.head..][0..fifo.count]);
  }
  var result = std.ArrayList(u8){
    .items = fifo.buf[0..fifo.count],
    .capacity = fifo.buf.len,
    .allocator = fifo.allocator,
  };
  fifo.* = std.io.PollFifo.init(fifo.allocator);
  return try result.toOwnedSlice();
}

pub const SpawnError = error{
  OutOfMemory,

  /// POSIX-only. `StdIo.Ignore` was selected and opening `/dev/null` returned ENODEV.
  NoDevice,

  /// Windows-only. `cwd` or `argv` was provided and it was invalid WTF-8.
  /// https://simonsapin.github.io/wtf-8/
  InvalidWtf8,

  /// Windows-only. `cwd` was provided, but the path did not exist when spawning the child process.
  CurrentWorkingDirectoryUnlinked,

  /// Windows-only. NUL (U+0000), LF (U+000A), CR (U+000D) are not allowed
  /// within arguments when executing a `.bat`/`.cmd` script.
  /// - NUL/LF signifiies end of arguments, so anything afterwards
  ///   would be lost after execution.
  /// - CR is stripped by `cmd.exe`, so any CR codepoints
  ///   would be lost after execution.
  InvalidBatchScriptArg,
} ||
  std.posix.ExecveError ||
  std.posix.SetIdError ||
  std.posix.ChangeCurDirError ||
  windows.CreateProcessError ||
  windows.GetProcessMemoryInfoError ||
  windows.WaitForSingleObjectError;

pub const Term = union(enum) {
  Exited: u8,
  Signal: u32,
  Stopped: u32,
  Unknown: u32,
};

fn windowsMakeAsyncPipe(rd: *?windows.HANDLE, wr: *?windows.HANDLE, sattr: *const windows.SECURITY_ATTRIBUTES) !void {
  var tmp_bufw: [128]u16 = undefined;

  // Anonymous pipes are built upon Named pipes.
  // https://docs.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-createpipe
  // Asynchronous (overlapped) read and write operations are not supported by anonymous pipes.
  // https://docs.microsoft.com/en-us/windows/win32/ipc/anonymous-pipe-operations
  const pipe_path = blk: {
    var tmp_buf: [128]u8 = undefined;
    // Forge a random path for the pipe.
    const pipe_path = std.fmt.bufPrintZ(
      &tmp_buf,
      "\\\\.\\pipe\\zig-childprocess-{d}-{d}",
      .{ windows.GetCurrentProcessId(), pipe_name_counter.fetchAdd(1, .monotonic) },
    ) catch unreachable;
    const len = std.unicode.wtf8ToWtf16Le(&tmp_bufw, pipe_path) catch unreachable;
    tmp_bufw[len] = 0;
    break :blk tmp_bufw[0..len :0];
  };

  // Create the read handle that can be used with overlapped IO ops.
  const read_handle = windows.kernel32.CreateNamedPipeW(
    pipe_path.ptr,
    windows.PIPE_ACCESS_INBOUND | windows.FILE_FLAG_OVERLAPPED,
    windows.PIPE_TYPE_BYTE,
    1,
    4096,
    4096,
    0,
    sattr,
  );
  if (read_handle == windows.INVALID_HANDLE_VALUE) {
    switch (windows.kernel32.GetLastError()) {
      else => |err| return windows.unexpectedError(err),
    }
  }
  errdefer std.posix.close(read_handle);

  var sattr_copy = sattr.*;
  const write_handle = windows.kernel32.CreateFileW(
    pipe_path.ptr,
    windows.GENERIC_WRITE,
    0,
    &sattr_copy,
    windows.OPEN_EXISTING,
    windows.FILE_ATTRIBUTE_NORMAL,
    null,
  );
  if (write_handle == windows.INVALID_HANDLE_VALUE) {
    switch (windows.kernel32.GetLastError()) {
      else => |err| return windows.unexpectedError(err),
    }
  }
  errdefer std.posix.close(write_handle);

  try windows.SetHandleInformation(read_handle, windows.HANDLE_FLAG_INHERIT, 0);

  rd.* = read_handle;
  wr.* = write_handle;
}

var pipe_name_counter = std.atomic.Value(u32).init(1);

const WindowsCommandLineCache = struct {
  cmd_line: ?[:0]u16 = null,
  argv: []const []const u8,
  allocator: std.mem.Allocator,

  fn init(allocator: std.mem.Allocator, argv: []const []const u8) WindowsCommandLineCache {
    return .{
      .allocator = allocator,
      .argv = argv,
    };
  }

  fn deinit(self: *WindowsCommandLineCache) void {
    if (self.cmd_line) |cmd_line| self.allocator.free(cmd_line);
  }

  fn commandLine(self: *WindowsCommandLineCache) ![:0]u16 {
    if (self.cmd_line == null) {
      self.cmd_line = try argvToCommandLineWindows(self.allocator, self.argv);
    }
    return self.cmd_line.?;
  }
};

const ArgvToCommandLineError = error{ OutOfMemory, InvalidWtf8, InvalidArg0 };

fn argvToCommandLineWindows(
  allocator: std.mem.Allocator,
  argv: []const []const u8,
) ArgvToCommandLineError![:0]u16 {
  var buf = std.ArrayList(u8).init(allocator);
  defer buf.deinit();

  if (argv.len != 0) {
    const arg0 = argv[0];

    // The first argument must be quoted if it contains spaces or ASCII control characters
    // (excluding DEL). It also follows special quoting rules where backslashes have no special
    // interpretation, which makes it impossible to pass certain first arguments containing
    // double quotes to a child process without characters from the first argument leaking into
    // subsequent ones (which could have security implications).
    //
    // Empty arguments technically don't need quotes, but we quote them anyway for maximum
    // compatibility with different implementations of the 'CommandLineToArgvW' algorithm.
    //
    // Double quotes are illegal in paths on Windows, so for the sake of simplicity we reject
    // all first arguments containing double quotes, even ones that we could theoretically
    // serialize in unquoted form.
    var needs_quotes = arg0.len == 0;
    for (arg0) |c| {
      if (c <= ' ') {
        needs_quotes = true;
      } else if (c == '"') {
        return error.InvalidArg0;
      }
    }
    if (needs_quotes) {
      try buf.append('"');
      try buf.appendSlice(arg0);
      try buf.append('"');
    } else {
      try buf.appendSlice(arg0);
    }

    for (argv[1..]) |arg| {
      try buf.append(' ');

      // Subsequent arguments must be quoted if they contain spaces, tabs or double quotes,
      // or if they are empty. For simplicity and for maximum compatibility with different
      // implementations of the 'CommandLineToArgvW' algorithm, we also quote all ASCII
      // control characters (again, excluding DEL).
      needs_quotes = for (arg) |c| {
        if (c <= ' ' or c == '"') {
          break true;
        }
      } else arg.len == 0;
      if (!needs_quotes) {
        try buf.appendSlice(arg);
        continue;
      }

      try buf.append('"');
      var backslash_count: usize = 0;
      for (arg) |byte| {
        switch (byte) {
          '\\' => {
            backslash_count += 1;
          },
          '"' => {
            try buf.appendNTimes('\\', backslash_count * 2 + 1);
            try buf.append('"');
            backslash_count = 0;
          },
          else => {
            try buf.appendNTimes('\\', backslash_count);
            try buf.append(byte);
            backslash_count = 0;
          },
        }
      }
      try buf.appendNTimes('\\', backslash_count * 2);
      try buf.append('"');
    }
  }

  return try std.unicode.wtf8ToWtf16LeAllocZ(allocator, buf.items);
}
