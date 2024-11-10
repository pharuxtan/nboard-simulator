const std = @import("std");

pub fn build(b: *std.Build) void {
  const dev = b.option(bool, "dev", "Run the application in development mode") orelse false;

  const optimize: std.builtin.OptimizeMode = if(dev) .Debug else .ReleaseSafe;
  const target = b.standardTargetOptions(.{});

  const exe = b.addExecutable(.{
    .name = "nboard-simulator",
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    .optimize = optimize,
    .error_tracing = true,
    .strip = false
  });

  exe.addWin32ResourceFile(.{
    .file = b.path("icons/icon.rc"),
  });

  exe.subsystem = .Windows;
  exe.linkLibC();

  const zig_webui = b.dependency("zig-webui", .{
    .target = target,
    .optimize = optimize,
    .enable_tls = false,
    .is_static = true,
  });

  exe.root_module.addImport("webui", zig_webui.module("webui"));

  const argv_dev = [_][]const u8{ "npm", "run", "dev" };
  const argv_prod = [_][]const u8{ "npm", "run", "build" };

  const build_web = b.addSystemCommand( if(optimize == .Debug) &argv_dev else &argv_prod );
  exe.step.dependOn(&build_web.step);

  const argv_install = [_][]const u8{ "npm", "run", "setup" };

  const install_web = b.addSystemCommand(&argv_install);

  std.fs.cwd().access("node_modules", .{}) catch {
    build_web.step.dependOn(&install_web.step);
  };

  const install = b.addInstallArtifact(exe, .{
    .dest_dir = .{
      .override = .{
        .custom = if(optimize == .Debug) "../build/Debug" else "../build/Release",
      },
    },
    .pdb_dir = if(optimize == .Debug) .default else .disabled,
  });

  b.getInstallStep().dependOn(&install.step);
}
