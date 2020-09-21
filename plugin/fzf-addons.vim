" ============================================================================
  " File: fzf_addons
  " Author: Faris Chugthai
  " Description: FZF Commands
  " Last Modified: Aug 06, 2020
" ============================================================================

" Options:
let s:fzf_options = get(g:, 'fzf_options', [])

if !exists(':FZF')
  finish
endif

if exists('g:did_fzf_addons') || &compatible || v:version < 700
  finish
endif
let g:did_fzf_addons = 1


" Brofiles:
  function! s:CompleteBrofiles(A, L, P)
    return v:oldfiles
  endfunction

  command! -bang -bar -nargs=* -complete=customlist,s:CompleteBrofiles Brofiles
        \ call fzf#run(fzf#wrap('oldfiles',
        \ {'source': v:oldfiles,
        \ 'sink': 'sp',
        \ 'options': s:fzf_options}, <bang>0))

  " TODO: `-nargs` not being passed to the fzf buffer upon initialization. Same with Brofiles
  command! -bar -bang -nargs=* -complete=help Help call fzf#vim#helptags(<bang>0)

  command! -bang -bar FZScriptnames call fzf_addons#fzf_scriptnames(<bang>0)

  " fzf_for_todos
  command! -bang -bar -complete=var -nargs=* TodoFuzzy call fzf_addons#RipgrepFzf('todo ' . <q-args>, <bang>0)

  " here's the call signature for fzf#vim#grep
  " - fzf#vim#grep(command, with_column, [options], [fullscreen])
  "   If you're interested it would be kinda neat to modify that `dir` line
  command! -complete=file_in_path -nargs=? -bang -bar FZGrep call fzf#run(fzf#wrap('grep', {
        \ 'source': 'silent! grep! <q-args>',
        \ 'sink': 'edit',
        \ 'options': ['--multi', '--ansi', '--border'],},
        \ <bang>0 ? fzf#vim#with_preview('up:60%') : 0))

  command! -bang -bar -complete=file -nargs=* GGrep
    \   call fzf#vim#grep(
    \   'git grep --line-number --color=always ' . shellescape(<q-args>),
    \   1,
    \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

  "   :Ag! - Start fzf in fullscreen and display the preview window above
  command! -complete=dir -bang -bar -nargs=* FZPreviewAg
    \ call fzf#vim#ag(<q-args>,
    \                 <bang>0 ? fzf#vim#with_preview('up:60%')
    \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
    \                 <bang>0)

" Rg: Use `:Rg` or `:FZRg` or `:FufRg` before this one
  command! -bar -complete=dir -bang -nargs=* FZMehRg
    \ call fzf#run(fzf#wrap('rg', {
          \   'source': 'rg --no-column --no-line-number --no-heading --color=ansi'
          \   . ' --smart-case --follow ' . shellescape(<q-args>),
          \   'sink': 'vsplit',
          \   'options': ['--ansi', '--multi', '--border', '--cycle', '--prompt', 'FZRG:',]
          \ }, <bang>0))

  command! -bang -nargs=? -complete=dir -bar FZPreviewFiles
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

  function! s:Plugins(...) abort
    return sort(keys(g:plugs))
  endfunction

  " TODO: Sink doesnt work
  command! -nargs=* -bang -bar -complete=customlist,s:Plugins FZPlugins
        \ call fzf#run(fzf#wrap(
        \ 'help',
        \ {'source': sort(keys(g:plugs)),
        \ 'sink'  : function('fzf_addons#plug_help_sink'),
        \ 'options': s:fzf_options},
        \ <bang>0))

" FZBuf: {{{ Works better than FZBuffers
  command! -bar -bang -complete=buffer FZBuf call fzf#run(fzf#wrap('buffers',
      \ {'source': map(range(1, bufnr('$')), 'bufname(v:val)'),
      \ 'sink': 'e',
      \ 'options': s:fzf_options,
      \ },
      \ <bang>0))

" FZBuffers: Use Of g:fzf_options:
  " As of Oct 15, 2019: this works. Also correctly locates files which none of my rg commands seem to do
  command! -bang -complete=buffer -bar FZBuffers call fzf#run(fzf#wrap('buffers',
          \ {'source':  reverse(fzf_addons#buflist()),
          \ 'sink':    function('fzf_addons#bufopen'),
          \ 'options': s:fzf_options,
          \ 'down':    len(fzf_addons#buflist()) + 2
          \ }, <bang>0))

