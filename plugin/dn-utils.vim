" Function:    Vim utility functions
" Last Change: 2015-06-11
" Maintainer:  David Nebauer <david@nebauer.org>
" License:     Public domain

" _1.  CONTROL STATEMENTS                                            {{{1
" Only do this when not done yet for this buffer                     {{{2
if exists("b:do_not_load_dn_utils") | finish | endif
let b:do_not_load_dn_utils = 1                                     " }}}2
" Use default cpoptions                                              {{{2
" - avoids unpleasantness from customised 'compatible' settings
let s:save_cpo = &cpo
set cpo&vim                                                        " }}}2

" _2.  VARIABLES                                                     {{{1
" bools                                                              {{{2
let b:dn_true = 1 | let b:dn_false = 0                             " }}}2
" help                                                               {{{2
if !exists('b:dn_help_plugins') | let b:dn_help_plugins = [] | endif
call add(b:dn_help_plugins, 'dn-utils')
if !exists('b:dn_help_topics') | let b:dn_help_topics = {} | endif
let b:dn_help_topics['vim'] = { 'version control': 'vim_version_control' }
if !exists('b:dn_help_data') | let b:dn_help_data = {} | endif
let b:dn_help_data['vim_version_control'] = [ 
            \ 'Version control is handled by git and the vcscommand plugin.',
            \ '',
            \ 'Here is how the most common operations are performed.',
            \ '',
            \ '  create repo: \git',
            \ '',
            \ '  add current file: \ca',
            \ '',
            \ '  view changes/diff: \cd',
            \ '',
            \ '  commit changes: \cc',
            \ '',
            \ 'For more information try ''h vcscommand''.', 
            \ ]                                                    " }}}2
" templates                                                          {{{2
" - templates found on system
let s:templates = {}
" - templates expected to be found
let s:expected_templates = {
            \ 'configfile.rc'    : 'configfile'  ,
            \ 'Makefile.am'      : 'makefile.am' ,
            \ 'manpage.1'        : 'manpage'     ,
            \ 'markdown.md'      : 'markdown'    ,
            \ 'perlmod.pm'       : 'perlmod'     ,
            \ 'perlscript.pl'    : 'perlscript'  ,
            \ 'shellscript.sh'   : 'shellscript' ,
            \ 'template.desktop' : 'desktop'     ,
            \ 'template.html'    : 'html'        ,
            \ 'template.xhtml'   : 'xhtml'       ,
            \ }                                                    " }}}2

" 3.  FUNCTIONS                                                      {{{1
" 3.1  Templates                                                     {{{2
" Functions related to template files
" Function: DNU_LoadTemplate                                         {{{3
" Purpose:  load template file
" Prints:   error feedback
" Params:   1 - template key (extension or filename)
" Return:   boolean (indicating outcome)
" Usage:    intended for vimrc command like:
"              au BufNewFile *.[0-9] call DNU_LoadTemplate('manpage')
function! DNU_LoadTemplate(key)
	" load script templates variable with available template files
    call s:index_templates()
    " get template file
    let l:template = s:template_filepath(a:key)
    if l:template == '' | return | endif
    " insert template file
    call append(0, readfile(l:template))
    " perform substitutions
    call s:template_substitutions()
    " detect filetype 
    execute ':filetype detect'
    " goto start token, delete it and enter insert mode
    call s:template_goto_start()
endfunction                                                        " }}}3
" Function: DNU_InsertTemplate                                       {{{3
" Purpose:  insert template file
" Prints:   error feedback
" Params:   1 - template key (extension or filename)
" Return:   boolean (indicating outcome)
" Usage:    intended for vimrc command like:
"              au BufNewFile *.[0-9] call DNU_LoadTemplate('manpage')
function! DNU_InsertTemplate(key)
    " only insert template if buffer is empty
    " - i.e., last line is first line and empty
    if getpos('$')[1] == 1 && strlen(getline('$')) == 0
        " load template
        call DNU_LoadTemplate(a:key)
    endif
endfunction                                                        " }}}3
" Function: s:index_templates                                        {{{3
" Purpose:  index template files in variable s:templates
" Prints:   nil
" Params:   nil
" Return:   boolean (indicating outcome)
function! s:index_templates()
	" variables
    let s:templates = {}
    let l:missing = deepcopy(s:expected_templates)
    let l:unexpected = []
    " find template directories
    let l:template_dir = 'vim-dn-utils-templates'
    let l:dirs = split(globpath(&rtp, l:template_dir, b:dn_true), ',')
    " cycle through template directories
    for l:dir in l:dirs
        " get directory files
        let l:dir_fps = glob(l:dir . "/*", b:dn_false, b:dn_true)
        " process directory files
        for l:dir_fp in l:dir_fps
            let l:dir_filename = fnamemodify(l:dir_fp, ':t')    " get filename
            if has_key(s:expected_templates, l:dir_filename)    " expected
                " not missing
                if has_key(l:missing, l:dir_filename)
                    call remove(l:missing, l:dir_filename)
                endif
                " index template file
                let l:key = s:expected_templates[l:dir_filename]
                if !has_key(s:templates, l:key)
                    let s:templates[l:key] = []
                endif
                call add(s:templates[l:key], l:dir_fp)
            else    " unexpected file
                call add(l:unexpected, l:dir_fp)
            endif    " has_key(expected, dir_filename)
        endfor    " dir_fp in dir_fps
    endfor    " for dir in dirs
    " give feedback if necessary
    let l:err = ''
    let l:pad = '    '
    " - list any unexpected template files
    if len(l:unexpected) > 0
        if len(l:unexpected) == 1
            let l:err .= l:pad . "found unexpected template file:\n"
        else
            let l:err = l:pad . "found unexpected template files:\n"
        endif
    endif
    for l:fp in l:unexpected
        let l:err .= l:pad . l:pad . l:fp . "\n"
    endfor
    " - list any missing template files
    if len(l:missing) > 0
        if len(l:missing) == 1
            let l:err .= l:pad . "did not find expected template file:\n"
        else
            let l:err = l:pad . "did not find expected template files:\n"
        endif
    endif
    for l:file in keys(l:missing)
        let l:err .= l:pad . l:pad . l:file . "\n"
    endfor
    if l:err != ''
        let l:err = "vim-dn-utils plugin encountered trouble\n"
                    \ . "while searching for templates:\n" 
                    \ . l:err
    endif
    call DNU_Error(l:err)
endfunction                                                        " }}}3
" Function: s:template_filepath                                      {{{3
" Purpose:  get template filepath
" Prints:   error feedback
" Params:   1 - template key (corresponds to s:templates keys)
" Return:   template filepath ('' if none found)
" Note:     relies on populated variable s:template
"           run function 's:index_templates' before this function
function! s:template_filepath(key)
    if has_key(s:templates, a:key)
        let l:templates = s:templates[a:key]
        if len(l:templates) == 0
            call DNU_Error("No template for key '" . a:key . "'")
            let l:template = ''    " failed
        elseif len(l:templates) == 1
            let l:template = l:templates[0]    " success
        else
            let l:template = DNU_MenuSelect(l:templates, 'Select template to use:')
            if l:template == ''
                call DNU_Error('No template selected')
                let l:template = ''    " failed
            endif
        endif
    else    " no template for key
        call DNU_Error("No template for key '" . a:key . "'")
        let l:template = ''    " failed
    endif
    return l:template
