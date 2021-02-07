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
    exe.addIncludeDir("src");
    exe.addIncludeDir("deps/bgfx/3rdparty/renderdoc");
    exe.addIncludeDir("deps/bgfx/include");
    exe.addIncludeDir("deps/bimg/3rdparty/astc-codec");
    exe.addIncludeDir("deps/bimg/3rdparty/astc-codec/include");
    exe.addIncludeDir("deps/bimg/include");
    exe.addIncludeDir("deps/bx/3rdparty");
    exe.addIncludeDir("deps/bx/include");
    exe.addIncludeDir("deps/glfw/include");

    const glfwFlags = [_][]const u8{"-std=c99"};
    const bxFlags = [_][]const u8{
        "-std=c++14",
        "-ffast-math",
        "-fno-exceptions",
        "-fno-rtti",
        // Needed to avoid UB in bx/include/tinystl/buffer.h.
        "-fno-delete-null-pointer-checks",
    };

    const glfwFiles = [_][]const u8{
        "deps/glfw/src/context.c",
        "deps/glfw/src/egl_context.c",
        "deps/glfw/src/init.c",
        "deps/glfw/src/input.c",
        "deps/glfw/src/monitor.c",
        "deps/glfw/src/osmesa_context.c",
        "deps/glfw/src/vulkan.c",
        "deps/glfw/src/window.c",
    };
    const bxFiles = [_][]const u8{
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
    const bimgFiles = [_][]const u8{
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
    const bgfxFiles = [_][]const u8{
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

    exe.addCSourceFiles(&bxFiles ++ &bimgFiles, &bxFlags);

    switch (target.getOsTag()) {
        .macos => {
            try b.env_map.set("ZIG_SYSTEM_LINKER_HACK", "1");
            exe.addIncludeDir("deps/bx/include/compat/osx");
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            exe.linkFramework("QuartzCore");
            exe.linkFramework("Metal");
            const cocoaFlag = [_][]const u8{"-D_GLFW_COCOA"};
            exe.addCSourceFiles(
                glfwFiles ++ &[_][]const u8{
                    "deps/glfw/src/cocoa_time.c",
                    "deps/glfw/src/posix_thread.c",
                },
                &glfwFlags ++ &cocoaFlag,
            );
            try addObjectiveCFiles(
                exe,
                &[_][]const u8{"src/metal.m"},
                &[_][]const u8{},
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
                &glfwFlags ++ &cocoaFlag,
            );
            const metalFlag = [_][]const u8{"-DBGFX_CONFIG_RENDERER_METAL=1"};
            exe.addCSourceFiles(&bgfxFiles, &bxFlags ++ &metalFlag);
            try addObjectiveCFiles(
                exe,
                &[_][]const u8{
                    "deps/bgfx/src/renderer_mtl.mm",
                },
                &bxFlags ++ &metalFlag,
            );
        },
        .windows => {
            if (target.abi != null and target.abi.?.isGnu()) {
                exe.addIncludeDir("deps/bx/include/compat/mingw");
            } else {
                exe.addIncludeDir("deps/bx/include/compat/msvc");
            }
            exe.linkSystemLibrary("gdi32");
            exe.addCSourceFiles(
                glfwFiles ++ &[_][]const u8{
                    "deps/glfw/src/wgl_context.c",
                    "deps/glfw/src/win32_init.c",
                    "deps/glfw/src/win32_joystick.c",
                    "deps/glfw/src/win32_monitor.c",
                    "deps/glfw/src/win32_thread.c",
                    "deps/glfw/src/win32_time.c",
                    "deps/glfw/src/win32_window.c",
                },
                glfwFlags ++ &[_][]const u8{"-D_GLFW_WIN32"},
            );
            exe.addCSourceFiles(
                &bgfxFiles,
                &bxFlags ++ &[_][]const u8{"-DBGFX_CONFIG_RENDERER_DIRECT3D12=1"},
            );
        },
        .linux => {
            exe.linkSystemLibrary("x11");
            exe.linkSystemLibrary("xcursor");
            exe.linkSystemLibrary("xi");
            exe.linkSystemLibrary("xinerama");
            exe.linkSystemLibrary("xrandr");
            exe.addCSourceFiles(
                glfwFiles ++ &[_][]const u8{
                    "deps/glfw/src/glx_context.c",
                    "deps/glfw/src/linux_joystick.c",
                    "deps/glfw/src/posix_thread.c",
                    "deps/glfw/src/posix_time.c",
                    "deps/glfw/src/x11_init.c",
                    "deps/glfw/src/x11_monitor.c",
                    "deps/glfw/src/x11_window.c",
                    "deps/glfw/src/xkb_unicode.c",
                },
                glfwFlags ++ &[_][]const u8{"-D_GLFW_X11"},
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

fn addObjectiveCFiles(
    exe: *std.build.LibExeObjStep,
    files: []const []const u8,
    flags: []const []const u8,
) !void {
    const b = exe.builder;
    const objectDir = try std.fs.path.join(
        b.allocator,
        &[_][]const u8{ b.build_root, b.cache_root, "objc" },
    );
    const cwd = std.fs.cwd();
    try cwd.makePath(objectDir);
    var argv = std.ArrayList([]const u8).init(b.allocator);
    defer argv.deinit();
    try argv.appendSlice(&[_][]const u8{ "clang", "-c", "", "-o", "" });
    if (exe.build_mode == .Debug) {
        try argv.appendSlice(&[_][]const u8{ "-Og", "-g" });
    } else {
        try argv.appendSlice(&[_][]const u8{ "-O2", "-DNDEBUG" });
    }
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
    var buf: [128]u8 = undefined;
    for (files) |file| {
        const object = b.fmt("{s}{s}{s}.o", .{
            objectDir,
            std.fs.path.sep_str,
            // All .m and .mm files in this project have unique filenames.
            std.fs.path.basename(file),
        });
        exe.addObjectFile(object);
        // Only build once. This code shouldn't be changing.
        cwd.access(object, .{}) catch |err| switch (err) {
            std.os.AccessError.FileNotFound => {
                argv.items[2] = file;
                argv.items[4] = object;
                const cmd = b.addSystemCommand(argv.items);
                exe.step.dependOn(&cmd.step);
            },
            else => return err,
        };
    }
}
