" Title:   Vim utility functions
" Author:  David Nebauer
" URL:     https://github.com/dnebauer/vim-dn-utils

" Load only once                                                       {{{1
if exists('g:loaded_dn_utils') | finish | endif
let g:loaded_dn_utils = 1

" Save cpoptions                                                       {{{1
" - avoids unpleasantness from customised 'compatible' settings
let s:save_cpo = &cpoptions
set cpoptions&vim

" Boolean variables                                                    {{{1
let g:dn_true  = 1
let g:dn_false = 0

" Help variables                                                       {{{1
if !exists('g:dn_help_plugins') | let g:dn_help_plugins = [] | endif
call add(g:dn_help_plugins, 'dn-utils')
if !exists('g:dn_help_topics') | let g:dn_help_topics = {} | endif
let g:dn_help_topics['vim'] = {'version control': 'vim_version_control'}
if !exists('g:dn_help_data') | let g:dn_help_data = {} | endif

" Mappings                                                             {{{1
" \ic : initial caps in selection or line                              {{{2
if !hasmapto('<Plug>DnICI')
	imap <buffer> <unique> <LocalLeader>ic <Plug>DnICI
endif
    " insert mode:
    " go to normal mode (<Esc>),
    " set mark v (mv),
    " select row (V),
    " make it lowercase (u),
    " global substitute (:s/) in line of character (.) at
    "   start of words (\<) with uppercased (\u) versions
    "   of each matched character (&),
    " return to mark (`v), and
    " return to insert mode (a)
imap <buffer> <unique> <Plug>DnICI <Esc>mvVu:s/\<./\u&/<CR>`va
if !hasmapto('<Plug>DnICN')
	nmap <buffer> <unique> <LocalLeader>ic <Plug>DnICN
endif
    " normal mode:
    " set mark v (mv),
    " select row (V),
    " make it lowercase (u),
    " global substitute (:s/) in line of character (.) at
    "   start of words (\<) with uppercased (\u) versions
    "   of each matched character (&), and
    " return to mark (`v)
nmap <buffer> <unique> <Plug>DnICN mvVu:s/\<./\u&/<CR>`v
if !hasmapto('<Plug>DnICV')
	vmap <buffer> <unique> <LocalLeader>ic <Plug>DnICV
endif
    " visual mode:
    " set mark v (mv),
    " make selected text lowercase (u),
    " reselect text (gv) before substitution,
    " global substitute (:s/) in selected text (\%V) of
    "   character (.) at start of words (\<) with
    "   uppercased (\u) versions of each matched
    "   character (&), and
    " return to mark (`v)
vmap <buffer> <unique> <Plug>DnICV mvugv:s/\%V\<./\u&/<CR>`v

" \hc : change header case                                             {{{2
if !hasmapto('<Plug>DnHCI')
    imap <buffer> <unique> <LocalLeader>hc <Plug>DNHCI
endif
imap <buffer> <unique> <Plug>DNHCI
            \ <Esc>:call dn#util#changeHeaderCaps('i')<CR>
if !hasmapto('<Plug>DnHCN')
    nmap <buffer> <unique> <LocalLeader>hc <Plug>DNHCN
endif
nmap <buffer> <unique> <Plug>DNHCN
            \ :call dn#util#changeHeaderCaps('n')<CR>
if !hasmapto('<Plug>DnHCV')
    vmap <buffer> <unique> <LocalLeader>hc <Plug>DNHCV
endif
vmap <buffer> <unique> <Plug>DNHCVi
            \ :call dn#util#changeHeaderCaps('v')<CR>

" \hh : provide user help                                              {{{2
if !hasmapto('<Plug>DnHI')
	imap <buffer> <unique> <LocalLeader>hh <Plug>DnHI
endif
imap <buffer> <unique> <Plug>DnHI
            \ <Esc>:call dn#util#help(g:dn_true)<CR>
if !hasmapto('<Plug>DnHN')
	nmap <buffer> <unique> <LocalLeader>hh <Plug>DnHN
endif
nmap <buffer> <unique> <Plug>DnHN :call dn#util#help()<CR>

" \tt : execute test function                                          {{{2
if !hasmapto('<Plug>DnTI')
	imap <buffer> <unique> <LocalLeader>tt <Plug>DnTI
endif
imap <buffer> <unique> <Plug>DnTI
            \ <Esc>:call dn#util#testFn()<CR>
if !hasmapto('<Plug>DnTN')
	nmap <buffer> <unique> <LocalLeader>tt <Plug>DnTN
endif
nmap <buffer> <unique> <Plug>DnTN
            \ :call dn#util#testFn()<CR>
if !hasmapto('<Plug>DnTV')
	vmap <buffer> <unique> <LocalLeader>tt <Plug>DnTV
endif
vmap <buffer> <unique> <Plug>DnTV
            \ :call dn#util#testFn()<CR>

" Commands                                                             {{{1
" Scriptnames : display script names in quickfix window                {{{2
command! -bar Scriptnames
            \ call setqflist(dn#util#scriptnames())|copen
" Filetypes : display fileypes in echo area                            {{{2
command Filetypes call dn#util#showFiletypes()

" Restore cpoptions                                                    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo                                                     " }}}1

" vim: set foldmethod=marker :
