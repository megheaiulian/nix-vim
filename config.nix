{
  vimPlugins,
  nixfmt-rfc-style,
  ripgrep,
  fd,
  statix,
  yamllint,
}:
let
  toLua = str: "lua << EOF\n${str}\nEOF";
  customRC =
    toLua
      # lua
      ''
        vim.loader.enable()

        local opt, g = vim.opt, vim.g
        local vimRc = vim.api.nvim_create_augroup('vimRc', { clear = true })
        local autocmd = vim.api.nvim_create_autocmd

        g.mapleader = ' '
        g.maplocalleader = ' '
        g.have_nerd_font = true
        g.netrw_banner = 0
        g.netrw_localcopydircmd = 'cp -r'
        g.netrw_localrmdir = 'rm -r'
        g.netrw_use_errorwindow = 0

        opt.path = '.,**'
        opt.swapfile = false
        opt.expandtab = true
        opt.smarttab = true
        opt.softtabstop = 2
        opt.tabstop = 2
        opt.shiftwidth = 2
        opt.shiftround = true
        opt.number = true
        opt.signcolumn = 'yes'
        opt.splitbelow = true
        opt.splitright = true
        opt.splitkeep = 'screen'
        opt.pumheight = 5
        opt.gdefault = true
        opt.wrap = false
        opt.showmode = false
        opt.completeopt = 'menuone,noselect,noinsert'
        opt.wildmode = 'longest:full,full'
        opt.diffopt = 'internal,filler,closeoff,context:3,indent-heuristic,algorithm:patience,linematch:60'
        opt.undofile = true
        opt.timeoutlen = 1500
        opt.updatetime = 300
        opt.grepprg = 'rg --color=never --vimgrep'
        opt.grepformat = '%f:%l:%c:%m,%f'
        opt.list = true
        opt.listchars = { tab = '› ', trail = '⋅', extends = '»', precedes = '«', nbsp = '␣' }
        opt.winborder = 'single'

        autocmd('BufRead', { pattern = '*', group = vimRc, command = [[call setpos(".", getpos("'\""))]] })
        autocmd('TextYankPost', {
          pattern = '*',
            callback = function()
              vim.highlight.on_yank { higroup = 'CursorLine', timeout = 200 }
            end,
        })
        vim.cmd('command! -nargs=* -complete=file -complete=dir Rg silent grep! <args>')

        vim.filetype.add({
          extension = {
            conf = 'config',
            njk = 'html',
          },
          filename = {
            ['.envrc'] = 'config',
          },
        })

        vim.diagnostic.config({
          underline = false,
          float = {
            border = 'single',
            header = ''',
            source = true,
          },
          signs = {
            text = {
              [vim.diagnostic.severity.HINT] = '󰌶',
              [vim.diagnostic.severity.ERROR] = '󰅚',
              [vim.diagnostic.severity.INFO] = '󰋽',
              [vim.diagnostic.severity.WARN] = '󰀪',
            },
          },
        })

      '';
  plugins = with vimPlugins; [
    {
      start = [
        fzf-lua
        lualine-nvim
        nvim-web-devicons
      ];
      config =
        toLua
          # lua
          ''
            require("lualine").setup({

              options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = {},
                section_separators = {},
              },
              sections = {
                lualine_a = {},
                lualine_b = {'%* %{expand("%:p:h:t")}/%t %#error#%{&modified?" ":""}%r%*'},
                lualine_c = { 'branch', 'diagnostics' },
                lualine_x = { 'filetype' },
                lualine_y = {'%*%4c:%l/%L'},
                lualine_z = {}
              }
            })
            require("fzf-lua").setup({
              winopts = {
                row = 1,
                height = 0.25,
                width = 1
              }
            })
            vim.keymap.set('n', '<c-p>', ':FzfLua files<cr>')
            vim.keymap.set('n', '<bs>', ':FzfLua buffers<cr>')
            vim.keymap.set('n', '<leader>g', '<cmd>lua require("fzf-lua").live_grep_native()<cr>')
          '';
      path = [
        fd
        ripgrep
      ];
    }
    {
      start = [
        (nvim-treesitter.withPlugins (
          p: with p; [
            astro
            javascript
            typescript
            tsx
            jsdoc
            json
            html
            http
            css
            scss
            styled
            bash
            lua
            nix
            rust
            toml
            twig
            go
            c_sharp
            cpp
            sql
            ledger
            hcl
            php
            markdown
            markdown_inline
            yaml
            helm
            terraform
            regex
            diff
          ]
        ))
        vim-ledger
      ];
      config =
        toLua
          # lua
          ''
            require'nvim-treesitter.configs'.setup {
              highlight = {enable = true, additional_vim_regex_highlighting = false},
              indent = {enable = true}
            }
          '';
    }
    {
      start = kanagawa-nvim;
      config =
        toLua
          # lua
          ''
            vim.cmd('colorscheme kanagawa')
          '';
    }
    {
      start = [
        gitsigns-nvim
        vim-fugitive
      ];
      config =
        toLua
          # lua
          ''
            require('gitsigns').setup({
              signs = {
                add = { text = '┊' },
                change = { text = '┊' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '┊' },
                untracked = { text = '┆' },
              },
              signs_staged_enable = false,
              on_attach = function()
                local gs = package.loaded.gitsigns
                local map = vim.keymap.set
                map('n', '[c', gs.prev_hunk, { buffer = true })
                map('n', ']c', gs.next_hunk, { buffer = true })
                map('n', 'ghr', gs.reset_hunk)
                map('n', 'ghp', gs.preview_hunk)
                map('n', 'ghi', gs.preview_hunk_inline)
                map('n', 'ghB', function()
                  gs.blame_line({ full = true })
                end)
                map('n', 'ghb', gs.toggle_current_line_blame)
              end,
            })
          '';
    }
    {
      start = [ nvim-lspconfig ];
      config =
        toLua
          # lua
          ''
            vim.lsp.enable('ts_ls')
            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('gopls')
            vim.lsp.enable('terraformls')
            vim.lsp.enable('tflint')
            vim.lsp.enable('nixd')

            vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
            vim.keymap.set('n', 'go', vim.lsp.buf.type_definition)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
            vim.keymap.set('n', '<leader>d', vim.diagnostic.setqflist)
            vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help)
          '';
    }

    {
      start = [ blink-cmp ];
      config =
        toLua
          # lua
          ''
            require('blink.cmp').setup({
              cmdline = { enabled = false },
              appearance = { nerd_font_variant = 'normal' },
              sources = { default = { 'lsp', 'buffer', 'snippets', 'path' } },
              completion = { list = { selection = { preselect = true, auto_insert = false }},
              accept = { auto_brackets = { enabled = false }},
              },
              keymap = {
                preset = 'enter',
                  ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
                  ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
                  ['<C-k>'] = { 'show', 'show_documentation', 'hide_documentation' },
              }
            })
          '';
    }
    {
      start = [ formatter-nvim ];
      config =
        toLua
          # lua
          ''
            local formatter = require('formatter.filetypes')
            local defaults = require "formatter.defaults"
            local util = require "formatter.util"
            require('formatter').setup({
              filetype = {
                lua = { formatter.lua.stylua },
                javascript = { formatter.javascript.prettier },
                typescript = { formatter.typescript.prettier },
                html = { formatter.javascript.prettier },
                liquid = { util.copyf(defaults.prettier) },
                twig = { util.copyf(defaults.prettier) },
                css = { formatter.css.prettier },
                yaml = { formatter.yaml.prettier },
                markdown = { formatter.markdown.prettier },
                json = { formatter.json.jq },
                jsonc = { formatter.json.jq },
                nix = { formatter.nix.nixfmt },
                rust = { formatter.rust.rustfmt },
                go = { formatter.go.gofmt },
                terraform =  { formatter.terraform.terraformfmt },
                xml = { formatter.xml.xmlformat },
                ['*'] = {
                  require('formatter.filetypes.any').remove_trailing_whitespace,
                },
              },
            })
            vim.keymap.set('n', 'Q', ':FormatWrite<cr>')
          '';
      path = [ nixfmt-rfc-style ];
    }
    {
      start = [ nvim-lint ];
      config =
        toLua
          # lua
          ''
            local lint = require('lint')
            local linters_by_ft = {
              lua = { 'luacheck' },
              nix = { 'statix' },
              javascript = { 'eslint' },
              yaml = { 'yamllint' },
              json = { 'jsonlint' },
              go = { 'golangci-lint' },
            }
            local executable_linters = {}
            for filetype, linters in pairs(linters_by_ft) do
              for _, linter in ipairs(linters) do
                if vim.fn.executable(linter) == 1 then
                  executable_linters[filetype] = executable_linters[filetype] or {}
                  table.insert(executable_linters[filetype], linter)
                end
              end
            end
            lint.linters_by_ft = executable_linters
            vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave', 'TextChanged' }, {
              callback = function()
                require("lint").try_lint()
              end,
            })
          '';
      path = [
        statix
        yamllint
      ];
    }
    {
      start = [ quicker-nvim ];
      config =
        toLua
          # lua
          ''
            require('quicker').setup({
              on_qf = function(bufnr)
                vim.keymap.set('n', 'q', function()
                  require('quicker').close()
                end, { buffer = bufnr })
              end,
            })
            vim.api.nvim_create_autocmd('QuickFixCmdPost', {
              group = vimRc,
              pattern = 'grep',
              command = 'copen'
            })
          '';
    }
  ];
in
{
  inherit customRC plugins;
}
