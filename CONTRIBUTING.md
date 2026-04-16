# Contributing to tinycross

> Don't.

Tapi kalau maksa:

## Rules
1. **No NDK.** Kalau PR butuh NDK, ditolak.
2. **Harus jalan di Termux.** Test di HP, bukan cuma di laptop.
3. **Binary <5MB.** Kalau nambah dependency, pikir dua kali.
4. **Zig 0.15+ only.** No C++, no Python build scripts.
5. **Satu binary.** Jangan pecah jadi banyak tool.

## Cara test
```sh
zig build
./zig-out/bin/tinycross link -i test.o -v
```

Harus keluar `type: 1 (REL)` tanpa error.

## Commit style
```
feat: tinyld phase2
fix: elf align
docs: update readme
```
No "fix bug", no emoji spam.

## PR
- Kecil aja (<200 lines)
- Jelaskan kenapa, bukan apa
- Kalau breaking, bilang dari awal

## Roadmap
Lihat README. Aku kerjain kalau sempat. Jangan tag "urgent".

## License
Dengan kontribusi, kamu setuju kode dirilis MIT/0BSD.

---
Liveiciee — "maybe, if I have time" 😴
