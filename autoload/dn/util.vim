" Title:   autoload script for vim-dn-utils plugin
" Author:  David Nebauer
" URL:     https://github.com/dnebauer/vim-dn-utils

" Load once    {{{1
if exists('g:loaded_dn_utils_autoload') | finish | endif
let g:loaded_dn_utils_autoload = 1

" Save coptions    {{{1
let s:save_cpo = &cpoptions
set cpoptions&vim

" Temporary file    {{{1
if !exists('s:temp_file')
    let s:temp_file = tempname()
endif

" Script variables    {{{1
" temporary file (as above)    {{{2
" submenu token    {{{2
let s:submenu_token = '__!_SUBMENU_!_TOKEN_!__'

" Public functions    {{{1

" Dates    {{{2
" dn#util#insertCurrentDate([insert_mode])    {{{3
" does:   insert current date in ISO format
" params: insert - whether called from insert mode
"                  [optional, default=false, boolean]
" insert: current date in ISO format (yyyy-mm-dd) [string]
" return: nil
function! dn#util#insertCurrentDate(...) abort
    " if call from command line then move cursor left
    if !(a:0 > 0 && a:1) | execute 'normal! h' | endif
    " insert date
    execute 'normal! a' . s:_currentIsoDate()
    " if finishing in insert mode move cursor to right
    if a:0 > 0 && a:1 | execute 'normal! l' | startinsert | endif
endfunction

" dn#util#nowYear()    {{{3
" does:   get current year
" params: nil
" insert: nil
" return: current year (yyyy) [integer]
function! dn#util#nowYear() abort
    return strftime('%Y')
endfunction

" dn#util#nowMonth()    {{{3
" does:   get current month
" params: nil
" insert: nil
" return: current month (m) [integer]
function! dn#util#nowMonth() abort
    return substitute(strftime('%m'), '^0', '', '')
endfunction

" dn#util#nowDay()    {{{3
" does:   get current day in month
" params: nil
" insert: nil
" return: current day in month (d) [integer]
function! dn#util#nowDay() abort
    return substitute(strftime('%d'), '^0', '', '')
endfunction

" dn#util#dayOfWeek(year, month, day)    {{{3
" does:   get name of weekday
" params: year  - year [integer]
"         month - month number [integer]
"         day   - day number [integer]
" insert: nil
" return: name of weekday [string]
function! dn#util#dayOfWeek(year, month, day) abort
    if !s:_validCalInput(a:year, a:month, a:day) | return '' | endif
    let l:doomsday = s:_yearDoomsday(a:year)
    let l:month_value = s:_monthValue(a:year, a:month)
    let l:day_number = (a:day - l:month_value + 14 + l:doomsday) % 7
    let l:day_number = (l:day_number == 0)
                \ ? 7
                \ : l:day_number
    return s:_dayValue(l:day_number)
endfunction

" File/directory    {{{2
" dn#util#getFilePath()    {{{3
" does:   get filepath of file being edited
" params: nil
" return: filepath [string]
function! dn#util#getFilePath() abort
    return expand('%:p')
endfunction

" dn#util#getFileDir()    {{{3
" does:   get directory of file being edited
" params: nil
" return: directory [string]
function! dn#util#getFileDir() abort
    return expand('%:p:h')
endfunction

" dn#util#getFileName()    {{{3
" does:   get name of file being edited
" params: nil
" return: directory [string]
function! dn#util#getFileName() abort
    return expand('%:p:t')
endfunction

" dn#util#getRtpDir(name, [multiple])    {{{3
" does:   finds directory in runtimepath
" params: name     - directory name [string]
"         multiple - allow multiples [boolean,optional, default=false]
" return: default: filepath [string], '0' if failure
"         multiple=true: filepaths [List], [] if failure
" note:   default behaviour is to return a single filepath
"         if multiple matches found get user to select one
"         if allow multiples, return list (even if only one match)
function! dn#util#getRtpDir(name, ...) abort
    " set vars
    if a:0 > 1 && a:1 | let l:allow_multiples = g:dn_true
    else              | let l:allow_multiples = g:dn_false
    endif
    if a:name ==? ''
        if l:allow_multiples | return []
        else                 | return
        endif
    endif
    " search for directory
    let l:matches = globpath(&runtimepath, a:name, g:dn_true, g:dn_true)
    " if allowing multiple matches
    if l:allow_multiples
        return l:matches
    endif
    " if insisting on single directory
    if     len(l:matches) == 0 | return
    elseif len(l:matches) == 1 | return l:matches[0]
    endif
    return dn#util#menuSelect(l:matches, 'Select directory path:')
endfunction

" dn#util#getRtpFile(name, [multiple])    {{{3
" does:   finds file under directories in runtimepath
" params: name     - file name [required, string]
"         multiple - allow multiples [boolean, optional, default=false]
" return: default: filepath [string], '0' if failure
"         multiple=true: filepaths [List], [] if failure
" note:   default behaviour is to return a single filepath
"         if multiple matches found get user to select one
"         if allow multiples, return list (even if only one match)
function! dn#util#getRtpFile(name, ...) abort
    " set vars
    let l:allow_multiples = (a:0 > 1 && a:1) ? g:dn_true : g:dn_false
    if a:name ==? ''
        if   l:allow_multiples | return []
        else                   | return
        endif
    endif
    " search for directory
    let l:search_term = '**/' . a:name
    let l:matches_raw = globpath(&runtimepath, l:search_term, 1, 1)
    " - globpath can produce duplicates
    let l:matches = filter(
                \ copy(l:matches_raw),
                \ 'index(l:matches_raw, v:val, v:key+1) == -1'
                \ )
    " if allowing multiple matches
    if l:allow_multiples
        return l:matches
    endif
    " if insisting on single file
    if     len(l:matches) == 0 | return
    elseif len(l:matches) == 1 | return l:matches[0]
    endif
    return dn#util#menuSelect(l:matches, 'Select file path:')
endfunction

" User interaction    {{{2
" dn#util#showMsg(msg, [type])    {{{3
" does:   display message to user
" params: 1 - message [string]
"         2 - message type [allowed values='generic'|'warning'|'info'|
"             'question'|'error', optional, string]
" return: nil
function! dn#util#showMsg(msg, ...) abort
    let l:msg = a:msg
    let l:valid_types =    {'warning': 1, 'info': 1, 'question': 1, 'error': 1}
    let l:type = ''
    " sanity check
    let l:error = 0
    if l:msg ==? ''
        let l:msg = "No message supplied to 'dn#util#showMsg'"
        let l:error = 1
        let l:type = 'Error'
    endif
    " set dialog type (if valid type supplied and not overridden by error)
    if !l:error && a:0 > 0 && has_key(l:valid_types, tolower(a:1))
        let l:type = tolower(a:1)
    endif
    " for non-gui environment add message type to output
    if !has ('gui_running') && l:type !=? ''
        let l:msg = toupper(strpart(l:type, 0, 1))
                    \ . tolower(strpart(l:type, 1))
                    \ . ': '
                    \ . l:msg
    endif
    " display message
    call confirm(l:msg, '&OK', 1, l:type)
endfunction

" dn#util#error(msg)    {{{3
" does:   display error message
" params: msg - error message [required, string or List]
" insert: nil
" prints: error msg in error highlighting accompanied by system bell
" return: nil
function! dn#util#error(msg) abort
    " require double quoting of execution string so backslash
    " is interpreted as an escape token
    if mode() ==# 'i' | execute "normal! \<Esc>" | endif
    " create List of messages
    let l:msgs = s:_listifyMsg(a:msg)
    " output messages
    echohl ErrorMsg
    for l:msg in l:msgs | echo l:msg | endfor
    echohl Normal
endfunction

" dn#util#warn(msg)    {{{3
" does:   display warning message
" params: msg - warning message [string]
" insert: nil
" prints: warning msg in warning highlighting accompanied by system bell
" return: nil
function! dn#util#warn(msg) abort
    if mode() ==# 'i' | execute "normal! \<Esc>" | endif
    echohl WarningMsg
    echo a:msg
    echohl Normal
endfunction

" dn#util#prompt([prompt])    {{{3
" does:   display prompt message
" params: prompt - prompt [default='Press [Enter] to continue...',
"                  optional, string]
" insert: nil
" prints: messages
" return: nil
function! dn#util#prompt(...) abort
    " variables
    if a:0 > 0 | let l:prompt = a:1
    else       | let l:prompt = 'Press [Enter] to continue...'
    endif
    " display prompt
    echohl MoreMsg
    call input(l:prompt)
    echohl Normal
    echo "\n"
endfunction

" dn#util#wrap(msg)    {{{3
" does:   echoes text but wraps it sensibly
" params: msg  - message [string]
"         hang - hanging indent size [integer, optional, default=0]
" insert: nil
" prints: messages
" return: nil
function! dn#util#wrap(msg, ...) abort
    " variables
    let l:width = winwidth(0) - 1
    let l:msg = a:msg
    let l:hang_size = 0
    if a:0 > 0 && dn#util#validPosInt(a:1) && (l:width - a:1) > 10
        let l:hang_size = a:1
    endif
    let l:hang_indent = ''
    while l:hang_size > 0
        let l:hang_indent .= ' '
        let l:hang_size -= 1
    endwhile
    " deal with simple case of no input
    if a:msg ==? ''
        echon "\n"
        return
    endif
    " process for wrapping
    let l:first_line = g:dn_true
    while l:msg !=? ''
        " exit on last output line
        if len(l:msg) <= l:width
            if !l:first_line
                let l:msg = l:hang_indent . l:msg
            endif
            echo l:msg
            break
        endif
        " find wrap point
        let l:break = -1 | let l:count = 1 | let l:done = g:dn_false
        while !l:done
            let l:index = match(l:msg, '[!@*\-+;:,./?\\ \t]', '', l:count)
            if     l:index == -1     | let l:done = g:dn_true
            elseif l:index < l:width | let l:break = l:index
            endif
            let l:count += 1
        endwhile
        " if no wrap point then have ugly situation where no breakpoint
        " exists so just output whole thing (ick!)
        if l:break == -1 | echo l:msg | break | endif
        " let's wrap!
        let l:break += 1
        let l:output = strpart(l:msg, 0, l:break)
        if !l:first_line
            let l:output = l:hang_indent . l:output
        endif
        echo l:output
        let l:msg = strpart(l:msg, l:break)
        " - if broke line on punctuation mark may now have leading space
        if strpart(l:msg, 0, 1) ==? ' '
            let l:msg = strpart(l:msg, 1)
        endif
        let l:first_line = g:dn_false
    endwhile
