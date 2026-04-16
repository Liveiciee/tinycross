const std = @import("std");
const elf = @import("elf.zig");

pub fn patch16k(file: std.fs.File)!void {
    const hdr = try elf.readHeader(file);
    var i: u16 = 0;
    while (i < hdr.phnum) : (i += 1) {
        var ph = try elf.readPhdr(file, hdr.phoff, i, hdr.phentsize);
        if (ph.type == elf.PT_GNU_RELRO or ph.type == 1) {
            ph.@"align" = 16384;
            try elf.writePhdr(file, hdr.phoff, i, hdr.phentsize, ph);
        }
    }
}
