# stage0

[stage0-posix](https://github.com/oriansj/stage0-posix) for AMD64, as caos
expressions: from a 256-byte hex0 seed, through hand-written assemblers, to the
first C compiler and the first programs it builds.

Each directory builds one product. Its `.caos-expr` is the kaem script from
stage0-posix, line for line, handed to `step`; its `DEPS` names the earlier
phases it consumes, which deep-deps mounts at `DEEP-DEPS/<name>`.

| phase | product | built by |
|---|---|---|
| 0 | `hex0` | the hex0 seed, and checked against it |
| 0b | `kaem-0` | `hex0` |
| 1 | `hex1` | `hex0` |
| 2 | `hex2-0` | `hex1` |
| 2b | `catm` | `hex2-0` |
| 3 | `M0` | `hex2-0` |
| 4 | `cc_amd64` | `M0` |
| 5 | `M2` (M2-Planet) | `cc_amd64` |
| 6 | `blood-elf-0` | `M2` |
| 7 | `M1-0` | `M2`, `blood-elf-0` |
| 8 | `hex2-1` | `M2`, `blood-elf-0`, `M1-0` |

The sources are pinned in `step/.caos-expr`, once, to the commits stage0-posix's
submodules record. A step's workspace is laid out like a stage0-posix checkout,
with the products of its `DEPS` beside them, and whatever it leaves at `./out`
is its product.

Build a phase by evaluating its path, for example `stage0/M2`.
