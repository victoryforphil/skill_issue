---
name: pro-zephyr
description: Expert-level reference for Zephyr RTOS — project structure, West meta-tool + CMake build system, application model, Kconfig, devicetree, driver model, modules, and the Develop guide index. Load when working in the firmware/ project, writing or modifying Zephyr apps/drivers/samples, building for new boards, adding devicetree overlays, configuring Kconfig, or working with Twister / modules.
---

# Pro: Zephyr

Zephyr is a small-footscale, real-time operating system for resource-constrained embedded systems (sensors, wearables, drones, IoT). Source-of-truth here is the `zephyrproject-rtos/zephyr` GitHub repo, `main` branch; the rendered docs live at https://docs.zephyrproject.org/latest/.

This skill is the agent's working memory. The full scraped developer reference lives at `docs/external/zephyr-developer-guide.md` (read that for in-depth coverage).

## At a glance

- **Language:** C (with C++ and assembly support).
- **Architectures:** ARCv2/v3, ARMv6-M/7-M/8-M/7-A/8-A/7-R/8-R, x86, MIPS, OpenRISC, Renesas RX, RISC-V, SPARC V8, Xtensa.
- **License:** Apache 2.0 (with some imported components under other licenses).
- **Build system:** CMake (with the `find_package(Zephyr)` extension) + Ninja/Make, driven by **West**.
- **Hardware description:** Devicetree (.dts / .dtsi / .overlay + YAML bindings).
- **Configuration:** Kconfig.
- **Source of truth:** `zephyrproject-rtos/zephyr` on GitHub.

## West — the meta-tool

West is Zephyr's meta-tool. It manages a *workspace* of multiple git repos from a single `west.yml` manifest.

```bash
# Bootstrap a workspace
mkdir ~/zephyrproject && cd ~/zephyrproject
west init .                       # creates .west/ pointing to the zephyr repo's west.yml
west update                       # clone all manifest projects

# Export Zephyr as a CMake package (so find_package(Zephyr) works)
west zephyr-export

# Install Python deps
west packages pip --install

# Build, flash, debug
west build -b <board> <app>
west flash
west debug
west build -t menuconfig         # interactive Kconfig UI
west build -t guiconfig          # graphical Kconfig UI
west boards                      # list supported boards
west list                        # list workspace projects
```

The workspace layout is a folder containing `.west/`, with each manifest project as a sub-folder:

```text
zephyrproject/
├── .west/
│   └── config
├── zephyr/                       # main Zephyr source (the manifest repo)
├── modules/                      # external modules from the manifest
├── bootloader/                   # e.g. mcuboot
└── tools/                        # tool repos
```

Re-run `west update` any time `zephyr/west.yml` changes (after `git pull`, branch switches, `git bisect`).

## Project layout for a new app

Convention: keep the app inside the workspace for easy `west build`. Standard app structure:

```text
<app>
├── CMakeLists.txt                # entry point — find_package(Zephyr) + project()
├── app.overlay                   # devicetree overlay (merged with board.dts)
├── prj.conf                      # Kconfig fragment (merged into final config)
├── VERSION                       # version metadata for image signing
└── src/
    └── main.c
```

Minimum `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.20.0)
find_package(Zephyr)
project(my_zephyr_app)
target_sources(app PRIVATE src/main.c)
```

Minimum `prj.conf` (empty is fine):

```cfg
# Kconfig values for my app
```

`west build -b <board> .` builds it. The build dir is always **out-of-tree** (`<app>/build/`) — Zephyr does not support in-tree builds. Final artifacts land in `<app>/build/zephyr/`: `zephyr.elf`, `zephyr.hex`, `zephyr.bin`, `.config`, etc.

## The build triplet

Every Zephyr build is defined by three things:

1. **Application directory** (`<app>`) — your code, `prj.conf`, `app.overlay`, `CMakeLists.txt`.
2. **Board** (`-b <board>`) — selects the board's Kconfig defaults, devicetree, SoC config, linker scripts, flash tool. List with `west boards`.
3. **Toolchain** (`ZEPHYR_TOOLCHAIN_VARIANT`) — defaults to Zephyr SDK (`zephyr`); alternatives: `host/llvm`, `gnuarmemb`, `xtools`, `gccarmnone`, etc.

The board's name encodes SoC/cluster for multi-core targets: `nrf5340dk/nrf5340/cpuapp` (board / SoC / CPU cluster). Hardware revisions: `nrf9160dk@0.14.0/nrf9160/ns`.

