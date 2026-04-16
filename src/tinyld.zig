const std = @import("std");
const elf = @import("elf.zig");
const elfpatch = @import("elfpatch.zig");
const tinybin = @import("tinybin.zig");

pub fn link(allocator: std.mem.Allocator, inputs: []const []const u8, output: []const u8)!void {
    _ = allocator;
    if (inputs.len == 0) return error.NoInput;

    const in_file = try std.fs.cwd().openFile(inputs[0],.{});
    defer in_file.close();

    const stat = try in_file.stat();
    const buf = try std.heap.page_allocator.alloc(u8, stat.size);
    defer std.heap.page_allocator.free(buf);
    _ = try in_file.preadAll(buf, 0);

    const out = try std.fs.cwd().createFile(output,.{.read=true,.truncate=true});
    defer out.close();

    var ehdr = elf.Elf64Hdr{};
    ehdr.type = 2;
    ehdr.machine = 0xB7;
    ehdr.entry = 0x400000;
    ehdr.phoff = 64;
    ehdr.phnum = 2;
    try elf.writeHeader(out, ehdr);

    const phdr_size: u64 = 56;
    const ph_phdr = elf.Elf64Phdr{.type = 6,.flags = 4,.offset = 64,.vaddr = 0x400040,.paddr = 0x400040,.filesz = phdr_size*2,.memsz = phdr_size*2,.@"align" = 8 };
    var ph_load = elf.Elf64Phdr{.type = 1,.flags = 5,.offset = 0,.vaddr = 0x400000,.paddr = 0x400000,.filesz = 0,.memsz = 0,.@"align" = 16384 };

    try elf.writePhdr(out, 64, 0, 56, ph_phdr);
    try elf.writePhdr(out, 64, 1, 56, ph_load);

    try out.pwriteAll(buf, 4096);

    ph_load.filesz = stat.size + 4096;
    ph_load.memsz = ph_load.filesz;
    try elf.writePhdr(out, 64, 1, 56, ph_load);

    try elfpatch.patch16k(out);
    try tinybin.pack(output);
}