endfunction                                                        " }}}3
" Function: s:template_substitutions                                 {{{3
" Purpose:  perform substitutions on tokens in template
" Prints:   error feedback
" Params:   nil
" Return:   nil
" Note:     supported tokens:
"           <BASENAME>       -> file basename
"           <FILENAME>       -> file name
"           <NAME>           -> file basename
"           <DATE>           -> yyyy-mm-dd
"           <HEADER_NAME>    -> manpage header name, use file basename
"           <HEADER_SECTION> -> manpage section, use numeric file extension
"           <TITLE_NAME>     -> manpage title name,
"                               use file basename in initial caps
"           <START>          -> where to start editing
function! s:template_substitutions()
    " <FILENAME> -> file name
    let l:filename = expand('%')
    call s:global_substitution('<FILENAME>', l:filename)
    " <BASENAME> -> file basename
    let l:basename = strpart(l:filename, 0, stridx(l:filename, '.'))
    call s:global_substitution('<BASENAME>', l:basename)
    " <NAME> -> use file basename
    call s:global_substitution('<NAME>', l:basename)
    " <DATE> -> yyyy-mm-dd
    let l:date = strftime('%Y-%m-%d')
    call s:global_substitution('<DATE>', l:date)
    " <HEADER_NAME> -> manpage header, use file basename
    call s:global_substitution('<HEADER_NAME>', l:basename)
    " <HEADER_SECTION> -> manpage section, use file extension
    let l:got_section = b:dn_false
    let l:ext = ''    " intentional non-numeric value
    let l:remnant = l:filename
    while l:remnant != l:basename
        if DNU_ValidPosInt(l:ext)
            let l:got_section = b:dn_true
            break
        endif
        let l:ext = fnamemodify(l:remnant, ':e')
        let l:remnant = fnamemodify(l:remnant, ':r')
    endwhile
    if l:got_section
        call s:global_substitution('<HEADER_SECTION>', l:ext)
    endif
    " <TITLE_NAME> -> use file basename in initial caps
    let l:title = substitute(l:basename, '\v<(.)(\w*)>', '\u\1\L\2', 'g')
    call s:global_substitution('<TITLE_NAME>', l:title)
endfunction                                                        " }}}3
" Function: s:global_substitution                                    {{{3
" Purpose:  perform global substitution in file
" Prints:   nil
" Params:   1 - pattern
"           2 - substitution
" Return:   nil
function! s:global_substitution(pattern, substitute)
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
endfunction                                                        " }}}3
" Function: s:template_goto_start                                    {{{3
" Purpose:  goto start token in file, delete it and enter insert mode
" Prints:   nil
" Params:   nil
" Return:   nil
function! s:template_goto_start()
    call setpos('.', [0, 1, 1, 0])
    let l:pattern = '<START>'
    let [l:line_num, l:col] = searchpos(l:pattern, 'nW')
    if l:line_num > 0
        let l:line = getline(l:line_num)
        let l:new_line = substitute(l:line, l:pattern, '', 'g')
        if l:new_line != l:line
            call setline(l:line_num, l:new_line)
        endif
    endif
    call setpos('.', [0, l:line_num, l:col, 0])
    call DNU_InsertMode()
endfunction                                                        " }}}3

" 3.2  Dates                                                         {{{2
" Functions related to dates
" API:                                                               {{{3
" DNU_InsertCurrentDate([bool])
"   params: 1 - whether in insert mode
"   insert: current date in ISO format [string]
"   return: nil

" DNU_NowYear() | DNU_NowMonth() | DNU_NowDay()
"   params: nil
"   insert: nil
"   return: current year | month | day [integer]

" DNU_DayOfWeek(int, int, int)
"   params: 1 - year
"           2 - month
"           3 - day
"   insert: nil
"   return: name of weekday [string]                                 }}}3
" Function: DNU_InsertCurrentDate                                    {{{3
" Purpose:  insert current date in ISO format
" Params:   1 - whether called from insert mode [optional, boolean]
" Insert:   current date in ISO format (yyyy-mm-dd) [string]
" Return:   nil
function! DNU_InsertCurrentDate(...)
	" if call from command line then move cursor left
	if !(a:0 > 0 && a:1) | execute "normal h" | endif
	" insert date
	execute 'normal a' . s:currentIsoDate()
	" if finishing in insert mode move cursor to right
	if a:0 > 0 && a:1 | execute 'normal l' | startinsert | endif
endfunction                                                        " }}}3
" Function: DNU_NowYear                                              {{{3
" Purpose:  get current year
" Params:   nil
" Insert:   nil
" Return:   current year (yyyy) [integer]
function! DNU_NowYear()
	return strftime('%Y')
endfunction                                                        " }}}3
" Function: DNU_NowMonth                                             {{{3
" Purpose:  get current month
" Params:   nil
" Insert:   nil
" Return:   current month (m) [integer]
function! DNU_NowMonth()
	return substitute(strftime('%m'), '^0', '', '')
endfunction                                                        " }}}3
" Function: DNU_NowDay                                               {{{3
" Purpose:  get current day in month
" Params:   nil
" Insert:   nil
" Return:   current day in month (d) [integer]
function! DNU_NowDay()
	return substitute(strftime('%d'), '^0', '', '')
endfunction                                                        " }}}3
" Function: DNU_DayOfWeek                                            {{{3
" Purpose:  get name of weekday
" Params:   1 - year [integer]
"           2 - month [integer]
"           3 - day [integer]
" Insert:   nil
" Return:   name of weekday [string]
function! DNU_DayOfWeek(year, month, day)
	if !s:validCalInput(a:year, a:month, a:day) | return '' | endif
	let l:doomsday = s:yearDoomsday(a:year)
	let l:month_value = s:monthValue(a:year, a:month)
	let l:day_number = (a:day - l:month_value + 14 + l:doomsday) % 7
	let l:day_number = (l:day_number == 0)
                \ ? 7 
                \ : l:day_number
	return s:dayValue(l:day_number)
endfunction                                                        " }}}3
" Function: s:centuryDoomsday                                        {{{3
" Purpose:  return doomsday for century
" Params:   1 - year [integer]
" Insert:   nil
" Return:   day in week [integer]
" Note:     uses Doomsday algorithm created by John Horton Conway
function! s:centuryDoomsday(year)
	let l:century = (a:year - (a:year % 100)) / 100
	let l:base_century = l:century % 4
	return        l:base_century == 3 ? 4 :
				\ l:base_century == 0 ? 3 :
				\ l:base_century == 1 ? 1 :
				\ l:base_century == 2 ? 6 : 0
endfunction                                                        " }}}3
" Function: s:currentIsoDate                                         {{{3
" Purpose:  return current date in ISO format (yyyy-mm-dd)
" Params:   nil
" Insert:   nil
" Return:   date in ISO format [string]
function! s:currentIsoDate()
	return strftime('%Y-%m-%d')
endfunction                                                        " }}}3
" Function: s:dayValue                                               {{{3
" Purpose:  get matching day name for day number
" Params:   1 - day number [integer]
" Insert:   nil
" Return:   day name [string]
" Note:     1=Sunday, 2=Monday, ..., 7=Saturday
function! s:dayValue(day)
	return        a:day == 1 ? 'Sunday'    :
				\ a:day == 2 ? 'Monday'    :
				\ a:day == 3 ? 'Tuesday'   :
				\ a:day == 4 ? 'Wednesday' :
				\ a:day == 5 ? 'Thursday'  :
				\ a:day == 6 ? 'Friday'    :
				\ a:day == 7 ? 'Saturday'  : ''
endfunction                                                        " }}}3
" Function: s:leapYear                                               {{{3
" Purpose:  determine whether leap year or not
" Params:   1 - year [integer]
" Insert:   nil
" Return:   whether leap year [boolean]
" Note:     return value used as numerical value in some functions
function! s:leapYear(year)
    if a:year % 4 == 0 && a:year != 0
        return b:dn_true
    else
        return b:dn_false
endfunction                                                        " }}}3
" Function: s:monthLength                                            {{{3
" Purpose:  get length of month in days
" Params:   1 - year [integer]
"           2 - month [integer]
" Insert:   nil
" Return:   length of month [integer]
function! s:monthLength(year, month)
	return        a:month == 1  ? 31 :
				\ a:month == 2  ? 28 + s:leapYear(a:year) :
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
endfunction                                                        " }}}3
" Function: s:monthValue                                             {{{3
" Purpose:  get day in month that is same day of week as year doomsday
" Params:   1 - year [integer]
"           2 - month [integer]
" Insert:   nil
" Return:   day in month [integer]
function! s:monthValue(year, month)
	let l:leapyear = s:leapYear(a:year)
	return        a:month == 1  ? (l:leapyear == 0 ? 3 : 4) :
				\ a:month == 2  ? (l:leapyear == 0 ? 0 : 1) :
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
endfunction                                                        " }}}3
" Function: s:validCalInput                                          {{{3
" Purpose:  check validity of calendrical input
" Params:   1 - year [integer]
"           2 - month [integer]
"           3 - day [integer]
" Insert:   error message if invalid input detected
" Return:   whether valid input [boolean]
function! s:validCalInput(year, month, day)
	let l:retval :dn_true
	if !s:validYear(a:year)
		let l:retval = b:dn_false
		echo "Invalid year: '" . a:year . "'"
	endif
	if !s:validMonth(a:month)
		let l:retval = b:dn_false
		echo "Invalid month: '" . a:month . "'"
	endif
	if !s:validDay(a:year, a:month, a:day)
		let l:retval = b:dn_false
		echo "Invalid day:   '" . a:day . "'"
	endif
	return l:retval
