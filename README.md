## meow — Package Manager

"MEOW" is an fast package manager written in python for LFS systems.

The commands you can do with meow are down below.

```
meow install <pkg...>         install packages
meow remove  <pkg...>         remove packages
meow update                   sync repo indexes
meow upgrade                  upgrade all installed packages
meow search  <term>           search available packages
meow list                     list installed packages
meow info    <pkg>            show package details
meow build   <meowspec.toml>  build a .meow from a spec
meow repo enable <repo-name>  enable a repository
meow repo disable <repo-name> disable a repository
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
