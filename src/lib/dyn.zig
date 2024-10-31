const std = @import("std");
const interop = @import("interop.zig");

pub fn funcType(comptime name: []const u8) type {
    return std.meta.Child(@field(interop, "PFN_" ++ name));
}

pub fn lookup(library: *std.DynLib, comptime name: [:0]const u8) funcType(name) {
    return library.lookup(funcType(name), name).?;
}

pub fn loadLibrary(library_name: []const u8) !std.DynLib {
    return std.DynLib.open(library_name) catch error.NotFound;
}
