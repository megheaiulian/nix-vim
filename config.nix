{ vimPlugins, nixpkgs-fmt, silver-searcher, ripgrep, nodePackages }:
let
  customRC = ''
    set encoding=utf-8
    scriptencoding utf-8

    augroup vimRc
      autocmd!
    augroup END

    set path& | let &path .= '**'
    set copyindent
    set preserveindent
    set expandtab
    set smarttab
    set softtabstop=2
    set tabstop=2
    set shiftwidth=2
    set shiftround
    set number
    set switchbuf+=useopen,usetab
    set splitbelow
    set splitright
    set nowrap
    set mouse=a
    set completeopt-=preview
    set completeopt+=menuone,noselect,noinsert
    set complete=.,w,b,u,U,t,i,d,k
    set wildmode=longest:full,full
    set wildignorecase
    set wildcharm=<C-Z>

    set list
    set listchars=tab:›\ ,trail:•,extends:»,precedes:«,nbsp:‡

    " statusline
    set statusline=%<%f\ %h%#error#%m%*%r%=%-14.(%l\:%c%)%{&filetype}

    " njk support
    au BufNewFile,BufRead *.njk set ft=html

  '';
  plugins = with vimPlugins; [
    {
      opt = editorconfig-vim;
      config = ''
        autocmd vimRc BufReadPre * execute 'packadd editorconfig-vim'
        let g:EditorConfig_exclude_patterns = ['fugitive://.*']
      '';
    }
    {
      start = fzf-vim;
      config = ''
        let $FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        let g:fzf_layout = { 'down': '~25%' }
        nnoremap <c-p> :Files<cr>
        nnoremap <bs> :Buffers<cr>
      '';
      path = [ silver-searcher ripgrep ];
    }
    {
      start = commentary;
    }
    {
      opt = plenary-nvim;
    }
    {
      start = nvim-treesitter;
      config = ''
        lua << EOF
        require'nvim-treesitter.configs'.setup {
          parser_install_dir = "~/.local/share/nvim/site",
          ensure_installed = { 'javascript', 'typescript', 'jsdoc', 'json', 'html', 'css', 'bash', 'lua', 'nix'},
          highlight = {enable = true, additional_vim_regex_highlighting = false},
          indent = {enable = true}
        }
        EOF
      '';
    }
    {
      start = kanagawa-nvim;
      config = ''
        colorscheme kanagawa
      '';
    }
    {
      start = gitsigns-nvim;
      config = ''
        lua << EOF
          require('gitsigns').setup()
        EOF
      '';
    }
    {
      start = formatter-nvim;
      config = ''
        lua << EOF
        local util = require("formatter.util")
        function prettier()
          return {
            exe = "prettier",
            args = {
              "--stdin-filepath",
              util.escape_path(util.get_current_buffer_file_path()),
            },
            stdin = true,
            try_node_modules = true,
          }
        end
        function nix()
          return {
            exe = "nixpkgs-fmt",
            args = {
              util.escape_path(util.get_current_buffer_file_path()),
            }
          }
        end
        require("formatter").setup {
          logging = true,
          log_level = vim.log.levels.WARN,
          filetype = {
            javascript = { prettier },
            typescript = { prettier },
            nix = { nix }
          }
        }
        EOF
      '';
      path = [ nixpkgs-fmt ];
    }
    {
      start = nvim-lspconfig;
      config = ''
        lua << EOF
        local lspconfig = require('lspconfig')
        local lsp_defaults = lspconfig.util.default_config

        lsp_defaults.capabilities = vim.tbl_deep_extend(
          'force',
          lsp_defaults.capabilities,
          require('cmp_nvim_lsp').default_capabilities()
        )
        vim.api.nvim_create_autocmd('LspAttach', {
          desc = 'LSP actions',
          callback = function()
            local bufmap = function(mode, lhs, rhs)
              local opts = {buffer = true}
              vim.keymap.set(mode, lhs, rhs, opts)
            end

            -- Displays hover information about the symbol under the cursor
            bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

            -- Jump to the definition
            bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

            -- Jump to declaration
            bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

            -- Lists all the implementations for the symbol under the cursor
            bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

            -- Jumps to the definition of the type symbol
            bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

            -- Lists all the references 
            bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

            -- Displays a function's signature information
            bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

            -- Renames all references to the symbol under the cursor
            bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

            -- Selects a code action available at the current cursor position
            bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
            bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

            -- Show diagnostics in a floating window
            bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

            -- Move to the previous diagnostic
            bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

            -- Move to the next diagnostic
            bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
          end
        })

        lspconfig.tsserver.setup({})

        local sign = function(opts)
          vim.fn.sign_define(opts.name, {
            texthl = opts.name,
            text = opts.text,
            numhl = ""
          })
        end
        sign({name = 'DiagnosticSignError', text = '✘'})
        sign({name = 'DiagnosticSignWarn', text = '▲'})
        sign({name = 'DiagnosticSignHint', text = '⚑'})
        sign({name = 'DiagnosticSignInfo', text = ''})

        vim.diagnostic.config({
          virtual_text = false,
          severity_sort = true,
          float = {
            border = 'rounded',
            source = 'always',
            header = "",
            prefix = "",
          },
        })

        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
          vim.lsp.handlers.hover,
          {border = 'rounded'}
        )

        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          {border = 'rounded'}
        )

        EOF
      '';
      path = [
        nodePackages.typescript-language-server
      ];
    }
    {
      start = [ nvim-cmp cmp-buffer cmp-path cmp-nvim-lsp ];
      config = ''
        lua << EOF
        vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
        local cmp = require('cmp')
        local select_opts = {behavior = cmp.SelectBehavior.Select}

        cmp.setup({
          sources = {
            {name = 'path'},
            {name = 'nvim_lsp', keyword_length = 3},
            {name = 'buffer', keyword_length = 3},
          },
          window = {
            documentation = cmp.config.window.bordered()
          },
          formatting = {
            fields = {'menu', 'abbr', 'kind'},
            format = function(entry, item)
              local menu_icon = {
                nvim_lsp = 'λ',
                buffer = 'Ω',
                path = '🖫',
              }

              item.menu = menu_icon[entry.source.name]
              return item
            end,
          },
          mapping = {
            ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
            ['<Down>'] = cmp.mapping.select_next_item(select_opts),

            ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
            ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),

            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({select = false}),

            ['<Tab>'] = cmp.mapping(function(fallback)
              local col = vim.fn.col('.') - 1

              if cmp.visible() then
                cmp.select_next_item(select_opts)
              elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                fallback()
              else
                cmp.complete()
              end
            end, {'i', 's'}),

            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item(select_opts)
              else
                fallback()
              end
            end, {'i', 's'}),
          },
        })
        EOF
      '';
    }

  ];
in
{ inherit customRC plugins; }