## Kconfig

Kconfig is the configuration system. Options live in `Kconfig` files; values are set in `prj.conf` (and any extra fragments you point to).

```cfg
# prj.conf
CONFIG_CPP=y
CONFIG_LOG=y
CONFIG_GPIO=y
```

`west build -t menuconfig` for the TUI editor, `guiconfig` for the GUI. Experimental options are tagged `[EXPERIMENTAL]`; enable `CONFIG_WARN_EXPERIMENTAL=y` to be warned when you turn one on.

Key variables:

- `CONF_FILE` — Kconfig fragments to use (space- or semicolon-separated).
- `EXTRA_CONF_FILE` — additional fragments merged in.
- `FILE_SUFFIX` — suffix appended to config filenames (e.g. `prj_mouse.conf`).

## Devicetree

Devicetree describes the hardware. Each board has a base `.dts`; apps add `.overlay` files to modify it.

- **Source files:** `.dts` (top-level), `.dtsi` (includes).
- **Overlays:** `.overlay` — applied on top of the board's devicetree.
- **Bindings:** YAML files in `zephyr/dts/bindings/` describe each node's properties.
- **Generated:** the devicetree compiler (`dtc`) generates a C header (`<devicetree.h>`) with macros like `DT_NODELABEL(my_led)` / `DT_PROP(node, prop)`.
- **Preprocessed:** devicetree source is C-preprocessed — use `DTS_EXTRA_CPPFLAGS` to pass `-D` flags.

```text
# app.overlay — flash an LED on gpio0 pin 13
&led0 {
    gpios = <&gpio0 13 GPIO_ACTIVE_LOW>;
};
```

Variables:

- `DTC_OVERLAY_FILE` — overlays to use (semicolon-separated).
- `EXTRA_DTC_OVERLAY_FILE` — additional overlays merged in.
- `DTS_ROOT` — extra devicetree tree roots.
- `BOARD_ROOT` — extra board definition roots (out-of-tree boards).
- `SOC_ROOT` — extra SoC definition roots.

## Driver model

Zephyr uses a **consistent device model**:

- Each device is a `struct device` with a name, initialisation function, and config + data pointers.
- Drivers live under `zephyr/drivers/<class>/` (e.g. `drivers/gpio/`, `drivers/uart/`, `drivers/spi/`).
- A driver provides an `init` function, registers itself via `DEVICE_DT_INST_DEFINE(...)`, and exposes a *driver API* (e.g. `struct gpio_driver_api`).
- Kconfig selects which drivers are compiled in; devicetree assigns each enabled instance to a hardware node.
- Subsystem APIs (`<zephyr/drivers/gpio.h>`, `<zephyr/drivers/uart.h>`, etc.) hide which driver backs a device — applications call the API.

The boot sequence: device tree is parsed → Kconfig selects which drivers to include → `SYS_INIT` / `DEVICE_DT_INST_DEFINE` registers each device with the appropriate init priority → kernel calls init functions at boot in priority order.

## Modules (external projects)

Modules are external repos integrated into the Zephyr build. Each is identified by a `zephyr/module.yml` at its root.

- **Default manifest modules** (hosted under `zephyrproject-rtos/`) are auto-discovered by west.
- **Out-of-tree modules** are added via `EXTRA_ZEPHYR_MODULES` (or `ZEPHYR_MODULES` to fully replace discovery).
- `module.yml` declares: name, `build` (cmake/kconfig/sysbuild paths, `depends`, `settings.*` roots), `samples`, `tests`, `boards`, `runners`, `package-managers`, `blobs`, `security.external-references`.

Module names in CMake/Kconfig: `foo-bar` → `ZEPHYR_FOO_BAR_MODULE_DIR`, `$(ZEPHYR_FOO_BAR_MODULE_DIR)`.

A west project that is also a module gets the same treatment; a west project that is not a module (e.g. tooling) does not.

## Twister — the test runner

Twister is Zephyr's test runner. It builds a matrix of sample/test/board combinations, runs them in QEMU or on hardware, and reports results.

```bash
west build -t twister                              # run default test set
./scripts/twister -p native_sim -T samples/hello_world/
./scripts/twister -p qemu_x86 -T tests/            # all tests on qemu_x86
```

Test sources live in `zephyr/tests/` and `zephyr/samples/`. Each test/sample has a `sample.yaml` / `testcase.yaml` declaring supported boards, configuration, and expected output.

