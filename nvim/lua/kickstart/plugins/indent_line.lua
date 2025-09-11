return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    enabled = true,  -- インデントガイドを有効化
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        highlight = 'IblIndent',
      },
      scope = {
        enabled = true,  -- スコープのハイライトを有効化
        show_start = true,  -- スコープの開始を表示
        show_end = true,    -- スコープの終了を表示
        highlight = 'IblScope',
        include = {
          node_type = {
            -- JSX/TSX要素を明示的に含める
            ["jsx_element"] = true,
            ["jsx_self_closing_element"] = true,
            ["jsx_opening_element"] = true,
            ["jsx_closing_element"] = true,
            ["jsx_fragment"] = true,
            ["element"] = true,
            ["*"] = true,
          },
        },
        injected_languages = true,
        priority = 500,
      },
    },
    config = function(_, opts)
      -- カスタムハイライトグループを定義
      vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#3a3a3a' })  -- 通常のインデント線（薄い色）
      vim.api.nvim_set_hl(0, 'IblScope', { fg = '#6a6a6a' })   -- 現在のスコープ（明るい色）
      
      -- ビジュアルモード用のハイライト
      vim.api.nvim_set_hl(0, 'VisualStart', { bg = '#4a4a6a', bold = true })  -- 開始行の背景色
      vim.api.nvim_set_hl(0, 'VisualEnd', { bg = '#6a4a4a', bold = true })    -- 終了行の背景色
      
      require('ibl').setup(opts)
      
      -- ビジュアルモードでの範囲表示
      local visual_ns = vim.api.nvim_create_namespace('visual_range')
      
      -- 選択範囲の開始と終了を表示する関数
      local function show_visual_range()
        vim.schedule(function()
          local mode = vim.fn.mode()
          if mode:match('[vV\x16]') then
            vim.api.nvim_buf_clear_namespace(0, visual_ns, 0, -1)
            
            local start_pos = vim.fn.getpos('v')
            local end_pos = vim.fn.getpos('.')
            local start_line = start_pos[2] - 1
            local end_line = end_pos[2] - 1
            
            -- 開始と終了が逆の場合は入れ替える
            if start_line > end_line then
              start_line, end_line = end_line, start_line
            end
            
            -- 開始行と終了行に異なるハイライトを適用
            if start_line == end_line then
              -- 同じ行の場合は別の表示
              vim.api.nvim_buf_set_extmark(0, visual_ns, start_line, 0, {
                line_hl_group = 'VisualStart',
                priority = 100,
              })
            else
              -- 開始行
              vim.api.nvim_buf_set_extmark(0, visual_ns, start_line, 0, {
                line_hl_group = 'VisualStart',
                priority = 100,
                sign_text = '▶',
                sign_hl_group = 'VisualStart',
              })
              
              -- 終了行
              vim.api.nvim_buf_set_extmark(0, visual_ns, end_line, 0, {
                line_hl_group = 'VisualEnd',
                priority = 100,
                sign_text = '◀',
                sign_hl_group = 'VisualEnd',
              })
            end
          end
        end)
      end
      
      -- ビジュアルモードでカーソルが動いた時に更新
      vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        callback = function()
          if vim.fn.mode():match('[vV\x16]') then
            show_visual_range()
          end
        end,
      })
      
      -- ビジュアルモードに入った時
      vim.api.nvim_create_autocmd('ModeChanged', {
        pattern = '*:[vV\x16]*',
        callback = show_visual_range,
      })
      
      -- ビジュアルモードから出た時
      vim.api.nvim_create_autocmd('ModeChanged', {
        pattern = '[vV\x16]*:*',
        callback = function()
          vim.api.nvim_buf_clear_namespace(0, visual_ns, 0, -1)
        end,
      })
    end,
  },
}
