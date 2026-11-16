#!/usr/bin/env bash
# collect.sh — 把 manifest.toml 声明的 ~/ 路径导入仓库 configs/home/(幂等)。
# 用法: collect.sh [--force]   (--force 覆盖仓库内已有副本)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

# 从 manifest.toml 读取所有 [[link]] path(单一事实源,不在脚本里重复清单)
mapfile -t LINK_PATHS < <(python3 - "$REPO_ROOT/manifest.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], "rb") as f:
    m = tomllib.load(f)
for link in m.get("link", []):
    print(link["path"])
PY
)

if [[ ${#LINK_PATHS[@]} -eq 0 ]]; then
  echo "ERROR: manifest.toml 中没有 [[link]] 条目" >&2
  exit 1
fi

missing=()
copied=0
skipped=0
for p in "${LINK_PATHS[@]}"; do
  src="$HOME/$p"
  dst="$REPO_ROOT/configs/home/$p"

  # ~/path 不存在 ⇒ manifest 漂移,收场报错
  if [[ ! -e "$src" && ! -L "$src" ]]; then
    missing+=("$p")
    continue
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ $FORCE -eq 1 ]]; then
      rm -rf "$dst"
    else
      echo "SKIP    configs/home/$p (已存在,--force 覆盖)"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  mkdir -p "$(dirname "$dst")"
  # cp -a 保留 exec 位、时间戳与相对符号链接(如 chatgpt → chatgpt-proxy)
  cp -a "$src" "$dst"

  # *.bak-* 不入库
  while IFS= read -r f; do
    rm -f "$f"
    echo "DROP    ${f#"$REPO_ROOT"/} (*.bak-*)"
  done < <(find "$dst" -name '*.bak-*')

  echo "OK      $p"
  copied=$((copied + 1))
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: manifest 声明但 \$HOME 缺失(manifest 漂移,先修正 manifest.toml):" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "collect 完成: 导入 $copied,跳过 $skipped"
