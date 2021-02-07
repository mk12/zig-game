// Copyright 2021 Mitchell Kember. Subject to the MIT License.

const std = @import("std");
const panic = std.debug.panic;
const c = @import("c.zig");

const window_width = 800;
const window_height = 600;
const window_title = "Furious Fowls";

// GLFW error callback.
fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {}\n", .{@as([*:0]const u8, description)});
}

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
    c.bgfx_set_debug(c.BGFX_DEBUG_TEXT);
    c.bgfx_set_view_clear(0, c.BGFX_CLEAR_COLOR | c.BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0);
    c.bgfx_set_view_rect(0, 0, 0, window_width, window_height);

    var i: i32 = 0;
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        c.glfwWaitEventsTimeout(0.1);

        // set view 0 default viewport.
        c.bgfx_set_view_rect(0, 0, 0, window_width, window_height);

        // this dummy draw call is here to make sure that view 0 is cleared
        // if no other draw calls are submitted to view 0.
        var encoder = c.bgfx_encoder_begin(true);
        c.bgfx_encoder_touch(encoder, 0);
        c.bgfx_encoder_end(encoder);

        // use debug font to print information about this example.
        c.bgfx_dbg_text_clear(0, false);
        c.bgfx_dbg_text_printf(0, 1, 0x0f, "color can be changed with ansi \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.");
        c.bgfx_dbg_text_printf(80, 1, 0x0f, "\x1b[;0m    \x1b[;1m    \x1b[; 2m    \x1b[; 3m    \x1b[; 4m    \x1b[; 5m    \x1b[; 6m    \x1b[; 7m    \x1b[0m");
        c.bgfx_dbg_text_printf(80, 2, 0x0f, "\x1b[;8m    \x1b[;9m    \x1b[;10m    \x1b[;11m    \x1b[;12m    \x1b[;13m    \x1b[;14m    \x1b[;15m    \x1b[0m");
        c.bgfx_dbg_text_printf(0, 3, 0x1f, "bgfx/examples/25-c99");
        var buf: [128]u8 = undefined;
        const str = std.fmt.bufPrintZ(&buf, "description: initialization and debug text with c99 api. Frame: {}", .{i}) catch unreachable;
        c.bgfx_dbg_text_printf(0, 4, 0x3f, str);
        i += 1;

        // advance to next frame. rendering thread will be kicked to
        // process submitted rendering primitives.
        _ = c.bgfx_frame(false);
    }
}

test "It works" {
    std.debug.assert(1 + 1 == 3);
}
