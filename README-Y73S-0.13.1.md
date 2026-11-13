# KernelPatch 0.13.1 — vivo Y73s adaptation (offline validation)

Target: vivo Y73s V2031A / PD2031, MediaTek MT6853, Android 10, ARM64, Linux 4.14.141+.

## Build

With an AArch64-capable Clang/LLVM toolchain:

```sh
KERNEL_CC='clang --target=aarch64-linux-gnu' TARGET_COMPILE=aarch64-linux-gnu- ./build-y73s.sh
```

The build script adds `-fno-pic -fno-pie` by default for Clang-based freestanding builds. The generated `kernel/kpimg` and host `tools/kptools` are included.

## Offline validation results

- Exact `kallsyms_num_syms`: 107,961 (8-byte field on this 4.14 vendor kernel).
- `kallsyms_markers`: 422 entries; all marker boundaries validate against the full compressed names stream.
- `kallsyms_addresses`: offset `0x01c1c700`.
- Kernel base: `0xffffff8008080000`.
- `vectors`: index 18, offset `0x2800`.
- `pid_vnr`: CFI branch thunk followed to the implementation; `SP_EL0` access verified.
- Positive tests: original kernel and repacked boot both dump 107,961 symbols.
- Negative tests: corrupted `kallsyms_num_syms` and corrupted marker table are rejected; no approximate symbol-count fallback is used.
- Build and link completed; no GOT/PLT sections remain in the KPIMG ELF.

## Safety status

The generated boot image is **offline-only and not flashable**. It contains the placeholder superkey `Y73S-OFFLINE-ONLY-NOT-FOR-USE`. The original AVB hash descriptor matches the factory image, but the repacked image's boot hash does not match the stored descriptor. No device signing key was available, so the AVB signature/hash was not regenerated. Do not flash the generated image.

The work has not been validated by a real device boot. `kptools -l` reporting `patched=true` only confirms the embedded KPIMG metadata.
