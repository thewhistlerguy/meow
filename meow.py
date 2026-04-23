#!/usr/bin/env python3
"""
meow — the re-pisi package manager
A reincarnation of PiSi for PixelOS / custom Linux builds.

Package format : .meow  (xz-compressed tar archive)
Package spec   : meowspec.toml
Database       : /var/lib/meow/
Repo cache     : /var/cache/meow/

Usage:
  meow install <pkg>        install a package
  meow remove  <pkg>        remove a package
  meow update               sync repo index
  meow upgrade              upgrade all installed packages
  meow search  <term>       search available packages
  meow list                 list installed packages
  meow info    <pkg>        show package details
  meow build   <specfile>   build a .meow from a meowspec.toml
  meow repo add <name> <url> add a repository
  meow repo list             list repos
"""

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional

# ── try tomllib (Python 3.11+) or fall back to tomli ────────────
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib  # pip install tomli
    except ImportError:
        tomllib = None

# ── PATHS ────────────────────────────────────────────────────────
ROOT        = Path(os.environ.get("MEOW_ROOT", "/"))
DB_DIR      = ROOT / "var/lib/meow"
CACHE_DIR   = ROOT / "var/cache/meow/packages"
REPO_DIR    = ROOT / "var/cache/meow/repos"
REPO_CONF   = ROOT / "etc/meow/repos.toml"
INSTALL_DB  = DB_DIR / "installed.json"
BUILD_DIR   = Path("/tmp/meow-build")

# ── COLORS ───────────────────────────────────────────────────────
class C:
    R = "\033[0;31m"; G = "\033[0;32m"; Y = "\033[1;33m"
    B = "\033[0;34m"; P = "\033[0;35m"; C = "\033[0;36m"
    W = "\033[1;37m"; N = "\033[0m";   BOLD = "\033[1m"

def info(msg):  print(f"{C.B}  →{C.N} {msg}")
def ok(msg):    print(f"{C.G}  ✓{C.N} {msg}")
def warn(msg):  print(f"{C.Y}  !{C.N} {msg}")
def err(msg):   print(f"{C.R}  ✗{C.N} {msg}"); sys.exit(1)
def section(msg): print(f"\n{C.W}{C.BOLD}── {msg} ──{C.N}")

# ── DATA CLASSES ─────────────────────────────────────────────────

@dataclass
class PackageMeta:
    """Metadata for a package — lives in meowspec.toml and inside .meow archives."""
    name:         str
    version:      str
    release:      int
    summary:      str
    description:  str  = ""
    license:      str  = "GPL-2.0"
    homepage:     str  = ""
    arch:         str  = "x86_64"
    depends:      list = field(default_factory=list)
    build_depends:list = field(default_factory=list)
    provides:     list = field(default_factory=list)
    conflicts:    list = field(default_factory=list)
    source_url:   str  = ""
    sha256:       str  = ""

    @property
    def evr(self):
        """epoch-version-release string"""
        return f"{self.version}-{self.release}"

    @property
    def filename(self):
        return f"{self.name}-{self.version}-{self.release}-{self.arch}.meow"

    def to_dict(self):
        return asdict(self)

    @classmethod
    def from_dict(cls, d: dict):
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})

    @classmethod
    def from_toml(cls, path: Path):
        if tomllib is None:
            err("tomllib/tomli not available. Install Python 3.11+ or: pip install tomli")
        with open(path, "rb") as f:
            data = tomllib.load(f)
        pkg = data.get("package", data)
        return cls(
            name         = pkg["name"],
            version      = pkg["version"],
            release      = int(pkg.get("release", 1)),
            summary      = pkg["summary"],
            description  = pkg.get("description", ""),
            license      = pkg.get("license", "GPL-2.0"),
            homepage     = pkg.get("homepage", ""),
            arch         = pkg.get("arch", "x86_64"),
            depends      = pkg.get("depends", []),
            build_depends= pkg.get("build_depends", []),
            provides     = pkg.get("provides", []),
            conflicts    = pkg.get("conflicts", []),
            source_url   = pkg.get("source_url", ""),
            sha256       = pkg.get("sha256", ""),
        )


