const std = @import("std");

pub const Config = struct {
    target: []const u8 = "aarch64-linux-android",
    optimize: []const u8 = "ReleaseSmall",
    verbose: bool = false,
    entry: []const u8 = "_start",
    stack_size: usize = 16384,
    align_page: usize = 65536,

    pub fn deinit(self: *Config, allocator: std.mem.Allocator) void {
        allocator.free(self.target);
        allocator.free(self.optimize);
        allocator.free(self.entry);
    }
};

pub fn load(allocator: std.mem.Allocator, path: []const u8)!Config {
    var cfg = Config{
      .target = try allocator.dupe(u8, "aarch64-linux-android"),
      .optimize = try allocator.dupe(u8, "ReleaseSmall"),
      .entry = try allocator.dupe(u8, "_start"),
    };

    const file = std.fs.cwd().openFile(path,.{}) catch return cfg;
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 64 * 1024);
    defer allocator.free(content);

    var it = std.mem.splitScalar(u8, content, '\n');
    var section: []const u8 = "";
    while (it.next()) |line| {
        const trim = std.mem.trim(u8, line, " \t\r");
        if (trim.len == 0 or trim[0] == '#') continue;

        if (trim[0] == '[' and trim[trim.len - 1] == ']') {
            section = trim[1.. trim.len - 1];
            continue;
        }

        if (std.mem.indexOfScalar(u8, trim, '=')) |eq| {
            const key = std.mem.trim(u8, trim[0..eq], " \t");
            var val = std.mem.trim(u8, trim[eq + 1..], " \t");

            // <-- FIX: buang komentar inline
            if (std.mem.indexOfScalar(u8, val, '#')) |hash| {
                val = std.mem.trim(u8, val[0..hash], " \t");
            }

            if (val.len >= 2 and val[0] == '"' and val[val.len - 1] == '"') {
                val = val[1.. val.len - 1];
            }

            if (std.mem.eql(u8, section, "build")) {
                if (std.mem.eql(u8, key, "target")) {
                    allocator.free(cfg.target);
                    cfg.target = try allocator.dupe(u8, val);
                } else if (std.mem.eql(u8, key, "optimize")) {
                    allocator.free(cfg.optimize);
                    cfg.optimize = try allocator.dupe(u8, val);
                } else if (std.mem.eql(u8, key, "verbose")) {
                    cfg.verbose = std.mem.eql(u8, val, "true");
                }
            } else if (std.mem.eql(u8, section, "link")) {
                if (std.mem.eql(u8, key, "entry")) {
                    allocator.free(cfg.entry);
                    cfg.entry = try allocator.dupe(u8, val);
                } else if (std.mem.eql(u8, key, "stack_size")) {
                    cfg.stack_size = try std.fmt.parseInt(usize, val, 10);
                }
            } else if (std.mem.eql(u8, section, "patch")) {
                if (std.mem.eql(u8, key, "align_page")) {
                    cfg.align_page = try std.fmt.parseInt(usize, val, 10);
                }
            }
        }
    }
    return cfg;
}
