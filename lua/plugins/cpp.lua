local uname = (vim.uv or vim.loop).os_uname()
local is_linux_arm = uname.sysname == "Linux" and (uname.machine == "aarch64" or vim.startswith(uname.machine, "arm"))

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = function(_, opts)
      opts.config = vim.tbl_deep_extend("keep", opts, {
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
        cmd = { "clangd", "--background-index", "--header-insertion=never" },
        -- on_attach = function()
        --   -- Enabling inlay hints feature
        --   require("clangd_extensions.inlay_hints").setup_autocmd()
        --   require("clangd_extensions.inlay_hints").set_inlay_hints()
        -- end
      },
      })
      if is_linux_arm then opts.servers = require("astrocore").list_insert_unique(opts.servers, { "clangd" }) end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "cpp", "c" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      if not is_linux_arm then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "clangd" })
      end
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          clangd_extensions = {
            {
              event = "LspAttach",
              desc = "Load clangd_extensions with clangd",
              callback = function(args)
                if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
                  require "clangd_extensions"
                  vim.api.nvim_del_augroup_by_name "clangd_extensions"
                end
              end,
            },
          },
          clangd_extension_mappings = {
            {
              event = "LspAttach",
              desc = "Load clangd_extensions with clangd",
              callback = function(args)
                if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
                  require("astrocore").set_mappings({
                    n = {
                      ["<F4>"] = { "<Cmd>ClangdSwitchSourceHeader<CR>", desc = "Switch Source/Header" },
                    },
                  }, { buffer = args.buf })
                end
              end,
            },
          },
        },
      },
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp" },
    dependencies = {
      {
       "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
          opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
        end,
      },
    },
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      local tools = { "codelldb" }
      if not is_linux_arm then table.insert(tools, "clangd") end
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, tools)
    end,
  },
}
