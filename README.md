# tinycross

Portable cross-toolchain for Termux/Android. Compile, link, patch, and compress binaries directly on your phone — no NDK, no 1GB LLVM.

> Author: Liveiciee | Status: Draft MVP 0.1.0 | License: MIT

## Why

- NDK terlalu berat (>1GB)
- Zig ld.lld masih bug di Bionic (O_TMPFILE + linkat)
- Binary kegedean, build system ribet
- Goal: **satu binary <5MB** yang handle semuanya

## Features (MVP)

- [x] args + TOML config parser
- [x] tinyld Phase 1: ELF relocatable reader
- [ ] tinyld Phase 2: link static executable
- [ ] elfpatch: force PT_GNU_RELRO align 16KB
- [ ] tinybin: stub + zlib compressor
- [ ] `tinycross.toml` build system

## Quick Start

```sh
git clone https://github.com/Liveiciee/tinycross
cd tinycross
zig build
./zig-out/bin/tinycross link -i test.o -v
```

## Architecture

```
tinycross
 ├─ src/args.zig
 ├─ src/config.zig (TOML with comments)
 ├─ src/elf.zig
 ├─ src/tinyld.zig
 ├─ src/elfpatch.zig
 └─ src/tinybin.zig
```

## Example tinycross.toml

```toml
[project]
name = "myserver"
default_target = "aarch64-android"

[compile]
sources = ["src/*.zig"]
optimize = "ReleaseSmall"

[link]
output = "server"
entry = "_start"
patch_alignment = 16384
compress = true
```

## Roadmap

- Week 1-2: tinyld Phase 2 (merge.text)
- Week 3: elfpatch 16KB
- Week 4: tinybin
- Month 2: v0.1.0 release

> "Maybe. If I have time. Don't hold your breath." 😴
