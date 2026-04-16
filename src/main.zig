const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("tinycross v0.1.0 - Cross compiler for Android\n", .{});
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    if (args.len < 2) {
        try stdout.print("Usage: tinycross <command> [options]\n", .{});
        return;
    }
    
    const command = args[1];
    if (std.mem.eql(u8, command, "build")) {
        try stdout.print("Building...\n", .{});
    } else if (std.mem.eql(u8, command, "help")) {
        try stdout.print("Commands: build, link, patch, compress\n", .{});
    } else {
        try stdout.print("Unknown command: {s}\n", .{command});
    }
}