## Sysbuild (multi-image builds)

For systems that need multiple Zephyr images (e.g. application + bootloader + network core), Zephyr provides `sysbuild` (system build). Top-level `sysbuild.cmake` describes the images; each is a normal Zephyr build. Enabled with `west build -b <board> --sysbuild` (or `cmake -DSYSBUILD=1`).

## Common commands

| Task | Command |
|---|---|
| List supported boards | `west boards` |
| Build for a board | `west build -b <board> <app>` |
| Pristine rebuild | `west build -p always -b <board> <app>` |
| Flash | `west flash` |
| Debug (GDB) | `west debug` |
| Run in QEMU | `west build -t run` |
| Native sim (Linux) | `west build -b native_sim <app> && ./build/zephyr/zephyr.exe` |
| Kconfig TUI | `west build -t menuconfig` |
| Kconfig GUI | `west build -t guiconfig` |
| Show final `.config` | `cat build/zephyr/.config` |
| Show resolved devicetree | `cat build/zephyr/zephyr.dts` (after build) |
| Run twister | `west build -t twister` or `./scripts/twister ...` |
| Update workspace | `west update` |
| Install Python deps | `west packages pip --install` |
| Install Zephyr SDK | `west sdk install` |
| Find env script | `source zephyrproject/zephyr/zephyr-env.sh` |

## Environment variables (cheat sheet)

| Variable | Purpose |
|---|---|
| `ZEPHYR_BASE` | Path to the Zephyr repo (set by `zephyr-env.sh`). |
| `BOARD` | Board to build for (or use `-b`). |
| `CONF_FILE` | Kconfig fragment(s) (or use `prj.conf`). |
| `DTC_OVERLAY_FILE` | Devicetree overlay(s) (or use `app.overlay`). |
| `ZEPHYR_TOOLCHAIN_VARIANT` | Toolchain name (`zephyr`, `host/llvm`, …). |
| `ZEPHYR_SDK_INSTALL_DIR` | Zephyr SDK install path. |
| `ZEPHYR_MODULES` | Full module list (replaces west discovery). |
| `EXTRA_ZEPHYR_MODULES` | Additional modules merged with west discovery. |
| `ZEPHYR_BOARD_ALIASES` | Path to a CMake file with `*_BOARD_ALIAS` defs. |
| `QEMU_BIN_PATH` | Override QEMU binary path. |
| `DTS_EXTRA_CPPFLAGS` | Extra `-D` flags for devicetree preprocessing. |

Set them in your shell, in `~/.zephyrrc` (loaded by `zephyr-env.sh`), or pass `-D` to `west build` / `cmake`.

## Develop guide — section structure

Mirrors `doc/develop/index.rst` (the source `.rst` lists 15 sub-sections; the rendered docs site order is the same):

