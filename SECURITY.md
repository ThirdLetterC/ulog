# Security Model

Trust boundaries:
- `ulog` does not parse network input; its untrusted inputs are caller-supplied format strings, format arguments, topic names, and runtime configuration values.
- Custom output handlers, prefix callbacks, lock callbacks, and `FILE *` destinations are trusted extension points and execute with library privileges.
- In static-topics mode, topic names are borrowed pointers; caller-owned storage must remain valid for the topic lifetime.

Attacker and misuse model:
- A buggy or hostile caller can pass invalid pointers, untrusted `printf` format strings, or callbacks that block, re-enter logger code, or violate lock contracts.
- A caller can attempt log flooding or unbounded topic creation when dynamic topics or extra outputs are enabled.
- Concurrent callers may race if no lock callback is installed; time capture also relies on `localtime`, so applications must choose an appropriate threading model.

Protected assets:
- Integrity of internal logger configuration, topic and output tables, and cleanup paths.
- Bounded writes when rendering events into caller-provided buffers.
- Predictable failure behavior for invalid levels, missing handlers, disabled features, and allocation failures.

Defensive posture:
- Buffer rendering uses `vsnprintf` and fixed-size timestamp buffers, so string conversion helpers truncate instead of overflowing.
- Public APIs validate null or empty strings, output IDs, and log levels before mutating state or dispatching logs.
- `va_list` state is copied with `va_copy` before fan-out to multiple outputs or conversion helpers, avoiding reuse undefined behavior.
- Dynamic topic records are zero-initialized with `calloc` and released by `ulog_topic_remove` and `ulog_cleanup`.
- Configuration mutations and log dispatch can be serialized through a user-provided lock callback; lock acquisition failure returns `ULOG_STATUS_BUSY` for configuration APIs and drops the log event for `ulog_log`.
- Build defaults enforce `-std=c23 -Wall -Wextra -Wpedantic -Werror`.

Non-goals and assumptions:
- The library does not sanitize hostile format strings; applications must never pass untrusted data as the `message` format string.
- The library does not provide confidentiality, integrity protection, or secure transport for log sinks.
- The library is not async-signal-safe, and callback code is outside the library's security boundary.
- Sanitizers and additional hardening flags are not enabled by default.
