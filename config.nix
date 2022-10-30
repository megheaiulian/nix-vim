{ vimPlugins, nixpkgs-fmt, silver-searcher, ripgrep }:
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
      opt = ale;
      config = ''
        autocmd vimRc BufReadPost * execute 'packadd ale'
        let g:ale_sign_error = '•'
        let g:ale_sign_warning = '• '
        let es_linters = ['eslint', 'tsserver']
        let g:ale_linters = {
            \   'javascript': es_linters,
            \   'typescript': es_linters,
            \   'nix': ['nixpkgs-fmt']
            \}
        let g:ale_fixers = {'javascript': ['eslint']}
        let g:ale_fix_on_save = 1
        nnoremap K :ALEHover<CR>
        nnoremap gd :ALEGoToDefinition<CR>
        nnoremap <silent> gr :ALEFindReferences<CR>
        nnoremap [a :ALEPreviousWrap<CR>
        nnoremap ]a :ALENextWrap<CR>
      '';
      path = [ nixpkgs-fmt ];
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
      start = pure-lua;
      config = ''
        colorscheme moonlight
      '';
    }
    { opt = vim-jinja; 
      config = ''
          au BufNewFile,BufRead *.njk set ft=jinja
      '';
    }
  ];
in
{ inherit customRC plugins; }
