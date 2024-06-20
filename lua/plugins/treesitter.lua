-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore", "python", "bash", "cmake",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
