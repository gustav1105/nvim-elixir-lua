-- Ensure packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Initialize packer and configure plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'        -- Packer manages itself
  use 'neovim/nvim-lspconfig'         -- LSP support
  use 'hrsh7th/nvim-cmp'              -- Autocompletion
  use 'hrsh7th/cmp-nvim-lsp'          -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip'              -- Snippet engine
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- Treesitter for syntax highlighting
  use 'nvim-tree/nvim-tree.lua'       -- File explorer tree view
  use 'nvim-tree/nvim-web-devicons'   -- File icons (optional)

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Setup LSP
local nvim_lsp = require('lspconfig')

nvim_lsp.elixirls.setup{
  cmd = { "/home/gus/Tooling/elixir-ls/release/language_server.sh" },  -- Path to your ElixirLS language server script
  on_attach = function(client, bufnr)
    -- Customize key mappings and settings here
    local opts = { noremap=true, silent=true }
    -- Example key mapping for LSP
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- Add more key mappings as needed
  end,
  flags = {
    debounce_text_changes = 150,
  }
}

-- Setup nvim-cmp for autocompletion
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `LuaSnip` users
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  },
  sources = {
    { name = 'nvim_lsp' },
    -- Add more sources if needed
  }
})

-- Setup TreeSitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- Or a list of languages you need
  highlight = {
    enable = true,              -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
}

-- Enable line numbers
vim.o.number = true              -- Show absolute line numbers
vim.o.relativenumber = false      -- Show relative line numbers
vim.o.signcolumn = 'yes'         -- Always show sign column
vim.o.ruler = true               -- Show cursor position in the status line

-- Key mappings for navigating between splits
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

require'nvim-tree'.setup {
  -- Configuration options go here
  update_cwd = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = "H",
      info = "I",
      warning = "W",
      error = "E",
    },
  },
  view = {
    width = 30,
    side = 'left',
    auto_resize = true,
  },
}

-- Toggle Nvim Tree
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

