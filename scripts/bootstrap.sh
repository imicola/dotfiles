#!/usr/bin/env bash
# bootstrap.sh — 新机器复现环境(本机已就绪,无需运行)。只装 pacman 包与 git 来源物,
# 不自动下载 [external] 清单里的任何手工二进制。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---- 从 manifest.toml 读包列表 / shell 来源 / external 清单 ----
mapfile -t PKGS < <(python3 - "$REPO_ROOT/manifest.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], "rb") as f:
    m = tomllib.load(f)
for p in m.get("packages", {}).get("pacman", []):
    print(p)
PY
)
OMZ_REPO=$(python3 -c 'import tomllib,sys; s=tomllib.load(open(sys.argv[1],"rb"))["shell"]["oh-my-zsh"]; print(s["repo"], s["commit"])' "$REPO_ROOT/manifest.toml")
OMZ_URL=${OMZ_REPO% *}; OMZ_COMMIT=${OMZ_REPO##* }
SHIP_REPO=$(python3 -c 'import tomllib,sys; s=tomllib.load(open(sys.argv[1],"rb"))["shell"]["oh-my-zsh"]["themes"]["spaceship-prompt"]; print(s["repo"], s["commit"])' "$REPO_ROOT/manifest.toml")
SHIP_URL=${SHIP_REPO% *}; SHIP_COMMIT=${SHIP_REPO##* }

# ---- 1. pacman 官方仓库包 ----
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# ---- 2. oh-my-zsh(固定 commit) ----
if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
  echo "SKIP    ~/.oh-my-zsh 已存在"
else
  git clone "$OMZ_URL" "$HOME/.oh-my-zsh"
  git -C "$HOME/.oh-my-zsh" checkout "$OMZ_COMMIT"
fi

# ---- 3. spaceship-prompt 主题(固定 commit) ----
if [[ -d "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/.git" ]]; then
  echo "SKIP    spaceship-prompt 已存在"
else
  git clone "$SHIP_URL" "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
  git -C "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" checkout "$SHIP_COMMIT"
fi

# ---- 4. autojump(install.py 装入 ~/.autojump) ----
if [[ -d "$HOME/.autojump" ]]; then
  echo "SKIP    ~/.autojump 已存在"
else
  tmp=$(mktemp -d)
  git clone https://github.com/wting/autojump.git "$tmp/autojump"
  python3 "$tmp/autojump/install.py"
  rm -rf "$tmp"
fi

# ---- 5. git 身份提示(仓库不含真实邮箱) ----
if [[ ! -f "$HOME/.gitconfig-local" ]]; then
  echo "提示: .gitconfig 通过 include 引用 ~/.gitconfig-local,请创建个人身份:"
  echo "  printf '[user]\n\temail = you@example.com\n' > ~/.gitconfig-local"
fi

# ---- 6. 手工二进制提示(不自动下载) ----
echo
echo "以下为 [external] 手工下载物,请按 docs/architecture.md 手动安装:"
python3 - "$REPO_ROOT/manifest.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], "rb") as f:
    m = tomllib.load(f)
for b in m.get("external", {}).get("binaries", []):
    print(f"  - {b}")
PY
echo
echo "bootstrap 完成。下一步: python3 $REPO_ROOT/scripts/deploy.py apply"
