---
name: theme-update
description: 更新紫阳花夜配色(palette → 派生文件 → 硬编码手动同步)与壁纸取色切换
---

# theme-update

## 步骤

### 切换配色模式(当前生效:壁纸取色 wallpaper soft)

- 从当前壁纸取色:`desktop-tools theme-wallpaper` ← 当前生效模式
- 切回自建配色:`desktop-tools theme-original`(palette = `palettes/HydrangeaNight.json`)
- 切换后跑 `desktop-tools theme-refresh` 派生 kitty/kando/系统色。

### 调整自建 palette

1. 编辑 `configs/home/.config/noctalia/palettes/HydrangeaNight.json`。
2. `desktop-tools theme-refresh`(= `noctalia msg templates-apply`)派生:
   - kitty `themes/noctalia.conf` — **入库**,`git diff` 应看到变更;
   - kando `menu-themes/morandi`、`~/.local/share/color-schemes/noctalia.colors` — 不入库,可再生。
3. **手动同步硬编码色**(不随派生):`configs/home/.config/fuzzel/fuzzel.ini`、`configs/home/.config/mako/config`。
4. `python3 ~/.dotfiles/scripts/deploy.py apply` → commit。

### 圆角图标

`colloid-icon <图片> <out.png> [--crop|--bg '#rrggbb']`

## 验证

- `desktop-tools theme-refresh` 输出 templates-apply 成功;
- `git -C ~/.dotfiles status --short` 只出现预期派生文件变更(kitty themes/noctalia.conf);
- 新 kitty 窗口颜色正确;`desktop-tools check` 打印当前配色。
