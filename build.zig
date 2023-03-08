const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zhp",
        .root_source_file = .{ .path = "src/zhp.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.install();

    const exe = b.addExecutable(.{
        .name = "zhttpd",
        .root_source_file = .{ .path = "example/main.zig" },
        .target = target,
        .optimize = optimize,

    });
    exe.valgrind_support = true;
    exe.addModule("zhp", b.createModule(.{
        .source_file = .{ .path = "src/zhp.zig" },
    }));
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/app.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);
}