endfunction                                                        " }}}3
" Function: s:validDay                                               {{{3
" Purpose:  check day validity
" Params:   1 - year [integer]
"           2 - month [integer]
"           3 - day [integer]
" Insert:   nil
" Return:   whether valid day [boolean]
function! s:validDay(year, month, day)
	if DNU_ValidPosInt(a:day)
		if a:day <= s:monthLength(a:year, a:month)
			return b:dn_true
		endif
	endif
	return b:dn_false
endfunction                                                        " }}}3
" Function: s:validMonth                                             {{{3
" Purpose:  check month validity
" Params:   1 - month [integer]
" Insert:   nil
" Return:   whether valid month [boolean]
function! s:validMonth (month)
	if DNU_ValidPosInt(a:month) && a:month <= 12
        return b:dn_true
    endif
	return b:dn_false
endfunction                                                        " }}}3
" Function: s:validYear                                              {{{3
" Purpose:  check year validity
" Params:   1 - year [integer]
" Insert:   nil
" Return:   whether valid year [boolean]
function! s:validYear(year)
	return DNU_ValidPosInt(a:year)
endfunction                                                        " }}}3
" Function: s:yearDoomsday                                           {{{3
" Purpose:  return doomsday for year
" Params:   1 - year [integer]
" Insert:   nil
" Return:   day in week [integer]
" Note:     uses Doomsday algorithm created by John Horton Conway
function! s:yearDoomsday(year)
	let l:years_in_century = a:year % 100
	let l:P = l:years_in_century / 12
	let l:Q = l:years_in_century % 12
	let l:R = l:Q / 4
	let l:century_doomsday = s:centuryDoomsday(a:year)
	return (l:P + l:Q + l:R + l:century_doomsday) % 7
endfunction                                                        " }}}3

" 3.3  File/directory                                                {{{2
" Functions related to files and directories
" Function: DNU_GetFilePath                                          {{{3
" Purpose:  get filepath of file being edited
" Params:   nil
" Return:   filepath [string]
function! DNU_GetFilePath()
	return expand('%:p')
endfunction                                                        " }}}3
" Function: DNU_GetFileDir                                           {{{3
" Purpose:  get directory of file being edited
" Params:   nil
" Return:   directory [string]
function! DNU_GetFileDir()
    return expand('%:p:h')
endfunction                                                        " }}}3
" Function: DNU_GetFileName                                          {{{3
" Purpose:  get name of file being edited
" Params:   nil
" Return:   directory [string]
function! DNU_GetFileName()
    return expand('%:p:t')
endfunction                                                        " }}}3
" Function: DNU_GetRtpDir                                            {{{3
" Purpose:  finds directory in runtimepath
" Params:   1 - directory name [string]
"           2 - allow multiples [boolean,optional, default=false]
" Return:   default: filepath [string], '0' if failure
"           multiple=true: filepaths [List], [] if failure
" Note:     default behaviour is to return a single filepath
"           - if multiple matches found get user to select one
"           if allow multiples, return list (even if only one match)
function! DNU_GetRtpDir(dir, ...)
    " set vars
    if a:0 > 1 && a:1
        let l:allow_multiples = b:dn_true
    else
        let l:allow_multiples = b:dn_false
    endif
    if a:dir == ''
        if l:allow_multiples
            return []
        else
            return 0
        endif
    endif
    " search for directory
    let l:matches = split(globpath(&rtp, a:dir, b:dn_false), ',')
    " if allowing multiple matches
    if l:allow_multiples
        return l:matches
    endif
    " if insisting on single directory
    if     len(l:matches) == 0
        return 0
    elseif len(l:matches) == 1
        return l:matches[0]
    else
        return DNU_MenuSelect(l:matches, 'Select directory path:')
    endif
endfunction                                                        " }}}3

" 3.4  User interaction                                              {{{2
" Functions related to user interaction
" Function: DNU_ShowMsg                                              {{{3
" Purpose:  display message to user
" Params:   1 - message [string]
"           2 - message type [allowed values='generic'|'warning'|'info'|
"               'question'|'error', optional, string]
" Return:   nil
function! DNU_ShowMsg(msg, ...)
	let l:msg = a:msg
    let l:valid_types = {'warning': 1, 'info': 1, 'question': 1, 'error': 1}
	let l:type = ''
	" sanity check
	let l:error = 0
	if l:msg == ''
		let l:msg = "No message supplied to 'DNU_ShowMsg'"
		let l:error = 1
		let l:type = "Error"
	endif
	" set dialog type (if valid type supplied and not overridden by error)
	if !l:error
		if a:0 > 0
            if has_key(l:valid_types, tolower(a:1))
    			let l:type = tolower(a:1)
	    	endif
        endif
	endif
	" for non-gui environment add message type to output
	if !has ('gui_running') && l:type != ''
		let l:msg = toupper(strpart(l:type, 0, 1)) 
					\ . tolower(strpart(l:type, 1))
					\ . ": " 
					\ . l:msg
	endif
	" display message
	call confirm(l:msg, '&OK', 1, l:type)
endfunction                                                        " }}}3
" Function: DNU_Error                                                {{{3
" Purpose:  display error message
" Params:   1 - error message [string]
" Insert:   nil
" Prints:   error msg in error highlighting accompanied by system bell
" Return:   nil
function! DNU_Error(msg)
    " require double quoting of execution string so backslash
    " is interpreted as an escape token
	if mode() == 'i' | execute "normal \<Esc>" | endif
	echohl ErrorMsg
	echo a:msg
	echohl Normal 
endfunction                                                        " }}}3
" Function: DNU_Warn                                                 {{{3
" Purpose:  display warning message
" Params:   1 - warning message [string]
" Insert:   nil
" Prints:   warning msg in warning highlighting accompanied by system bell
" Return:   nil
function! DNU_Warn(msg)
	if mode() == 'i' | execute "normal \<Esc>" | endif
	echohl WarningMsg
	echo a:msg
	echohl Normal 
endfunction                                                        " }}}3
" Function: DNU_Prompt                                               {{{3
" Purpose:  display prompt message
" Params:   1 - prompt [default='Press [Enter] to continue...', 
"                       optional, string]
" Insert:   nil
" Prints:   messages
" Return:   nil
function! DNU_Prompt(...)
    " variables
    if a:0 > 0 | let l:prompt = a:1
    else       | let l:prompt = 'Press [Enter] to continue...'
    endif
    " display prompt
	echohl MoreMsg
	call input(l:prompt)
	echohl Normal
    echo "\n"
endfunction                                                        " }}}3
" Function: DNU_Wrap                                                 {{{3
" Purpose:  echoes text but wraps it sensibly
" Params:   1 - message [string]
" Insert:   nil
" Prints:   messages
" Return:   nil
function! DNU_Wrap(msg)
    " variables
    let l:width = winwidth(0) - 1
    let l:msg = a:msg
    " deal with simple case of no input
    if a:msg == ''
        echon "\n"
        return
    endif
    " process for wrapping
    while l:msg != ''
        " exit on last output line
        if len(l:msg) <= l:width
            echo l:msg
            break
        endif
        " find wrap point
        let l:break = -1 | let l:count = 1 | let l:done = b:dn_false
        while !l:done
            let l:index = match(l:msg, '[!@*-+;:,./? \t]', '', l:count)
            if     l:index == -1     | let l:done = b:dn_true
            elseif l:index < l:width | let l:break = l:index
            endif
            let l:count += 1
        endwhile
        " if no wrap point then have ugly situation where no breakpoint
        " exists so just output whole thing (ick!)
        if l:break == -1 | echo l:msg | break | endif
        " let's wrap!
        let l:break += 1
        echo strpart(l:msg, 0, l:break)
        let l:msg = strpart(l:msg, l:break)
        " - if broke line on punctuation mark may now have leading space
        if strpart(l:msg, 0, 1) == ' '
            let l:msg = strpart(l:msg, 1)
        endif
    endwhile
