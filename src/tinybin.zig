const std = @import("std");
pub fn pack(path: []const u8)!void {
    var src = try std.fs.cwd().openFile(path,.{});
    defer src.close();
    const data = try src.readToEndAlloc(std.heap.page_allocator, 10*1024*1024);
    defer std.heap.page_allocator.free(data);
    var dst = try std.fs.cwd().createFile("a.out.packed",.{.truncate=true});
    defer dst.close();
    const stub = [_]u8{0} ** 2048;
    try dst.writeAll(&stub);
    try dst.writeAll(data);
}
