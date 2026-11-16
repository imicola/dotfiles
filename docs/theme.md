# 主题系统(当前生效:壁纸取色)

**当前配色来自壁纸取色**(模式 `wallpaper soft`,`desktop-tools check` 末行 / `noctalia msg color-scheme-get` 可查)。
自建紫阳花夜配色是备选方案,随时可切回;`config.toml` 里的 `custom_palette = "HydrangeaNight"` 只是 custom 模式的指向,不代表当前模式。

## 两种配色来源

| 模式 | 命令 | 颜色来源 |
|---|---|---|
| **壁纸取色(当前)** | `desktop-tools theme-wallpaper`(= `color-scheme-set wallpaper soft`) | 当前壁纸,noctalia 原生取色 |
| 自建紫阳花夜 | `desktop-tools theme-original`(= `color-scheme-set custom HydrangeaNight`) | `palettes/HydrangeaNight.json` |

## 派生链

`desktop-tools theme-refresh`(`noctalia msg templates-apply`)把**当前生效配色**派生到:

```
desktop-tools theme-refresh        # = noctalia msg templates-apply
    ├── kitty  ~/.config/kitty/themes/noctalia.conf        ← 入库;当前内容为壁纸取色派生物
    ├── kando  ~/.config/kando/menu-themes/morandi         ← 不入库,可再生
    └── 系统   ~/.local/share/color-schemes/noctalia.colors ← 不入库,可再生
```

壁纸取色模式下改壁纸 → `theme-wallpaper` 重新取色 → `theme-refresh` 派生,kitty 侧 diff 可见。

## kitty include 链

`kitty.conf` 末尾按序 include,后者覆盖前者:

```
kitty.conf
 └─ include hydrangea-night.conf              # 基础视觉覆盖
     └─ include themes/hydrangea-night-pinned.conf   # 钉住的固定值
         └─ include themes/noctalia.conf              # templates-apply 派生(随当前生效配色变)
```

改配色(palette 或壁纸取色)后跑 `theme-refresh`,`git diff configs/home/.config/kitty/themes/noctalia.conf` 应看到派生变更。

## 硬编码色(配色变更后需手动同步)

以下文件颜色**不随 templates-apply 派生**,配色变更后手动对齐:

- `configs/home/.config/fuzzel/fuzzel.ini`
- `configs/home/.config/mako/config`

## 圆角图标生成

```
colloid-icon <图片> <输出.png> [--crop | --bg '#rrggbb']
```

从图片取底色生成 colloid 风格圆角图标;`--crop` 图片铺满整图标,`--bg` 指定标志背后底色(六位 hex)。

## 资产绝对路径

壁纸 `~/.local/share/hydrangea-night/wallpaper.jpg`、头像 `claude-avatar.jpg` 被 noctalia `config.toml` 以绝对路径引用;光标主题 `HydrangeaNight-cursors` 在 `~/.local/share/icons`(external,见 architecture.md)。
