-- カスタムプラグインの設定
return {
  -- lazygit.nvim - Neovim内でlazygitを使用
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    },
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
  },

  -- nvim-ts-autotag - HTMLタグとJSXタグを自動で閉じる
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
      })
    end,
  },

  -- alpha-nvim - スタート画面
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- ヘッダーの設定
      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        [[                                                    ]],
      }

      -- ボタンの設定
      dashboard.section.buttons.val = {
        dashboard.button("f", "  ファイルを探す", ":Telescope find_files <CR>"),
        dashboard.button("e", "  新規ファイル", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  最近使用したファイル", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  Grep検索", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  設定", ":e ~/.config/nvim/init.lua <CR>"),
        dashboard.button("q", "  終了", ":qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end,
  },

  -- inc-rename.nvim - インクリメンタルリネーム
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
      vim.keymap.set("n", "<leader>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true, desc = "インクリメンタルリネーム" })
    end,
  },


  -- avante.nvim - AI駆動のコード提案
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      provider = "claude", -- または "openai", "copilot"など
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-sonnet-20241022",
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
          -- UTF-8対応の強化
          signs = { enabled = false }, -- 特殊文字サインを無効化
          code = {
            -- コードブロックの文字化け対策
            sign = false,
            width = 'block',
          },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- nvim-ts-context-commentstring - コメントストリングのコンテキスト認識
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    config = function()
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
      })
    end,
  },

  
}