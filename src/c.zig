// Copyright 2021 Mitchell Kember. Subject to the MIT License.

const std = @import("std");

pub usingnamespace @cImport({
    @cInclude("bgfx_constants.h");
    @cDefine("GLFW_INCLUDE_NONE", {});
    switch (std.Target.current.os.tag) {
        .macos => {},
        .windows => @cDefine("GLFW_EXPOSE_NATIVE_WIN32", {}),
        .linux => @cDefine("GLFW_EXPOSE_NATIVE_X11", {}),
        else => @compileError("unsupported os"),
    }
    @cInclude("GLFW/glfw3.h");
    @cInclude("GLFW/glfw3native.h");
    @cInclude("bgfx/c99/bgfx.h");
});

// Defined in metal.m.
pub extern fn getMetalLayer(window: ?*GLFWwindow) ?*c_void;

pub fn getPlatformData(window: ?*GLFWwindow) bgfx_platform_data_t {
    return bgfx_platform_data_t{
        .nwh = switch (std.Target.current.os.tag) {
            .macos => getMetalLayer(window),
            .windows => glfwGetWin32Window(window),
            .linux => glfwGetX11Window(window),
            else => @compileError("unsupported os"),
        },
        .ndt = switch (std.Target.current.os.tag) {
            .linux => glfwGetX11Display(),
            else => null,
        },
        .context = null,
        .backBuffer = null,
        .backBufferDS = null,
    };
}
