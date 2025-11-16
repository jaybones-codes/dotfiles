-- Save this as: ~/.config/nvim/lua/tmux-sync.lua
-- Then add to your init.lua: require('tmux-sync')

local M = {}

-- Function to send directory change to tmux pane
local function sync_directory()
  -- Only run if we're inside tmux
  if vim.env.TMUX == nil then
    return
  end
  
  -- Get the directory of the current file
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    return
  end
  
  local dir = vim.fn.fnamemodify(filepath, ':h')
  
  -- Get current tmux pane
  local current_pane = vim.fn.system("tmux display-message -p '#{pane_index}'"):gsub("\n", "")
  
  -- Calculate target pane (the one below nvim, which is current_pane + 1)
  local target_pane = tonumber(current_pane) + 1
  
  -- Send cd command to the pane below
  local cmd = string.format("tmux send-keys -t %d 'cd %s' C-m", target_pane, vim.fn.shellescape(dir))
  vim.fn.system(cmd)
end

-- Set up autocmd to trigger on buffer enter
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
  pattern = "*",
  callback = sync_directory,
})

-- Optional: Add a manual command
vim.api.nvim_create_user_command('TmuxSyncDir', sync_directory, {})

return M
