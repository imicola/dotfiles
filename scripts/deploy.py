#!/usr/bin/env python3
"""deploy.py — 把仓库 configs/home/ 部署为 $HOME 下的符号链接(幂等)。

用法:
  deploy.py apply [--backup-dir <dir>]   建链 + daemon-reload + enable --now
  deploy.py check                        校验链接/权限/服务/配置,全过 exit 0
"""
from __future__ import annotations

import argparse
import os
import shutil
import socket
import subprocess
import sys
import time
import tomllib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
HOME = Path.home()
MANIFEST = REPO_ROOT / "manifest.toml"


def load_manifest() -> dict:
    with open(MANIFEST, "rb") as f:
        return tomllib.load(f)


def check_machine(meta: dict) -> None:
    host = socket.gethostname()
    if host != meta.get("machine"):
        sys.exit(f"ERROR: 目标机为 {meta.get('machine')!r},当前主机 {host!r},拒绝执行")


def link_paths(m: dict) -> list[str]:
    links = [l["path"] for l in m.get("link", [])]
    if not links:
        sys.exit("ERROR: manifest.toml 中没有 [[link]] 条目")
    return links


def run(cmd: list[str]) -> tuple[int, str]:
    p = subprocess.run(cmd, capture_output=True, text=True)
    return p.returncode, (p.stdout + p.stderr).strip()


def print_table(rows: list[tuple[str, str, str]]) -> None:
    """rows: (status, path, detail)"""
    width = max(len(s) for s, _, _ in rows)
    for status, path, detail in rows:
        line = f"{status:<{width}}  {path}"
        if detail:
            line += f"  ({detail})"
        print(line)


# ---------------------------------------------------------------- apply ----

def cmd_apply(m: dict, backup_dir: Path | None) -> int:
    backup_root = backup_dir or (HOME / ".dotfiles-backup")
    ts = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    backup_ts = backup_root / ts
    rows: list[tuple[str, str, str]] = []
    failed = False

    for path in link_paths(m):
        # resolve():源可能是仓库内相对符号链接(如 chatgpt → chatgpt-proxy),
        # 部署直接指向最终目标,保证 readlink -f 与 check 的比较稳定。
        src = (REPO_ROOT / "configs/home" / path).resolve()
        dst = HOME / path

        if not src.exists():
            rows.append(("FAIL", path, "仓库源缺失,先跑 scripts/collect.sh"))
            failed = True
            continue

        # .local/bin 下条目必须有 exec 位
        if path.startswith(".local/bin/") and not os.access(src, os.X_OK):
            rows.append(("FAIL", path, "源缺 exec 位"))
            failed = True
            continue

        dst.parent.mkdir(parents=True, exist_ok=True)
        status, detail = "OK", ""

        if dst.is_symlink():
            if Path(os.path.realpath(dst)) == src:
                status = "SKIP"
            else:
                dst.unlink()  # 指向别处:删后重建
        elif dst.exists():
            # 真实文件/目录 → 整体移入备份区
            target = backup_ts / path
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(dst), str(target))
            status, detail = "BACKUP", f"原件 → {target}"
        # 不存在 → 直接建

        if status != "SKIP":
            os.symlink(src, dst)
        rows.append((status, path, detail))

    print_table(rows)

    if failed:
        sys.exit("ERROR: 存在失败条目,未执行服务操作;修复后重跑(幂等)")

    print("systemctl --user daemon-reload ...")
    rc, out = run(["systemctl", "--user", "daemon-reload"])
    if rc != 0:
        print(f"FAIL daemon-reload: {out}")
        return 1

    services = m.get("services", {})
    for unit in services.get("enable_now", []):
        rc, out = run(["systemctl", "--user", "enable", "--now", unit])
        print(f"{'OK' if rc == 0 else 'FAIL'}  enable --now {unit}" + (f": {out}" if rc else ""))
        if rc:
            failed = True
    for unit in services.get("daemon_reload_only", []):
        print(f"SKIP  enable (仅 daemon-reload): {unit}")

    return 1 if failed else 0


# ---------------------------------------------------------------- check ----

def cmd_check(m: dict) -> int:
    rows: list[tuple[bool, str, str]] = []  # (ok, name, detail)

    def record(ok: bool, name: str, detail: str = "") -> None:
        rows.append((ok, name, detail))

    for path in link_paths(m):
        src = (REPO_ROOT / "configs/home" / path).resolve()
        dst = HOME / path
        if not dst.is_symlink():
            record(False, f"link {path}", "目标不是符号链接")
        elif Path(os.path.realpath(dst)) != src:
            record(False, f"link {path}", f"指向 {os.path.realpath(dst)}")
        else:
            record(True, f"link {path}")

        if path.startswith(".local/bin/"):
            executable = os.access(src, os.X_OK)
            record(executable, f"exec {path}", "" if executable else "缺 exec 位")

    for unit in m.get("services", {}).get("enable_now", []):
        rc, out = run(["systemctl", "--user", "is-enabled", unit])
        record(rc == 0 and out == "enabled", f"unit {unit}", out)

    for tool in ("niri", "noctalia", "kitty", "zsh"):
        found = shutil.which(tool) is not None
        record(found, f"bin {tool}", "" if found else "未安装")

    rc, out = run(["niri", "validate"])
    record(rc == 0, "niri validate", out)
    rc, out = run(["noctalia", "config", "validate"])
    record(rc == 0, "noctalia config validate", out)

    width = max(len(name) for _, name, _ in rows)
    for ok, name, detail in rows:
        print(f"{'PASS' if ok else 'FAIL'}  {name:<{width}}  {detail}".rstrip())
    passed = sum(1 for ok, *_ in rows if ok)
    print(f"\n{passed}/{len(rows)} PASS")
    return 0 if passed == len(rows) else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["apply", "check"])
    parser.add_argument("--backup-dir", type=Path, default=None,
                        help="apply 时备份目录(默认 ~/.dotfiles-backup)")
    args = parser.parse_args()

    m = load_manifest()
    check_machine(m.get("meta", {}))
    if args.command == "apply":
        return cmd_apply(m, args.backup_dir)
    return cmd_check(m)


if __name__ == "__main__":
    sys.exit(main())
