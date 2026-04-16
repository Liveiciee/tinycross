const std = @import("std");

pub const Command = enum {
    build,
    link,
    patch,
    compress,
    help,
    unknown,
};

pub const Args = struct {
    command: Command =.help,
    input:?[]const u8 = null,
    output:?[]const u8 = null,
    target:?[]const u8 = null,
    optimize:?[]const u8 = null, // <-- sekarang optional
    verbose: bool = false,

    pub fn parse(allocator: std.mem.Allocator)!Args {
        var args = Args{};
        const argv = try std.process.argsAlloc(allocator);
        defer std.process.argsFree(allocator, argv);

        if (argv.len < 2) return args;
        args.command = parseCommand(argv[1]);

        var i: usize = 2;
        while (i < argv.len) : (i += 1) {
            const arg = argv[i];
            if (std.mem.eql(u8, arg, "-i") or std.mem.eql(u8, arg, "--input")) {
                i += 1;
                if (i < argv.len) args.input = try allocator.dupe(u8, argv[i]);
            } else if (std.mem.eql(u8, arg, "-o") or std.mem.eql(u8, arg, "--output")) {
                i += 1;
                if (i < argv.len) args.output = try allocator.dupe(u8, argv[i]);
            } else if (std.mem.eql(u8, arg, "-t") or std.mem.eql(u8, arg, "--target")) {
                i += 1;
                if (i < argv.len) args.target = try allocator.dupe(u8, argv[i]);
            } else if (std.mem.eql(u8, arg, "-O")) {
                i += 1;
                if (i < argv.len) args.optimize = try allocator.dupe(u8, argv[i]);
            } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--verbose")) {
                args.verbose = true;
            }
        }
        return args;
    }
};

fn parseCommand(cmd: []const u8) Command {
    if (std.mem.eql(u8, cmd, "build")) return.build;
    if (std.mem.eql(u8, cmd, "link")) return.link;
    if (std.mem.eql(u8, cmd, "patch")) return.patch;
    if (std.mem.eql(u8, cmd, "compress")) return.compress;
    if (std.mem.eql(u8, cmd, "help")) return.help;
    return.unknown;
}