endfunction                                                        " }}}3
" Function: DNU_MenuSelect                                           {{{3
" Purpose:  select item from menu
" Params:   1 - menu items [List,Dict]
"           2 - prompt [default='Select an option:', optional, string]
" Insert:   nil
" Return:   selected menu item ("" means no item selected) [string]
" Warning:  if an empty menu item is provided it can be selected and returned
"           and there is no way to distinguish this from an aborted selection
" Note:     with dicts the keys become menu options and the corresponding
"           value is the return value
" Note:     lists and dicts can have lists and dicts as elements/values
" Note:     if list has list for element the first element in the child list
"           is used as menu item in parent menu
" Note:     if list has dict for element the value for key '__PARENT_ITEM__'
"           is used as menu item in parent menu
" Note:     to indicate a submenu this function appends an arrow (->) to the
"           end of the parent menu option
function! DNU_MenuSelect(items, ...)
    " set basic variables
    " - simple data types
    let l:simple_types = []    " [string, number, float]
    call add(l:simple_types, type(""))
    call add(l:simple_types, type(0))
    call add(l:simple_types, type(0.0))
    " - data types used for menus
    let l:menu_types = []    " [List, Dict]
    call add(l:menu_types, type([]))
    call add(l:menu_types, type({}))
    if     type(a:items) == type([]) | let l:menu_type = 'list'
    elseif type(a:items) == type({}) | let l:menu_type = 'dict'
    else
        call DNU_Error('Parent menu must be List or Dict')
        return ''
    endif
    " - check supplied menu items
    if len(a:items) == 0 | return "" | endif |    " must have menu items
    " - prompt
    let l:prompt = "Select an option:"    " default used if none provided
    if a:0 > 0 && a:1 != "" | let l:prompt = DNU_Stringify(a:1) | endif
    " - dict key used for parent menu item
    let l:parent_item_key = "__PARENT_ITEM__"
    " build list of options for display
    let l:display = [] | let l:dict_vals = [] | let l:index = 1
	call add(l:display, l:prompt)
	let l:len = len(len(a:items))    " gives width of largest item index
    if l:menu_type == 'list' | let l:items = deepcopy(a:items)
    else                     | let l:items = keys(a:items)
    endif
	for l:Item in l:items
		" left pad index with zeroes to ensure all right justified
		let l:display_index = l:index
		while len(l:display_index) < l:len
			let l:display_index = '0' . l:display_index
		endwhile
        " if submenu process differently
        if l:menu_type == 'list'
            " check if parent list has child list
            " - if so, use child list's first element as parent menu option
            if type(l:Item) == type([])
                " need at least one item in child list
                if len(l:Item) == 0
                    call DNU_Error('Empty child list')
                    return ''
                endif
                " first element must be simple data type
                if index(l:simple_types, type(l:Item[0])) == -1
                    let l:msg = "Invalid parent menu item in child list:\n\n"
                    call DNU_Error(l:msg . DNU_Stringify(l:Item[0]))
                    return ''
                endif
                " first element cannot be empty
                let l:candidate_option = DNU_Stringify(l:Item[0])
                if l:candidate_option != ''  " add submenu signifier
                    unlet l:Item
                    let l:Item = l:candidate_option . ' ->'
                else  " first element is empty
                    let l:msg = "Empty parent menu item in child dict\n\n"
                    call DNU_Error(l:msg . DNU_Stringify(l:Item))
                    return ''
                endif
            endif
            " check if parent list has child dict
            " - if so, use child dict's parent item value as parent menu option
            if type(l:Item) == type({})
                " must have parent menu item key
                if has_key(l:Item, l:parent_item_key)
                    let l:candidate_option = 
                                \ DNU_Stringify(l:Item[l:parent_item_key])
                    " parent menu item value cannot be empty
                    if l:candidate_option != ''    " add submenu signifier
                        unlet l:Item
                        let l:Item = l:candidate_option . ' ->'
                    else  " parent item value is empty
                        let l:msg = "Empty parent menu item in child dict\n\n"
                        call DNU_Error(l:msg . DNU_Stringify(l:Item))
                        return ''
                    endif
                else    " no parent menu item key in dict
                    let l:msg = "No parent menu item in child dict:\n\n"
                    call DNU_Error(l:msg . DNU_Stringify(l:Item))
                    return ''
                endif
            endif
        else    " l:menu_type == 'dict'
            " add dict value to values list
            call add(l:dict_vals, a:items[l:Item])
            " check if parent dict has child list or dict 
            " - if so, add submenu signifier to parent menu item
            if index(l:menu_types, type(a:items[l:Item])) >= 0
                let l:Item .= ' ->'
            endif
        endif
        " prepend index to option text and add option to display list
		let l:option = l:display_index . ') ' . DNU_Stringify(l:Item)
		call add(l:display, l:option)
        " prepare for next loop iteration
		let l:index += 1
        unlet l:Item    " in case a:items elements are of different types
	endfor
	" make choice
	let l:choice = inputlist(l:display)
    echo ' ' |    " needed to force next output to new line
    " process choice
	if l:choice > 0 && l:choice < l:index    " must be valid selection
        if l:menu_type == 'list'
            " return menu item if list
            let l:Selection = get(a:items, l:choice - 1)
        else    " l:menu_type == 'dict'
            " return matching value if dict
            let l:Selection = l:dict_vals[l:choice - 1]
        endif
        " recurse if selected a submenu
        if     type(l:Selection) == type([])    " list child menu
            if l:menu_type == 'list'    " list parent menu
                " list parent uses first element of child list as menu item
                call remove(l:Selection, 0)
            endif
            return DNU_MenuSelect(l:Selection, l:prompt)
        elseif type(l:Selection) == type({})    " dict child menu
            if l:menu_type == 'list'    " list parent menu
                " list parent uses special value in child dict as menu item
                call remove(l:Selection, l:parent_item_key)
            endif
            return DNU_MenuSelect(l:Selection, l:prompt)
        else    " return simple value
            return l:Selection
        endif
	else    " invalid selection
        return ''
	endif
endfunction                                                        " }}}3
" Function: DNU_Help                                                 {{{3
" Purpose:  user can select from help topics
" Params:   1 - insert mode [default=<false>, optional, boolean]
" Insert:   nil
" Return:   nil
" Note:     extensible help system relying on buffer Dictionary
"           variables b:dn_help_plugins, b:dn_help_topics and b:dn_help_data
" Note:     b:dn_help_plugins is a list of all plugins contributing help
" Note:     b:dn_help_topics will be submitted to DNU_MenuSelect to
"           obtain a *unique* value
" Note:     b:dn_help_data has as keys the unique values returned by
"           b:dn_help_topics and as values Lists with the help text to
"           be returned
" Note:     the List help data is output as concatenated text; to insert
"           a newline use an empty lists element ('')
" Note:     other plugins can add to the help variables and so take
"           advantage of the help system; the most friendly way to do this
"           is for the b:dn_help_topics variable to have a single top-level
"           menu item reflecting the plugin name/type, and for the topic
"           values to be made unique by appending to each a prefix unique to
"           its plugin
" Example:  if !exists('b:dn_help_plugins') | let b:dn_help_plugins = {} | endif
"           if index(b:dn_help_plugins, 'foo', b:dn_true) == -1
"             call add(b:dn_help_plugins, 'foo')
"           endif
"           if !exists('b:dn_help_topics') | let b:dn_help_topics = {} | endif
"           let b:dn_help_topics['foo'] = { 'how to wibble': 'foo_wibble' }
"           if !exists('b:dn_help_data') | let b:dn_help_data = {} | endif
"           let b:dn_help_data['foo_wibble'] = [ 'How to wibble:', '', 'Details...' ]
function! DNU_Help(...)
	echo '' | " clear command line
    " variables
    let l:insert = (a:0 > 0 && a:1) ? b:dn_true : b:dn_false
    let l:topic = ''  " help topic selected by user
    " - require basic help variables
    if !exists('b:dn_help_topics')
        call DNU_Error('No help menu variable available')
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    if empty(b:dn_help_topics)
        call DNU_Error('No help topics defined')
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    if !exists('b:dn_help_data')
        call DNU_Error('No help data variable available')
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    if empty(b:dn_help_data)
        call DNU_Error('No help data defined')
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    " brag about help
    echo 'Dn-Utils Help System'
    if exists('b:dn_help_plugins') && !empty(b:dn_help_plugins) 
        let l:plugin = (len(b:dn_help_plugins) == 1) ? 'plugin' : 'plugins'
        echon "\n[contributed by " . l:plugin . ': '
        echon join(b:dn_help_plugins, ', ') . "]\n"
    endif
    " select help topic
    let l:prompt = 'Select a help topic:'
    let l:topic = DNU_MenuSelect(b:dn_help_topics, l:prompt)
    if l:topic == ''
        call DNU_Error('No help topic selected')
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    if !has_key(b:dn_help_data, l:topic)
        call DNU_Error("No help data for topic '" . l:topic . "'")
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    let l:data = b:dn_help_data[l:topic]
    if type(l:data) != type([])
        let l:msg = "Help data for topic '" . l:topic . "' is not a List"
        call DNU_Error(l:msg)
        if l:insert | call DNU_InsertMode(1) | endif
        return
    endif
    " display help
    redraw  " erase menu output
    let l:more = &more  " want pager for long help
    set more
    let l:msg = ''
    for l:output in l:data
        if l:output == '' | call DNU_Wrap(l:msg) | let l:msg = ''
        else              | let l:msg .= l:output
        endif
    endfor
    if l:msg != '' | call DNU_Wrap(l:msg) | endif
    if !l:more | set nomore | endif
    " return to calling mode
    if l:insert | call DNU_InsertMode(1) | endif
