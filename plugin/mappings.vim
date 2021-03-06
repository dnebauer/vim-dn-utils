" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

if exists('b:disable_dn_utils') && b:disable_dn_utils | finish | endif
if exists('s:loaded') | finish | endif
let s:loaded = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" Documentation    {{{1
" - vimdoc does not automatically generate a mappings section

""
" @section Mappings, mappings
"
" [NIV]<Leader>ic
"   * change current line or selection to initial caps
"
" [NIV]<Leader>cc
"   * change header case of current line or selection
"   * calls @function(dn#util#changeHeaderCaps)
"
" [NI]<Leader>help
"   * display user help
"   * calls @function(dn#util#help)

" }}}1

" Mappings

" \cc   - change header case    {{{1
if !hasmapto('<Plug>DnHCI')
    imap <buffer> <unique> <LocalLeader>cc <Plug>DNHCI
endif
imap <buffer> <unique> <Plug>DNHCI
            \ <Esc>:call dn#util#changeHeaderCaps('i')<CR>
if !hasmapto('<Plug>DnHCN')
    nmap <buffer> <unique> <LocalLeader>cc <Plug>DNHCN
endif
nmap <buffer> <unique> <Plug>DNHCN
            \ :call dn#util#changeHeaderCaps('n')<CR>
if !hasmapto('<Plug>DnHCV')
    vmap <buffer> <unique> <LocalLeader>cc <Plug>DNHCV
endif
vmap <buffer> <unique> <Plug>DNHCV
            \ :call dn#util#changeHeaderCaps('v')<CR>

" \ic   - initial caps in selection or line    {{{1
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

" \help - provide user help    {{{1
if !hasmapto('<Plug>DnHI')
	imap <buffer> <unique> <LocalLeader>help <Plug>DnHI
endif
imap <buffer> <unique> <Plug>DnHI
            \ <Esc>:call dn#util#help(v:true)<CR>
if !hasmapto('<Plug>DnHN')
	nmap <buffer> <unique> <LocalLeader>help <Plug>DnHN
endif
nmap <buffer> <unique> <Plug>DnHN :call dn#util#help()<CR>
" }}}1

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim:foldmethod=marker:
