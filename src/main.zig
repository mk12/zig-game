// Copyright 2021 Mitchell Kember. Subject to the MIT License.

const std = @import("std");
const panic = std.debug.panic;
const c = @import("c.zig");

const window_width = 800;
const window_height = 600;
const window_title = "Furious Fowls";

var mouse_x: f64 = 0;
var mouse_y: f64 = 0;

const PosColorVertex = struct {
    x: f64,
    y: f64,
    z: f64,
    abgr: u32,
};

pub fn main() !void {
    // Set up GLFW and the window.
    _ = c.glfwSetErrorCallback(errorCallback);
    if (c.glfwInit() == c.GLFW_FALSE) {
        panic("GLFW init failure\n", .{});
    }
    defer c.glfwTerminate();
    c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_FALSE);
    const window = c.glfwCreateWindow(window_width, window_height, window_title, null, null);
    if (window == null) {
        panic("GLFW window failure\n", .{});
    }
    defer c.glfwDestroyWindow(window);

    // Set up GLFW event callbacks.
    _ = c.glfwSetCursorPosCallback(window, cursorPositionCallback);

    // Set up BGFX and the renderer.
    const platform_data = c.getPlatformData(window);
    c.bgfx_set_platform_data(&platform_data);
    var init: c.bgfx_init_t = undefined;
    c.bgfx_init_ctor(&init);
    if (!c.bgfx_init(&init)) {
        panic("BGFX init failure\n", .{});
    }
    defer c.bgfx_shutdown();
    c.bgfx_reset(window_width, window_height, c.BGFX_RESET_VSYNC, init.resolution.format);
    // c.bgfx_set_debug(c.BGFX_DEBUG_TEXT); // | c.BGFX_DEBUG_STATS);
    c.bgfx_set_view_clear(0, c.BGFX_CLEAR_COLOR | c.BGFX_CLEAR_DEPTH, 0xedededff, 1.0, 0);
    c.bgfx_set_view_rect(0, 0, 0, window_width, window_height);

    // var frame: i32 = 0;
    var timer = try std.time.Timer.start();
    timer.reset();
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        // c.glfwWaitEventsTimeout(0.016);
        c.glfwPollEvents();
        

        // set view 0 default viewport.
        c.bgfx_set_view_rect(0, 0, 0, window_width, window_height);

        // this dummy draw call is here to make sure that view 0 is cleared
        // if no other draw calls are submitted to view 0.
        var encoder = c.bgfx_encoder_begin(true);
        c.bgfx_encoder_touch(encoder, 0);
        c.bgfx_encoder_end(encoder);

        // use debug font to print information about this example.
        // c.bgfx_dbg_text_clear(0, false);
        // var buf: [128]u8 = undefined;
        // const str = std.fmt.bufPrintZ(
        //     &buf,
        //     "Frame: {}, x: {}, y: {}",
        //     .{ frame, @floatToInt(u32, mouse_x), @floatToInt(u32, mouse_y) },
        // ) catch unreachable;
        // var y = @floatToInt(u16, mouse_y) / 10;
        // if (y < 0) y = 0;
        // if (y > 30) y = 30;
        // c.bgfx_dbg_text_printf(3, y, 0x3f, str);
        // frame += 1;

        // advance to next frame. rendering thread will be kicked to
        // process submitted rendering primitives.
        _ = c.bgfx_frame(false);

        // const gap = 16_666_667 - timer.lap();
        const dt = timer.lap();
        const target = 16_666_667;
        if (dt < target) std.time.sleep(target - dt);
    }
}

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {}\n", .{@as([*:0]const u8, description)});
}

fn cursorPositionCallback(window: ?*c.GLFWwindow, x: f64, y: f64) callconv(.C) void {
    mouse_x = x;
    mouse_y = y;
}

test "It works" {
    std.debug.assert(1 + 1 == 3);
}
