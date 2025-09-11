-- Telescopeで選択したコミットの差分を表示

local M = {}


-- ファイル履歴から差分を表示（統合差分形式）
M.file_history_with_diff = function()
  -- 現在のファイルの相対パスを取得（gitリポジトリのルートから）
  local current_file = vim.fn.expand('%:.')
  -- 元のバッファを記憶
  local original_buf = vim.api.nvim_get_current_buf()
  
  require('telescope.builtin').git_bcommits({
    layout_strategy = 'vertical',
    layout_config = {
      preview_cutoff = 0,
      vertical = {
        preview_height = 0.5,
      },
    },
    attach_mappings = function(_, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      -- Enterキーで統合差分を表示
      local function open_diff(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          
          -- 新しいバッファで差分を表示
          vim.cmd('enew')
          
          -- git diffコマンドで統合差分を取得
          vim.cmd('silent read !git diff ' .. selection.value .. '~1 ' .. selection.value .. ' -- ' .. current_file)
          vim.cmd('0delete_')
          
          -- 設定
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
          vim.bo.modifiable = false
          vim.bo.filetype = 'diff'  -- diff構文ハイライト
          
          -- バッファ名
          vim.api.nvim_buf_set_name(0, 'Diff: ' .. selection.value:sub(1, 7) .. ' ' .. vim.fn.fnamemodify(current_file, ':t'))
          
          -- 先頭に移動
          vim.cmd('normal! gg')
          
          -- ZQで元のバッファに戻るようにマッピング
          vim.keymap.set('n', 'ZQ', function()
            vim.cmd('buffer ' .. original_buf)
          end, { buffer = true })
        end
      end
      
      map('i', '<CR>', open_diff)
      map('n', '<CR>', open_diff)
      
      return true
    end,
  })
end

-- ファイル履歴から分割差分を表示（従来版）
M.file_history_with_split_diff = function()
  local current_file = vim.fn.expand('%:.')
  
  require('telescope.builtin').git_bcommits({
    layout_strategy = 'vertical',
    layout_config = {
      preview_cutoff = 0,
      vertical = {
        preview_height = 0.5,
      },
    },
    attach_mappings = function(_, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      local function open_diff(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          
          local original_buf = vim.api.nvim_get_current_buf()
          
          vim.cmd('leftabove vsplit')
          vim.cmd('enew')
          vim.cmd('silent read !git show ' .. selection.value .. ':' .. current_file)
          vim.cmd('0delete_')
          
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
          vim.bo.modifiable = false
          vim.bo.filetype = vim.filetype.match({ filename = current_file }) or ''
          
          vim.api.nvim_buf_set_name(0, '[' .. selection.value:sub(1, 7) .. '] ' .. vim.fn.fnamemodify(current_file, ':t'))
          
          vim.cmd('diffthis')
          vim.cmd('wincmd p')
          
          if vim.api.nvim_get_current_buf() ~= original_buf then
            vim.api.nvim_set_current_buf(original_buf)
          end
          
          vim.cmd('diffthis')
        end
      end
      
      map('i', '<CR>', open_diff)
      map('n', '<CR>', open_diff)
      
      return true
    end,
  })
end

-- プロジェクト全体のコミット履歴から差分を表示
M.project_history_with_diff = function()
  -- 元のバッファを記憶
  local original_buf = vim.api.nvim_get_current_buf()
  
  require('telescope.builtin').git_commits({
    layout_strategy = 'vertical',
    layout_config = {
      preview_cutoff = 0,
      vertical = {
        preview_height = 0.5,
      },
    },
    attach_mappings = function(_, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      -- Enterキーでコミット全体の差分を表示
      local function open_diff(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          
          -- 新しいバッファで差分を表示
          vim.cmd('enew')
          
          -- git showコマンドでコミット全体の差分を取得
          vim.cmd('silent read !git show ' .. selection.value)
          vim.cmd('0delete_')
          
          -- 設定
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
          vim.bo.modifiable = false
          vim.bo.filetype = 'git'  -- git構文ハイライト（コミットメッセージ含む）
          
          -- バッファ名
          vim.api.nvim_buf_set_name(0, 'Commit: ' .. selection.value:sub(1, 7))
          
          -- 先頭に移動
          vim.cmd('normal! gg')
          
          -- ZQで元のバッファに戻るようにマッピング
          vim.keymap.set('n', 'ZQ', function()
            vim.cmd('buffer ' .. original_buf)
          end, { buffer = true })
        end
      end
      
      map('i', '<CR>', open_diff)
      map('n', '<CR>', open_diff)
      
      return true
    end,
  })
end

-- 現在のファイルの未コミット変更を表示
M.file_unstaged_diff = function()
  local current_file = vim.fn.expand('%:.')
  local original_buf = vim.api.nvim_get_current_buf()
  
  -- 新しいバッファで差分を表示
  vim.cmd('enew')
  
  -- git diff で現在のファイルの未コミット変更を取得
  vim.cmd('silent read !git diff HEAD -- ' .. current_file)
  vim.cmd('0delete_')
  
  -- 差分がない場合の処理
  if vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '' then
    vim.cmd('buffer ' .. original_buf)
    vim.notify('No unstaged changes in ' .. current_file, vim.log.levels.INFO)
    return
  end
  
  -- 設定
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.bo.modifiable = false
  vim.bo.filetype = 'diff'  -- diff構文ハイライト
  
  -- バッファ名
  vim.api.nvim_buf_set_name(0, 'Unstaged changes: ' .. vim.fn.fnamemodify(current_file, ':t'))
  
  -- 先頭に移動
  vim.cmd('normal! gg')
  
  -- ZQで元のバッファに戻るようにマッピング
  vim.keymap.set('n', 'ZQ', function()
    vim.cmd('buffer ' .. original_buf)
  end, { buffer = true })
end

-- プロジェクト全体の未コミット変更を表示
M.project_unstaged_diff = function()
  local original_buf = vim.api.nvim_get_current_buf()
  
  -- 新しいバッファで差分を表示
  vim.cmd('enew')
  
  -- git diff で全体の未コミット変更を取得
  vim.cmd('silent read !git diff HEAD')
  vim.cmd('0delete_')
  
  -- 差分がない場合の処理
  if vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '' then
    vim.cmd('buffer ' .. original_buf)
    vim.notify('No unstaged changes in the project', vim.log.levels.INFO)
    return
  end
  
  -- 設定
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.bo.modifiable = false
  vim.bo.filetype = 'diff'  -- diff構文ハイライト
  
  -- バッファ名
  vim.api.nvim_buf_set_name(0, 'Unstaged changes: Project')
  
  -- 先頭に移動
  vim.cmd('normal! gg')
  
  -- ZQで元のバッファに戻るようにマッピング
  vim.keymap.set('n', 'ZQ', function()
    vim.cmd('buffer ' .. original_buf)
  end, { buffer = true })
end

-- git statusを表示して変更ファイルを選択
M.git_status = function()
  require('telescope.builtin').git_status({
    layout_strategy = 'vertical',
    layout_config = {
      preview_cutoff = 0,
      vertical = {
        preview_height = 0.5,
      },
    },
    attach_mappings = function(_, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      -- Enterキーで選択したファイルの差分を表示
      local function open_diff(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          
          local original_buf = vim.api.nvim_get_current_buf()
          
          -- 新しいバッファで差分を表示
          vim.cmd('enew')
          
          -- git diff でファイルの差分を取得
          vim.cmd('silent read !git diff HEAD -- ' .. selection.value)
          vim.cmd('0delete_')
          
          -- 設定
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
          vim.bo.modifiable = false
          vim.bo.filetype = 'diff'  -- diff構文ハイライト
          
          -- バッファ名
          vim.api.nvim_buf_set_name(0, 'Diff: ' .. vim.fn.fnamemodify(selection.value, ':t'))
          
          -- 先頭に移動
          vim.cmd('normal! gg')
          
          -- ZQで元のバッファに戻るようにマッピング
          vim.keymap.set('n', 'ZQ', function()
            vim.cmd('buffer ' .. original_buf)
          end, { buffer = true })
        end
      end
      
      map('i', '<CR>', open_diff)
      map('n', '<CR>', open_diff)
      
      return true
    end,
  })
end

-- キーマップ設定
vim.keymap.set('n', '<leader>gc', M.file_history_with_diff, { desc = 'Git [c]ommits for current file' })
vim.keymap.set('n', '<leader>gC', M.project_history_with_diff, { desc = 'Git [C]ommits for project' })
vim.keymap.set('n', '<leader>gd', M.file_unstaged_diff, { desc = 'Git [d]iff current file (unstaged)' })
vim.keymap.set('n', '<leader>gD', M.project_unstaged_diff, { desc = 'Git [D]iff all files (unstaged)' })
vim.keymap.set('n', '<leader>gs', M.git_status, { desc = 'Git [s]tatus with diff preview' })


return M