| Section | Covers |
|---|---|
| **Getting Started Guide** | OS setup, dep install (`apt`/`brew`/`winget`), West workspace bootstrap, SDK install, first build & flash (Blinky / Hello World). |
| **Beyond the Getting Started Guide** | Python/pip notes, toolchain selection & switching, `west init/update`, board aliases, Linux udev rules, QEMU & `native_sim` run targets. |
| **Environment Variables** | Three ways to set vars (shell, rc file, `zephyrrc`), `zephyr-env.sh` / `zephyr-env.cmd`, full list of important Zephyr env vars. |
| **Application Development** | **(foundational)** app layout, `CMakeLists.txt`, `prj.conf`, devicetree overlays, build variables, `FILE_SUFFIX`, building, flashing, QEMU, custom out-of-tree boards/SoCs/DTS. |
| **Debugging** | GDB integration, CoreDump, tracing, `west debug`, debug probes. |
| **API Status and Guidelines** | API lifecycle (experimental/stable/deprecated), naming, doxygen conventions. |
| **Language Support** | C/C++ standards, assembly, language-specific build flags. |
| **Optimizations** | Size, speed, LTO, newlib-nano, footprint tuning. |
| **Flashing and Hardware Debugging** | `west flash`/`west debug`, runners, hardware-specific flash tools. |
| **Modules (External projects)** | Module lifecycle, `zephyr/module.yml` schema, integration with/without west, binary blobs, vulnerability monitoring, runners. |
| **West (Zephyr's meta-tool)** | Workspace topologies (T1/T2), manifest format, west config, extension commands, submanifests. |
| **Testing** | Twister, sanity tests, integration tests, native_posix/native_sim test execution, testcase.yaml. |
| **Static Code Analysis (SCA)** | Scan tools integrated into the build (`west build -t <tool>`). |
| **Toolchains** | Zephyr SDK, GNU Arm, LLVM, IAR, host (native), toolchain switching. |
| **Tools and IDEs** | IDE integrations (VS Code, Eclipse, etc.), `west build` from IDE, devcontainer, etc. |

## Develop sub-section URLs (quick reference)

All paths are relative to https://docs.zephyrproject.org/latest/

- Getting Started Guide: `develop/getting_started/index.html`
- Beyond the Getting Started Guide: `develop/beyond-GSG.html`
- Environment Variables: `develop/env_vars.html`
- Application Development: `develop/application/index.html`
- Debugging: `develop/debug/index.html`
- API Status and Guidelines: `develop/api/index.html`
- Language Support: `develop/languages/index.html`
- Optimizations: `develop/optimizations/index.html`
- Flashing and Hardware Debugging: `develop/flash_debug/index.html`
- Modules (External projects): `develop/modules.html`
- West (Zephyr's meta-tool): `develop/west/index.html`
- Testing: `develop/test/index.html`
- Static Code Analysis (SCA): `develop/sca/index.html`
- Toolchains: `develop/toolchains/index.html`
- Tools and IDEs: `develop/tools/index.html`

## Pointers to the scraped reference

For full, offline-readable coverage of the develop guide, sample walkthroughs, build variables, environment variables, and the modules model, read:

- `docs/external/zephyr-developer-guide.md` — the scraped reference. Section headings mirror the source subdirectories (`doc/develop/application/`, `doc/develop/getting_started/`, etc.).

Other relevant external docs (not yet scraped, but useful):

- `kernel/services/` — kernel API reference (use Doxygen).
- `build/dts/` — devicetree bindings schema and overlay tutorial.
- `build/kconfig/` — Kconfig tutorial.
- `hardware/porting/` — porting Zephyr to a new SoC/board.
- `boards/` — supported boards (rendered index at `boards/index.html`).

## Quick "first build" recipe (new workspace)

```bash
# 0. Prereqs: CMake 3.20.5+, Python 3.12+, dtc 1.4.6+, C compiler, git
#    See: https://docs.zephyrproject.org/latest/develop/getting_started/index.html

# 1. Workspace
python3 -m venv ~/zephyrproject/.venv
source ~/zephyrproject/.venv/bin/activate
pip install west
west init ~/zephyrproject
cd ~/zephyrproject
west update
west zephyr-export
west packages pip --install
west sdk install

# 2. New app
mkdir -p my-app/src
# write my-app/src/main.c, my-app/CMakeLists.txt (find_package(Zephyr) + project + target_sources), my-app/prj.conf

# 3. Build & flash
cd my-app
west build -b <board> .
west flash
```

## Tips & gotchas

1. **Out-of-tree builds only.** Never build inside `<app>/src/` or inside the Zephyr repo — always `<app>/build/`.
2. **No spaces in paths.** `C:\Users\Your Name\app` will not build on Windows.
3. **`west update` whenever the manifest changes.** `git pull`, branch switch, or `git bisect` in the Zephyr repo all require it.
4. **Re-run `west zephyr-export`** once per workspace if `find_package(Zephyr)` complains — it writes the Zephyr CMake package into the user package registry.
5. **Activate your venv every session.** Zephyr's Python deps live there.
6. **Board name for multi-core SoCs** may need a SoC/cluster qualifier (`nrf5340dk/nrf5340/cpuapp`).
7. **Driver enable/disable is Kconfig, instance binding is devicetree.** Add `CONFIG_FOO=y` to enable; the driver instance is auto-bound from `foo.dtsi`/`.overlay`.
8. **Out-of-tree boards:** use `BOARD_ROOT` (or `-DBOARD_ROOT=...`) — vendor name must match `dts/bindings/vendor-prefixes.txt` (`others` if not a real vendor).
9. **Modules are auto-discovered by west** — only set `ZEPHYR_MODULES` if you want to fully override; use `EXTRA_ZEPHYR_MODULES` to add.
10. **Twister** is how you run the test matrix — local boards get filtered out unless you whitelist them.
11. **Run `west build -t menuconfig`** before committing Kconfig changes — it catches invalid dependencies.
12. **`grep -r 'DT_NODELABEL'` in your app** to find devicetree hooks; `DT_PROP(node, prop)` is the C macro for reading a property.