endfunction                                                        " }}}3
" Function: DNU_GetSelection                                         {{{3
" Purpose:  returns selected text
" Params:   nil
" Insert:   nil
" Return:   selected text ('' if no text selected) [string]
" Note:     works for all selection types; newlines are preserved
" Note:     can return multi-line string -- functions that use return value
"           and are called via a mapping can have range assigned, which may
"           result in function being called once per line if it does not
"           handle the range (see |:call| and |function-range-example|)
function! DNU_GetSelection()
    try
        let l:a_save = @a
        normal! gv"ay
        return @a
    finally
        let @a = l:a_save
    endtry
endfunction                                                        " }}}3

" 3.5  Lists                                                         {{{2
" Functions related to lists
" Function: DNU_ListGetPartialMatch                                  {{{3
" Purpose:  get the first element containing given pattern
" Params:   1 - list to search [List]
"           2 - pattern fragment to match on [string]
" Return:   first matching element (empty string if no match) [string]
function! DNU_ListGetPartialMatch(list, pattern)
	let l:matches = filter(
                \   deepcopy(a:list), 
				\   'v:val =~ "' . a:pattern . '"' 
				\ )
	if empty(l:matches) | return ''
	else                | return index(a:list, l:matches[0])
	endif
endfunction                                                        " }}}3
" Function: DNU_ListExchangeItems                                    {{{3
" Purpose:  exchange two elements in the same list
" Params:   1 - list to process [List]
"           2 - index of first element to exchange [integer]
"           3 - index of second element to exchange [integer]
" Return:   whether successfully exchanged items [boolean]
" Note:     by not copying input list are acting on original
function! DNU_ListExchangeItems(list, index1, index2)
	if get(a:list, a:index1, ":INVALID:") ==# ":INVALID:" | return 0 | endif
	if get(a:list, a:index2, ":INVALID:") ==# ":INVALID:" | return 0 | endif
	let l:item1 = a:list[a:index1]
    let a:list[a:index1] = a:list[a:index2]
    let a:list[a:index2] = l:item1
	return b:dn_true
endfunction                                                        " }}}3
" Function: DNU_ListSubtract                                         {{{3
" Purpose:  subtract one list from another
" Params:   1 - list to subtract from [List]
"           2 - list to be subtracted [List]
" Return:   new list [List]
" Note:     performs 'list_1 - list_2'
function! DNU_ListSubtract(list_1, list_2)
	let l:list_new = []
	" cycle through major list elements
	" for each, check if in minor list - if not, add to return list
	for l:item in a:list1
		if !count(a:list2, l:item)
			call add(l:list_new, l:item)
		endif
	endfor
	return l:list_new
endfunction                                                        " }}}3
" Function: DNU_ListToScreen                                         {{{3
" Purpose:  formats list for screen display
" Params:   1 - list to format for display [List]
"           2 - maximum width of text [default=60, optional, integer]
"           3 - indext at start of line [default=0, optional, integer]
"           4 - delimiter [default=' ', optional, integer]
" Return:   formatted display [string]
function! DNU_ListToScreen(list, ...)
	" determine variables
	let l:delim = ' ' | let l:scrn_width = 60 | let l:indent_len = 0
	if a:0 >= 3 && a:3 != '' | let l:delim = a:3 | endif
	if a:0 >= 2 && DNU_ValidPosInt(a:2) | let l:indent_len = a:2 | endif
	let l:indent = repeat(' ', l:indent_len)
	if a:0 >= 1 && DNU_ValidPosInt(a:1) | let l:scrn_width = a:1 | endif
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
endfunction                                                        " }}}3
" Function: DNU_ListToScreenColumns                                  {{{3
" Purpose:  formats list for screen display in columns
" Params:   1 - list to format for display [List]
"           2 - maximum width of text (default: 60) [optional, integer]
"           3 - column width = longest item strlen
"                              + col_padding (default: 1) [optional, integer]
"           4 - indent at start of line (default: 0) [optional, integer]
" Return:   formatted display [string]
function! DNU_ListToScreenColumns(list, ...)
	" determine variables
	let l:scrn_width = 60 | let l:col_padding = 1 | let l:indent_len = 0
	if a:0 >= 3 && DNU_ValidPosInt(a:3) | let l:indent_len  = a:3 | endif
	if a:0 >= 2 && DNU_ValidPosInt(a:2) | let l:col_padding = a:2 | endif
	if a:0 >= 1 && DNU_ValidPosInt(a:1) | let l:scrn_width  = a:1 | endif
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
	while get(a:list, l:index, ":INVALID:") !=# ":INVALID:"
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
	return DNU_TrimChar(l:msg)  " remove trailing spaces
endfunction                                                        " }}}3

" 3.6  Programming                                                   {{{2
" Function: DNU_UnusedFunctions                                      {{{3
" Purpose:  checks for uncalled functions
" Params:   1 - lower line boundary within which to search
"               default: 1 [optional, integer]
"           2 - upper line boundary within which to search
"               default: last line [optional, integer]
" Return:   list of unused functions [string]
function! DNU_UnusedFunctions(...)
	try
		" variables
		let l:errmsg = ''
        let l:cursors = []
        call add(l:cursors, getpos("."))
		let l:bound_lower = 1 | let l:bound_upper = line("$")
		if a:0 >= 1 && DNU_ValidPosInt(a:1)
			let l:bound_lower = (a:1 > 1) 
                        \ ? (a:1 - 1) 
                        \ : 1
		endif
		if a:0 >= 2 && DNU_ValidPosInt(a:2)
			let l:bound_upper = (a:2 <= l:bound_upper) 
                        \ ? a:2 
                        \ : l:bound_upper
		endif
		if l:bound_upper <= l:bound_lower
			let l:errmsg = 'Upper bound must be greater then lower bound'
			throw ''
		endif
		let l:index = l:bound_lower
		let l:unused = ''
		" remove folds
		execute 'normal zR'
		" time to start iterating through range
		call cursor(l:bound_lower, 1)
		" find next function
		let l:func_decl = '^\s\{}fu\%[nction]\s\{1,}\p\{1,}('
		while search(l:func_decl, 'W') && line('.') <= l:bound_upper
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
			call cursor(l:bound_lower, 1)
			let l:called = b:dn_false
			while search(l:func_srch . '(', 'W')
						\ && line(".") <= l:bound_upper
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
						let l:called = b:dn_true
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
		let l:retval = 1
		if len(l:unused) > 0
			let l:msg = 'Declared but unused functions:' . "\n"
						\ . '[Warning: Algorithm is imperfect -- '
						\ . 'check before deleting!]'
						\ . "\n\n"
						\ . DNU_ListToScreenColumns(l:unused, 1)
		else
			let l:msg = 'There are no unused functions'
		endif
		echo l:msg		
	catch
		let l:errmsg = (l:errmsg != '') ? l:errmsg
					\ : 'Unhandled exception occurred'
		call DNU_ShowMsg(l:errmsg, "Error")
		let l:retval = 0
	finally
        call setpos('.', remove(l:cursors, -1)) 
		return l:retval
	endtry
