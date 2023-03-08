const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zhp_module = b.addModule("zph", .{
        .source_file = .{ .path = "src/zhp.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "zhp",
        .root_source_file = .{ .path = "src/zhp.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.install();

    // run command (start the demo app on :9000)
    const exe = b.addExecutable(.{
        .name = "zhttpd",
        .root_source_file = .{ .path = "example/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.valgrind_support = true;
    exe.addModule("zhp", zhp_module);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // run tests
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/app.zig" },
        .target = target,
        .optimize = optimize,
    });
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);

    // run parser tests
    const parser_tests = b.addExecutable(.{
        .name = "zhp-parser-test",
        .root_source_file = .{ .path = "tests/parser.zig" },
        .target = target,
        .optimize = optimize,
    });
    parser_tests.addModule("zhp", zhp_module);

    const parser_test_cmd = parser_tests.run();
    parser_test_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        parser_test_cmd.addArgs(args);
    }
    const parser_test_step = b.step("parser_test", "Run parser tests");
    parser_test_step.dependOn(&parser_test_cmd.step);
}
