---
name: onboard-config
description: 把一个新应用/新文件纳入仓库托管:粒度判断、加 manifest 条目、导入、忽略运行时产物
---

# onboard-config

## 何时用

机器上出现(或新装)一个想纳入版本管理的配置。

## 步骤

1. **判断粒度**(决定整目录还是单文件):
   - 应用会向目录写**运行时状态**(缓存/锁/会话,如 kando Singleton*、fcitx5、rime build/)→ **单文件**托管,只收静态配置文件;
   - 目录**纯静态**(如 niri、kitty、noctalia、scripts)→ **整目录**。
2. 在 `manifest.toml` 追加 `[[link]] path = "<相对 $HOME 路径>"`(单一事实源,先加条目再导入)。
3. `bash ~/.dotfiles/scripts/collect.sh` 导入(重复路径 `--force` 覆盖;`*.bak-*` 自动丢弃)。
4. 运行时产物:确认 `.gitignore` 覆盖(现有 `*.bak-*`、`*.zwc`),必要时追加模式;不要提交状态文件。
5. `python3 ~/.dotfiles/scripts/deploy.py apply` 生效(原真实路径自动进备份区)。
6. 更新文档:AGENTS.md 仓库地图(如有新类别)、docs/architecture.md(服务/启动链/代理相关时)、docs/theme.md(主题相关时)。
7. commit。

## 验证

`python3 ~/.dotfiles/scripts/deploy.py check` 出现新条目 PASS;应用读取新路径正常工作;`git status` 干净。

## 已知 diff 噪音(不回滚)

btop 退出重写 `btop.conf`;桌面应用改写 `mimeapps.list`。
