const std = @import("std");
const panic = std.debug.panic;
const c = @import("c.zig");

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {}\n", .{@as([*:0]const u8, description)});
}

pub fn main() !void {
    std.log.info("All your codebase are belong to us.", .{});

    _ = c.glfwSetErrorCallback(errorCallback);
    if (c.glfwInit() == c.GLFW_FALSE) {
        panic("GLFW init failure\n", .{});
    }
    defer c.glfwTerminate();
}

test "It works" {
    std.debug.assert(1 + 1 == 3);
}
