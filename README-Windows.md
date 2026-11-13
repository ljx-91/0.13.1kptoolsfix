# Windows 版 kptools（KernelPatch 0.13.1）

本仓库提供原生 Windows x64 的 `kptools.exe` 构建流程。它直接编译仓库 `tools/` 下的 C 源码，不依赖 WSL，也不需要在运行时安装 MSYS2。

## 下载

在 GitHub Actions 中运行 **Build Windows kptools** 工作流，完成后下载名为 `kptools-windows-x64` 的 artifact。压缩包内包含：

- `kptools.exe`：Windows x64 命令行程序
- `README-Windows.md`：使用说明

该工作流使用 MinGW-w64 UCRT64 编译，并启用静态链接；CI 会执行 `--help`、`--version` 冒烟测试，并检查是否意外依赖 MSYS2、zlib 或 GCC 运行时 DLL。

## 使用

在 PowerShell 或 CMD 中进入 `kptools.exe` 所在目录：

```powershell
.\kptools.exe --help
.\kptools.exe --version

# 解析 Android boot.img 并提取 kernel
.\kptools.exe unpack .\boot.img

# 解析内核 kallsyms
.\kptools.exe --dump --image .\kernel

# 查看补丁信息
.\kptools.exe --list --image .\kernel

# 使用指定 KPIMG 修补内核
.\kptools.exe --patch --image .\kernel --kpimg .\kpimg --out .\kernel.patched
```

命令参数以程序 `--help` 输出为准。路径建议使用引号包裹，避免空格导致参数拆分。

## 从源码构建

需要安装 MSYS2，并在 UCRT64 环境安装：

```bash
pacman -S --needed mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-zlib
```

然后在仓库根目录执行：

```bash
cp kernel/include/preset.h tools/preset.h
cmake -S tools -B tools/build/windows-x64 \
  -G "MinGW Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DZLIB_USE_STATIC_LIBS=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++"
cmake --build tools/build/windows-x64 --parallel
```

生成文件：`tools/build/windows-x64/kptools.exe`。

## 兼容性说明

- 这是运行在 Windows x64 主机上的工具；它处理的仍然是 ARM64 Android/Linux 内核镜像。
- 不改变 KPIMG 的目标架构或内核端代码。
- Windows CI 的冒烟测试只验证程序能启动并显示帮助/版本，不等同于已完成所有 boot.img 格式的端到端回归。正式发布前仍应使用原厂镜像分别验证 unpack、patch、dump、list 和 repack。
- 不要将离线解析或补丁元数据检查结果等同于设备启动验证。
