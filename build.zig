const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    b.setPreferredReleaseMode(.ReleaseFast);
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("furious-fowls", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("glfw");
    exe.install();

    const tests = b.addTest("src/main.zig");
    tests.setTarget(target);
    tests.setBuildMode(mode);

    const run = exe.run();
    run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run.step);

    const test_step = b.step("test", "Test the app");
    test_step.dependOn(&tests.step);
}