endfunction                                                        " }}}3
" Function: DNU_InsertMode                                           {{{3
" Purpose:  switch to insert mode
" Params:   1 - right skip [optional, integer]
" Insert:   nil
" Return:   nil
" Note:     this function is often used by other functions if they were
"           called from insert mode; in such cases it will usually be
"           invoked with one right skip to compensate for the left skip
"           that occured when initially escaping from insert mode
function! DNU_InsertMode(...)
	let l:right_skip = (a:0 > 0 && a:1 > 0) 
                \ ? a:1 
                \ : 0
	" override skip if cursor at eol to prevent error beep
	if col('.') >= strlen(getline('.')) | let l:right_skip = 0 | endif
	" skip right if so instructed
	if l:right_skip > 0 | silent execute 'normal ' . l:right_skip . 'l' | endif
	" handle case where cursor at end of line
	if col('.') >= strlen(getline('.')) | startinsert! " =~ 'A'
	else                                | startinsert  " =~ 'i'
	endif
endfunction                                                        " }}}3

" 3.7  Version control                                               {{{2
" Functions related to version control
" RCS functions are deprecated in favour of git functions
" Function: DNU_GitMake                                              {{{3
" Purpose:  creates git repo, adds current file and does first commit
" Params:   1 - called from insert mode [default=<false>, optional, boolean]
" Return:   nil
" Note:     creates git repo in current file's directory
function! DNU_GitMake(...)
    echo '' | " clear command line
    " mode specific
    if a:0 > 0 && a:1 | execute "normal \<Esc>" | endif
	" write file as VCS commands do not automatically do this
	silent execute 'update'
	" change to filedir if it isn't cwd
    let l:file = expand('%')
	let l:path = DNU_GetFileDir()
	let l:cwd = getcwd() . '/'
	if l:cwd != l:path
		try
			silent execute 'lcd %:p:h'
		catch
			let l:msg = 'Fatal error: Unable to change to the current' 
						\ . "document's directory:\n"
						\ . "'" . l:path . "'.\n"
						\ . 'Aborting.'
			call confirm(l:msg, 'OK')
            if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
			return
		endtry
	endif
    " create git repo in file directory
    if has('unix')
        call system('git init')
        if v:shell_error
            let l:msg = 'Fatal Error: Unable to initialise git repository'
            call DNU_Error(l:msg)
            if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
            return
        endif
    elseif has('win32') || has('win64')
        call DNU_Warn('Not yet implemented for windows')
        if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
        return
    else
        call DNU_Warn('Not yet implemented on this OS')
        if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
        return
    endif
    " add current file to repository
    try
        silent execute 'VCSAdd'
    catch
        let l:msg = 'Fatal error: Unable to add current file to' 
                    \ . "git repository.\n"
                    \ . 'Aborting.'
        call confirm(l:msg, 'OK')
        if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
        return
    endtry
    execute 'bdelete' | " VCSAdd creates hsplit buffer 'git add <file>'
    " commit file
    try
        silent execute 'VCSCommit initial commit'
    catch
        let l:msg = 'Fatal error: Unable to commit current file to' 
                    \ . "git repository.\n"
                    \ . 'Aborting.'
        call confirm(l:msg, 'OK')
        if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
        return
    endtry
    execute 'bdelete' | " VCSCommit creates hsplit buffer 'git commit <file>'
    " succeeded
    let l:msg = 'Successfully (re-)initialised git repository' . "\n"
                \ . "and committed file '" . l:file . "' to it."
    call DNU_ShowMsg(l:msg)
    if a:0 > 0 && a:1 | call DNU_InsertMode(1) | endif
endfunction                                                        " }}}3

" 3.8  Strings                                                       {{{2
" Functions related to strings
" Function: DNU_StripLastChar                                        {{{3
" Purpose:  removes last character from string
" Params:   string to edit [string]
" Return:   altered string [string]
function! DNU_StripLastChar(edit_string)
	return strpart(
				\ 	a:edit_string,
				\ 	0,
				\ 	strlen(a:edit_string) - 1
				\ )
endfunction                                                        " }}}3
" Function: DNU_InsertString                                         {{{3
" Purpose:  insert string at current cursor location
" Params:   1 - string for insertion [string]
"           2 - use 'paste' setting  [default=<true>, optional, boolean]
" Return:   nil
" Usage:    function! s:dn:doSomething(...)
"           	let l:insert = (a:0 > 0 && a:1)
"           	        \ ? 1 
"           	        \ : 0
"           	...
"           	call DNU_InsertString(l:string)
"           	if l:insert | call DNU_InsertMode() | endif
"           endfunction
function! DNU_InsertString(inserted_text, ...)
    let l:restrictive = b:dn_true
    if a:0 > 1 && ! a:1 | let l:restrictive = b:dn_false | endif
	if l:restrictive | let l:paste_setting = &paste | set paste | endif
	silent execute 'normal a' . a:inserted_text
	if l:restrictive && ! l:paste_setting | set nopaste | endif
endfunction                                                        " }}}3
" Function: DNU_TrimChar                                             {{{3
" Purpose:  removes leading and trailing chars from string
" Params:   1 - string to trim [string]
"           2 - char to trim [default=' ', optional, char]
" Return:   trimmed string [string]
function! DNU_TrimChar(edit_string, ...)
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
endfunction                                                        " }}}3
" Function: DNU_Entitise                                             {{{3
" Purpose:  replace special html characters with entities
" Params:   1 - string [string]
" Insert:   nil
" Return:   altered string [string]
function! DNU_Entitise(str)
	let l:str = a:str
	let l:str = substitute(l:str, '&', '&amp;',  'g')
	let l:str = substitute(l:str, '>', '&gt;',   'g')
	let l:str = substitute(l:str, '<', '&lt;',   'g')
	let l:str = substitute(l:str, "'", '&apos;', 'g')
	let l:str = substitute(l:str, '"', '&quot;', 'g')
	return l:str
endfunction                                                        " }}}3
" Function: DNU_Deentitise                                           {{{3
" Purpose:  replace entities with characters for special html characters
" Params:   1 - string [string]
" Insert:   nil
" Return:   altered string [string]
function! DNU_Deentitise(str)
	let l:str = a:str
	let l:str = substitute(l:str, '&quot;', '"', 'g')
	let l:str = substitute(l:str, '&apos;', "'", 'g')
	let l:str = substitute(l:str, '&lt;',   '<', 'g')
	let l:str = substitute(l:str, '&gt;',   '>', 'g')
	let l:str = substitute(l:str, '&amp;',  '&', 'g')
	return l:str
endfunction                                                        " }}}3
" Function: DNU_Stringify                                            {{{3
" Purpose:  convert variables to string
" Params:   1 - variable [any]
"           2 - quote_strings [optional, default=false, boolean]
" Insert:   nil
" Return:   converted variable [string]
" Note:     if quoting then strings will be enclosed in single quotes
"           with internal single quotes doubled
function! DNU_Stringify(var, ...)
    " l:Var and l:Item are capitalised because they can be funcrefs
    " and local funcref variables must start with a capital letter
    let l:Var = deepcopy(a:var)
    " are we quoting string output?
    let l:quoting_strings = (a:0 > 0 && a:1) 
                \ ? b:dn_true 
                \ : b:dn_false
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
            call add(l:out, DNU_Stringify(l:Item, b:dn_true))
            unlet l:Item
        endfor
        return "[ " . join(l:out, ", ") . " ]"
    " Dictionary
    " use perl-style 'big arrow' notation
    elseif type(a:var) == type({})
        let l:out = []
        for l:key in sort(keys(l:Var))
            let l:val = DNU_Stringify(l:Var[l:key], b:dn_true)
            call add(l:out, "'" . l:key . "' => " . l:val)
        endfor
        return "{ " . join(l:out, ", ") . " }"
    " Funcref
    elseif type(a:var) == type(function("tr"))
        return string(l:Var)
    " have now covered all five variable types
    else
        call DNU_Error('invalid variable type')
        return b:dn_false
    endif    
