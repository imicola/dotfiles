-- 透明背景:让终端(kitty background_opacity / background_blur)透出来
-- 生效路径: ~/.config/nvim/lua/plugins/transparent.lua

-- 需要抹掉底色(guibg/ctermbg)的高亮组,保留前景色与语义型背景
-- (PmenuSel / CursorLine / Diff* 等刻意不动,避免丢失可读性)
local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "EndOfBuffer",
  "SignColumn",
  "LineNr",
  "LineNrAbove",
  "LineNrBelow",
  "Folded",
  "FoldColumn",
  "WinSeparator",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "WinBar",
  "WinBarNC",
  -- 侧栏 / 浮窗插件
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeEndOfBuffer",
  "NeoTreeWinSeparator",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "SnacksNormal",
  "SnacksNormalNC",
  "SnacksWinBar",
  "LazyNormal",
  "MasonNormal",
}

local function clear_bg()
  for _, name in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl and next(hl) then
      hl.bg = nil
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

-- 注册在 spec 顶层:早于配色加载,换配色后自动重新生效
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true }),
  callback = clear_bg,
  desc = "透明背景:配色切换后重新抹掉底色",
})
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(clear_bg)
  end,
})

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    -- 将来切换到 catppuccin 时同样透明
    "catppuccin/nvim",
    optional = true,
    opts = { transparent_background = true },
  },
}
