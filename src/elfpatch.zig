const std = @import("std");
const elf = @import("elf.zig");

pub const ElfPatcher = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ElfPatcher {
        return .{ .allocator = allocator };
    }

    pub fn patchRelroAlign(self: *ElfPatcher, path: []const u8, new_align: u64) !void {
        _ = self;

        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_write });
        defer file.close();

        const hdr = try elf.readHeader(file);
        if (hdr.phnum == 0) return;

        var i: u16 = 0;
        while (i < hdr.phnum) : (i += 1) {
            var ph = try elf.readPhdr(file, hdr.phoff, i, hdr.phentsize);
            
            if (ph.type == elf.PT_GNU_RELRO) {
                if (ph.@"align" >= new_align) return;
                
                ph.@"align" = new_align;
                try elf.writePhdr(file, hdr.phoff, i, hdr.phentsize, ph);
                return;
            }
        }
    }
};