endfunction                                                        " }}}3
" Function: DNU_MatchCount                                           {{{3
" Purpose:  finds number of occurrences of a substring in a string
" Params:   1 - haystack [string]
"           2 - needle [string]
" Insert:   nil
" Return:   number of occurrences [number]
function! DNU_MatchCount(haystack, needle)
    " variables
    " - stridx provides informative errors for wrongly typed
    "   haystack and needle values
    let l:matches = 0  " number of searches performed
    let l:pos = -1   " position to search from
    " do progressive search
    while b:dn_true
        let l:pos = stridx(a:haystack, a:needle, l:pos + 1)
        " stop searching when run out of matches
        if l:pos == -1 | break | endif
        " if still here then search was successful
        let l:matches += 1
    endwhile
    " return count
    return l:matches
endfunction                                                        " }}}3
" Function: DNU_StridxNum                                            {{{3
" Purpose:  finds position of the X'th match of a substring in a string
" Params:   1 - haystack [string]
"           2 - needle [string]
"           3 - which successive match to return index of [number]
" Insert:   nil
" Return:   position of start of final match
"           (-1 if match not found) [number]
" Example:  let l:string = 'inside Winston''s inner sanctum'
"           echo DNU_StridxNum(l:string, 'in', 2)  " 8
function! DNU_StridxNum(haystack, needle, number)
    " variables
    " - stridx provides informative errors for wrongly typed
    "   haystack and needle values
    " - wrongly typed a:number causes silent fail so detect manually
    if type(a:number) != type(0)
        let l:msg = "Number argument '" . DNU_Stringify(a:number) 
                    \ . "' is wrong type (" . type(a:number) . ")"
        call DNU_Error(l:msg)
        return -1
    endif
    let l:search_count = 0  " number of searches performed
    let l:pos = -1   " position to search from
    " do progressive search
    while b:dn_true
        let l:pos = stridx(a:haystack, a:needle, l:pos + 1)
        " no valid match to be found
        if l:pos == -1 | return -1 | endif
        " if still here then search was successful
        let l:search_count += 1
        " are finished if have reached required number of searches
        if l:search_count == a:number | return l:pos | endif
    endwhile
endfunction                                                        " }}}3
" Function: DNU_PadInternal                                          {{{3
" Purpose:  insert char at given position until initial location is at
"           the desired location
" Params:   1 - initial string [string]
"           2 - position to insert at [number]
"           3 - target position [number]
"           4 - char to pad with [default=' ', optional, char]
" Insert:   nil
" Return:   altered string [string]
" Note:     if arg 4 is string then only first char is used
" Example:  let l:string1 = 'Column Twenty & Column Twenty One"
"           let l:string2 = 'Column Twenty Two & Column Twenty Three"
"           let l:string1 = DNU_PadInternal(l:string1, 14, 4)
"           echo l:string1  " Column Twenty     & Column Twenty One
"           echo l:string2  " Column Twenty Two & Column Twenty Three
function! DNU_PadInternal(string, start, target, ...)
    " variables
    if type(a:string) != type('')
        call DNU_Error('First argument is not a string')
        return a:string
    endif
    if type(a:start) != type(0)
        call DNU_Error('Second argument is not an integer')
        return a:string
    endif
    if type(a:target) != type(0)
        call DNU_Error('Third argument is not an integer')
        return a:string
    endif
    let l:char = (a:0 > 0 && a:1 != '') 
                \ ? strpart(a:1, 0, 1) 
                \ : ' '
    let l:start = a:start
    if l:start >= a:target | return a:string | endif
    if a:start < 0
        call DNU_Error('Negative start argument')
        return a:string
    endif
    " build internal pad
    let l:pad = ''
    while l:start < a:target | let l:pad .= ' ' | let l:start += 1 | endwhile
    " insert internal pad and return result
    return strpart(a:string, 0, a:start) 
                \ . l:pad 
                \ . strpart(a:string, a:start)
endfunction                                                        " }}}3
" Function: DNU_ChangeHeaderCaps                                     {{{3
" Purpose:  changes capitalisation of line or visual selection
" Params:   1 - calling mode ['n'|'v'|'i']
" Insert:   replaces line or selection with altered line or selection
" Return:   nil
" Note:     user chooses capitalisation type:
"             upper case
"             lower case
"             capitalise every word
"             sentence case
"             title case
function! DNU_ChangeHeaderCaps(mode)
    echo "" | " clear command line
    " mode specific
    let l:mode = tolower(a:mode)
    if l:mode == 'i' | execute "normal \<Esc>" | endif
    " variables
    let l:line_replace_modes = ['n', 'i']
    let l:visual_replace_modes = ['v']
    let l:options = {
                \ 'Upper case':            'upper',
                \ 'Lower case':            'lower',
                \ 'Capitalise every word': 'start',
                \ 'Sentence case':         'sentence',
                \ 'Title case':            'title'
                \ }
    " get header case type
    try
        let l:type = DNU_MenuSelect(l:options, 'Select header case:')
        if l:type == '' | throw 'No header selected' | endif
    catch /.*/
        echo ' ' | " ensure starts on new line
        call DNU_Error('Header case not selected')
        return ''
    endtry
    " operate on current line (normal or insert mode)
    if     count(l:line_replace_modes, l:mode)
        let l:header = getline('.')
        let l:header = s:headerCapsEngine(l:header, l:type)
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
            let l:header = s:headerCapsEngine(l:header, l:type)
            " write back result to register x
            let @x = l:header
            " re-select visual selection and delete
            normal gvd
            " paste replacement string
            normal "xP
        finally
            " make sure to leave register a as we found it
            let @x = l:x_save
        endtry
    else
        call DNU_Error("Mode param is '" . l:mode . "'; must be [n|i|v]")
    endif
    " return to insert mode if called from there
    if l:mode == 'i' | call DNU_InsertMode(1) | endif
endfunction                                                        " }}}3
" Function: s:headerCapsEngine                                       {{{3
" Purpose:  change capitalisation of header
" Params:   1 - header to convert [string]
"           2 - caps type ('upper'|'lower'|'sentence'|'start'|'title')
"               [string]
" Insert:   nil
" Return:   converted header [string]
" Note:     newlines are not expected but happen to be preserved
"           types of capitalisation:
"             upper:    TO BE OR NOT TO BE
"             lower:    to be or not to be
"             sentence: To be or not to be (capitalise first word only)
"             start:    To Be Or Not To Be (calitalise all words)
"             title:    To Be or Not to Be (capitalise first and last words,
"                                           and all words except articles,
"                                           prepositions and conjunctions of
"                                           fewer than five letters)
function! s:headerCapsEngine(string, type)
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
    if a:string == '' | return '' | endif
    if count(l:types, l:type) != 1 | throw "Bad type '" . l:type . "'" | endif
    " break up string into word fragments
    let l:words = split(a:string, '\<\|\>')
    " process words individually
    let l:index = 0
    let l:last_index = len(l:words) - 1
    let l:first_word = b:dn_true
    let l:last_word = b:dn_false
    for l:word in l:words
        let l:word = tolower(l:word)    " first make all lowercase
        let l:last_word = (l:index == l:last_index)    " check for last word
        if     l:type == 'upper'
            let l:word = toupper(l:word)
        elseif l:type == 'lower'
            " already made lowercase so nothing to do here
        elseif l:type == 'start'
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
            if l:type == 'title' && !count(l:pseudowords, l:word)
                let l:word = substitute(l:word, "\\w\\+", "\\u\\0", 'g')
            endif
        else  " type is 'sentence' or 'title' and word is neither first or last
            " if 'sentence' type then leave lowercase
            if l:type == 'title'
                " capitalise if not in list of words to be kept lowercase
                " and is not a psuedo-word
                if !count(l:title_lowercase, l:word) 
                            \ && !count(l:pseudowords, l:word)
                    let l:word = substitute(l:word, "\\w\\+", "\\u\\0", 'g')
                endif
            endif
        endif
        " negate first word flag after first word is encountered
        if l:first_word && l:word =~ '^\a'
            let l:first_word = b:dn_false
        endif
        " write changed word
        let l:words[l:index] = l:word
        " move to next list item
        let l:index += 1
    endfor
    " return altered header
    return join(l:words, '')
