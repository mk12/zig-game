// Copyright 2021 Mitchell Kember. Subject to the MIT License.

const std = @import("std");
const panic = std.debug.panic;
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    b.setPreferredReleaseMode(.ReleaseFast);
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("furious-fowls", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("c++");
    exe.addIncludeDir("deps/bgfx/include");
    exe.addIncludeDir("deps/bimg/3rdparty/astc-codec");
    exe.addIncludeDir("deps/bimg/3rdparty/astc-codec/include");
    exe.addIncludeDir("deps/bimg/include");
    exe.addIncludeDir("deps/bx/3rdparty");
    exe.addIncludeDir("deps/bx/include");
    exe.addIncludeDir("deps/glfw/include");

    const glfwCommonFlags = [_][]const u8{"-std=c99"};
    const bxCommonFlags = [_][]const u8{
        "-std=c++14",
        "-ffast-math",
        "-fno-exceptions",
        "-fno-rtti",
    };

    const glfwCommonFiles = [_][]const u8{
        "deps/glfw/src/context.c",
        "deps/glfw/src/egl_context.c",
        "deps/glfw/src/init.c",
        "deps/glfw/src/input.c",
        "deps/glfw/src/monitor.c",
        "deps/glfw/src/osmesa_context.c",
        "deps/glfw/src/vulkan.c",
        "deps/glfw/src/window.c",
    };
    const bxCommonFiles = [_][]const u8{
        "deps/bx/src/allocator.cpp",
        "deps/bx/src/bx.cpp",
        "deps/bx/src/commandline.cpp",
        "deps/bx/src/crtnone.cpp",
        "deps/bx/src/debug.cpp",
        "deps/bx/src/dtoa.cpp",
        "deps/bx/src/easing.cpp",
        "deps/bx/src/file.cpp",
        "deps/bx/src/filepath.cpp",
        "deps/bx/src/hash.cpp",
        "deps/bx/src/math.cpp",
        "deps/bx/src/mutex.cpp",
        "deps/bx/src/os.cpp",
        "deps/bx/src/process.cpp",
        "deps/bx/src/semaphore.cpp",
        "deps/bx/src/settings.cpp",
        "deps/bx/src/sort.cpp",
        "deps/bx/src/string.cpp",
        "deps/bx/src/thread.cpp",
        "deps/bx/src/timer.cpp",
        "deps/bx/src/url.cpp",
    };
    const bgfxCommonFiles = [_][]const u8{
        "deps/bgfx/src/bgfx.cpp",
        "deps/bgfx/src/debug_renderdoc.cpp",
        "deps/bgfx/src/dxgi.cpp",
        "deps/bgfx/src/glcontext_egl.cpp",
        "deps/bgfx/src/glcontext_glx.cpp",
        "deps/bgfx/src/glcontext_html5.cpp",
        "deps/bgfx/src/glcontext_wgl.cpp",
        "deps/bgfx/src/nvapi.cpp",
        "deps/bgfx/src/renderer_d3d11.cpp",
        "deps/bgfx/src/renderer_d3d12.cpp",
        "deps/bgfx/src/renderer_d3d9.cpp",
        "deps/bgfx/src/renderer_gl.cpp",
        "deps/bgfx/src/renderer_gnm.cpp",
        "deps/bgfx/src/renderer_noop.cpp",
        "deps/bgfx/src/renderer_nvn.cpp",
        "deps/bgfx/src/renderer_vk.cpp",
        "deps/bgfx/src/renderer_webgpu.cpp",
        "deps/bgfx/src/shader_dx9bc.cpp",
        "deps/bgfx/src/shader_dxbc.cpp",
        "deps/bgfx/src/shader_spirv.cpp",
        "deps/bgfx/src/shader.cpp",
        "deps/bgfx/src/topology.cpp",
        "deps/bgfx/src/vertexlayout.cpp",
    };
    const bimgCommonFiles = [_][]const u8 {
        "deps/bimg/3rdparty/astc-codec/src/decoder/astc_file.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/codec.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/endpoint_codec.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/footprint.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/integer_sequence_codec.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/intermediate_astc_block.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/logical_astc_block.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/partition.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/physical_astc_block.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/quantization.cc",
        "deps/bimg/3rdparty/astc-codec/src/decoder/weight_infill.cc",
        "deps/bimg/src/image_gnf.cpp",
        "deps/bimg/src/image.cpp",
    };

    addCFiles(exe, &bxCommonFiles, &bxCommonFlags);
    addCFiles(exe, &bimgCommonFiles, &bxCommonFlags);

    switch (target.getOsTag()) {
        .linux => {
            exe.linkSystemLibrary("x11");
            exe.linkSystemLibrary("xcursor");
            exe.linkSystemLibrary("xi");
            exe.linkSystemLibrary("xinerama");
            exe.linkSystemLibrary("xrandr");
            addCFiles(
                exe,
                glfwCommonFiles ++ &[_][]const u8{
                    "deps/glfw/src/glx_context.c",
                    "deps/glfw/src/linux_joystick.c",
                    "deps/glfw/src/posix_thread.c",
                    "deps/glfw/src/posix_time.c",
                    "deps/glfw/src/x11_init.c",
                    "deps/glfw/src/x11_monitor.c",
                    "deps/glfw/src/x11_window.c",
                    "deps/glfw/src/xkb_unicode.c",
                },
                glfwCommonFlags ++ &[_][]const u8{"-D_GLFW_X11"},
            );
        },
        .macos => {
            // Prior to https://github.com/ziglang/zig/pull/7715 this has no
            // effect on the child processes, and must be set manually.
            try b.env_map.set("ZIG_SYSTEM_LINKER_HACK", "1");
            exe.addIncludeDir("deps/bx/include/compat/osx");
            exe.addFrameworkDir(try getMacFrameworksDir(b));
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            exe.linkFramework("QuartzCore");
            exe.linkFramework("Metal");
            // exe.linkFramework("MetalKit");
            const cocoaFlag = [_][]const u8{"-D_GLFW_COCOA"};
            addCFiles(
                exe,
                glfwCommonFiles ++ &[_][]const u8{
                    "deps/glfw/src/cocoa_time.c",
                    "deps/glfw/src/posix_thread.c",
                },
                &glfwCommonFlags ++ &cocoaFlag,
            );
            try addObjectiveCFiles(
                exe,
                &[_][]const u8{
                    "deps/glfw/src/cocoa_init.m",
                    "deps/glfw/src/cocoa_joystick.m",
                    "deps/glfw/src/cocoa_monitor.m",
                    "deps/glfw/src/cocoa_window.m",
                    "deps/glfw/src/nsgl_context.m",
                },
                &glfwCommonFlags ++ &cocoaFlag,
            );
            const metalFlag = [_][]const u8{"-DBGFX_CONFIG_RENDERER_METAL=1"};
            addCFiles(
                exe,
                &bgfxCommonFiles,
                &bxCommonFlags ++ &metalFlag,
            );
            try addObjectiveCFiles(
                exe,
                &[_][]const u8{
                    "deps/bgfx/src/glcontext_eagl.mm",
                    "deps/bgfx/src/glcontext_nsgl.mm",
                    "deps/bgfx/src/renderer_mtl.mm",
                },
                &bxCommonFlags ++ &metalFlag,
            );
        },
        .windows => {
            exe.linkSystemLibrary("gdi32");
            addCFiles(
                exe,
                glfwCommonFiles ++ &[_][]const u8{
                    "deps/glfw/src/wgl_context.c",
                    "deps/glfw/src/win32_init.c",
                    "deps/glfw/src/win32_joystick.c",
                    "deps/glfw/src/win32_monitor.c",
                    "deps/glfw/src/win32_thread.c",
                    "deps/glfw/src/win32_time.c",
                    "deps/glfw/src/win32_window.c",
                },
                glfwCommonFlags ++ &[_][]const u8{"-D_GLFW_WIN32"},
            );
        },
        else => |tag| panic("unsupported OS {}", .{tag}),
    }
    exe.install();

    const tests = b.addTest("src/main.zig");
    tests.setTarget(target);
    tests.setBuildMode(mode);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&tests.step);

    const run = exe.run();
    run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run.addArgs(args);
    }
    const run_step = b.step("run", "Launch the game");
    run_step.dependOn(&run.step);
}

