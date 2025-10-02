local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available keybindings
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here for your own.
  --  If you need more language servers, see:
  --  https://github.com/williamboman/mason-lspconfig.nvim#available-servers
  ensure_installed = {
    'jdtls',
    'ts_ls',
    'eslint',
    'intelephense',
  },
  handlers = {
    lsp_zero.default_setup,
    -- Configure ts_ls to start automatically for projects with package.json
    function(server_name)
      if server_name == "ts_ls" then
        require('lspconfig')[server_name].setup({
          root_dir = require('lspconfig.util').root_pattern('package.json', '.git'),
        })
      else
        lsp_zero.default_setup()
      end
    end,
  },
})

-- Java specific configuration for jdtls
local extended_java_capabilities = vim.lsp.protocol.make_client_capabilities()
extended_java_capabilities.textDocument.completion.completionItem.snippetSupport = true

require('lspconfig').jdtls.setup({
  capabilities = extended_java_capabilities,
  on_attach = function(client, bufnr)
    lsp_zero.default_keymaps({buffer = bufnr})
    -- Additional Java-specific keybindings or configurations can go here
  end,
  -- You might need to adjust the path to your JDTLS installation
  -- and the workspace directory.
  -- See https://github.com/mfussenegger/nvim-jdtls#installation
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1G',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. vim.fn.glob('/home/angelo/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
    '-jar', vim.fn.glob('/home/angelo/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', vim.fn.glob('/home/angelo/.local/share/nvim/mason/packages/jdtls/config_linux'),
    '-data', vim.fn.stdpath('data') .. '/jdtls-workspace',
  },
  root_dir = require('lspconfig.util').root_pattern('pom.xml', 'build.gradle', '.git'),
  settings = {
    java = {
      completion = {
        favoriteStaticMembers = {
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.nonNull',
          'java.util.Objects.isNull',
          'java.util.Optional.empty',
          'java.util.Optional.of',
          'java.util.Optional.ofNullable',
        },
        importOrder = {
          'java',
          'javax',
          'org',
          'com',
        },
      },
      contentProvider = {
        preferred = 'fernflower',
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = 'all',
        },
      },
      signatureHelp = {
        enabled = true,
      },
      format = {
        enabled = false,
      },
    },
  },
  init_options = {
    bundles = {},
  },
})
