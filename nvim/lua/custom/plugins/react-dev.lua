-- React開発向けの追加設定とキーバインド
return {
  -- typescript-tools.nvim (より高度なTypeScript LSP)
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      require("typescript-tools").setup({
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = "all",
          tsserver_path = nil,
          tsserver_plugins = {},
          tsserver_max_memory = "auto",
          tsserver_format_options = {},
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
          complete_function_calls = true,
        },
      })
    end,
  },

  -- package-info.nvim - package.jsonの依存関係の最新バージョンを表示
  {
    "vuki656/package-info.nvim",
    ft = { "json" },
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("package-info").setup({
        autostart = true,
        package_manager = "pnpm",
      })
      
      -- キーバインド
      vim.keymap.set("n", "<leader>nu", require("package-info").update, { desc = "Update package", silent = true })
      vim.keymap.set("n", "<leader>nd", require("package-info").delete, { desc = "Delete package", silent = true })
      vim.keymap.set("n", "<leader>ni", require("package-info").install, { desc = "Install package", silent = true })
      vim.keymap.set("n", "<leader>nc", require("package-info").change_version, { desc = "Change package version", silent = true })
    end,
  },

  -- vim-jsx-pretty - JSX構文のハイライトを改善
  {
    "MaxMEllon/vim-jsx-pretty",
    ft = { "javascriptreact", "typescriptreact" },
  },

  -- vim-graphql - GraphQL構文ハイライト
  {
    "jparise/vim-graphql",
    ft = { "graphql", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  },

  -- vim-styled-components - styled-components構文ハイライト
  {
    "styled-components/vim-styled-components",
    ft = { "javascriptreact", "typescriptreact" },
  },
}