// https://github.com/ziglang/zig/issues/2208
fn getMacFrameworksDir(b: *Builder) ![]u8 {
    const sdk = try b.exec(&[_][]const u8{ "xcrun", "-show-sdk-path" });
    const parts = &[_][]const u8{
        std.mem.trimRight(u8, sdk, "\n"),
        "/System/Library/Frameworks",
    };
    return std.mem.concat(b.allocator, u8, parts);
}

const opt_flags = [_][]const u8{ "-O3", "-DNDEBUG" };

fn addCFiles(
    exe: *std.build.LibExeObjStep,
    files: []const []const u8,
    comptime flags: []const []const u8,
) void {
    const finalFlags = flags ++ opt_flags;
    for (files) |file| {
        exe.addCSourceFile(file, finalFlags);
    }
}

fn addObjectiveCFiles(
    exe: *std.build.LibExeObjStep,
    files: []const []const u8,
    flags: []const []const u8,
) !void {
    const cwd = std.fs.cwd();
    var argv = std.ArrayList([]const u8).init(exe.builder.allocator);
    defer argv.deinit();
    try argv.appendSlice(
        &[_][]const u8{ "clang", "-c", "", "-o", "" } ++ opt_flags,
    );
    for (exe.include_dirs.items) |dir| {
        switch (dir) {
            .RawPath => |path| {
                try argv.append("-I");
                try argv.append(path);
            },
            else => {},
        }
    }
    try argv.appendSlice(flags);
    var buf: [64]u8 = undefined;
    for (files) |file| {
        const object = try std.fmt.bufPrint(&buf, "{}.o", .{file});
        exe.addObjectFile(object);
        // Only build once. This code shouldn't be changing.
        cwd.access(object, .{}) catch |err| switch (err) {
            std.os.AccessError.FileNotFound => {
                argv.items[2] = file;
                argv.items[4] = object;
                const cmd = exe.builder.addSystemCommand(argv.items);
                exe.step.dependOn(&cmd.step);
            },
            else => return err,
        };
    }
}
