# HydrangeaNight · niri 桌面配置

[![Arch](https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=fff)](https://archlinux.org/)
[![niri](https://img.shields.io/badge/niri-26.04-fdb414)](https://github.com/YaLTeR/niri)
[![noctalia](https://img.shields.io/badge/noctalia-5.5.0-8b5cf6)](https://github.com/noctalia-dev/noctalia)
[![kitty](https://img.shields.io/badge/kitty-0.50-6db9f7)](https://sw.kovidgoyal.net/kitty/)
[![License: MIT](https://img.shields.io/badge/License-MIT-89b4fa.svg)](LICENSE)

一套跑在 EndeavourOS(Arch 系)上的 Wayland 滚动平铺桌面:**niri** 作 compositor,**noctalia** 作 shell,配色随壁纸取色、也可一键切回自建的「紫阳花夜」主题。所有配置以符号链接部署——改仓库、跑一条命令、立即生效。

## 桌面一览

| 组件 | 软件 | 说明 |
|---|---|---|
| Compositor | [niri](https://github.com/YaLTeR/niri) 26.04 | 滚动平铺,`config.kdl` 声明式配置,热重载 |
| Shell | [noctalia](https://github.com/noctalia-dev/noctalia) 5.5.0 | 锁屏 / 通知 / 桌面小组件 / 主题派生 |
| 终端 | [kitty](https://sw.kovidgoyal.net/kitty/) 0.50 | 四层 include 链组织主题 |
| 编辑器 | Neovim(LazyVim) | `lazy-lock.json` 锁定插件版本 |
| Shell | zsh + oh-my-zsh + spaceship-prompt | 插件走 pacman 源,固定 commit |
| 输入法 | fcitx5 + rime(雾凇拼音) | 自定义短语与方案覆写 |
| 启动器 | fuzzel | 通知 mako · 文件 yazi · 监控 btop / fastfetch |
| 菜单 | kando | 径向菜单,niri 快捷键联动 |
| 主题 | 壁纸取色(当前)/ HydrangeaNight | kitty / kando / 系统配色自动派生 |

## 仓库结构

```
.
├── manifest.toml        # 唯一事实源:哪些路径被托管、装哪些包、启哪些服务
├── configs/home/        # $HOME 的镜像;configs/home/<p> ⇄ ~/<p>
├── scripts/
│   ├── bootstrap.sh     # 新机器:装包 + oh-my-zsh + spaceship + autojump
│   ├── deploy.py        # apply 建符号链接 / check 全量体检
│   └── collect.sh       # 把 ~ 下现状导入仓库
├── docs/                # architecture · theme · troubleshooting
├── skills/              # 常见操作的标准化流程
├── AGENTS.md            # 给 AI 助手的仓库操作规范
├── README.md
└── LICENSE              # MIT
```

## 快速开始

> 面向 Arch 系发行版;`manifest.toml` 默认只允许在 `imicola-fmbp` 这台机器上部署,换机先改 `[meta].machine`。

```bash
git clone <repo> ~/.dotfiles && cd ~/.dotfiles

# 1. 装依赖(pacman 官方仓库 + oh-my-zsh/spaceship/autojump 固定 commit)
bash scripts/bootstrap.sh

# 2. 建 git 身份(仓库不含真实邮箱)
printf '[user]\n\temail = you@example.com\n' > ~/.gitconfig-local

# 3. 部署:~/ 下的原配置会整体移入 ~/.dotfiles-backup/<时间戳>/,不会丢
python3 scripts/deploy.py apply

# 4. 体检:链接、可执行位、服务、niri/noctalia 配置全量校验
python3 scripts/deploy.py check
```

## 日常命令

| 命令 | 用途 |
|---|---|
| `python3 scripts/deploy.py apply` | 改完仓库配置后生效(幂等,冲突自动备份) |
| `python3 scripts/deploy.py check` | 全量体检,全 PASS 退出码 0 |
| `desktop-tools check` | `niri validate` + `noctalia config validate` + 当前配色 |
| `desktop-tools reload` | 配置改了没生效的统一重载入口 |
| `desktop-tools theme-wallpaper` | 从当前壁纸取色,整套配色跟随 |
| `desktop-tools theme-original` | 切回自建 HydrangeaNight 配色 |
| `desktop-tools theme-refresh` | 把当前配色派生到 kitty / kando / 系统色 |
| `desktop-tools input-reload` | 重载 fcitx5(rime 改动后) |

## 主题系统

当前模式为**壁纸取色**(`color-scheme-set wallpaper soft`):noctalia 从壁纸提取柔和色板,`theme-refresh` 一键派生到 kitty 主题、kando 菜单和系统 color-scheme;`palettes/HydrangeaNight.json` 是自建的紫阳花夜配色,`theme-original` 随时切回。

kitty 侧由四层 include 组成,后者覆盖前者:

```
kitty.conf
 └─ hydrangea-night.conf            # 基础视觉覆盖
     └─ themes/hydrangea-night-pinned.conf   # 钉住的固定值
         └─ themes/noctalia.conf             # 自动派生,随配色更新
```

另有 `colloid-icon` 从任意图片取底色生成圆角图标:`colloid-icon <图> <out.png> [--crop|--bg '#rrggbb']`。

细节见 [docs/theme.md](docs/theme.md)。

## 文档

- [docs/architecture.md](docs/architecture.md) — 启动链、用户服务、代理体系、外部二进制清单
- [docs/theme.md](docs/theme.md) — 配色模式、派生链、kitty include、硬编码色同步
- [docs/troubleshooting.md](docs/troubleshooting.md) — 常见故障速查

## 致谢

- [LanRhyme/dotfiles](https://github.com/LanRhyme/dotfiles) — `desktop-tools` 快捷命令的灵感来源
- [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) · [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt) · [LazyVim](https://github.com/LazyVim/LazyVim) · [雾凇拼音](https://github.com/gaboolic/rime-frost)

## License

[MIT](LICENSE) © 2026 imicola
