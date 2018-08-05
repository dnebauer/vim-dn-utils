" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

if exists('b:disable_dn_utils') && b:disable_dn_utils | finish | endif
if exists('s:loaded') | finish | endif
let s:loaded = 1
let g:loaded_dn_utils = v:true  " for backwards compatibility

let s:save_cpo = &cpoptions
set cpoptions&vim
" }}}1

" Commands

" Scriptnames  - display script names in quickfix window    {{{1

""
" Displays script names in a quickfix window (|:ccl| to close). Calls
" @function(dn#util#scriptnames).
command! -bar Scriptnames
            \ call setqflist(dn#util#scriptnames())|copen

" Filetypes    - display fileypes in echo area    {{{1

""
" Displays all available filetypes in the echo area. Calls
" @function(dn#util#showFiletypes).
command Filetypes call dn#util#showFiletypes()

" Runtimepaths - display runtime paths in echo area    {{{1

""
" Displays runtime paths in the echo area. Calls
" @function(dn#util#showRuntimepaths).
command Runtimepaths call dn#util#showRuntimepaths()
" }}}1

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: set foldmethod=marker :
