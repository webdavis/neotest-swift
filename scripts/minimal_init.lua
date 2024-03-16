-- Credit: https://github.com/nvim-neotest/neotest-go/pull/71

-- This script creates a separate XDG path which avoids Lazy.nvim taking control of the
-- loading.
local M = {}

function M.path_root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

---@param plugin string
function M.download(plugin)
  local name = plugin:match(".*/(.*)")
  local package_root = M.path_root(".tests/site/pack/deps/start/")
  if not vim.loop.fs_stat(package_root .. name) then
    print("Installing " .. plugin)
    vim.fn.mkdir(package_root, "p")
    vim.fn.system({
      "git",
      "clone",
      "--depth=1",
      "https://github.com/" .. plugin .. ".git",
      package_root .. "/" .. name,
    })
  end
end

function M.setup()
  M.download("nvim-lua/plenary.nvim")
  M.download("antoinemadec/FixCursorHold.nvim")
  M.download("nvim-treesitter/nvim-treesitter")
  M.download("neovim/nvim-lspconfig")
  M.download("nvim-neotest/neotest")

  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.path_root())
  vim.opt.packpath = { M.path_root(".tests/site") }

  vim.cmd("runtime! plugin/plenary.vim")

  require("nvim-treesitter.configs").setup({
    modules = {},
    ignore_install = {},
    sync_install = true,
    auto_install = true,
    ensure_installed = { "lua" },
  })
end

M.setup()