# ── DATABASE ─────────────────────────────────────────────────────

class InstallDB:
    """Tracks installed packages in /var/lib/meow/installed.json"""

    def __init__(self):
        DB_DIR.mkdir(parents=True, exist_ok=True)
        self._data: dict = {}
        self._load()

    def _load(self):
        if INSTALL_DB.exists():
            with open(INSTALL_DB) as f:
                self._data = json.load(f)

    def _save(self):
        with open(INSTALL_DB, "w") as f:
            json.dump(self._data, f, indent=2)

    def is_installed(self, name: str) -> bool:
        return name in self._data

    def get(self, name: str) -> Optional[PackageMeta]:
        d = self._data.get(name)
        return PackageMeta.from_dict(d) if d else None

    def record(self, meta: PackageMeta, files: list[str]):
        self._data[meta.name] = {**meta.to_dict(), "_files": files}
        self._save()

    def remove(self, name: str):
        self._data.pop(name, None)
        self._save()

    def files_of(self, name: str) -> list[str]:
        return self._data.get(name, {}).get("_files", [])

    def all(self) -> list[PackageMeta]:
        return [PackageMeta.from_dict(v) for v in self._data.values()]


# ── REPOSITORY ───────────────────────────────────────────────────

# Predefined repos — only these are allowed.
# To add a new official repo in the future, add it here.
KNOWN_REPOS = {
    "main": "https://raw.githubusercontent.com/thewhistlerguy/meow/main/",
}

class RepoManager:
    """
    Manages repository definitions and cached package indexes.
    Repos are predefined in KNOWN_REPOS — users enable/disable them.
    """

    def __init__(self):
        REPO_DIR.mkdir(parents=True, exist_ok=True)
        REPO_CONF.parent.mkdir(parents=True, exist_ok=True)
        self._enabled = self._load_enabled()

    def _load_enabled(self):
        if not REPO_CONF.exists():
            self._save_enabled({"main"})
            return {"main"}
        if tomllib is None:
            return {"main"}
        with open(REPO_CONF, "rb") as f:
            data = tomllib.load(f)
        return set(data.get("enabled", ["main"]))

    def _save_enabled(self, enabled=None):
        if enabled is not None:
            self._enabled = enabled
        with open(REPO_CONF, "w") as f:
            names = ", ".join(f'"{n}"' for n in sorted(self._enabled))
            f.write(f"enabled = [{names}]\n")

    @property
    def _repos(self):
        return {n: u for n, u in KNOWN_REPOS.items() if n in self._enabled}

    def enable(self, name):
        if name not in KNOWN_REPOS:
            err(f"Unknown repo: '{name}'. Available: {', '.join(KNOWN_REPOS)}")
        self._enabled.add(name)
        self._save_enabled()
        ok(f"Enabled repo: {name} → {KNOWN_REPOS[name]}")

    def disable(self, name):
        if name not in KNOWN_REPOS:
            err(f"Unknown repo: '{name}'. Available: {', '.join(KNOWN_REPOS)}")
        self._enabled.discard(name)
        self._save_enabled()
        ok(f"Disabled repo: {name}")

    def list_repos(self):
        print(f"\n  Name             Status     URL")
        print(f"  {chr(8212)*16} {chr(8212)*10} {chr(8212)*45}")
        for name, url in KNOWN_REPOS.items():
            status = f"{C.G}enabled{C.N}" if name in self._enabled else f"{C.Y}disabled{C.N}"
            print(f"  {C.W}{name:<16}{C.N} {status:<18} {url}")
        print()

    def update(self):
        if not self._enabled:
            warn("No repos enabled. Run: meow repo enable main")
            return
        for name, url in self._repos.items():
            info(f"Syncing {name}...")
            idx_url = url.rstrip("/") + "/index.json"
            local   = REPO_DIR / f"{name}.json"
            try:
                urllib.request.urlretrieve(idx_url, local)
                ok(f"{name}")
            except Exception as e:
                warn(f"Failed to sync {name}: {e}")

    def _all_packages(self) -> dict:
        """Merge all repo indexes into one dict. Last repo wins on conflict."""
        merged = {}
        for path in REPO_DIR.glob("*.json"):
            try:
                with open(path) as f:
                    idx = json.load(f)
                for pkg_name, meta in idx.get("packages", {}).items():
                    meta["_repo"] = path.stem
                    merged[pkg_name] = meta
            except Exception:
                pass
        return merged

    def find(self, name: str) -> Optional[dict]:
        return self._all_packages().get(name)

    def search(self, term: str) -> list[dict]:
        term = term.lower()
        return [
            {"name": n, **m}
            for n, m in self._all_packages().items()
            if term in n.lower() or term in m.get("summary", "").lower()
        ]

    def download(self, pkg_info: dict) -> Path:
        """Download a .meow file, verify sha256, return local path."""
        repo_url  = self._repos.get(pkg_info["_repo"], "")
        filename  = pkg_info["filename"]
        url       = repo_url.rstrip("/") + "/" + filename
        dest      = CACHE_DIR / filename
        CACHE_DIR.mkdir(parents=True, exist_ok=True)

        if dest.exists():
            if _sha256(dest) == pkg_info.get("sha256", ""):
                info(f"Using cached {filename}")
                return dest
            dest.unlink()

        info(f"Downloading {filename}...")
        urllib.request.urlretrieve(url, dest)
        expected = pkg_info.get("sha256", "")
        if expected and _sha256(dest) != expected:
            dest.unlink()
            err(f"sha256 mismatch for {filename}!")
        ok(f"Downloaded {filename}")
        return dest


