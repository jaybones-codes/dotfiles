return {
  "nvim-treesitter/nvim-treesitter",
  build = "", -- prevent Lazy.nvim from auto-running :TSUpdate
  config = function()
    -- Persistent parser directory (prevents reinstall)
    local parser_path = vim.fn.stdpath("data") .. "/treesitter"
    vim.opt.runtimepath:append(parser_path)

    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "cpp",
      },
      parser_install_dir = parser_path,
      sync_install = false,
      auto_install = false,
      ignore_install = { "javascript" },

      highlight = {
        enable = true,
        disable = { "c", "rust" },
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },

      -- your extra section (correctly placed)
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<Enter>",
          node_incremental = "<Enter>",
          scope_incremental = false,
          node_decremental = "<Backspace>",
        },
      },

      indent = {
        enable = true,
      },
    })
  end,
}

