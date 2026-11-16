---
name: deploy
description: 把仓库 configs/home/ 部署为 ~/ 符号链接;何时 apply vs check、备份区语义、服务启用
---

# deploy

## 何时用

- **apply**:改了 `configs/home/**` 或 manifest 后,让本机生效;或新机器 bootstrap 后首次部署。
- **check**:任何时候想确认部署健康(链接指向、exec 位、服务状态、niri/noctalia 配置合法性);CI/排障自检。

## 步骤

1. 确认目标机匹配:manifest `[meta].machine == hostname`(deploy.py 自动校验,不符直接退出)。
2. `python3 ~/.dotfiles/scripts/deploy.py apply`
   - 已是正确符号链接 → SKIP;指向别处 → 删后重建;
   - 真实文件/目录 → 整体移入 `~/.dotfiles-backup/<UTC时间戳>/<path>` 再建**绝对符号链接**;
   - 收尾自动 `systemctl --user daemon-reload`,`enable_now` 逐个 `enable --now`。
   - 备份位置可用 `--backup-dir <dir>` 覆盖。
3. 幂等:中断/部分失败直接重跑,已完成条目 SKIP;失败条目修复(如源缺 exec 位 → `chmod +x` 仓库源)后重跑。

## 验证

```
python3 ~/.dotfiles/scripts/deploy.py check   # 期望全 PASS,exit 0
systemctl --user is-enabled empty-workspace-widgets.service sshx-agent.service honor-sleep-test-guard.service  # 均 enabled
```

注意:`noctalia.service`/`deepseek-harness.service` 不 enable——前者由 niri spawn-at-startup 拉起,后者按需启动;check 不校验它们的 enabled 状态。
