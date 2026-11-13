#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET_COMPILE="${TARGET_COMPILE:-aarch64-linux-gnu-}"

find "$ROOT/kernel" -name '*.o' -delete
rm -f "$ROOT/kernel/kpimg" "$ROOT/kernel/kpimg.elf"

if [[ -n "${KERNEL_CC:-}" ]]; then
    KERNEL_LD="${KERNEL_LD:-ld.lld -m aarch64elf}"
    KERNEL_OBJCOPY="${KERNEL_OBJCOPY:-llvm-objcopy}"
    KERNEL_CFLAGS="${KERNEL_CFLAGS:--fno-pic -fno-pie}"
    make -C "$ROOT/kernel" TARGET_COMPILE="$TARGET_COMPILE" \
        CC="$KERNEL_CC $KERNEL_CFLAGS" LD="$KERNEL_LD" OBJCOPY="$KERNEL_OBJCOPY" ANDROID=1
else
    make -C "$ROOT/kernel" TARGET_COMPILE="$TARGET_COMPILE" ANDROID=1
fi

make -C "$ROOT/tools" clean
make -C "$ROOT/tools"
"$ROOT/tools/kptools" -l -k "$ROOT/kernel/kpimg"
