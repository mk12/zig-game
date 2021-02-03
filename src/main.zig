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
    const window = c.glfwCreateWindow(640, 480, "Furious Fowls", null, null);
    if (window == null) {
        panic("GLFW window failure\n", .{});
    }
    defer c.glfwDestroyWindow(window);
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        c.glfwPollEvents();
        std.time.sleep(30_000_000);
    }
}

test "It works" {
    std.debug.assert(1 + 1 == 3);
}
