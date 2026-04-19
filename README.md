# PixelOS

A minimal Linux distribution built entirely from source — LFS-style, musl libc, runit init, and **meow**, a lightweight package manager inspired by PiSi/eopkg.

```
  PixelOS LFS Bootstrap
  ─────────────────────────────────────────
  Target root : /mnt/pixelos
  Triplet     : x86_64-pixelos-linux-musl
  Jobs        : 16
```

## Stack

| Component  | Version  | Role                          |
|------------|----------|-------------------------------|
| Linux      | 6.8.1    | Kernel + headers              |
| musl libc  | 1.2.5    | C standard library            |
| GCC        | 13.2.0   | Cross + native compiler       |
| binutils   | 2.42     | Assembler, linker             |
| BusyBox    | 1.36.1   | Static early-boot userland    |
| Python     | 3.12.3   | Runtime for meow              |
| bash       | 5.2.21   | Default shell                 |
| coreutils  | 9.5      | GNU core utilities            |
| util-linux | 2.40     | System utilities              |
| runit      | 2.1.2    | Init + service supervision    |

## Quick Start

> **Requirements:** Linux host (any distro), root access, ~20 GB free on target partition, gcc, make, wget, tar, python3 ≥ 3.11.

```bash
# 1. Mount your target partition
mount /dev/sdXY /mnt/pixelos

# 2. Clone this repo
git clone https://github.com/youruser/pixelos
cd pixelos

# 3. Run the bootstrap (takes 2–4 hours)
sudo bash lfs-bootstrap.sh --target /mnt/pixelos
```

After the bootstrap completes, chroot in and start building:

```bash
chroot /mnt/pixelos \
    /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/bin:/usr/sbin /bin/sh

# Set root password
passwd

# Add a package repo and install packages
meow repo add main https://your-repo-url
meow update
meow install bash coreutils vim
```

## meow — Package Manager

```
meow install <pkg...>         install packages
meow remove  <pkg...>         remove packages
meow update                   sync repo indexes
meow upgrade                  upgrade all installed packages
meow search  <term>           search available packages
meow list                     list installed packages
meow info    <pkg>            show package details
meow build   <meowspec.toml>  build a .meow from a spec
meow repo add <n> <url>       register a repository
meow repo list                list configured repositories
```

## Creating a Package

Each package lives in `packages/<name>/` and consists of:

- **`meowspec.toml`** — package metadata, source URL, dependencies
- **`build.sh`** — build instructions (runs inside extracted source)
- **`install.sh`** *(optional)* — post-install hook
- **`remove.sh`** *(optional)* — pre-remove hook

```toml
# packages/bash/meowspec.toml
[package]
name        = "bash"
version     = "5.2.21"
release     = 1
summary     = "The GNU Bourne Again shell"
license     = "GPL-3.0"
source_url  = "https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz"
sha256      = "c8e31bdc59b69aaffc5b36509905ba3e5d464c58f23e9670b85c4a9f2accc98b"
depends       = ["glibc", "readline", "ncurses"]
build_depends = ["gcc", "make", "readline-dev", "ncurses-dev"]
provides      = ["sh"]
```

Then build it:

```bash
meow build packages/bash/meowspec.toml -o ./dist/
```

## Repo Layout

```
pixelos/
├── lfs-bootstrap.sh        # Stage 0 — build base system from scratch
├── meow.py                 # The meow package manager
├── packages/               # Package specs
│   ├── bash/
│   │   ├── meowspec.toml
│   │   └── build.sh
│   └── ...
├── docs/                   # Extra documentation
└── README.md
```

## Contributing

1. Fork and branch: `git checkout -b pkg/yourpackage`
2. Add `packages/yourpackage/meowspec.toml` and `build.sh`
3. Test: `meow build packages/yourpackage/meowspec.toml`
4. Open a PR

Always pin a concrete upstream version and include a `sha256` checksum. Floating versions are not accepted.

## License

GPL-3.0 — see [LICENSE](LICENSE).
