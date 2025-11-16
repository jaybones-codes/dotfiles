return{
  "ibhagwan/fzf-lua",
  -- optional for icon support
 -- dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
   dependencies = { "nvim-mini/mini.icons" },
  opts = {},
  keys={
        {"<leader>ff",
        function() require('fzf-lua').files() end,
        desc="Find Files in current Directory"},

         {"<leader>fg",
        function() require('fzf-lua').live_grep() end,
        desc="Find by Grepping in Project Directory"},
      {"<leader>fc",
        function() require('fzf-lua').files({cwd=vim.fn.stdpath("config")}) end,
        desc="Find NVim Config"},
        {"<leader>fc",
        function() require('fzf-lua').files({cwd=vim.fn.stdpath("config")}) end,
        desc="Find Project Directory"}
    
  }
}
