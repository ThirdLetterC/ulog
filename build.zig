const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const c_flags = &[_][]const u8{
        "-std=c23",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Werror",
    };
    const c_flags_dynamic = &[_][]const u8{
        "-std=c23",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Werror",
        "-DULOG_BUILD_DYNAMIC_CONFIG=1",
    };

    const exe = b.addExecutable(.{
        .name = "ulog_example",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addIncludePath(b.path("include"));
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ulog.c"), .flags = c_flags });
    exe.root_module.addCSourceFile(.{ .file = b.path("examples/ulog_example.c"), .flags = c_flags });
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the ulog example");
    run_step.dependOn(&run_cmd.step);

    const all_features = b.addExecutable(.{
        .name = "ulog_all_features",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    all_features.root_module.addIncludePath(b.path("include"));
    all_features.root_module.addIncludePath(b.path("extensions"));
    all_features.root_module.addCSourceFile(.{ .file = b.path("src/ulog.c"), .flags = c_flags_dynamic });
    all_features.root_module.addCSourceFile(.{ .file = b.path("extensions/ulog_syslog.c"), .flags = c_flags_dynamic });
    all_features.root_module.addCSourceFile(.{ .file = b.path("examples/ulog_all_features.c"), .flags = c_flags_dynamic });
    all_features.linkLibC();

    b.installArtifact(all_features);

    const run_all_cmd = b.addRunArtifact(all_features);
    run_all_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_all_cmd.addArgs(args);
    }

    const run_all_step = b.step("run-all-features", "Run the all-features example");
    run_all_step.dependOn(&run_all_cmd.step);
}
