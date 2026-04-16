const std = @import("std");
const elf = @import("elf.zig");

pub const Object = struct {
    path: []const u8,
    header: elf.Elf64Hdr,
    sections: usize,

    pub fn load(allocator: std.mem.Allocator, path: []const u8)!Object {
        const file = try std.fs.cwd().openFile(path,.{});
        defer file.close();

        const hdr = try elf.readHeader(file);

        if (hdr.type != 1) return error.NotRelocatable; // ET_REL = 1

        return Object{
         .path = try allocator.dupe(u8, path),
         .header = hdr,
         .sections = hdr.shnum,
        };
    }

    pub fn dump(self: Object, writer: anytype)!void {
        try writer.print("Object: {s}\n",.{self.path});
        try writer.print(" type: {d} (1=REL)\n",.{self.header.type});
        try writer.print(" machine: {d} (183=AArch64)\n",.{self.header.machine});
        try writer.print(" sections: {d}\n",.{self.sections});
        try writer.print(" entry: 0x{x}\n",.{self.header.entry});
    }
};

pub fn link(allocator: std.mem.Allocator, inputs: []const []const u8, output: []const u8)!void {
    var stdout_buf: [256]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const out = &stdout_writer.interface;

    try out.print("tinyld linking {d} objects -> {s}\n",.{inputs.len, output});

    for (inputs) |path| {
        const obj = Object.load(allocator, path) catch |e| {
            try out.print(" skip {s}: {any}\n",.{path, e});
            continue;
        };
        try obj.dump(out);
    }
    try out.writeAll("Phase 1: dump only, no output written yet\n");
    try out.flush();
}