" Mru:
  " I feel like this could work with complete=history right?
  command! -bang -bar -nargs=* -complete=customlist,s:CompleteBrofiles Mru call fzf_addons#FZFMru(<bang>0)

" FZGit:
  " Oct 15, 2019: Works!
  " TODO: The above command should use the fzf funcs
  " and also use this
  command! -bar -complete=file -bang GLsFiles call fzf_addons#FZFGit(<bang>0)

" Rg That Updates:
" I deleted this function at some point?
  " command! -bar -complete=dir -nargs=* -bang FZRg call fzf_addons#RipgrepFzf(<q-args>, <bang>0)

  " Doesn't update but i thought i was cool
  command! -bar -complete=dir -bang -nargs=* FzRgPrev
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case ' . <q-args>,
    \   1,
    \   <bang>0 ? fzf#vim#with_preview('up:60%')
    \           : fzf#vim#with_preview('right:50%:hidden', '?'))

  command! -bar -bang -complete=dir -nargs=* LS
      \ call fzf#run(fzf#wrap(
      \ 'ls',
      \ {'source': 'ls', 'dir': <q-args>},
      \ <bang>0))

  command! -bar -bang Projects call fzf#vim#files('~/projects', <bang>0)

  " Or, if you want to override the command with different fzf options, just pass
  " a custom spec to the function.
  " *Hey we actually handle args!
  command! -bar -bang -nargs=* -complete=file RFiles
      \ call fzf#vim#files(<q-args>,
      \ {'options': s:fzf_options},
      \ <bang>0)

  " Want a preview window?
  command! -bar -bang -nargs=* -complete=file Preview
      \ call fzf#vim#files(<q-args>,
      \ { 'source': 'fd -H -t f',
      \ 'sink': 'botright split',
      \ 'options': [
      \     '--layout=reverse', '--info=inline',
      \     '--preview', 'bat --color=always {}'
      \ ]},
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'))

  command! -bar -bang -nargs=* -complete=file Files
      \ call fzf#vim#files(<q-args>,
      \ {'source': 'fd -H -t f',
      \ 'sink': 'pedit',
      \ 'options': [
      \     '--layout=reverse', '--info=inline', '--preview', expand('~/.vim/plugged/fzf.vim/bin/preview.sh') . '{}'
      \ ]},
      \ <bang>0)

" Override His Commands To Add Completion:
  function! s:p(bang, ...)
    let preview_window = get(g:, 'fzf_preview_window', a:bang && &columns >= 80 || &columns >= 120 ? 'right': '')
    if len(preview_window)
      return call('fzf#vim#with_preview', add(copy(a:000), preview_window))
    endif
    return {}
  endfunction

  " Add fugitives completion to make this command way better
  " FUCK YES THIS WORKS PERFECTLY HOLY FUCK
  command! -bar -bang -nargs=? -complete=customlist,fugitive#PathComplete GFiles call fzf#vim#gitfiles(<q-args>, <q-args> == "?" ? {} : s:p(<bang>0), <bang>0)
  command! -bar -bang -nargs=? -complete=customlist,fugitive#PathComplete GitFiles call fzf#vim#gitfiles(<q-args>, <q-args> == "?" ? {} : s:p(<bang>0), <bang>0)

" Maps:
  " Me just copy pasting his plugin with added completion
  command! -bar -bang -complete=mapping IMaps call fzf#vim#maps("i", <bang>0)
  command! -bar -bang -complete=mapping CMaps call fzf#vim#maps("c", <bang>0)
  command! -bar -bang -complete=mapping TMaps call fzf#vim#maps("t", <bang>0)

  " Add completion to his Maps command but define ours the same way
  command! -bar -bang -nargs=? -complete=mapping NMaps call fzf#vim#maps("n", <bang>0)
  command! -bar -bang -nargs=? -complete=mapping XMaps call fzf#vim#maps("x", <bang>0)
  command! -bar -bang -nargs=? -complete=mapping OMaps call fzf#vim#maps("o", <bang>0)

  command! -bar -bang -nargs=* -complete=color Colo
    \ call fzf#vim#colors({'left': '35%',
    \ 'options': '--reverse --margin 30%,0'}, <bang>0)