catch
    call DNU_Error(v:exception . ' at ' . v:throwpoint)
endtry
endfunction                                                        " }}}3

" 3.9  Numbers                                                       {{{2
" Functions related to numbers
" Function: DNU_ValidPosInt                                          {{{3
" Purpose:  check whether input is valid positive integer
" Params:   1 - value [integer]
" Insert:   nil
" Return:   whether valid positive integer [boolean]
" Note:	    zero is not a positive integer
function! DNU_ValidPosInt(value)
	return a:value =~ '^[1-9]\{1}[0-9]\{}$'
endfunction                                                        " }}}3
" 3.10 Miscellaneous                                                 {{{2
" Functions that cannot be placed in any other category 
" Function: DNU_JumpPlace                                            {{{3
" Purpose:  jump to placeholder
" Params:   1 - place holder start marker [string]
"           2 - place holder end marker [string]
"           3 - direction ('f', 'b') [char]
" Insert:   nil
" Return:   nil
function! DNU_JumpPlace(begin, end, direction)
	" set variables and sanity checks
	if (a:begin == '' || a:end == '')| return '' | endif
	if a:direction !~? '^f$\|^b$' | return '' | endif
	let l:direction = (a:direction == 'b')
                \ ? 'b' 
                \ : ''
	let l:searchString = ''
	let s:RemoveLastHistoryItem 
				\ = ':call histdel("/", -1)|let @/=b:Tex_LastSearchPattern'
	" if the current cursor position does not contain a placeholder character,
	" then search for the placeholder characters
	if strpart(getline('.'), col('.') - 1) !~ '\V\^' . a:begin
		let l:searchString = '\V' . a:begin . '\_.\{-}' . a:end
	endif
	" if we didn't find any placeholders return quietly
	if l:searchString != '' && !search(l:searchString, l:direction)
		let l:msg = "No placeholder '" . a:begin . '...' . a:end . "' found"
		call DNU_Warn(l:msg)
		return ''
	endif
	" open any closed folds and make this part of the text visible
	silent! foldopen!
	" calculate if we have an empty placeholder or if it contains some
	" description
	let l:template = 
		\ matchstr(strpart(getline('.'), col('.') - 1),
		\          '\V\^' . a:begin . '\zs\.\{-}\ze\(' . a:end . '\|\$\)')
	let l:placeHolderEmpty = !strlen(l:template)
	" if we are selecting in exclusive mode, then we need to move one step to
	" the right
	let l:extramove = ''
	if &selection == 'exclusive' | let l:extramove = 'l' | endif
	" select till the end placeholder character
	let l:movement = "\<C-o>v/\\V" . a:end . "/e\<CR>" . l:extramove
	" first remember what the search pattern was -- s:RemoveLastHistoryItem will
	" reset @/ to this pattern so we do not create new highlighting
	let b:Tex_LastSearchPattern = @/
	" now either goto insert mode or select mode
	if l:placeHolderEmpty
		" delete empty placeholder into the blackhole
        " quotes remain balanced because '\"' is black hole register
        " (see ':h quote_' for vim help on this register)
		return l:movement . "\"_c\<C-o>:" . s:RemoveLastHistoryItem . "\<CR>"
	else
		return l:movement . "\<C-\>\<C-N>:" 
					\ . s:RemoveLastHistoryItem . "\<CR>gv\<C-g>"
	endif
endfunction                                                        " }}}3
" Function: DNU_SelectWord                                           {{{3
" Purpose:  selects <cword> under cursor (must be only [0-9a-zA-Z_]
" Params:   nil
" Insert:   nil
" Return:   selected text ('' if no text selected) [string]
function! DNU_SelectWord()
	" select <cword> and analyse
	let l:fragment = expand('<cword>')
	if l:fragment !~ '^\w\+$' | return '' | endif    " must be [[alnum]_]
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
	execute "normal v"
	call cursor(l:orig_line, l:terminus)
	" done
	return l:fragment
endfunction                                                        " }}}3
" Function: DNU_VarType                                              {{{3
" Purpose:  get variable type
" Params:   1 - variable to be analysed
" Insert:   nil
" Return:   variable type ('number'|'string'|'funcref'|'list'|
"                          'dictionary'|'float'|'unknown')
function! s:VarType(var)
    if     type(a:var) == type(0)              | return 'number'
    elseif type(a:var) == type('')             | return 'string'
    elseif type(a:var) == type(function('tr')) | return 'funcref'
    elseif type(a:var) == type([])             | return 'List'
    elseif type(a:var) == type({})             | return 'Dictionary'
    elseif type(a:var) == type(0.0)            | return 'float'
    else                                       | return 'unknown'
    endif
endfunction                                                        " }}}3
" Function: DNU_TestFn                                               {{{3
" Purpose:  utility function used for testing purposes only
" Params:   varies
" Insert:   varies
" Return:   varies
function! DNU_TestFn() range
    let l:var = 'A RABBIT AND A DOG SHOW'
    call DNU_ShowMsg(string(l:var))
endfunction                                                        " }}}3
                                                                   " }}}2
                                                                   " }}}3

" _4.  CONTROL STATEMENTS                                            {{{1
" restore user's cpoptions                                           {{{2
let &cpo = s:save_cpo                                              " }}}2

" _5.  MAPPINGS                                                      {{{1
" \git  : put file under git version control                         {{{3
if !hasmapto('<Plug>DnGMI')
	imap <buffer> <unique> <LocalLeader>git <Plug>DnGMI
endif
imap <buffer> <unique> <Plug>DnGMI <Esc>:call DNU_GitMake(b:dn_true)<CR>
if !hasmapto('<Plug>DnRMN')
	nmap <buffer> <unique> <LocalLeader>git <Plug>DnGMN
endif
nmap <buffer> <unique> <Plug>DnGMN :call DNU_GitMake()<CR>
                                                                   " }}}3
" \ic   : initial caps in selection or line                          {{{3
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
                                                                   " }}}3
" \hh   : provide user help                                          {{{3
if !hasmapto('<Plug>DnHI')
	imap <buffer> <unique> <LocalLeader>hh <Plug>DnHI
endif
imap <buffer> <unique> <Plug>DnHI <Esc>:call DNU_Help(b:dn_true)<CR>
if !hasmapto('<Plug>DnHN')
	nmap <buffer> <unique> <LocalLeader>hh <Plug>DnHN
endif
nmap <buffer> <unique> <Plug>DnHN :call DNU_Help()<CR>
                                                                   " }}}3
" \hc   : change header case                                         {{{3
if !hasmapto('<Plug>DnHCI')
    imap <buffer> <unique> <LocalLeader>hc <Plug>DNHCI
endif
imap <buffer> <unique> <Plug>DNHCI <Esc>:call DNU_ChangeHeaderCaps('i')<CR>
if !hasmapto('<Plug>DnHCN')
    nmap <buffer> <unique> <LocalLeader>hc <Plug>DNHCN
endif
nmap <buffer> <unique> <Plug>DNHCN :call DNU_ChangeHeaderCaps('n')<CR>
if !hasmapto('<Plug>DnHCV')
    vmap <buffer> <unique> <LocalLeader>hc <Plug>DNHCV
endif
vmap <buffer> <unique> <Plug>DNHCV :call DNU_ChangeHeaderCaps('v')<CR>
                                                                   " }}}3
" \tt   : execute test function                                      {{{3
if !hasmapto('<Plug>DnTI')
	imap <buffer> <unique> <LocalLeader>tt <Plug>DnTI
endif
imap <buffer> <unique> <Plug>DnTI <Esc>:call DNU_TestFn()<CR>
if !hasmapto('<Plug>DnTN')
	nmap <buffer> <unique> <LocalLeader>tt <Plug>DnTN
endif
nmap <buffer> <unique> <Plug>DnTN :call DNU_TestFn()<CR>
if !hasmapto('<Plug>DnTV')
	vmap <buffer> <unique> <LocalLeader>tt <Plug>DnTV
endif
vmap <buffer> <unique> <Plug>DnTV :call DNU_TestFn()<CR>
                                                                   " }}}1
" vim: set foldmethod=marker :