# ── .meow ARCHIVE FORMAT ─────────────────────────────────────────
#
# A .meow file is a tar.xz archive with this layout:
#
#   meow.json         ← package metadata (PackageMeta serialised)
#   files.tar.xz      ← the actual installed files (rooted at /)
#   install.sh        ← optional post-install hook
#   remove.sh         ← optional pre-remove hook
#

class MeowArchive:

    @staticmethod
    def pack(meta: PackageMeta, files_dir: Path, output_dir: Path,
             install_hook: Optional[Path] = None,
             remove_hook:  Optional[Path] = None) -> Path:
        """Create a .meow archive from a staged directory tree."""
        output_dir.mkdir(parents=True, exist_ok=True)
        out_path = output_dir / meta.filename

        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)

            # 1. metadata
            with open(tmp / "meow.json", "w") as f:
                json.dump(meta.to_dict(), f, indent=2)

            # 2. files tarball
            files_tar = tmp / "files.tar.xz"
            with tarfile.open(files_tar, "w:xz") as tf:
                tf.add(files_dir, arcname=".")

            # 3. hooks
            if install_hook and install_hook.exists():
                shutil.copy(install_hook, tmp / "install.sh")
            if remove_hook and remove_hook.exists():
                shutil.copy(remove_hook, tmp / "remove.sh")

            # 4. wrap everything in the outer .meow tar
            with tarfile.open(out_path, "w:xz") as tf:
                for p in tmp.iterdir():
                    tf.add(p, arcname=p.name)

        ok(f"Built: {out_path}")
        return out_path

    @staticmethod
    def unpack(meow_path: Path, dest_root: Path) -> tuple[PackageMeta, list[str]]:
        """
        Extract a .meow archive into dest_root.
        Returns (meta, list_of_installed_files).
        """
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)

            # Outer archive
            with tarfile.open(meow_path, "r:xz") as tf:
                tf.extractall(tmp)

            # Metadata
            with open(tmp / "meow.json") as f:
                meta = PackageMeta.from_dict(json.load(f))

            # Files
            installed_files = []
            files_tar = tmp / "files.tar.xz"
            if files_tar.exists():
                with tarfile.open(files_tar, "r:xz") as tf:
                    members = tf.getmembers()
                    tf.extractall(dest_root)
                    installed_files = [
                        str(Path("/") / m.name)
                        for m in members
                        if m.isfile()
                    ]

            # Post-install hook
            hook = tmp / "install.sh"
            if hook.exists():
                info("Running post-install hook...")
                subprocess.run(["bash", str(hook)], check=False)

        return meta, installed_files