" Mappings:
if !exists('*FZFBinding')
  function FZFBinding()
    if exists('*fzf#wrap')
      nnoremap <M-x>                      <Cmd>Commands<CR>
      nnoremap <C-x>B                     <Cmd>Buffers<CR>
      nnoremap <C-x><C-f>                 <Cmd>Files ~/<CR>
    else
      nnoremap <M-x>                      <Cmd>verbose command<CR>
      nnoremap <C-x>B                     <Cmd>buffers<CR>
      nnoremap <C-x><C-f>                 :<C-u>Find ~/**
    endif

    " NOTE: The imap should probably only be invoked using \<tab>
    nmap \<tab>                 <Plug>(fzf-maps-n)
    omap \<tab>                 <Plug>(fzf-maps-o)
    xmap \<tab>                 <Plug>(fzf-maps-x)
    imap \<tab>                 <Plug>(fzf-maps-i)

    " Map Vim Defaults To FZF History Commands:
    nnoremap q:        <Cmd>History:<CR>
    " nnoremap q/        <Cmd>History/<CR>
    nnoremap q/        <Plug>(-fzf-/) /
    " But id still want to use q: when i can
    nnoremap q;        q:

    " Get The Rest Of The FZF Vim Commands Involved:
    nnoremap  <Leader>L         <Cmd>Lines<CR>
    nnoremap  <Leader>fs         <Cmd>Ag <C-R><C-W><CR>
    nnoremap  <Leader>fa         <Cmd>Ag <C-R><C-A><CR>
    xnoremap  <Leader>f         y<Cmd>Ag <C-R>"<CR>
    nnoremap  <Leader>`         <Cmd>Marks<CR>
    " FZF beat fugitive out on this one. Might take git log too.
    nnoremap  <Leader>gg         <Cmd>GGrep<CR>
    nnoremap  <Leader>gl         <Cmd>Commits<CR>
    nnoremap  <Leader>g?         <Cmd>GFiles?<CR>
    nnoremap  <Leader>fb                 <Cmd>Buffers<CR>
    nnoremap  <Leader>fB                 <Cmd>Buffers<CR>

    " Where did all my imaps for this go??
    " Alright let's see how many we can churn out in a sitting Whoo works perfectly!
    inoremap <expr> <C-x><C-b> fzf#vim#complete#buffer_line()
    inoremap <expr> <C-x><C-l> fzf#vim#complete#line()

    if has('unix')
      " unfortunately really doesn't work on windows
      inoremap <expr> <C-x><C-f> fzf#vim#complete#path('fd -H -t f')
    else
      " I don't know why i had an else here but i'm gonna throw in something ramdom
      " i realized i missed
      call msdos#set_shell_cmd()
    endif

    if filereadable(expand('$_ROOT/share/dict/words'))
      " Note: This is dependant on /usr/share/dict/words existing because this
      " function implicitly depends on it.
      " inoremap <expr> <C-x><C-k>         fzf#vim#complete#word({'left': '45%'})
      " Word completion with custom spec with popup layout option
      inoremap <expr> <C-x><C-k>          fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})
    else
    " dictionary isn't set on windows
      inoremap <C-x><C-k> <C-x><C-u>
    " Supertab should've made that mapping pretty sweet.
    endif

    " Is file_ag not a function anymore????
    inoremap <expr> <C-x><C-j> fzf#vim#complete#file()

    " i'm not really sure what this is gonna do but let's find out!
    inoremap <expr> <M-c> <Plug>(-fzf-complete-trigger)
    inoremap <expr> <C-x><C-j> fzf#vim#complete#path('fd -H -t f')
    inoremap <expr> <C-x><C-w> fzf#vim#complete#path('rg --files')

    function! s:make_sentence(lines)
      return substitute(join(a:lines), '^.', '\=toupper(submatch(0))', '').'.'
    endfunction

    " TODO: windows paths
    inoremap <expr> <C-x><C-s> fzf#vim#complete({
      \ 'source': 'cat ~/.config/nvim/spell/en.utf-8.add $_ROOT/share/dict/words 2>/dev/null',
      \ 'reducer': function('<sid>make_sentence'),
      \ 'options': '--ansi --cycle --multi --reverse --margin 15%,0',
      \ 'left':    20})

    " Reminder: Leader<tab>
    nnoremap <Leader>m   <Cmd>Maps<CR>

    nnoremap <Leader>fg  <Cmd>Files ~/ <CR>
  endfunction
endif

" Requires nvim currently because of our use of the <Cmd> mapping
if !exists('no_plugin_maps') && !exists('no_fzf_vim_maps') && has('nvim')
  call FZFBinding()
  " toggle on to stop loading maps
  " let g:no_fzf_vim_maps = 1
endif

" Vim: set fdm=indent:
