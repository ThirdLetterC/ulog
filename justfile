set shell := ["bash", "-uc"]

CC := env_var_or_default("CC", "cc")
CLANG_FORMAT := env_var_or_default("CLANG_FORMAT", "clang-format")

default:
    @just --list

# Zig build helpers
build:
    zig build

run:
    zig build run

run-all-features:
    zig build run-all-features

format:
    {{CLANG_FORMAT}} -i \
        include/ulog/ulog.h \
        src/ulog.c \
        examples/ulog_example.c \
        examples/ulog_all_features.c \
        extensions/ulog_syslog.c

# Direct C compiler helpers
cc-example out="ulog_example":
    {{CC}} -std=c23 -Wall -Wextra -Wpedantic -Werror -Iinclude \
        src/ulog.c examples/ulog_example.c -o {{out}}

cc-all-features out="ulog_all_features":
    {{CC}} -std=c23 -Wall -Wextra -Wpedantic -Werror -DULOG_BUILD_DYNAMIC_CONFIG=1 \
        -Iinclude -Iextensions src/ulog.c extensions/ulog_syslog.c \
        examples/ulog_all_features.c -o {{out}}

clean:
    rm -rf zig-out zig-cache ulog_example ulog_all_features
