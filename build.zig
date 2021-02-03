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
    exe.addIncludeDir("glfw/include");

    const commonCFiles = [_][]const u8{
        "glfw/src/context.c",
        "glfw/src/egl_context.c",
        "glfw/src/init.c",
        "glfw/src/input.c",
        "glfw/src/monitor.c",
        "glfw/src/osmesa_context.c",
        "glfw/src/vulkan.c",
        "glfw/src/window.c",
    };
    switch (target.getOsTag()) {
        .linux => {
            exe.linkSystemLibrary("x11");
            exe.linkSystemLibrary("xcursor");
            exe.linkSystemLibrary("xi");
            exe.linkSystemLibrary("xinerama");
            exe.linkSystemLibrary("xrandr");
            const cFiles = commonCFiles ++ [_][]const u8{
                "glfw/src/glx_context.c",
                "glfw/src/linux_joystick.c",
                "glfw/src/posix_thread.c",
                "glfw/src/posix_time.c",
                "glfw/src/x11_init.c",
                "glfw/src/x11_monitor.c",
                "glfw/src/x11_window.c",
                "glfw/src/xkb_unicode.c",
            };
            for (cFiles) |file| {
                exe.addCSourceFile(file, &[_][]const u8{"-D_GLFW_X11"});
            }
        },
        .macos => {
            exe.addFrameworkDir(try getMacFrameworksDir(b));
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            const flag = "-D_GLFW_COCOA";
            const cFiles = commonCFiles ++ [_][]const u8{
                "glfw/src/cocoa_time.c",
                "glfw/src/posix_thread.c",
            };
            for (cFiles) |file| {
                exe.addCSourceFile(file, &[_][]const u8{flag});
            }
            const objcFiles = [_][]const u8{
                "glfw/src/cocoa_init.m",
                "glfw/src/cocoa_joystick.m",
                "glfw/src/cocoa_monitor.m",
                "glfw/src/cocoa_window.m",
                "glfw/src/nsgl_context.m",
            };
            var argv = [_][]const u8{ "clang", "-c", "", "-o", "", "-O3", flag };
            inline for (objcFiles) |file| {
                const object = file ++ ".o";
                exe.addObjectFile(object);
                std.fs.cwd().access(object, .{}) catch |err| switch (err) {
                    std.os.AccessError.FileNotFound => {
                        argv[2] = file;
                        argv[4] = object;
                        const clang = b.addSystemCommand(&argv);
                        exe.step.dependOn(&clang.step);
                    },
                    else => return err,
                };
            }
        },
        .windows => {
            exe.linkSystemLibrary("gdi32");
            const cFiles = commonCFiles ++ [_][]const u8{
                "glfw/src/wgl_context.c",
                "glfw/src/win32_init.c",
                "glfw/src/win32_joystick.c",
                "glfw/src/win32_monitor.c",
                "glfw/src/win32_thread.c",
                "glfw/src/win32_time.c",
                "glfw/src/win32_window.c",
            };
            for (cFiles) |file| {
                exe.addCSourceFile(file, &[_][]const u8{"-D_GLFW_WIN32"});
            }
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
