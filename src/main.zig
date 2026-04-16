const std = @import("std");
const Args = @import("args.zig").Args;
const Command = @import("args.zig").Command;
const Config = @import("config.zig");
const tinyld = @import("tinyld.zig");
const elfpatch = @import("elfpatch.zig");

pub fn main()!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    var cfg = try Config.load(allocator, "tinycross.toml");
    defer cfg.deinit(allocator);

    const args = try Args.parse(allocator);

    var stdout_writer = std.fs.File.stdout().writer(&.{});
    const stdout = &stdout_writer.interface;

    switch (args.command) {
   .help => {
        try stdout.writeAll(
            \\tinycross v0.1.0
            \\Usage: tinycross <command> [options]
            \\
            \\Commands:
            \\ build Compile source files
            \\ link Link object files (tinyld)
            \\ patch Patch ELF alignment
            \\ compress Compress binary
            \\ help Show this message
            \\
            \\Options:
            \\ -i, --input <file> Input file
            \\ -o, --output <file> Output file
            \\ -t, --target <triple> Target triple
            \\ -O <mode> Optimization
            \\ -v, --verbose Verbose output
            \\
        );
    },
   .build => {
        try stdout.writeAll("Building...\n");
        const target = args.target orelse cfg.target;
        const optimize = args.optimize orelse cfg.optimize;
        const verbose = args.verbose or cfg.verbose;

        if (args.input) |i| try stdout.print("Input: {s}\n",.{i});
        if (args.output) |o| try stdout.print("Output: {s}\n",.{o});
        try stdout.print("Target: {s}\n",.{target});
        try stdout.print("Optimize: {s}\n",.{optimize});
        if (verbose) try stdout.writeAll("Verbose on\n");
    },
   .link => {
        const input = args.input orelse {
            try stdout.writeAll("link: missing -i <object.o>\n");
            return;
        };
        const output = args.output orelse "a.out";
        if (args.verbose or cfg.verbose) {
            try stdout.print("tinyld: {s} -> {s} (entry={s})\n",.{input, output, cfg.entry});
        }
        try tinyld.link(allocator, &.{input}, output);
    },
   .patch => {
        const input = args.input orelse {
            try stdout.writeAll("patch: missing -i <elf>\n");
            return;
        };
        const output = args.output orelse input;
        try stdout.print("Patching ELF... align={d}\n",.{cfg.align_page});
        // placeholder: panggil elfpatch nanti
        _ = elfpatch;
        _ = output;
    },
   .compress => {
        try stdout.writeAll("Compressing... (tinybin not implemented)\n");
    },
   .unknown => {
        try stdout.writeAll("Unknown command. Try 'help'.\n");
    },
    }
}