# ── DEPENDENCY RESOLVER ──────────────────────────────────────────

class Resolver:
    """
    Dead-simple topological dependency resolver.
    No version ranges yet — just name-based deps.
    """

    def __init__(self, repo: RepoManager, db: InstallDB):
        self.repo = repo
        self.db   = db

    def resolve(self, names: list[str], seen: set = None) -> list[str]:
        """Return ordered install list (deps before dependents)."""
        if seen is None:
            seen = set()
        order = []
        for name in names:
            if name in seen:
                continue
            seen.add(name)
            if self.db.is_installed(name):
                continue
            pkg = self.repo.find(name)
            if not pkg:
                err(f"Package not found: {name}")
            deps = pkg.get("depends", [])
            order.extend(self.resolve(deps, seen))
            order.append(name)
        return order


# ── PACKAGE OPERATIONS ───────────────────────────────────────────

class Meow:

    def __init__(self):
        self.db   = InstallDB()
        self.repo = RepoManager()

    # ── install ─────────────────────────────────────────────────
    def install(self, names: list[str], yes: bool = False):
        section("Resolving dependencies")
        resolver = Resolver(self.repo, self.db)
        to_install = resolver.resolve(names)

        if not to_install:
            ok("Nothing to do — all packages already installed.")
            return

        print(f"\n  Packages to install ({len(to_install)}):")
        for n in to_install:
            pkg = self.repo.find(n)
            ver = f"{pkg['version']}-{pkg['release']}" if pkg else "?"
            print(f"    {C.G}{n}{C.N}  {ver}")

        if not yes:
            ans = input("\n  Continue? [Y/n] ").strip().lower()
            if ans and ans != "y":
                print("  Aborted.")
                return

        for name in to_install:
            self._install_one(name)

    def _install_one(self, name: str):
        pkg_info = self.repo.find(name)
        if not pkg_info:
            err(f"Package not found in any repo: {name}")

        section(f"Installing {name}-{pkg_info['version']}-{pkg_info['release']}")

        # Check conflicts
        for conflict in pkg_info.get("conflicts", []):
            if self.db.is_installed(conflict):
                err(f"{name} conflicts with installed package: {conflict}")

        meow_path = self.repo.download(pkg_info)
        meta, files = MeowArchive.unpack(meow_path, ROOT)
        self.db.record(meta, files)
        ok(f"Installed {name}-{meta.evr}")

    # ── remove ──────────────────────────────────────────────────
    def remove(self, names: list[str], yes: bool = False):
        for name in names:
            if not self.db.is_installed(name):
                warn(f"{name} is not installed")
                continue

            meta = self.db.get(name)
            print(f"\n  Remove: {C.R}{name}{C.N}  {meta.evr}")
            if not yes:
                ans = input("  Continue? [Y/n] ").strip().lower()
                if ans and ans != "y":
                    continue

            self._remove_one(name)

    def _remove_one(self, name: str):
        section(f"Removing {name}")
        files = self.db.files_of(name)
        removed = 0
        for f in files:
            p = ROOT / f.lstrip("/")
            try:
                p.unlink(missing_ok=True)
                removed += 1
            except Exception as e:
                warn(f"Could not remove {f}: {e}")
        self.db.remove(name)
        ok(f"Removed {name} ({removed} files)")

    # ── update ──────────────────────────────────────────────────
    def update(self):
        section("Syncing repositories")
        self.repo.update()

    # ── upgrade ─────────────────────────────────────────────────
    def upgrade(self, yes: bool = False):
        section("Checking for upgrades")
        to_upgrade = []
        for installed in self.db.all():
            available = self.repo.find(installed.name)
            if not available:
                continue
            av = (available["version"], int(available.get("release", 1)))
            iv = (installed.version,    installed.release)
            if av > iv:
                to_upgrade.append((installed, available))

        if not to_upgrade:
            ok("Everything is up to date.")
            return

        print(f"\n  Packages to upgrade ({len(to_upgrade)}):")
        for old, new in to_upgrade:
            print(f"    {C.Y}{old.name}{C.N}  {old.evr} → {new['version']}-{new['release']}")

        if not yes:
            ans = input("\n  Continue? [Y/n] ").strip().lower()
            if ans and ans != "y":
                return

        for _, new in to_upgrade:
            self._install_one(new["name"] if "name" in new else new)

    # ── search ──────────────────────────────────────────────────
    def search(self, term: str):
        results = self.repo.search(term)
        if not results:
            print(f"  No packages found for: {term}")
            return
        print(f"\n  {len(results)} result(s):\n")
        for r in results:
            inst = f" {C.G}[installed]{C.N}" if self.db.is_installed(r["name"]) else ""
            print(f"  {C.W}{r['name']}{C.N}{inst}")
            print(f"    {r.get('version','?')}-{r.get('release','?')} — {r.get('summary','')}")
        print()

    # ── list installed ───────────────────────────────────────────
    def list_installed(self):
        pkgs = self.db.all()
        if not pkgs:
            print("  No packages installed.")
            return
        print(f"\n  {len(pkgs)} installed package(s):\n")
        for p in sorted(pkgs, key=lambda x: x.name):
            print(f"  {C.G}{p.name:<30}{C.N} {p.evr:<20} {p.summary[:50]}")
        print()

    # ── info ─────────────────────────────────────────────────────
    def info(self, name: str):
        inst = self.db.get(name)
        repo = self.repo.find(name)
        meta = inst or (PackageMeta.from_dict({**repo, "release": repo.get("release",1)}) if repo else None)
        if not meta:
            err(f"Package not found: {name}")
        print(f"""
  {C.W}{C.BOLD}{meta.name}{C.N}  {meta.evr}
  {'─'*50}
  Summary    : {meta.summary}
  License    : {meta.license}
  Homepage   : {meta.homepage or '—'}
  Arch       : {meta.arch}
  Depends    : {', '.join(meta.depends) or '—'}
  Conflicts  : {', '.join(meta.conflicts) or '—'}
  Status     : {'installed' if inst else 'not installed'}
  Description:
    {meta.description or '—'}
""")

    # ── build from meowspec.toml ──────────────────────────────────
    def build(self, specfile: Path, output_dir: Path):
        section(f"Building from {specfile}")

        if not specfile.exists():
            err(f"Spec file not found: {specfile}")

        meta = PackageMeta.from_toml(specfile)
        spec_dir = specfile.parent

        info(f"Package : {meta.name}-{meta.evr}")
        info(f"Source  : {meta.source_url or 'local'}")

        BUILD_DIR.mkdir(parents=True, exist_ok=True)
        work   = BUILD_DIR / f"{meta.name}-{meta.version}"
        stage  = BUILD_DIR / f"{meta.name}-stage"
        shutil.rmtree(work,  ignore_errors=True)
        shutil.rmtree(stage, ignore_errors=True)
        work.mkdir(parents=True)
        stage.mkdir(parents=True)

        # Download + verify source
        if meta.source_url:
            src_file = BUILD_DIR / Path(meta.source_url).name
            if not src_file.exists():
                info("Downloading source...")
                urllib.request.urlretrieve(meta.source_url, src_file)
            if meta.sha256 and _sha256(src_file) != meta.sha256:
                err("sha256 mismatch on source tarball!")
            ok("Source verified")

            # Extract
            if tarfile.is_tarfile(src_file):
                with tarfile.open(src_file) as tf:
                    tf.extractall(work)
                # Move into top-level dir if archive has a single root dir
                contents = list(work.iterdir())
                if len(contents) == 1 and contents[0].is_dir():
                    work = contents[0]

        # Run build script if provided
        build_sh = spec_dir / "build.sh"
        if build_sh.exists():
            info("Running build.sh...")
            env = os.environ.copy()
            env.update({
                "MEOW_WORK":  str(work),
                "MEOW_STAGE": str(stage),
                "MEOW_NAME":  meta.name,
                "MEOW_VER":   meta.version,
                "MEOW_REL":   str(meta.release),
            })
            result = subprocess.run(
                ["bash", str(build_sh)],
                cwd=str(work),
                env=env,
            )
            if result.returncode != 0:
                err("build.sh failed!")
            ok("Build complete")
        else:
            warn("No build.sh found — assuming pre-staged files in ./stage/")
            if (spec_dir / "stage").exists():
                shutil.copytree(spec_dir / "stage", stage, dirs_exist_ok=True)

        # Pack
        MeowArchive.pack(
            meta       = meta,
            files_dir  = stage,
            output_dir = output_dir,
            install_hook = spec_dir / "install.sh" if (spec_dir / "install.sh").exists() else None,
            remove_hook  = spec_dir / "remove.sh"  if (spec_dir / "remove.sh").exists()  else None,
        )


