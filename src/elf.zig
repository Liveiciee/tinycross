const std = @import("std");

pub const Elf64Hdr = extern struct {
    magic: [4]u8 =.{ 0x7F, 'E', 'L', 'F' },
    class: u8 = 2,
    endian: u8 = 1,
    version: u8 = 1,
    osabi: u8 = 0,
    abiversion: u8 = 0,
    pad: [7]u8 =.{0} ** 7,
    type: u16 = 2,
    machine: u16 = 0xB7,
    eversion: u32 = 1,
    entry: u64 = 0,
    phoff: u64 = 64,
    shoff: u64 = 0,
    flags: u32 = 0,
    ehsize: u16 = 64,
    phentsize: u16 = 56,
    phnum: u16 = 0,
    shentsize: u16 = 64,
    shnum: u16 = 0,
    shstrndx: u16 = 0,
};

pub const Elf64Phdr = extern struct {
    type: u32,
    flags: u32,
    offset: u64,
    vaddr: u64,
    paddr: u64,
    filesz: u64,
    memsz: u64,
    @"align": u64,
};

pub fn readHeader(file: std.fs.File)!Elf64Hdr {
    var hdr: Elf64Hdr = undefined;
    _ = try file.preadAll(std.mem.asBytes(&hdr), 0);
    if (!std.mem.eql(u8, &hdr.magic, &.{ 0x7F, 'E', 'L', 'F' })) {
        return error.NotElf;
    }
    return hdr;
}

pub fn writeHeader(file: std.fs.File, hdr: Elf64Hdr)!void {
    _ = try file.pwriteAll(std.mem.asBytes(&hdr), 0);
}

pub const PT_GNU_RELRO = 0x6474E552;

pub fn readPhdr(file: std.fs.File, phoff: u64, idx: u16, phentsize: u16) !Elf64Phdr {
    var ph: Elf64Phdr = undefined;
    const off = phoff + @as(u64, idx) * @as(u64, phentsize);
    _ = try file.preadAll(std.mem.asBytes(&ph), off);
    return ph;
}

pub fn writePhdr(file: std.fs.File, phoff: u64, idx: u16, phentsize: u16, ph: Elf64Phdr) !void {
    const off = phoff + @as(u64, idx) * @as(u64, phentsize);
    _ = try file.pwriteAll(std.mem.asBytes(&ph), off);
}

pub const Elf64Shdr = extern struct {
    name: u32, type: u32, flags: u64, addr: u64,
    offset: u64, size: u64, link: u32, info: u32,
    addralign: u64, entsize: u64,
};
