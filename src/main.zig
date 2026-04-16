const std = @import("std");
const Args = @import("args.zig").Args;
const Command = @import("args.zig").Command;

pub fn main()!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // pakai arena biar dupe di args otomatis ke-free, gak ada leak report
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try Args.parse(allocator);

    // Zig 0.15: writer tanpa buffer (aman di Termux, gak infinite loop)
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
                \\ link Link object files
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
            if (args.input) |i| {
                try stdout.writeAll("Input: ");
                try stdout.writeAll(i);
                try stdout.writeAll("\n");
            }
            if (args.output) |o| {
                try stdout.writeAll("Output: ");
                try stdout.writeAll(o);
                try stdout.writeAll("\n");
            }
            if (args.verbose) {
                try stdout.writeAll("Verbose on\n");
            }
        },
       .link => try stdout.writeAll("Linking...\n"),
       .patch => try stdout.writeAll("Patching ELF...\n"),
       .compress => try stdout.writeAll("Compressing...\n"),
       .unknown => try stdout.writeAll("Unknown command. Try 'help'.\n"),
    }
}
