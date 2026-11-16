---
name: config-change
description: 修改任一受管配置(niri/noctalia/kitty/zshrc/服务/脚本)的标准流程
---

# config-change

## 何时用

需要改动任何受管配置文件内容时。

## 步骤

1. **只编辑仓库副本** `~/.dotfiles/configs/home/<path>`,**禁止**直接改 `~` 下受管路径(会被下次 deploy 覆盖/漂移)。
2. 新增文件属于新路径的,先在 `manifest.toml` 加 `[[link]]`(参见 onboard-config 技能)。
3. `python3 ~/.dotfiles/scripts/deploy.py apply`(链接已存在则内容即时生效,apply 保证结构一致)。
4. 对应校验:
   - niri:`niri validate`(niri 会热重载)
   - noctalia:`noctalia config validate`
   - kitty:`kitty --debug-config`
   - systemd unit:改后 apply 自动 daemon-reload
   - shell:`zsh -i -c 'echo ok'`
5. `git -C ~/.dotfiles add -A && git -C ~/.dotfiles commit -m "<配置名>: <改动>"`

## 验证

`python3 ~/.dotfiles/scripts/deploy.py check` 全 PASS;界面实际生效(新 kitty 窗口 / `desktop-tools reload`)。