endfunction

" dn#util#menuSelect(items, [prompt])    {{{3
" does:   select item from menu
" params: items  - menu items [List,Dict]
"         prompt - prompt [default='Select an option:', optional, string]
" insert: nil
" return: selected menu item ("" means no item selected) [string]
" warning:if an empty menu item is provided it can be selected and returned
"         and there is no way to distinguish this from an aborted selection
" note:   with dicts the keys become menu options and the corresponding
"         value is the return value
" note:   lists and dicts can have lists and dicts as elements/values
" note:   in addition, a list can contain as elements single-item dicts with
"         simple values; the dict key becomes the menu item and the dict value
"         is the value returned if the corresponding menu item is selected
" note:   when a list has list or dict child elements the child element must
"         be preceded by an element consisting of the submenu token (see
"         script variable s:submenu_token) and an element containing the
"         submenu header (which becomes the parent menu item that, when
"         selected, opens the submenu) -- so, a submenu is defined by three
"         consecutive elements:
"           submenu_token, submenu_header, submenu_dict_or_list_variable
" note:   when a dict has list or dict child elements there is no need for
"         the child elements to provide the parent menu item, i.e., they
"         contain only the contents of the child menu
" note:   to indicate a submenu this function appends an arrow (->) to the
"         end of the parent menu option
function! dn#util#menuSelect(items, ...) abort
    " set menu type
    if     type(a:items) == type([]) | let l:menu_type = 'list'
    elseif type(a:items) == type({}) | let l:menu_type = 'dict'
    else
        call dn#util#error('Parent menu must be List or Dict')
        return ''
    endif
    " - check supplied menu items
    if len(a:items) == 0 | return '' | endif |    " must have menu items
    " - prompt
    let l:prompt = 'Select an option:'    " default used if none provided
    if a:0 > 0 && a:1 !=? '' | let l:prompt = dn#util#stringify(a:1) | endif
    " - submenu token (used in lists)
    let s:submenu_token = '__!_SUBMENU_!_TOKEN_!__'
    " process items to build parallel lists of options and return values
    let l:state = (l:menu_type ==# 'list') ? 'list_expecting-option'
                \                          : 'dict_expecting-option'
    let l:items = (l:menu_type ==# 'list') ? deepcopy(a:items)
                \                          : keys(a:items)
    let l:submenu_header = ''
    let l:options = [l:prompt] | let l:return_values = []
    for l:Item in l:items
        " what kind of item do we have?
        if     s:_menuSimpleType(l:Item)  | let l:item_type = 'simple'
        elseif s:_menuSubmenuType(l:Item) | let l:item_type = 'submenu'
        else
            let l:msg = 'Invalid data type ' . type(l:Item)
                        \ . " for menu item:\n\n"
            call dn#util#error(l:msg . dn#util#stringify(l:Item))
            return ''
        endif
        " list menu item might be:
        " - simple data item, which includes submenu flag
        " - list (must be an expected submenu)
        " - dict (might be an expected submenu)
        " - dict (might be an option:return-value pair,
        "         but if so can only be a single key:value pair)
        if     l:state ==# 'list_expecting-submenu-header'
            if l:item_type !=# 'simple'  " need simple value
                let l:msg = "Expecting submenu header but got submenu:\n\n"
                call dn#util#error(l:msg . dn#util#stringify(l:Item))
                return ''
            endif
            let l:submenu_header = l:Item . ' ->'
            let l:state = 'list_expecting-submenu'
            unlet l:Item  " in case a:items elements are of different types
            continue
        elseif l:state ==# 'list_expecting-submenu'
            if l:item_type !=# 'submenu'  " need list or dict
                let l:msg = 'Expecting submenu but got: ' . l:Item
                call dn#util#error(l:msg)
                return ''
            endif
            call add(l:options, dn#util#stringify(l:submenu_header))
            call add(l:return_values, l:Item)
            let l:state = 'list_expecting-option'
            unlet l:Item  " a:items elements may be of different types
            continue
        elseif l:state ==# 'list_expecting-option'
            " can be a simple data type
            if l:item_type ==# 'simple'
                if l:Item ==# s:submenu_token  " submenu coming
                    let l:state = 'list_expecting-submenu-header'
                else  " simple menu option
                    call add(l:options, dn#util#stringify(l:Item))
                    call add(l:return_values, l:Item)
                endif
                unlet l:Item  " a:items elements may be of different types
                continue
            endif
            " can be a simple single-pair dict
            if type(l:Item) == type({})
                " ignore empty dict
                if len(l:Item) == 0 | continue | endif
                " cannot have multiple entries
                if len(l:Item) > 1
                    let l:msg = "Multiple entries in dict menu option:\n\n"
                    call dn#util#error(l:msg . dn#util#stringify(l:Item))
                    return ''
                endif
                " value must be a simple data type
                let l:option = items(l:Item)[0][0]
                let l:retval = items(l:Item)[0][1]
                if !s:_menuSimpleType(l:retval)
                    let l:msg = "Menu item return value is not simple:\n\n"
                    call dn#util#error(l:msg . dn#util#stringify(l:retval))
                    return ''
                endif
                " okay, looks good
                call add(l:options, dn#util#stringify(l:option))
                call add(l:return_values, l:retval)
                unlet l:Item  " a:items elements may be of different types
                continue
            endif
            " if reached here then invalid menu option
            let l:msg = "Invalid list menu option:\n\n"
            call dn#util#error(l:msg . dn#util#stringify(l:Item))
            return ''
        elseif l:state ==# 'dict_expecting-option'
            " dict menu item can only be simple
            " - it comes from a Dict key and vim won't permit otherwise
            " but dict return value, i.e., Dict value, can be anything
            " so, check return value is valid
            let l:retval = a:items[l:Item]
            if !s:_menuType(l:retval)
                let l:msg = "Invalid menu dict value:\n\n"
                call dn#util#error(l:msg . dn#util#stringify(l:retval))
                return ''
            endif
            " modify menu option if it is a submenu header
            let l:option = l:Item
            if s:_menuSubmenuType(l:retval) | let l:option .= ' ->' | endif
            " add option and return value
            call add(l:options, dn#util#stringify(l:option))
            call add(l:return_values, l:retval)
            unlet l:Item  " a:items elements may be of different types
            continue
        else  " unexpected state reached (programmer error!)
            call dn#util#error('Menu reached unexpected state: ' . l:state)
            return ''
        endif
    endfor
    " prepend index to menu options
    let l:len = len(len(l:options))  " gives width of largest item index
    let l:index = 1  " no item number for prompt (in index 0)
    while l:index < len(l:options)
        " - left pad index with spaces to ensure all right justified
        let l:display_index = l:index
        while len(l:display_index) < l:len
            let l:display_index = ' ' . l:display_index
        endwhile
        let l:options[l:index] = l:display_index . ') ' . l:options[l:index]
        let l:index += 1
    endwhile
    " make choice
    let l:choice = inputlist(l:options)
    echo ' ' |    " needed to force next output to new line
    " process choice
    " - must be valid selection
    if l:choice <= 0 || l:choice >= len(l:options)
        return ''
    endif
    " - get selected value
    "   . no prompt added to l:return_values,
    "     so is 'off by one' compared to l:options
    let l:Selection = l:return_values[l:choice - 1]
    " - recurse if selected a submenu, otherwise return selection
    if s:_menuSubmenuType(l:Selection)
        return dn#util#menuSelect(l:Selection, l:prompt)  " recurse
    else
        return l:Selection
    endif
endfunction

" dn#util#menuAddOption(menu, option, [retval])    {{{3
" does:   add option to menu used with dn#util#menuSelect
" params: menu   - menu variable [required, List or Dict]
"         option - menu option [required, String or Number or Float]
"         retval - return value [optional, String or Number or Float]
" insert: nil
" return: nil, menu variable is edited in place
" usage:  call dn#util#menuAddSubmenu(l:menu, l:header, l:submenu)
function! dn#util#menuAddOption(...) abort
    " process parameters
    " - must have 2 or 3 items (menu + option +/- retval)
    if a:0 == 0
        call dn#util#error('No menu to add option to')
        return
    endif
    if a:0 > 3
        call dn#util#error('Too many options to add to menu')
        return
    endif
    let l:menu = a:1
    if !s:_menuSubmenuType(l:menu)
        let l:msg = "Invalid menu variable:\n\n"
        call dn#util#error(l:msg . dn#util#stringify(l:menu))
        return
    endif
    let l:option = a:2
    if !s:_menuSimpleType(l:option)
        let l:msg = 'Invalid option (data type ' . type(l:option) . "):\n\n"
        call dn#util#error(l:msg . dn#util#stringify(l:option))
        return
    endif
    let l:retval = (a:0 == 3) ? a:3 : l:option
    if !s:_menuSimpleType(l:retval)
        let l:msg = 'Invalid return value (data type ' . type(l:retval)
                    \ . "):\n\n"
        call dn#util#error(l:msg . dn#util#stringify(l:retval))
        return
    endif
    " add option
    let l:item =    {}
    let l:item[l:option] = l:retval
    if   type(l:menu) == type([])  " list
        call add(l:menu, l:item)
    else  " dict
        call extend(l:menu, l:item)
    endif
endfunction

" dn#util#menuAddSubmenu(menu, header, submenu)    {{{3
" does:   add submenu to menu used with dn#util#menuSelect
" params: menu    - menu variable [required, List or Dict]
"         header  - submenu header [required, String]
"         submenu - return value [required, List or Dict]
" insert: nil
" return: nil, menu variable is edited in place
" usage:  call dn#util#menuAddSubmenu(l:menu, l:header, l:submenu)
function! dn#util#menuAddSubmenu(menu, header, submenu) abort
    " process parameters
    if empty(a:submenu) | call dn#util#error('No submenu provided') | endif
    if empty(a:header)  | call dn#util#error('No header provided')  | endif
    if empty(a:submenu) | call dn#util#error('No menu provided')    | endif
    if !s:_menuSubmenuType(a:submenu)
        let l:msg = "Invalid submenu variable:\n\n"
        call dn#util#error(l:msg . dn#util#stringify(a:submenu))
        return
    endif
    if !s:_menuSimpleType(a:header)
        let l:msg = 'Invalid header variable:' . dn#util#stringify(a:header)
        call dn#util#error(l:msg)
        return
    endif
    if !s:_menuSubmenuType(a:menu)
        let l:msg = "Invalid menu variable:\n\n"
        call dn#util#error(l:msg . dn#util#stringify(a:menu))
        return
    endif
    " add submenu
    if   type(a:menu) == type([])  " list
        let l:item = [g:submenu_token, a:header, a:submenu]
        call extend(a:menu, l:item)
    else  " dict
        if has_key(a:menu, a:header)
            let l:msg = "Overwriting menu item '" . a:header
                        \ . "' in menu variable:\n\n"
            call dn#util#warn(l:msg . dn#util#stringify(a:menu))
        endif
        let a:menu[a:header] = a:submenu
    endif
endfunction

" dn#util#consoleSelect(single, plural, items, [method])    {{{3
" does:   select item from list using the console
" params: single - item singular name [required, string]
"         plural - item plural name [required, string]
"         items  - items to select from [required, List]
"         method - selection method
"                  [default='filter', optional, values='complete'|'filter']
" insert: nil
" return: selected item ("" means no item selected) [string]
" note:   both methods requires perl to be installed on the system
" note:   method 'complete' uses Term::Complete::complete function
"         which uses word completion
" note:   method 'filter' enables the user to type a fragment of
"         the item and uses Term::Clui::choose to enable the user
"         select from a list of matching items
" note:   both methods handle items containing spaces
" usage:  let l:element = dn#util#consoleSelect(
"                   \ 'Element name', 'Element names', l:items 'complete')
function! dn#util#consoleSelect(single, plural, items, ...) abort
    " check variables    {{{4
    for l:var in ['single', 'plural', 'items']
        if empty(a:{l:var})
            echoerr "No '" . l:var . "' parameter provided"
            return ''
        endif
    endfor
    let l:method = 'filter'
    if a:0 >= 1
        if a:0 > 1
            echoerr 'Ignoring extra arguments: ' . join(a:000[1:], ', ')
        endif
        if a:1 =~# '^complete$\|^filter$'
            let l:method = a:1
        else
            echoerr "Invalid method: '" . a:1 . "'"
            return ''
        endif
    endif
    " check required files    {{{4
    " - temporary file must be writable and start empty
    let l:write_result = writefile([], s:temp_file)
    if l:write_result != 0  " -1 = error, 0 = success
        echoerr "Cannot write to temp file '" . s:temp_file . "'"
        return ''
    endif
    " - script file must be located
    let l:script = dn#util#getRtpFile('vim-dn-utils-console-select')
    if l:script ==? ''
        echoerr 'dn-utils: cannot find console-select script'
        return ''
    endif
    " assemble shell command to run script    {{{4
    let l:opts = []
    let l:opts += ['--name-single', a:single]
    let l:opts += ['--name-plural', a:plural]
    let l:opts += ['--output-file', fnameescape(s:temp_file)]
    let l:opts += ['--items', join(a:items, "\t")]
    let l:opts += ['--select-method', l:method]
    call map(l:opts, 'shellescape(v:val)')
    let l:cmd = '!perl' . ' ' . l:script . ' ' . join(l:opts, ' ')
    " run script to select docbook element    {{{4
    silent execute l:cmd
    redraw!
    " retrieve and return result    {{{4
    if ! filereadable(s:temp_file)  " assume script aborted with error
        return ''
    endif
    let l:output = readfile(s:temp_file)
    if     len(l:output) == 0
        return ''
    elseif len(l:output) == 1  " success
        return l:output[0]
    else  " more than one line of output!
        echoerr 'dn-utils: unexpected output:' . l:output
        return ''
    endif
endfunction

" dn#util#help([insert])    {{{3
" does:   user can select from help topics
" params: insert - insert mode [default=false, optional, boolean]
" insert: nil
" return: nil
" note:   extensible help system relying on buffer Dictionary
"         variables g:dn_help_plugins, g:dn_help_topics and g:dn_help_data
" note:   g:dn_help_plugins is a list of all plugins contributing help
" note:   g:dn_help_topics will be submitted to dn#util#menuSelect to
"         obtain a *unique* value
" note:   g:dn_help_data has as keys the unique values returned by
"         g:dn_help_topics and as values Lists with the help text to
"         be returned
" note:   the List help data is output as concatenated text; to insert
"         a newline use an empty lists element ('')
" note:   other plugins can add to the help variables and so take
"         advantage of the help system; the most friendly way to do this
"         is for the g:dn_help_topics variable to have a single top-level
"         menu item reflecting the plugin name/type, and for the topic
"         values to be made unique by appending to each a prefix unique to
"         its plugin
" example:if !exists('g:dn_help_plugins') | let g:dn_help_plugins =    {} | endif
"         if index(g:dn_help_plugins, 'foo', g:dn_true) == -1
"           call add(g:dn_help_plugins, 'foo')
"         endif
"         if !exists('g:dn_help_topics') | let g:dn_help_topics =    {} | endif
"         let g:dn_help_topics['foo'] =    { 'how to wibble': 'foo_wibble' }
"         if !exists('g:dn_help_data') | let g:dn_help_data =    {} | endif
"         let g:dn_help_data['foo_wibble'] = [ 'How to wibble:', '', 'Details...' ]
function! dn#util#help(...) abort
    echo '' | " clear command line
    " variables
    let l:insert = (a:0 > 0 && a:1) ? g:dn_true : g:dn_false
    let l:topic = ''  " help topic selected by user
    " - require basic help variables
    if !exists('g:dn_help_topics')
        call dn#util#error('No help menu variable available')
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    if empty(g:dn_help_topics)
        call dn#util#error('No help topics defined')
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    if !exists('g:dn_help_data')
        call dn#util#error('No help data variable available')
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    if empty(g:dn_help_data)
        call dn#util#error('No help data defined')
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    " brag about help
    echo 'Dn-Utils Help System'
    if exists('g:dn_help_plugins') && !empty(g:dn_help_plugins)
        let l:plugin = (len(g:dn_help_plugins) == 1) ? 'plugin' : 'plugins'
        echon "\n[contributed by " . l:plugin . ': '
        echon join(g:dn_help_plugins, ', ') . "]\n"
    endif
    " select help topic
    let l:prompt = 'Select a help topic:'
    let l:topic = dn#util#menuSelect(g:dn_help_topics, l:prompt)
    if l:topic ==? ''
        call dn#util#error('No help topic selected')
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    if !has_key(g:dn_help_data, l:topic)
        call dn#util#error("No help data for topic '" . l:topic . "'")
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    let l:data = g:dn_help_data[l:topic]
    if type(l:data) != type([])
        let l:msg = "Help data for topic '" . l:topic . "' is not a List"
        call dn#util#error(l:msg)
        if l:insert | call dn#util#insertMode(1) | endif
        return
    endif
    " display help
    redraw  " erase menu output
    let l:more = &more  " want pager for long help
    set more
    let l:msg = ''
    for l:output in l:data
        if l:output ==? '' | call dn#util#wrap(l:msg) | let l:msg = ''
        else               | let l:msg .= l:output
        endif
    endfor
    if l:msg !=? '' | call dn#util#wrap(l:msg) | endif
    if !l:more | set nomore | endif
    " return to calling mode
    if l:insert | call dn#util#insertMode(1) | endif
endfunction

" dn#util#getSelection()    {{{3
" does:   returns selected text
" params: nil
" insert: nil
" return: selected text ('' if no text selected) [string]
" note:   works for all selection types; newlines are preserved
" note:   can return multi-line string -- functions that use return value
"         and are called via a mapping can have range assigned, which may
"         result in function being called once per line if it does not
"         handle the range (see |:call| and |function-range-example|)
function! dn#util#getSelection() abort
    try
        let l:a_save = @a
        normal! gv"ay
        return @a
    finally
        let @a = l:a_save
    endtry
endfunction

" Lists    {{{2
" dn#util#listExchangeItems(list, index1, index2)    {{{3
" does:   exchange two elements in the same list
" params: list    - list to process [List]
"         insert1 - index of first element to exchange [integer]
"         insert2 - index of second element to exchange [integer]
" return: whether successfully exchanged items [boolean]
" note:   by not copying input list are acting on original
function! dn#util#listExchangeItems(list, index1, index2) abort
    if get(a:list, a:index1, ':INVALID:') ==# ':INVALID:' | return | endif
    if get(a:list, a:index2, ':INVALID:') ==# ':INVALID:' | return | endif
    let l:item1 = a:list[a:index1]
    let a:list[a:index1] = a:list[a:index2]
    let a:list[a:index2] = l:item1
    return g:dn_true
endfunction

" dn#util#listSubtract(list_1, list_2)    {{{3
" does:   subtract one list from another
" params: list1 - list to subtract from [List]
"         list2 - list to be subtracted [List]
" return: new list [List]
" note:   performs 'list_1 - list_2'
function! dn#util#listSubtract(list_1, list_2) abort
    let l:list_new = []
    " cycle through major list elements
    " for each, check if in minor list - if not, add to return list
    for l:item in a:list_1
        if !count(a:list_2, l:item)
            call add(l:list_new, l:item)
        endif
    endfor
    return l:list_new
endfunction

" dn#util#listToScreen(list, width, start, delimiter)    {{{3
" does:   formats list for screen display
" params: list      - list to format for display [List]
"         width     - maximum width of text
"                     [default=60, optional, integer]
"         start     - indext at start of line
"                     [default=0, optional, integer]
"         delimiter - delimiter [default=' ', optional, integer]
" return: formatted display [string]
function! dn#util#listToScreen(list, ...) abort
    " determine variables
    let l:delim = ' ' | let l:scrn_width = 60 | let l:indent_len = 0
    if a:0 >= 3 && a:3 !=? '' | let l:delim = a:3 | endif
    if a:0 >= 2 && dn#util#validPosInt(a:2) | let l:indent_len = a:2 | endif
    let l:indent = repeat(' ', l:indent_len)
    if a:0 >= 1 && dn#util#validPosInt(a:1) | let l:scrn_width = a:1 | endif
    let l:msg = ''
    " get max element name length (to reset screen width if necessary)
    let l:max_len = 0
    for l:item in a:list
        let l:item_len = strlen(l:item)
        let l:max_len = (l:item_len > l:max_len) ? l:item_len : l:max_len
    endfor
    let l:max_item_width = l:indent_len + l:max_len
    let l:scrn_width = (l:max_item_width > l:scrn_width)
                \ ? l:max_item_width : l:scrn_width
    " build display
    let l:length = 0 | let l:index = 0
    while get(a:list, l:index, ':INVALID:') !=# ':INVALID:'
        let l:item = get(a:list, l:index)
        if (l:length + strlen(l:item)) > l:scrn_width
            let l:msg = l:msg . "\n"
            let l:length = 0
        endif
        if l:length == 0
            let l:length = l:indent_len + strlen(l:item)
            let l:msg = l:msg . l:indent . l:item
        else
            let l:length = l:length + strlen(l:delim . l:item)
            let l:msg = l:msg . l:delim . l:item
        endif
        let l:index += 1
    endwhile
    " return formatted string
    return l:msg
endfunction

" dn#util#listToScreenColumns(list, [width], [padding], [indent])    {{{3
" does:   formats list for screen display in columns
" params: list    - list to format for display [List]
"         width   - maximum width of text (default: 60)
"                   [optional, integer]
"         padding - size of column padding (default: 1)
"                   note: column width = longest item strlen + padding
"                   [optional, integer]
"         indent  - size of indent at start of each line (default: 0)
"                   [optional, integer]
" return: formatted display [string]
function! dn#util#listToScreenColumns(list, ...) abort
    " determine variables
    let l:scrn_width = 60 | let l:col_padding = 1 | let l:indent_len = 0
    if a:0 >= 3 && dn#util#validPosInt(a:3) | let l:indent_len  = a:3 | endif
    if a:0 >= 2 && dn#util#validPosInt(a:2) | let l:col_padding = a:2 | endif
    if a:0 >= 1 && dn#util#validPosInt(a:1) | let l:scrn_width  = a:1 | endif
    let l:indent = repeat(' ', l:indent_len)
    let l:column_pad = repeat(' ', l:col_padding)
    " get max element name length
    let l:max_len = 0
    for l:item in a:list
        let l:item_len = strlen(l:item)
        let l:max_len = (l:item_len > l:max_len)
                    \ ? l:item_len
                    \ : l:max_len
    endfor
    let l:col_width = l:max_len + l:col_padding
    let l:max_column_width = l:indent_len + l:col_width
    let l:scrn_width = (l:max_column_width > l:scrn_width)
                \ ? l:max_column_width
                \ : l:scrn_width
    " get number of columns
    let l:col_nums = 0 | let l:modulo = l:col_width + 1
    while l:modulo >= l:col_width
        let l:col_nums = l:col_nums + 1
        let l:modulo = l:scrn_width - l:indent - (l:col_width * l:col_nums)
    endwhile
    " build display
    let l:col_num = 1 | let l:msg = '' | let l:index = 0
    while get(a:list, l:index, ':INVALID:') !=# ':INVALID:'
        let l:item = get(a:list, l:index)
        if l:col_num > l:col_nums  " add CR to end of line
            let l:msg = l:msg . "\n"
            let l:col_num = 1
        endif
        if l:col_num == 1  " add indent before col 1 and pad before other cols
            let l:msg = l:msg . l:indent
        else
            let l:msg = l:msg . l:column_pad
        endif
        while strlen(l:item) < l:col_width  " pad item to col width
            let l:item = l:item . ' '
        endwhile
        let l:msg = l:msg . l:item
        let l:col_num = l:col_num + 1  " increment column number
        let l:index += 1
    endwhile
    return dn#util#trimChar(l:msg)  " remove trailing spaces
endfunction

" Programming    {{{2
" dn#util#unusedFunctions([silent], [lower], [upper])    {{{3
" does:   checks for uncalled vim functions
" params: silent - suppress user feedback
"                  [optional, default=0, boolean]
"         lower  - lower line boundary within which to search
"                  [optional, default=1, integer]
"         upper  - upper line boundary within which to search
"                  [optional, default=last line, integer]
" return: list of unused functions [List]
function! dn#util#unusedFunctions(...) abort
    " only intended for vim scripts
    if &filetype !=# 'vim'
        echoerr 'dn#util#unusedFunctions() work only on vim scripts'
        return ''
    endif
    try
        " variables
        let l:errmsg  = ''
        let l:cursors = []
        call add(l:cursors, getpos('.'))
        let l:silent = 0
        let l:lower  = 1
        let l:upper  = line('$')
        if a:0 >= 1 && a:1 | let l:silent = 1 | endif
        if a:0 >= 2 && dn#util#validPosInt(a:2)
            let l:lower = (a:2 > 1) ? (a:2 - 1) : 1
        endif
        if a:0 >= 2 && dn#util#validPosInt(a:2)
            let l:upper = (a:2 <= l:upper) ? a:2 : l:upper
        endif
        if l:upper <= l:lower
            let l:errmsg = 'Upper bound must be greater then lower bound'
            throw ''
        endif
        let l:index = l:lower
        let l:unused = []
        " remove folds
        execute 'normal! zR'
        " time to start iterating through range
        call cursor(l:lower, 1)
        " find next function
        let l:func_decl = '^\s\{}fu\%[nction]\s\{1,}\p\{1,}('
        while search(l:func_decl, 'W') && line('.') <= l:upper
            " extract function name
            let l:func_start = line('.')
            let l:line = getline('.')
            let l:func_name = substitute(
                        \ 	l:line,
                        \ 	'^\s\{}fu\%[nction]\s\{1,}\(\p\{1,}\)(\p\{}$',
                        \ 	'\1',
                        \ 	''
                        \ )
            " remove 's:' prefix if present
            let l:func_srch = substitute(
                        \ 	l:func_name,
                        \ 	'^s:\(\p\{}\)$',
                        \ 	'\1',
                        \ 	''
                        \ )
            " find end of function
            let l:end_decl = '^\s\{}endf\%[unction]\s\{}$'
            call search(l:end_decl, 'W')
            let l:func_end = line('.')
            if l:func_start == l:func_end
                let l:errmsg = "Could not find 'endfunction' for function '"
                            \ . l:func_name . "'"
                throw ''
            endif
            " now find whether function ever called
            call cursor(l:lower, 1)
            let l:called = g:dn_false
            while search(l:func_srch . '(', 'W')
                        \ && line('.') <= l:upper
                let l:line_num = line('.')
                let l:line = getline('.')
                " must ensure match is not part of function declaration ...
                if !(l:line_num >= l:func_start
                            \ && l:line_num <= l:func_end)
                    " ... and not part of comment
                    let l:comment = '"[^"]\p\{-}'
                                \ . l:func_srch
                                \ . '[^"]\{}$'
                    if match(l:line, l:comment) == -1
                        let l:called = g:dn_true
                        break
                    endif
                endif
                call cursor(line('.') + 1, 1)
            endwhile
            " report if not called
            if !l:called
                let l:unused = add(l:unused, l:func_name)
            endif
            " position ourselves at end of last found function
            call cursor(l:func_end, 1)
        endwhile
        " should now have list of uncalled functions
        if empty(l:unused)
            let l:msg = 'There are no unused functions'
        else
            let l:msg = 'Declared but unused functions:' . "\n"
                        \ . '[Warning: Algorithm is imperfect -- '
                        \ . 'check before deleting!]'
                        \ . "\n\n"
                        \ . dn#util#listToScreenColumns(l:unused, 1)
        endif
        if !l:silent | echo l:msg | endif
    catch
        let l:errmsg = (l:errmsg !=? '') ? l:errmsg
                    \ : 'Unhandled exception occurred'
        call dn#util#showMsg(l:errmsg, 'Error')
    finally
        return l:unused
    endtry
endfunction

" dn#util#insertMode([skip])    {{{3
" does:   switch to insert mode
" params: skip - right skip [optional, integer]
" insert: nil
" return: nil
" note:   this function is often used by other functions if they were
"         called from insert mode; in such cases it will usually be
"         invoked with one right skip to compensate for the left skip
"         that occured when initially escaping from insert mode
function! dn#util#insertMode(...) abort
    let l:right_skip = (a:0 > 0 && a:1 > 0)
                \ ? a:1
                \ : 0
    " override skip if cursor at eol to prevent error beep
    if col('.') >= strlen(getline('.')) | let l:right_skip = 0 | endif
    " skip right if so instructed
    if l:right_skip > 0
        silent execute 'normal! ' . l:right_skip . 'l'
    endif
    " handle case where cursor at end of line
    if col('.') >= strlen(getline('.')) | startinsert! " =~# 'A'
    else                                | startinsert  " =~# 'i'
    endif
endfunction

" dn#util#executeShellCommand(cmd, [msg])    {{{3
" does:   execute shell command
" params: cmd - shell command [required, string]
"         msg - error message [optional, List, default='Error occured:']
" prints: if error display user error message and shell feedback
" return: return status of command as vim boolean
function! dn#util#executeShellCommand(cmd, ...) abort
    echo '' | " clear command line
    " variables
    let l:errmsg = (a:0 > 0) ? a:1 : ['Error occurred:']
    " run command
    let l:shell_feedback = system(a:cmd)
    " if failed display error message and shell feedback
    if v:shell_error
        echo ' ' |    " previous output was echon
        for l:line in l:errmsg
            call dn#util#error(l:line)
        endfor
        echo '--------------------------------------'
        echo l:shell_feedback
        echo '--------------------------------------'
        return
    else
        return g:dn_true
    endif
endfunction

" dn#util#scriptnames()    {{{3
" does:   prepare quickfix output for the quickfix list
" params: nil
" return: content for quickfix window [List of Dicts]
" note:   intended to be used by :Scriptnames command,
"         so not included in help file
" credit: adapted from tpope's vim-scriptease plugin at
"         https://github.com/tpope/vim-scriptease
function! dn#util#scriptnames() abort
    " capture scriptnames command output
    try
        redir => l:output
        exe 'silent! scriptnames'
        redir END
    catch
        redir END
        echo "Vim command ':scriptnames' failed"
        return
    endtry
    " convert output into quickfix list items
    let l:quickfix_list_items = []
    for l:line in split(l:output, "\n")
        if l:line =~# ':'
            call add(l:quickfix_list_items,    {
                        \ 'text': matchstr(l:line, '\d\+'),
                        \ 'filename': expand(matchstr(l:line,
                        \                             ': \zs.*'))})
        endif
    endfor
    return l:quickfix_list_items
endfunction

" dn#util#scriptNumber(script)    {{{3
" does:   gets dynamically assigned number (SID, SNR) of script
" params: script - file name of script [string, required]
" prints: error message if fails
" return: integer, null if error
" note:   file name must be complete, i.e., 'base.ext', but can
"         wildcards as if \V ("very nomagic") is in effect
" note:   if no script name provided, returns null with no error
" credit: from Stack Overflow [https://stackoverflow.com/a/39216373]
function! dn#util#scriptNumber(script) abort
    " check param
    if empty(a:script) | return | endif
    if type(a:script) != type('')
        let l:err = 'Expected string script name, got '
        call dn#util#error(l:err . dn#util#varType(a:script))
        return
    endif
    " get script number
    " - create List of script numbers+path with split and execute
    " - return first matching number+path with matchstr
    "   . use of '\V\/' and '\_$' means a:script must contain
    "     complete file name
    " - return beginning (space+)scriptnumber with matchstr
    " - return trailing scriptnumber with matchstr
    return matchstr(matchstr(matchstr(split(execute('scriptnames'), "\n"),
                \ '\V\/' . a:script . '\_$'), '^\s*\d\+'), '\d\+$')
endfunction

" dn#util#filetypes()    {{{3
" does:   get list of available filetypes
" params: nil
" insert: nil
" return: filetypes [List]
function! dn#util#filetypes() abort
    " loop through each directory path in the runtimepath
    let l:filetypes = []
    for l:dir in split(&runtimepath, ',')
        let l:syntax_dir = l:dir . '/syntax'
        " check for syntax directory in this runtime directory
        if (isdirectory(l:syntax_dir))
            " loop through each vimscript file in the syntax directory
            for l:syntax_file in glob(l:syntax_dir . '/*.vim', 1, 1)
                " add basename of syntax file
                call add(l:filetypes, fnamemodify(l:syntax_file, ':t:r'))
            endfor
        endif
    endfor
    " remove duplicates
    return uniq(sort(l:filetypes))
endfunction

" dn#util#showFiletypes()    {{{3
" does:   display available filetypes in echo area
" params: nil
" return: nil
function! dn#util#showFiletypes() abort
    " get filetype list
    let l:filetypes = dn#util#filetypes()
    " prepare for display
    let l:display = dn#util#listToScreenColumns(
                \ l:filetypes, winwidth(0)-3)
    " display
    echo l:display
endfunction

" dn#util#runtimepaths()    {{{3
" does:   get list of runtime paths
" params: nil
" insert: nil
" return: runtime paths [List]
function! dn#util#runtimepaths() abort
    return split(&runtimepath, ',')
endfunction

" dn#util#showRuntimepaths()    {{{3
" does:   display available filetypes in echo area
" params: nil
" return: nil
function! dn#util#showRuntimepaths() abort
    " get filetype list
    let l:runtimepaths = dn#util#runtimepaths()
    " prepare for display
    for l:path in l:runtimepaths
        call dn#util#wrap(l:path)
    endfor
endfunction

" dn#util#updateUserHelpTags()    {{{3
" does:   individually updates user vim helpdocs
" params: nil
" return: nil
function! dn#util#updateUserHelpTags() abort
    " get user directories from rtp
    let l:user_rtp = []
    for l:path in split(&runtimepath, ',')
        if match(l:path, $HOME) == 0  " $HOME starts path
            call add(l:user_rtp, l:path)
        endif
    endfor
    " find user directories with 'doc' subdirectories
    let l:doc_dirs = []
    for l:path in l:user_rtp
        let l:doc_dir = l:path . '/doc'
        if isdirectory(l:doc_dir)
            call add(l:doc_dirs, l:doc_dir)
        endif
    endfor
    " update doc directories
    for l:path in l:doc_dirs
        execute 'helptags' l:path
    endfor
    " give user feedback
    echo 'Generated help tags in directories:'
    if exists('*dn#util#wrap')
        echo dn#util#wrap(join(sort(l:doc_dirs), "\n"))
    else
        echo join(sort(l:doc_dirs), "\n")
    endif
endfunction

" dn#util#os()    {{{3
" does:   determine operating system in use
" params: nil
" return: string ('windows'|'unix'|'other')
function! dn#util#os() abort
    if has('win32') || has ('win64') || has('win95') || has('win32unix')
        return 'windows'
    elseif has('unix')
        return 'unix'
    else
        return 'other'
    endif
endfunction

" dn#util#isWindows()    {{{3
" does:   determine whether operating system is windows
" params: nil
" return: boolean
function! dn#util#isWindows() abort
    return dn#util#os() ==# 'windows'
endfunction

" dn#util#isUnix()    {{{3
" does:   determine whether operating system is unix-like
" params: nil
" return: boolean
function! dn#util#isUnix() abort
    return dn#util#os() ==# 'unix'
endfunction

" Version control    {{{2
" dn#util#localGitRepoFetch(dir, [prefix])    {{{3
" does:   perform a fetch on a local git repository
" params: dir    - path to '.git' subdirectory in repository [required]
"         prefix - prepend string to all output
"                  must include any additional punctuation, e.g., ': '
"                  [optional, default='dn-utils: ']
" prints: error messages if fails
" return: boolean (whether fetch successful)
function! dn#util#localGitRepoFetch(dir, ...) abort
    echo '' | " clear command line
    " set prefix
    let l:prefix = 'dn-utils: '
    if a:0 > 0 && strlen(a:1) > 0
        let l:prefix = a:1
    endif
    " check directory
    let l:dir = resolve(expand(a:dir))
    if ! isdirectory(l:dir)
        echoerr l:prefix . "invalid repository '.git' directory ('"
                    \ . a:dir . "')"
        return
    endif
    " need git
    if ! executable('git')  " need git to update
        echoerr l:prefix . "cannot find 'git'"
        echoerr l:prefix . 'unable to perform fetch operation'
        return
    endif
    " do fetch
    let l:cmd = "git --git-dir='" . l:dir . "' fetch"
    if exists('l:err') | unlet l:err | endif
    let l:err = systemlist(l:cmd)
    if v:shell_error
        echoerr l:prefix . "unable to perform fetch operation on '"
                    \ . a:dir . "'"
        if len(l:err) > 0
            echoerr l:prefix . 'error message:'
            for l:line in l:err | echoerr '  ' . l:line | endfor
        endif
        return
    endif  " v:shell_error
    " success if still here
    return 1
endfunction

" dn#util#localGitRepoUpdatedRecently(dir, time, [prefix])    {{{3
" does:   check that a local repository has been updated
"         within a given time period
" params: dir    - directory containing local repository [required]
"         time   - time in seconds [required]
"         prefix - prepend string to all output
"                  must include any additional punctuation, e.g., ': '
"                  [optional, default='dn-utils: ']
" prints: error messages if setup fails
" return: boolean
" note:   determines time of last 'fetch' operation
"         (so also 'pull' operations)
" note:   uses python and python modules 'os' and 'time'
" note:   designed to determine whether repo needs to be
"         updated, so if it fails it returns false,
"         presumably triggering an update
" note:   a week is 604800 seconds
" note:   will display error message if:
"         - cannot find '.git/FETCH_HEAD' file in directory
"         - time value is invalid
"         - python is absent
"         - python command fails or returns unexpected output
function! dn#util#localGitRepoUpdatedRecently(dir, time, ...) abort
    " check parameters
    " - set prefix
    let l:prefix = 'dn-utils: '
    if a:0 > 0 && strlen(a:1) > 0
        let l:prefix = a:1
    endif
    " - check directory
    let l:dir = resolve(expand(a:dir))
    if ! isdirectory(l:dir)
        echoerr l:prefix . "not a valid directory ('" . l:dir . "')"
        return
    endif
    let l:fetch = l:dir . '/.git/FETCH_HEAD'
    if ! filereadable(l:fetch)
        echoerr l:prefix . "not a valid git repository ('" . l:dir . "')"
        return
    endif
    " - check time
    if a:time !~# '^0$\|^[1-9][0-9]*$'
        echoerr l:prefix . "not a valid time ('" . a:time . "')"
    endif
    " need python
    if ! executable('python')
        echoerr l:prefix . "cannot find 'python'"
        echoerr l:prefix . 'unable to get time of last fetch operation'
        return
    endif
    " get time of last fetch (in seconds since epoch)
    let l:cmd = "python -c \"import os;print os.stat('"
                \ . l:fetch . "').st_mtime\""
    let l:last_fetch_list = systemlist(l:cmd)
    if v:shell_error
        echoerr l:prefix . "modify-time query of '" . l:fetch . "' failed"
        if len(l:last_fetch_list) > 0
            echoerr l:prefix . 'error message:'
            for l:line in l:last_fetch_list
                echoerr '  ' . l:line
            endfor
        endif
        return
    endif
    if type(l:last_fetch_list) != type([])
                \ || len(l:last_fetch_list) != 1
                \ || len(l:last_fetch_list[0]) == 0
        " expected single-item list
        echoerr l:prefix . 'unexpected output from modify-time query'
        return
    endif
    let l:last_fetch = l:last_fetch_list[0]
    " get current time (in seconds since epoch)
    let l:cmd = "python -c \"import time;print int(time.time())\""
    let l:now_list = systemlist(l:cmd)
    if v:shell_error
        echoerr l:prefix . 'python now-time query failed'
        if len(l:now_list) > 0
            echoerr l:prefix . 'error message:'
            for l:line in l:now_list | echoerr '  ' . l:line | endfor
        endif
        return
    endif
    if type(l:now_list) != type([])
                \ || len(l:now_list) != 1
                \ || len(l:now_list[0]) == 0
        " expected single-item list
        echoerr l:prefix . 'unexpected output from now-time query'
        return
    endif
    let l:now = l:now_list[0]
    " have both time values
    " - if less than the supplied time then return true
    let l:diff = l:now - l:last_fetch
    if l:diff < a:time | return g:dn_true | else | return | endif
endfunction

" Strings    {{{2
" dn#util#stripLastChar(str)    {{{3
" does:   removes last character from string
" params: str - string to edit [string]
" return: altered string [string]
function! dn#util#stripLastChar(edit_string) abort
    return strpart(
                \ 	a:edit_string,
                \ 	0,
                \ 	strlen(a:edit_string) - 1
                \ )
endfunction

" dn#util#insertString(str, [paste])    {{{3
" does:   insert string at current cursor location
" params: str   - string for insertion [string]
"         paste - use 'paste' setting  [optional, default=true, boolean]
" return: nil
" usage:  function! s:DnDoSomething(...)
"         	let l:insert = (a:0 > 0 && a:1)
"         	        \ ? 1
"         	        \ : 0
"         	...
"         	call dn#util#insertString(l:string)
"         	if l:insert | call dn#util#insertMode() | endif
"         endfunction
function! dn#util#insertString(inserted_text, ...) abort
    let l:restrictive = g:dn_true
    if a:0 > 1 && ! a:1 | let l:restrictive = g:dn_false | endif
    if l:restrictive | let l:paste_setting = &paste | set paste | endif
    silent execute 'normal! a' . a:inserted_text
    if l:restrictive && ! l:paste_setting | set nopaste | endif
endfunction

" dn#util#trimChar(str, [char])    {{{3
" does:   removes leading and trailing chars from string
" params: str  - string to trim [string]
"         char - char to trim [optional, default=' ', char]
" return: trimmed string [string]
function! dn#util#trimChar(edit_string, ...) abort
    " set trim character
    let l:char = (a:0 > 0)
                \ ? a:1
                \ : ' '
    " build match terms
    let l:left_match_str = '^' . l:char . '\+'
    let l:right_match_str = l:char . '\+$'
    " do trimming
    let l:string = substitute(a:edit_string, l:left_match_str, '', '')
    return substitute(l:string, l:right_match_str, '', '')
endfunction

" dn#util#entitise(str)    {{{3
" does:   replace special html characters with entities
" params: str - string [string]
" insert: nil
" return: altered string [string]
function! dn#util#entitise(str) abort
    let l:str = a:str
    let l:str = substitute(l:str, '&', '&amp;',  'g')
    let l:str = substitute(l:str, '>', '&gt;',   'g')
    let l:str = substitute(l:str, '<', '&lt;',   'g')
    let l:str = substitute(l:str, "'", '&apos;', 'g')
    let l:str = substitute(l:str, '"', '&quot;', 'g')
    return l:str
endfunction

" dn#util#deentitise(str)    {{{3
" does:   replace entities with characters for special html characters
" params: str - string [string]
" insert: nil
" return: altered string [string]
function! dn#util#deentitise(str) abort
    let l:str = a:str
    let l:str = substitute(l:str, '&quot;', '"', 'g')
    let l:str = substitute(l:str, '&apos;', "'", 'g')
    let l:str = substitute(l:str, '&lt;',   '<', 'g')
    let l:str = substitute(l:str, '&gt;',   '>', 'g')
    let l:str = substitute(l:str, '&amp;',  '&', 'g')
    return l:str
endfunction

" dn#util#stringify(var, [quote])    {{{3
" does:   convert variables to string
" params: var   - variable [any]
"         quote - quote_strings [optional, default=false, boolean]
" insert: nil
" return: converted variable [string]
" note:   if quoting then strings will be enclosed in single quotes
"         with internal single quotes doubled
function! dn#util#stringify(var, ...) abort
    " l:Var and l:Item are capitalised because they can be funcrefs
    " and local funcref variables must start with a capital letter
    let l:Var = deepcopy(a:var)
    " are we quoting string output?
    let l:quoting_strings = (a:0 > 0 && a:1)
                \ ? g:dn_true
                \ : g:dn_false
    " string
    if     type(a:var) == type('')
        let l:Var = strtrans(l:Var)  " ensure all chars printable
        if l:quoting_strings
            " double all single quotes
            let l:Var = substitute(l:Var, "'", "''", 'g')
            " enclose in single quotes
            let l:Var = "'" . l:Var . "'"
        endif
        return l:Var
    " integer
    elseif type(a:var) == type(0)
        return printf('%d', a:var)
    " float
    elseif type(a:var) == type(0.0)
        return printf('%g', a:var)
    " List
    elseif type(a:var) == type([])
        let l:out = []
        for l:Item in l:Var
            call add(l:out, dn#util#stringify(l:Item, g:dn_true))
            unlet l:Item
        endfor
        return '[ ' . join(l:out, ', ') . ' ]'
    " Dictionary
    " use perl-style 'big arrow' notation
    elseif type(a:var) == type({})
        let l:out = []
        for l:key in sort(keys(l:Var))
            let l:val = dn#util#stringify(l:Var[l:key], g:dn_true)
            call add(l:out, "'" . l:key . "' => " . l:val)
        endfor
        return '{ ' . join(l:out, ', ') . ' }'
    " Funcref
    elseif type(a:var) == type(function('tr'))
        return string(l:Var)
    " have now covered all five variable types
    else
        call dn#util#error('invalid variable type')
        return g:dn_false
    endif
endfunction

" dn#util#matchCount(haystack, needle)    {{{3
" does:   finds number of occurrences of a substring in a string
" params: haystack - string to search [string]
"         needle   - substring to search for [string]
" insert: nil
" return: number of occurrences [number]
function! dn#util#matchCount(haystack, needle) abort
    " variables
    " - stridx provides informative errors for wrongly typed
    "   haystack and needle values
    let l:matches = 0  " number of searches performed
    let l:pos = -1   " position to search from
    " do progressive search
    while g:dn_true
        let l:pos = stridx(a:haystack, a:needle, l:pos + 1)
        " stop searching when run out of matches
        if l:pos == -1 | break | endif
        " if still here then search was successful
        let l:matches += 1
    endwhile
    " return count
    return l:matches
endfunction

" dn#util#padInternal(str, start, finish, char)    {{{3
" does:   insert char at given position until initial location is at
"         the desired location
" params: str    - initial string [string]
"         start  - position to insert at [number]
"         finish - target position [number]
"         char   - char to pad with [optional, default=' ', char]
" insert: nil
" return: altered string [string]
" note:   if arg 4 is string then only first char is used
" usage:  let l:string1 = 'Column Twenty & Column Twenty One"
"         let l:string2 = 'Column Twenty Two & Column Twenty Three"
"         let l:string1 = dn#util#padInternal(l:string1, 14, 4)
"         echo l:string1  " Column Twenty     & Column Twenty One
"         echo l:string2  " Column Twenty Two & Column Twenty Three
function! dn#util#padInternal(string, start, target, ...) abort
    " variables
    if type(a:string) !=? type('')
        call dn#util#error('First argument is not a string')
        return a:string
    endif
    if type(a:start) != type(0)
        call dn#util#error('Second argument is not an integer')
        return a:string
    endif
    if type(a:target) != type(0)
        call dn#util#error('Third argument is not an integer')
        return a:string
    endif
    let l:char = (a:0 > 0 && a:1 !=? '')
                \ ? strpart(a:1, 0, 1)
                \ : ' '
    let l:start = a:start
    if l:start >= a:target | return a:string | endif
    if a:start < 0
        call dn#util#error('Negative start argument')
        return a:string
    endif
    " build internal pad
    let l:pad = ''
    while l:start < a:target | let l:pad .= ' ' | let l:start += 1 | endwhile
    " insert internal pad and return result
    return strpart(a:string, 0, a:start)
                \ . l:pad
                \ . strpart(a:string, a:start)
endfunction

" dn#util#padLeft(str, length, [char])    {{{3
" does:   add char to start of string until it is the target length
" params: str    - initial string [string]
"         length - target string length[number]
"         char   - char to pad with [optional, default=' ', char]
" insert: nil
" return: altered string [string]
" note:   if arg 3 is string then only first char is used
function! dn#util#padLeft(string, length, ...) abort
    " variables
    if type(a:string) !=? type('')
        call dn#util#error('First argument is not a string')
        return a:string
    endif
    if type(a:length) != type(0)
        call dn#util#error('Second argument is not an integer')
        return a:string
    endif
    let l:char = (a:0 > 0 && a:1 !=? '')
                \ ? strpart(a:1, 0, 1)
                \ : ' '
    " right pad
    let l:string = copy(a:string)
    while len(l:string) < a:length
        let l:string = l:char . l:string
    endwhile
    return l:string
endfunction

" dn#util#padRight(str, length, [char])    {{{3
" does:   add char to end of string until it is the target length
" params: str    - initial string [string]
"         length - target string length[number]
"         char   - char to pad with [optional, default=' ', char]
" insert: nil
" return: altered string [string]
" note:   if arg 3 is string then only first char is used
function! dn#util#padRight(string, length, ...) abort
    " variables
    if type(a:string) !=? type('')
        call dn#util#error('First argument is not a string')
        return a:string
    endif
    if type(a:length) != type(0)
        call dn#util#error('Second argument is not an integer')
        return a:string
    endif
    let l:char = (a:0 > 0 && a:1 !=? '')
                \ ? strpart(a:1, 0, 1)
                \ : ' '
    " right pad
    let l:string = copy(a:string)
    while len(l:string) < a:length | let l:string .= l:char | endwhile
    return l:string
endfunction

" dn#util#globalSubstitution(pattern, substitution)    {{{3
" does:   perform global substitution in file
" insert: nil
" params: pattern      - string to search for [string]
"         substitution - replacement string [string]
" return: nil
function! dn#util#globalSubstitution(pattern, substitute) abort
    let l:pos = getcurpos()
    call setpos('.', [0, 1, 1, 0])
    let l:line_num = search(a:pattern, 'nW')
    while l:line_num > 0
        let l:line = getline(l:line_num)
        let l:new_line = substitute(l:line, a:pattern, a:substitute, 'g')
        if l:new_line != l:line
            call setline(l:line_num, l:new_line)
        endif
        let l:line_num = search(a:pattern, 'nW')
    endwhile
    call setpos('.', l:pos)
endfunction

" dn#util#changeHeaderCaps(mode)    {{{3
" does:   changes capitalisation of line or visual selection
" params: mode - calling mode ['n'|'v'|'i']
" insert: replaces line or selection with altered line or selection
" return: nil
" note:   user chooses capitalisation type: upper case, lower case,
"         capitalise every word, sentence case, title case
function! dn#util#changeHeaderCaps(mode) abort
    echo '' | " clear command line
    " mode specific
    let l:mode = tolower(a:mode)
    if l:mode ==# 'i' | execute "normal! \<Esc>" | endif
    " variables
    let l:line_replace_modes = ['n', 'i']
    let l:visual_replace_modes = ['v']
    let l:options =    {
                \ 'Upper case':            'upper',
                \ 'Lower case':            'lower',
                \ 'Capitalise every word': 'start',
                \ 'Sentence case':         'sentence',
                \ 'Title case':            'title'
                \ }
    " get header case type
    try
        let l:type = dn#util#menuSelect(l:options, 'Select header case:')
        if l:type ==? '' | throw 'No header selected' | endif
    catch /.*/
        echo ' ' | " ensure starts on new line
        call dn#util#error('Header case not selected')
        return ''
    endtry
    " operate on current line (normal or insert mode)
    if     count(l:line_replace_modes, l:mode)
        let l:header = getline('.')
        let l:header = s:_headerCapsEngine(l:header, l:type)
        call setline('.', l:header)
    elseif count(l:visual_replace_modes, l:mode)
        try
            " preserve current contents of register x
            let l:x_save = @x
            " yank current visual selection to register x
            normal! gv"xy
            " extract contents of register x to variable
            let l:header = @x
            " change case
            let l:header = s:_headerCapsEngine(l:header, l:type)
            " write back result to register x
            let @x = l:header
            " re-select visual selection and delete
            normal! gvd
            " paste replacement string
            normal! "xP
        finally
            " make sure to leave register a as we found it
            let @x = l:x_save
        endtry
    else
        call dn#util#error("Mode param is '" . l:mode . "'; must be [n|i|v]")
    endif
    " return to insert mode if called from there
    if l:mode ==# 'i' | call dn#util#insertMode(1) | endif
endfunction

" Numbers    {{{2
" dn#util#validPosInt(val    {{{3
" does:   check whether input is valid positive integer
" params: val - value to check [integer]
" insert: nil
" return: whether valid positive integer [boolean]
" note:   zero is not a positive integer
function! dn#util#validPosInt(value) abort
    return a:value =~# '^[1-9]\{1}[0-9]\{}$'
endfunction

" Miscellaneous    {{{2
" dn#util#selectWord()    {{{3
" does:   selects <cword> under cursor (must be only [0-9a-zA-Z_]
" params: nil
" insert: nil
" return: selected text ('' if no text selected) [string]
function! dn#util#selectWord() abort
    " select <cword> and analyse
    let l:fragment = expand('<cword>')
    if l:fragment !~? '^\w\+$' | return '' | endif    " must be [[alnum]_]
    " get index of fragment start
    let l:orig_line = line('.') | let l:orig_col = col('.')
    let l:target_col = l:orig_col - 1    " strings are zero-, not one-based
    let l:line = getline('.')
    let l:distance = 1000 | let l:iteration = 1 | let l:count = 0
    let l:begin = -1 | let l:terminus = -1
    let l:index = match(l:line, l:fragment, 0, l:iteration)
    while l:index != -1
        let l:match_distance = l:target_col - l:index
        if l:match_distance < 0  " ensure absolute value
            let l:match_distance = strpart(l:match_distance, 1)
        endif
        " keep match if begins closer to, but before, original cursor pos
        if (l:match_distance <= l:distance) && (l:index <= l:target_col)
            let l:distance = l:match_distance
            let l:count = l:iteration
        endif
        let l:iteration += 1
        let l:index = match(l:line, l:fragment, 0, l:iteration)
    endwhile
    if l:count == 0 | return '' | endif
    let l:begin = match(l:line, l:fragment, 0, l:count)
    " next, get index of fragment end
    let l:terminus = matchend(l:line, l:fragment, 0, l:count) - 1
    if l:terminus == -1 | return '' | endif
    " adjust indices because strings are zero-based but lines are one-based
    let l:begin += 1 | let l:terminus += 1
    " select fragment
    call cursor(l:orig_line, l:begin)
    execute 'normal! v'
    call cursor(l:orig_line, l:terminus)
    " done
    return l:fragment
endfunction

" dn#util#varType(var)    {{{3
" does:   get variable type
" params: var - variable to be analysed
" insert: nil
" return: variable type ('number'|'string'|'funcref'|'List'|
"                        'Dictionary'|'float'|'unknown')
function! dn#util#varType(var) abort
    if     type(a:var) == type(0)              | return 'number'
    elseif type(a:var) == type('')             | return 'string'
    elseif type(a:var) == type(function('tr')) | return 'funcref'
    elseif type(a:var) == type([])             | return 'List'
    elseif type(a:var) == type({})             | return 'Dictionary'
    elseif type(a:var) == type(0.0)            | return 'float'
    else                                       | return 'unknown'
    endif
endfunction

" dn#util#testFn()    {{{3
" does:   utility function used for testing purposes only
" params: varies
" insert: varies
" return: varies
function! dn#util#testFn() range abort
    let l:var = 'A RABBIT AND A DOG SHOW'
    call dn#util#showMsg(string(l:var))
endfunction    " }}}3

" Private functions    {{{1

" s:_centuryDoomsday(year)    {{{2
" does:   return doomsday for century
" params: year - year [integer]
" insert: nil
" return: day in week [integer]
" note:   uses Doomsday algorithm created by John Horton Conway
function! s:_centuryDoomsday(year) abort
    let l:century = (a:year - (a:year % 100)) / 100
    let l:base_century = l:century % 4
    return        l:base_century == 3 ? 4 :
                \ l:base_century == 0 ? 3 :
                \ l:base_century == 1 ? 1 :
                \ l:base_century == 2 ? 6 : 0
endfunction

" s:_currentIsoDate()    {{{2
" does:   return current date in ISO format (yyyy-mm-dd)
" params: nil
" insert: nil
" return: date in ISO format [string]
function! s:_currentIsoDate() abort
    return strftime('%Y-%m-%d')
endfunction

" s:_dayValue(day)    {{{2
" does:   get matching day name for day number
" params: day - day number [integer]
" insert: nil
" return: day name [string]
" note:   1=Sunday, 2=Monday, ..., 7=Saturday
function! s:_dayValue(day) abort
    return        a:day == 1 ? 'Sunday'    :
                \ a:day == 2 ? 'Monday'    :
                \ a:day == 3 ? 'Tuesday'   :
                \ a:day == 4 ? 'Wednesday' :
                \ a:day == 5 ? 'Thursday'  :
                \ a:day == 6 ? 'Friday'    :
                \ a:day == 7 ? 'Saturday'  : ''
endfunction

" s:_headerCapsEngine(header, type)    {{{2
" does:   change capitalisation of header
" params: header - header to convert [string]
"         type   - caps type
"                  ('upper'|'lower'|'sentence'|'start'|'title') [string]
" insert: nil
" return: converted header [string]
" note:   newlines are not expected but happen to be preserved
"         types of capitalisation:
"           upper:    TO BE OR NOT TO BE
"           lower:    to be or not to be
"           sentence: To be or not to be (capitalise first word only)
"           start:    To Be Or Not To Be (calitalise all words)
"           title:    To Be or Not to Be (capitalise first and last words,
"                                         and all words except articles,
"                                         prepositions and conjunctions of
"                                         fewer than five letters)
function! s:_headerCapsEngine(string, type) abort
try
    " variables
    " - capitalisation types
    let l:types = ['upper', 'lower', 'sentence', 'start', 'title']
    let l:type = tolower(a:type)
    " - articles of speech are not capitalised in title case
    let l:articles = ['a', 'an', 'the']
    " - prepositions are not capitalised in title case
    let l:prepositions = [
                \ 'amid',   'as',   'at', 'atop',  'but',   'by',  'for', 'from',
                \   'in', 'into',  'mid', 'near', 'next',   'of',  'off',   'on',
                \ 'onto',  'out', 'over',  'per',  'quo', 'sans', 'than', 'till',
                \   'to',   'up', 'upon',    'v',   'vs',  'via', 'with'
                \ ]
    " - conjunctions are not capitalised in title case
    let l:conjunctions = [
                \  'and',   'as', 'both',  'but',  'for',  'how',   'if', 'lest',
                \  'nor', 'once',   'or',   'so', 'than', 'that', 'till', 'when',
                \  'yet'
                \ ]
    let l:temp = l:articles + l:prepositions + l:conjunctions
    " - merge all words not capitalised in title case
    " - weed out duplicates for aesthetic reasons
    let l:title_lowercase = []
    for l:item in l:temp
        if count(l:title_lowercase, l:item) == 0
            call add(l:title_lowercase, l:item)
        endif
    endfor
    " - splitting of header on word boundaries produces some pseudo-words that
    "   are not actual words, and these should not be capitalised in 'start'
    "   or 'title' case
    let l:pseudowords = ['s']
    unlet l:temp l:articles l:prepositions l:conjunctions l:item
    " check parameters
    if a:string ==? '' | return '' | endif
    if count(l:types, l:type) != 1 | throw "Bad type '" . l:type . "'" | endif
    " break up string into word fragments
    let l:words = split(a:string, '\<\|\>')
    " process words individually
    let l:index = 0
    let l:last_index = len(l:words) - 1
    let l:first_word = g:dn_true
    let l:last_word = g:dn_false
    for l:word in l:words
        let l:word = tolower(l:word)    " first make all lowercase
        let l:last_word = (l:index == l:last_index)    " check for last word
        if     l:type ==# 'upper'
            let l:word = toupper(l:word)
        elseif l:type ==# 'lower'
            " already made lowercase so nothing to do here
        elseif l:type ==# 'start'
            " some pseudo-words must not be capitalised
            if !count(l:pseudowords, l:word)
                let l:word = substitute(l:word, "\\w\\+", "\\u\\0", 'g')
            endif
        " behaviour of remaining types 'sentence' and 'title' depends on
        " position  of word in heading, and for single word headings first
        " position takes precedence over last position
        elseif l:first_word
            let l:word = substitute(l:word, "\\w\\+", "\\u\\0", 'g')
        elseif l:last_word
            " if 'sentence' type then leave lowercase
            " if 'title' beware some psuedo-words must not be capitalised
            if l:type ==# 'title' && !count(l:pseudowords, l:word)
                let l:word = substitute(l:word, "\\w\\+", "\\u\\0", 'g')
            endif
        else  " type is 'sentence' or 'title' and word is neither first or last
            " if 'sentence' type then leave lowercase
            if l:type ==# 'title'
                " capitalise if not in list of words to be kept lowercase
                " and is not a psuedo-word
                if !count(l:title_lowercase, l:word)
                            \ && !count(l:pseudowords, l:word)
                    let l:word = substitute(l:word, "\\w\\+", "\\u\\0", 'g')
                endif
            endif
        endif
        " negate first word flag after first word is encountered
        if l:first_word && l:word =~# '^\a'
            let l:first_word = g:dn_false
        endif
        " write changed word
        let l:words[l:index] = l:word
        " move to next list item
        let l:index += 1
    endfor
    " return altered header
    return join(l:words, '')
catch
    call dn#util#error(v:exception . ' at ' . v:throwpoint)
endtry
endfunction

" s:_leapYear(year)    {{{2
" does:   determine whether leap year or not
" params: year - year [integer]
" insert: nil
" return: whether leap year [boolean]
" note:   return value used as numerical value in some functions
function! s:_leapYear(year) abort
    if a:year % 4 == 0 && a:year != 0
        return g:dn_true
    else
        return g:dn_false
    endif
endfunction

" s:_listifyMsg(msg)    {{{2
" does:   convert msg into List
" params: msg - message variable to convert [required, any]
" insert: nil
" prints: error if var other than List or string encountered
" return: List
" note:   if arg is List, stringify each element, else stringify arg
function! s:_listifyMsg(msg) abort
    " params
    let l:valid_types = ['info', 'warning', 'error']
    if empty(a:type) || !count(l:valid_types, a:type)
        echoerr "Invalid message type '" . a:type . "'"
        return []
    endif
    " convert
    let l:msgs = []
    if type(a:msg) == type([])
        for l:msg in a:msg
            call add(l:msgs, dn#util#stringify(l:msg))
        endfor
    else
        call add(l:msgs, dn#util#stringify(a:msg))
    endif
    " return List
    return l:msgs
endfunction

" s:_menuSimpleType(var)    {{{2
" does:   whether variable is a plain option, i.e., number, float or string
" params: var - variable to test [required, any]
" insert: nil
" return: boolean
function! s:_menuSimpleType(...) abort
    " process parameters
    if a:0 == 0
        call dn#util#error('Simple type test got no variable')
        return
    endif
    if a:0 > 1
        call dn#util#error('Simple type test got multiple variables')
        return
    endif
    let l:var = a:1
    " test var
    let l:valid_types = [type(''), type(0), type(0.0)]
    let l:type = type(l:var)
    return count(l:valid_types, l:type)
endfunction

" s:_menuSubMenuType(var)    {{{2
" does:   whether variable is a submenu option, i.e., List or Dict
" params: var - variable to test [required, any]
" insert: nil
" return: boolean
function! s:_menuSubmenuType(...) abort
    " process parameters
    if a:0 == 0
        call dn#util#error('Submenu type test got no variable')
        return
    endif
    if a:0 > 1
        call dn#util#error('Submenu type test got multiple variables')
        return
    endif
    let l:var = a:1
    " test var
    let l:valid_types = [type([]), type({})]
    let l:type = type(l:var)
    return count(l:valid_types, l:type)
endfunction

" s:_menuType(var)    {{{2
" does:   whether variable is a simple or submenu option,
"         i.e., number, float, string, List or Dict
" params: var - variable to test [required, any]
" insert: nil
" return: boolean
function! s:_menuType(...) abort
    " process parameters
    if a:0 == 0
        call dn#util#error('Menu type test got no variable')
        return
    endif
    if a:0 > 1
        call dn#util#error('Menu type test got multiple variables')
        return
    endif
    let l:var = a:1
    " test var
    let l:valid_types = [type(''), type(0), type(0.0), type([]), type({})]
    let l:type = type(l:var)
    return count(l:valid_types, l:type)
endfunction

" s:_monthLength(year, month)    {{{2
" does:   get length of month in days
" params: year  - year [integer]
"         month - month number [integer]
" insert: nil
" return: length of month [integer]
function! s:_monthLength(year, month) abort
    return        a:month == 1  ? 31 :
                \ a:month == 2  ? 28 + s:_leapYear(a:year) :
                \ a:month == 3  ? 31 :
                \ a:month == 4  ? 30 :
                \ a:month == 5  ? 31 :
                \ a:month == 6  ? 30 :
                \ a:month == 7  ? 31 :
                \ a:month == 8  ? 31 :
                \ a:month == 9  ? 30 :
                \ a:month == 10 ? 31 :
                \ a:month == 11 ? 30 :
                \ a:month == 12 ? 31 : 0
endfunction

" s:_monthValue(year, month)    {{{2
" does:   get day in month that is same day of week as year doomsday
" params: year - year [integer]
"         month - month number [integer]
" insert: nil
" return: day in month [integer]
function! s:_monthValue(year, month) abort
    let l:Leapyear = s:_leapYear(a:year)
    return        a:month == 1  ? (l:Leapyear == 0 ? 3 : 4) :
                \ a:month == 2  ? (l:Leapyear == 0 ? 0 : 1) :
               	\ a:month == 3  ? 0  :
                \ a:month == 4  ? 4  :
                \ a:month == 5  ? 9  :
                \ a:month == 6  ? 6  :
                \ a:month == 7  ? 11 :
                \ a:month == 8  ? 8  :
                \ a:month == 9  ? 5  :
                \ a:month == 10 ? 10 :
                \ a:month == 11 ? 7  :
                \ a:month == 12 ? 12 : 0
endfunction

" s:_validCalInput(year, month, day)    {{{2
" does:   check validity of calendrical input
" params: year  - year [integer]
"         month - month number [integer]
"         day   - day number [integer]
" insert: nil
" print:  error message if invalid input detected
" return: whether valid input [boolean]
function! s:_validCalInput(year, month, day) abort
    let l:retval :dn_true
    if !s:_validYear(a:year)
        let l:retval = g:dn_false
        echo "Invalid year: '" . a:year . "'"
    endif
    if !s:_validMonth(a:month)
        let l:retval = g:dn_false
        echo "Invalid month: '" . a:month . "'"
    endif
    if !s:_validDay(a:year, a:month, a:day)
        let l:retval = g:dn_false
        echo "Invalid day:   '" . a:day . "'"
    endif
    return l:retval
endfunction

" s:_validDay(year, month, day)    {{{2
" does:   check day validity
" params: year  - year [integer]
"         month - month number [integer]
"         day   - day number [integer]
" insert: nil
" return: whether valid day [boolean]
function! s:_validDay(year, month, day) abort
    if dn#util#validPosInt(a:day)
        if a:day <= s:_monthLength(a:year, a:month)
            return g:dn_true
        endif
    endif
    return g:dn_false
endfunction

" s:_validMonth(month)    {{{2
" does:   check month validity
" params: month - month integer [integer]
" insert: nil
" return: whether valid month [boolean]
function! s:_validMonth (month) abort
    if dn#util#validPosInt(a:month) && a:month <= 12
        return g:dn_true
    endif
    return g:dn_false
endfunction

" s:_validYear(year)    {{{2
" does:   check year validity
" params: year - year [integer]
" insert: nil
" return: whether valid year [boolean]
function! s:_validYear(year) abort
    return dn#util#validPosInt(a:year)
endfunction

" s:_yearDoomsday(year)    {{{2
" does:   return doomsday for year
" params: year - year [integer]
" insert: nil
" return: day in week [integer]
" note:   uses Doomsday algorithm created by John Horton Conway
function! s:_yearDoomsday(year) abort
    let l:years_in_century = a:year % 100
    let l:P = l:years_in_century / 12
    let l:Q = l:years_in_century % 12
    let l:R = l:Q / 4
    let l:century_doomsday = s:_centuryDoomsday(a:year)
    return (l:P + l:Q + l:R + l:century_doomsday) % 7
endfunction

" Restore cpoptions    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo    " }}}1

" vim: set foldmethod=marker :
