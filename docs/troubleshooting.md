# 故障排查

| 症状 | 处置 |
|---|---|
| shell 挂了(noctalia 不工作/锁屏异常) | `systemctl --user status noctalia`;noctalia 由 niri spawn-at-startup 拉起,不要手动 enable |
| 配置改了没生效 | `desktop-tools reload`;niri 改动可 `niri validate` 后等热重载;kitty 新窗口即生效 |
| deploy 冲突 / 改坏了想找回原件 | `~/.dotfiles-backup/<UTC时间戳>/<原路径>`,apply 覆盖真实文件前必先进备份区 |
| 输入法不生效 | `desktop-tools input-reload`(= `fcitx5-remote -r`);环境变量来自 niri `environment {}` + `environment.d/60-fcitx5.conf`(XMODIFIERS/QT_IM_MODULE) |
| rime 词库/方案改动无效 | 改的是 `*.custom.yaml` 后需重启 fcitx5 重新部署(fcitx5 配置目录里的"重新部署"或注销重登) |
| kando 菜单异常/陈旧 Singleton 锁 | `desktop-tools kando-theme-refresh`,其 pid/exe 校验逻辑会清理陈旧锁;Singleton*/session/ipc-info 为运行时产物,不入库 |
| 网络异常 | FlClash 是否在跑:`ss -ltn | grep 7897`;代理三处消费点见 architecture.md(environment.d 90-proxy / proxy.sh / zshrc 自动 proxy_on) |
| noctalia 不可达时锁屏失败 | `niri-lock` 回退到 swaylock |
| btop 退出重写 btop.conf / mimeapps.list 被改写 | 预期 diff 噪音,不回滚;确认无意义可 `git checkout -- configs/home/<path>` |

## 通用自检

```
python3 ~/.dotfiles/scripts/deploy.py check   # 全 PASS = 链接/服务/配置健康
desktop-tools check                            # niri + noctalia 校验 + 当前配色
```