# ── HELPERS ──────────────────────────────────────────────────────

def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


# ── CLI ──────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        prog="meow",
        description="meow — the re-pisi package manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="cmd", metavar="<command>")

    # install
    p = sub.add_parser("install", help="install packages")
    p.add_argument("packages", nargs="+")
    p.add_argument("-y", "--yes", action="store_true")

    # remove
    p = sub.add_parser("remove", aliases=["rm"], help="remove packages")
    p.add_argument("packages", nargs="+")
    p.add_argument("-y", "--yes", action="store_true")

    # update
    sub.add_parser("update", help="sync repo indexes")

    # upgrade
    p = sub.add_parser("upgrade", help="upgrade installed packages")
    p.add_argument("-y", "--yes", action="store_true")

    # search
    p = sub.add_parser("search", help="search packages")
    p.add_argument("term")

    # list
    sub.add_parser("list", help="list installed packages")

    # info
    p = sub.add_parser("info", help="show package details")
    p.add_argument("package")

    # build
    p = sub.add_parser("build", help="build .meow from meowspec.toml")
    p.add_argument("specfile", type=Path)
    p.add_argument("-o", "--output", type=Path, default=Path("."),
                   help="output directory (default: .)")

    # repo
    repo_p = sub.add_parser("repo", help="manage repositories")
    repo_sub = repo_p.add_subparsers(dest="repo_cmd")
    repo_sub.add_parser("list", help="list available repositories")
    p = repo_sub.add_parser("enable", help="enable a repository")
    p.add_argument("name")
    p = repo_sub.add_parser("disable", help="disable a repository")
    p.add_argument("name")

    args = parser.parse_args()
    if not args.cmd:
        parser.print_help(); sys.exit(0)

    m = Meow()

    match args.cmd:
        case "install":
            m.install(args.packages, yes=args.yes)
        case "remove" | "rm":
            m.remove(args.packages, yes=args.yes)
        case "update":
            m.update()
        case "upgrade":
            m.upgrade(yes=args.yes)
        case "search":
            m.search(args.term)
        case "list":
            m.list_installed()
        case "info":
            m.info(args.package)
        case "build":
            m.build(args.specfile, args.output)
        case "repo":
            match args.repo_cmd:
                case "list":
                    m.repo.list_repos()
                case "enable":
                    m.repo.enable(args.name)
                case "disable":
                    m.repo.disable(args.name)
                case _:
                    repo_p.print_help()
        case _:
            parser.print_help()


if __name__ == "__main__":
    main()
