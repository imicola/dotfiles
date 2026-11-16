# AGENTS.md — dotfiles 仓库操作手册

本仓库以**符号链接**托管本机(EndeavourOS,`imicola-fmbp`)桌面配置:niri + noctalia + kitty + oh-my-zsh + fcitx5/rime + 自写脚本。
生效路径 = 仓库内文件:改仓库 → `deploy.py apply` → 生效。

## 仓库地图

| 路径 | 内容 |
|---|---|
| `manifest.toml` | **唯一事实源**:53 条 `[[link]]`、服务启用、包列表、external 清单 |
| `configs/home/` | `$HOME` 的镜像;`configs/home/<p>` ⇄ `~/<p>`(deploy 规则) |
| `scripts/collect.sh` | 把 `~/` 现状导入仓库(onboard 新配置用) |
| `scripts/deploy.py` | `apply`(建链)/ `check`(全量校验,exit 0 = 健康) |
| `scripts/bootstrap.sh` | 新机器复现(本机勿跑) |
| `docs/` | architecture / theme / troubleshooting 知识库 |
| `skills/` | deploy / config-change / theme-update / onboard-config 技能 |
| `README.md` / `LICENSE` | 开源说明与 MIT 许可证 |

## 黄金规则

1. **只改 `configs/home/**`**,禁止直接改 `~` 下受管路径——那会被下次 deploy 覆盖或造成漂移。
2. **manifest.toml 是唯一事实源**:新配置必须先加 `[[link]]` 条目,再 collect/deploy。
3. **密钥永不入库**:`~/.ssh`、`~/.config/gh/hosts.yml`、`~/.npmrc`、浏览器/IM 状态目录、`~/.local/bin` 里的二进制(omp/sshx/tree-sitter 及 node_modules 链接)、`~/.oh-my-zsh` 本体、`~/.autojump`、`*.bak-*`、kando 运行时(Singleton*/session/ipc-info)、rime `build/` 与共享词库、zsh history/zcompdump。
4. **任何改动后**:`python3 ~/.dotfiles/scripts/deploy.py apply` + 下表校验命令,然后 git commit。

## 命令速查

| 命令 | 用途 |
|---|---|
| `python3 scripts/deploy.py apply` | 部署链接 + daemon-reload + enable --now(冲突原件进 `~/.dotfiles-backup/<UTC时间戳>/`) |
| `python3 scripts/deploy.py check` | 全量校验(链接/exec/服务/`niri validate`/`noctalia config validate`),全 PASS exit 0 |
| `bash scripts/collect.sh [--force]` | 按 manifest 把 `~/` 现状导入仓库 |
| `bash scripts/bootstrap.sh` | 仅新机器:pacman + omz + spaceship + autojump |
| `desktop-tools check` | niri validate + noctalia config validate + 打印当前配色 |
| `desktop-tools reload` | 配置改了没生效时的统一重载入口 |
| `desktop-tools theme-refresh` | noctalia templates-apply,派生 kitty/kando/color-schemes |
| `desktop-tools input-reload` | fcitx5 重载(rime 改动后) |
| `niri validate` / `noctalia config validate` | 单项配置校验 |
| `kitty --debug-config` | kitty 配置校验 |

## 索引

- 架构/启动链/代理体系/external 安装:`docs/architecture.md`
- 紫阳花夜主题系统(真源、派生链、硬编码色):`docs/theme.md`
- 故障排查:`docs/troubleshooting.md`
- 技能:`skills/deploy/`、`skills/config-change/`、`skills/theme-update/`、`skills/onboard-config/`
