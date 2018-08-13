" Vim utility plugin
" Last change: 2018 Aug 6
" Maintainer: David Nebauer
" License: GPL3

" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

" Documentation    {{{1

""
" @section Introduction, intro
" @library
" @order function-list
" A plugin to provide useful generic functions. It is intended to be available
" to all files being edited. These functions were developed over time by the
" author and later combined into a library. All functions are global and have
" the prefix "dn#util#" to try and avoid namespace collisions. Some
" @section(commands) and @section(mappings) are provided.
"
" See @function(dn#util#rev) for a discussion of how scripts depending on
" @plugin(name) can check for its availability.

""
" @section Function List, function-list
" This is a list of functions grouped by what they are used for.
"
" Dates
"   * @function(dn#util#insertCurrentDate) insert current date in ISO format
"   * @function(dn#util#nowYear)           get current year
"   * @function(dn#util#nowMonth)          get current month
"   * @function(dn#util#nowDay)            get current day in month
"   * @function(dn#util#dayOfWeek)         get name of weekday
" 
" Files and directories
"   * @function(dn#util#fileExists)        whether file exists (uses |glob()|)
"   * @function(dn#util#getFilePath)       get filepath of file being edited
"   * @function(dn#util#getFileDir)        get directory of file being edited
"   * @function(dn#util#getFileName)       get name of file being edited
"   * @function(dn#util#getRtpDir)         finds directory from runtimepath
"   * @function(dn#util#getRtpFile)        finds file(s) in directories under 'rtp'
" 
" User interaction
"   * @function(dn#util#showMsg)           display message to user
"   * @function(dn#util#error)             display error message
"   * @function(dn#util#warn)              display warning message
"   * @function(dn#util#prompt)            display prompt message
"   * @function(dn#util#wrap)              echoes text but wraps it sensibly
"   * @function(dn#util#menuSelect)        select item from menu
"   * @function(dn#util#menuAddOption)     add option to menu
"   * @function(dn#util#menuAddSubmenu)    add submenu to menu
"   * @function(dn#util#consoleSelect)     select item from list using the console
"   * @function(dn#util#help)              user can select from help topics
"   * @function(dn#util#getSelection)      returns currently selected text
" 
" Lists
"   * @function(dn#util#listExchangeItems) exchange two elements in the same list
"   * @function(dn#util#listSubtract)      subtract one list from another
"   * @function(dn#util#listToScreen)      formats list for screen display
"   * @function(dn#util#listToScreenColumns)
"                                          formats list for coloumnar screen display
" 
" Programming
"   * @function(dn#util#unusedFunctions)   checks for uncalled functions
"   * @function(dn#util#insertMode)        switch to insert mode
"   * @function(dn#util#executeShellCommand)
"                                          execute shell command
"   * @function(dn#util#exceptionError)    extract error message from exception
"   * @function(dn#util#scriptNumber)      get SID of given script
"   * @function(dn#util#filetypes)         get list of available filetypes
"   * @function(dn#util#showFiletypes)     display list of available filetypes
"   * @function(dn#util#runtimepaths)      get list of runtime paths
"   * @function(dn#util#showRuntimepaths)  display list of runtime paths
"   * @function(dn#util#updateUserHelpTags)
"                                          rebuild help tags in rtp "doc" subdirs
"   * @function(dn#util#os)                determine operating system family
"   * @function(dn#utilis#isWindows)       determine whether using windows OS
"   * @function(dn#utilis#isUnix)          determine whether using unix-like OS
" 
" Version control
"   * @function(dn#util#localGitRepoFetch) perform a fetch on a local git repository
"   * @function(dn#util#localGitRepoUpdatedRecently)
"                                          check that a local repo has been updated
" 
" String manipulation
"   * @function(dn#util#stripLastChar)     removes last character from string
"   * @function(dn#util#insertString)      insert string at current cursor location
"   * @function(dn#util#trimChar)          removes leading and trailing chars
"   * @function(dn#util#entitise)          replace special html chars with entities
"   * @function(dn#util#deentitise)        replace html entities with characters
"   * @function(dn#util#stringify)         convert variable to string
"   * @function(dn#util#matchCount)        finds number of occurrences of string
"   * @function(dn#util#padInternal)       pad string at internal location
"   * @function(dn#util#padLeft)           left pad string               
"   * @function(dn#util#padRight)          right pad string               
"   * @function(dn#util#globalSubstitution)
"                                          perform global substitution in file
"   * @function(dn#util#changeHeaderCaps)  changes capitalisation of line
"                                          or visual selection
" 
" Numbers
"   * @function(dn#util#validPosInt)       check whether input is valid positive int
" 
" Miscellaneous
"   * @function(dn#util#selectWord)        select |<cword>| under cursor
"   * @function(dn#util#varType)           get variable type
"   * @function(dn#util#testFn)            utility function used for testing only

" }}}1

" Scripts variables

" s:rev           - revision number    {{{1

""
" Revision number in the form "yyyymmdd".
let s:rev = 20180806

" s:submenu_token - submenu token    {{{1

""
" Token in a menu list signifying the following item is a submenu. 
let s:submenu_token = '__!_SUBMENU_!_TOKEN_!__'
" }}}1

" Script functions

" s:centuryDoomsday(year)    {{{1

""
" @private
" Get doomsday for century containing {year}.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:centuryDoomsday(year) abort
    let l:century = (a:year - (a:year % 100)) / 100
    let l:base_century = l:century % 4
    return        l:base_century == 3 ? 4 :
                \ l:base_century == 0 ? 3 :
                \ l:base_century == 1 ? 1 :
                \ l:base_century == 2 ? 6 : 0
endfunction

" s:currentIsoDate()    {{{1

""
" @private
" Return current date in ISO format (yyyy-mm-dd).
function! s:currentIsoDate() abort
    return strftime('%Y-%m-%d')
endfunction

" s:dayValue(day)    {{{1

""
" @private
" Converts {day} number into day name. Day numbers 1..7 with 1=Sunday.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:dayValue(day) abort
    return        a:day == 1 ? 'Sunday'    :
                \ a:day == 2 ? 'Monday'    :
                \ a:day == 3 ? 'Tuesday'   :
                \ a:day == 4 ? 'Wednesday' :
                \ a:day == 5 ? 'Thursday'  :
                \ a:day == 6 ? 'Friday'    :
                \ a:day == 7 ? 'Saturday'  : ''
endfunction

" s:headerCapsEngine(header, type)    {{{1

""
" @private
" Change capitalisation of {header} string. The {type} of capitalisation can
" be "upper", "lower", "sentence", "start" or "title":
"
" upper:
"   * convert the string to all uppercase characters
"
" lower:
"   * convert the string to all lowercase characters
"
" sentence:
"   * convert the first character to uppercase and all other characters to
"     lowercase
"
" start:
"   * convert the first letter of each word to uppercase and all other letters
"     to lower case
"
" title:
"   * capitalises first and last words, and all other words except articles,
"     prepositions and conjunctions of fewer than five letters
"
" Newlines are preserved. The converted header string is returned.
function! s:headerCapsEngine(string, type) abort
try
    " variables
    " - capitalisation types
    let l:types = ['upper', 'lower', 'sentence', 'start', 'title']
    let l:type = tolower(a:type)
    " - articles of speech are not capitalised in title case
    let l:articles = ['a', 'an', 'the']
    " - prepositions are not capitalised in title case
    let l:prepositions = [
                \ 'amid', 'as',   'at',   'atop', 'but',  'by',   'for',
                \ 'from', 'in',   'into', 'mid',  'near', 'next', 'of',
                \ 'off',  'on',   'onto', 'out',  'over', 'per',  'quo',
                \ 'sans', 'than', 'till', 'to',   'up',   'upon', 'v',
                \ 'vs',   'via',  'with'
                \ ]
    " - conjunctions are not capitalised in title case
    let l:conjunctions = [
                \  'and', 'as',   'both', 'but', 'for', 'how',  'if',
                \ 'lest', 'nor',  'once',  'or',  'so', 'than', 'that',
                \ 'till', 'when', 'yet'
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
    let l:first_word = v:true
    let l:last_word = v:false
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
        else  " type is 'sentence' or 'title' and word is not first or last
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
            let l:first_word = v:false
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

" s:leapYear(year)    {{{1

""
" @private
" Determine whether {year} is a leap year. Returns an integer boolean (0 or 1)
" because the return value can be used by calling functions in calculations.
function! s:leapYear(year) abort
    return (a:year % 4 == 0 && a:year != 0)
endfunction

" s:listifyMsg(var)    {{{1

""
" @private
" Convert variable {var} into a |List|. If a List is provided then all list
" items are converted to strings. If a non-List variable is provided it is
" converted to a string and then made into a single-item List. All string
" conversion is done by @function(dn#util#stringify).
function! s:listifyMsg(var) abort
    let l:items = []
    if type(a:var) == type([])
        for l:var in a:var
            call add(l:items, dn#util#stringify(l:var))
        endfor
    else
        call add(l:items, dn#util#stringify(a:var))
    endif
    return l:items
endfunction

" s:menuSimpleType(var)    {{{1

""
" @private
" Check whether variable {var} is a "simple" menu items, i.e., |Number|,
" |Float|, |String|, boolean or null (see |type()|). Used in menu generation
" by @function(dn#util#menuSelect) and @function(dn#util#menuAddOption).
" Returns a bool.
function! s:menuSimpleType(...) abort
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
    let l:valid_types = [type(''), type(0), type(0.0),
                \        type(v:true), type(v:null)]
    let l:type = type(l:var)
    return count(l:valid_types, l:type)
endfunction

" s:menuSubMenuType(var)    {{{1

""
" @private
" Checks variable {var} is a submenu option, i.e., List or Dict. Used in menu
" generation by @function(dn#util#menuSelect),
" @function(dn#util#menuAddOption) and @function(dn#util#menuAddSubmenu).
" Returns a bool.
function! s:menuSubmenuType(...) abort
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

" s:menuType(var)    {{{1

""
" @private
" Checks whether variable {var} is a simple or submenu option, i.e., number,
" float, string, List or Dict. Used in menu generation by
" @function(dn#util#menuSelect). Returns a bool.
function! s:menuType(...) abort
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

" s:monthLength(year, month)    {{{1

""
" @private
" Get length of a given {month} in a {year} in days. Both {month} and {year}
" are integers.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:monthLength(year, month) abort
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
endfunction

" s:monthValue(year, month)    {{{1

""
" @private
" Gets the day in a month that is the same day of week as the year doomsday.
" The month is specified by {month} and {year}, both integers.
" Returns day as an integer.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:monthValue(year, month) abort
    let l:Leapyear = s:leapYear(a:year)
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

" s:validCalInput(year, month, day)    {{{1

""
" @private
" Check that a given {day}, {month} and {year}, all integers, is valid.
" Echoes details of incorrect value(s) and returns a bool.
" 
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:validCalInput(year, month, day) abort
    let l:retval = v:true
    if !s:validYear(a:year)
        echomsg "Invalid year: '" . a:year . "'"
        let l:retval = v:false
    endif
    if !s:validMonth(a:month)
        echomsg "Invalid month: '" . a:month . "'"
        let l:retval = v:false
    endif
    if !s:validDay(a:year, a:month, a:day)
        echomsg "Invalid day:   '" . a:day . "'"
        let l:retval = v:false
    endif
    return l:retval
endfunction

" s:validDay(year, month, day)    {{{1

""
" @private
" Check validity of day specified by {year}, {month} and {day} integer values.
" Returns a bool.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:validDay(year, month, day) abort
    return (dn#util#validPosInt(a:day)
                \ && a:day <= s:monthLength(a:year, a:month))
endfunction

" s:validMonth(month)    {{{1

""
" @private
" Check validity of integer {month} value. Returns a bool.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:validMonth (month) abort
    return (dn#util#validPosInt(a:month) && a:month <= 12)
endfunction

" s:validYear(year)    {{{1

""
" @private
" Check validity of integer {year} value. Returns a bool.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:validYear(year) abort
    return dn#util#validPosInt(a:year)
endfunction

" s:yearDoomsday(year)    {{{1

""
" @private
" Get integer doomsday for integer {year}.
"
" Part of determining the day of week for a given date using the Doomsday
" algorithm created by John Horton Conway. See @function(dn#util#dayOfWeek)
" for details.
function! s:yearDoomsday(year) abort
    let l:years_in_century = a:year % 100
    let l:P = l:years_in_century / 12
    let l:Q = l:years_in_century % 12
    let l:R = l:Q / 4
    let l:century_doomsday = s:centuryDoomsday(a:year)
    return (l:P + l:Q + l:R + l:century_doomsday) % 7
endfunction
" }}}1

" Private functions

" dn#util#scriptnames()    {{{1

""
" @private
" Prepare quickfix output for the quickfix window, i.e., a List of Dicts. This
" output is intended for use by the @command(Scriptnames) command. Adapted
" from tpope's vim-scriptease plugin at
" https://github.com/tpope/vim-scriptease.
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
" }}}1

" Public functions

" dn#util#changeHeaderCaps(mode)    {{{1

""
" @public
" Changes capitalisation of line or visual selection. The {mode} is "n"
" (|Normal-mode|) "i"
" (|Insert-mode|) or "v" (|Visual-mode|). The line or selection is replaced
" with the altered line or selection. The user chooses the type of
" capitalisation from a menu:
" upper case:
"   * convert to all uppercase characters
"
" lower case:
"   * convert to all lowercase characters
"
" sentence case:
"   * convert the first character to uppercase and all other characters to
"     lowercase
"
" start case:
"   * convert the first letter of each word to uppercase and all other letters
"     to lower case
"
" title case:
"   * capitalises first and last words, and all other words except articles,
"     prepositions and conjunctions of fewer than five letters
"
" Newlines in a selection are preserved.
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
    catch
        echo ' ' | " ensure starts on new line
        call dn#util#error('Header case not selected')
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

" dn#util#consoleSelect(singular, plural, items, [method])    {{{1

""
" @public
" Select item from list using the console. During user interaction items in
" the menu may be referred to by {singular} or {plural} terms. For example, if
" the list contains elements, the {singular} term might be "element name"
" while the {plural} term might be "element names". The menu {items} are
" provided in a |List|.
"
" The optional selection [method] can be "complete" or "filter". The
" "complete" selection method uses word completion. The "filter" selection
" method enables the user to type part of the target item and select from the
" resulting list of matches. Both selection methods can handle unescaped
" spaces in the menu items.
" @default method='filter'
"
" Returns the selected item, or "" if no item was selected.
"
" This function uses a perl5 script called "vim-dn-utils-console-select" that
" is installed as part of this plugin, so a working perl installation is
" required. The "complete" selection method uses the Term::Complete::complete
" perl5 function while the "filter" selection method uses the
" Term::Clui::choose perl5 function.
function! dn#util#consoleSelect(singular, plural, items, ...) abort
    " check variables    {{{2
    for l:var in ['singular', 'plural', 'items']
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
    let l:temp_file = tempname()
    " check required files    {{{2
    " - temporary file must be writable and start empty
    let l:write_result = writefile([], l:temp_file)
    if l:write_result != 0  " -1 = error, 0 = success
        echoerr "Cannot write to temp file '" . l:temp_file . "'"
        return ''
    endif
    " - script file must be located
    let l:script = dn#util#getRtpFile('vim-dn-utils-console-select')
    if l:script ==? ''
        echoerr 'dn-utils: cannot find console-select script'
        return ''
    endif
    " assemble shell command to run script    {{{2
    let l:opts = []
    let l:opts += ['--name-single', a:singular]
    let l:opts += ['--name-plural', a:plural]
    let l:opts += ['--output-file', fnameescape(l:temp_file)]
    let l:opts += ['--items', join(a:items, "\t")]
    let l:opts += ['--select-method', l:method]
    call map(l:opts, 'shellescape(v:val)')
    let l:cmd = '!perl' . ' ' . l:script . ' ' . join(l:opts, ' ')
    " run script to select item    {{{2
    silent execute l:cmd
    redraw!
    " retrieve and return result    {{{2
    if !filereadable(l:temp_file)  " assume script aborted with error
        return ''
    endif
    let l:output = readfile(l:temp_file)
    if     len(l:output) == 0 | return ''           " no selection
    elseif len(l:output) == 1 | return l:output[0]  " got selection!
    else  " more than one line of output!
        echoerr 'dn-utils: unexpected output:' . l:output
        return ''
    endif    " }}}2
endfunction

" dn#util#dayOfWeek(year, month, day)    {{{1

""
" @public
" Get name of weekday defined by {year}, {month} and {day} (all integers).
"
" The name of the weekday is determined using the Doomsday algorithm created
" by John Horton Conway. This algorithm takes advantage of each year having a
" certain day of the week, called the "doomsday", upon which certain
" easy-to-remember dates fall; for example, 4/4, 6/6, 8/8, 10/10, 12/12, and
" the last day of February all occur on the same day of the week in any year.
function! dn#util#dayOfWeek(year, month, day) abort
    if !s:validCalInput(a:year, a:month, a:day) | return '' | endif
    let l:doomsday = s:yearDoomsday(a:year)
    let l:month_value = s:monthValue(a:year, a:month)
    let l:day_number = (a:day - l:month_value + 14 + l:doomsday) % 7
    let l:day_number = (l:day_number == 0) ? 7 : l:day_number
    return s:dayValue(l:day_number)
endfunction

" dn#util#deentitise(string)    {{{1

""
" @public
" Replace the following html entities in {string} with corresponding
" characters: "&quot;" to """, "&apos;" to "'", "&lt;" to "<", "&gt;" to ">",
" and "&amp;" to "&". Returns the altered {string}.
function! dn#util#deentitise(string) abort
    let l:string = a:string
    let l:string = substitute(l:string, '&quot;', '"', 'g')
    let l:string = substitute(l:string, '&apos;', "'", 'g')
    let l:string = substitute(l:string, '&lt;',   '<', 'g')
    let l:string = substitute(l:string, '&gt;',   '>', 'g')
    let l:string = substitute(l:string, '&amp;',  '&', 'g')
    return l:string
endfunction

" dn#util#entitise(string)    {{{1

""
" @public
" Replace special html characters in {string} with html entities. See
" @function(dn#util#deentitise) for the characters that are replaced. Returns
" the altered {string}.
function! dn#util#entitise(string) abort
    let l:string = a:string
    let l:string = substitute(l:string, '&', '&amp;',  'g')
    let l:string = substitute(l:string, '>', '&gt;',   'g')
    let l:string = substitute(l:string, '<', '&lt;',   'g')
    let l:string = substitute(l:string, "'", '&apos;', 'g')
    let l:string = substitute(l:string, '"', '&quot;', 'g')
    return l:string
endfunction

" dn#util#error(message)    {{{1

""
" @public
" Display error {message}. The {message} can be a string or a |List|. A List
" is converted to a string by @function(dn#util#stringify). The error message
" is displayed in error highlighting (see |hl-ErrorMsg|).
function! dn#util#error(message) abort
    " require double quoting of execution string so backslash
    " is interpreted as an escape token
    if mode() ==# 'i' | execute "normal! \<Esc>" | endif
    echohl ErrorMsg
    for l:message in s:listifyMsg(a:message) | echomsg l:message | endfor
    echohl Normal
endfunction

" dn#util#exceptionError(exception)    {{{1

""
" @public
" Extracts error message from a Vim {exception}.
"
" This is useful for Vim exceptions, i.e., those that begin with the string
" "Vim", which vim does not allow to be re-thrown. This function extracts the
" error message from Vim exceptions, allowing them to be re-thrown. Non-Vim
" exceptions are returned unaltered.
function! dn#util#exceptionError(exception) abort
    let l:matches = matchlist(a:exception,
                \ '^Vim\%((\a\+)\)\=:\(E\d\+\p\+$\)')
    return (!empty(l:matches) && !empty(l:matches[1])) ? l:matches[1]
                \                                      : a:exception
endfunction

" dn#util#executeShellCommand(cmd, [msg])    {{{1

""
" @public
" Execute shell command {cmd} and return exit status using a conventional vim
" bool value, i.e., true value means the shell command executed successfully.
" If an error occurs when {cmd} is executed an error [message] is displayed,
" followed by shell feedback. The error [message] is a |List| and each string
" item is displayed on a separate line.
" @default message='Error occured:'
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
        echomsg '--------------------------------------'
        echomsg l:shell_feedback
        echomsg '--------------------------------------'
        return
    else
        return v:true
    endif
endfunction

" dn#util#file_exists(filepath)    {{{1

""
" @public
" Determine whether {filepath} exists.
"
" Uses |glob()| which is more robust than using |filereadable()| and
" |filewritable()| which can give a false negative result if the user lacks
" read and write permissions for the file being sought. While |glob()| is not
" similarly affected, it too can return a false negative result if the user
" does not have execute permissions for the directory containing the sough
" file.
function! dn#util#fileExists(filepath)
    return !empty(glob(a:filepath))
endfunction

" dn#util#filetypes()    {{{1

""
" @public
" Get |List| of available |filetypes|.
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

" dn#util#getFilePath()    {{{1

""
" @public
" Get filepath of file being edited.
function! dn#util#getFilePath() abort
    return simplify(resolve(expand('%:p')))
endfunction

" dn#util#getFileDir()    {{{1

""
" @public
" Get directory of file being edited.
function! dn#util#getFileDir() abort
    return expand('%:p:h')
endfunction

" dn#util#getFileName()    {{{1

""
" @public
" Get name of file being edited.
function! dn#util#getFileName() abort
    return expand('%:p:t')
endfunction

" dn#util#getRtpDir(directory, [multiple])    {{{1

""
" @public
" Finds {directory} in 'runtimepath'. Returns a single matching directory as a
" string. If no matches are found an empty string is returned. If multiple
" matches are found the user is required to select one. If [multiple] is a
" true value then all matches are returned in a |List|, even if there is only
" one match. If there are no matches an empty List is returned.
" @default multiple=false
function! dn#util#getRtpDir(directory, ...) abort
    " set vars
    let l:allow_multiples = (a:0 && a:1)
    if a:directory ==? '' | return (l:allow_multiples ? [] : '') | endif
    " search for directory
    let l:matches = globpath(&runtimepath, a:directory, v:true, v:true)
    " if allowing multiple matches
    if l:allow_multiples | return l:matches | endif
    " if insisting on single directory
    if     len(l:matches) == 0 | return
    elseif len(l:matches) == 1 | return l:matches[0]
    else | return dn#util#menuSelect(l:matches, 'Select directory path:')
    endif
endfunction

" dn#util#getRtpFile(file, [multiple])    {{{1

""
" @public
" Finds {file} if it is located anywhere under the directories in runtimepath.
" Returns a single matching filepath as a string. If no matches are found an
" empty string is returned. If multiple matches are found the user is required
" to select one. If [multiple] is a true value then all matches are returned
" in a |List|, even if there is only one match. If there are no matches an
" empty List is returned.
" @default multiple=false
function! dn#util#getRtpFile(file, ...) abort
    " set vars
    let l:allow_multiples = (a:0 && a:1)
    if a:file ==? '' | return (l:allow_multiples ? [] : '') | endif
    " search for directory
    let l:search_term = '**/' . a:file
    let l:matches_raw = globpath(&runtimepath, l:search_term, 1, 1)
    " - globpath can produce duplicates
    let l:matches = filter(copy(l:matches_raw),
                \          'index(l:matches_raw, v:val, v:key+1) == -1')
    " if allowing multiple matches
    if l:allow_multiples | return l:matches | endif
    " if insisting on single file
    if     len(l:matches) == 0 | return
    elseif len(l:matches) == 1 | return l:matches[0]
    endif | return dn#util#menuSelect(l:matches, 'Select file path:')
endfunction

" dn#util#getSelection()    {{{1

""
" @public
" Returns selected text ("" if no text selected). Works for all selection
" types.
"
" Newlines are preserved which means a multi-line string can be returned. Be
" aware that functions using the return value may be executed once on the
" entire string or separately for each line in the string, depending on
" whether the function accepts a range. (See |:call| and
" |function-range-example|.)
function! dn#util#getSelection() abort
    try
        let l:a_save = @a
        normal! gv"ay
        return @a
    finally
        let @a = l:a_save
    endtry
endfunction

" dn#util#globalSubstitution(pattern, substitute)    {{{1

""
" @public
" Perform global substitution of {pattern} for {substitute} in current buffer.
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

" dn#util#help([insert])    {{{1

""
" @setting g:dn_help_plugins
" One of three variables (|g:dn_help_plugins|, |g:dn_help_topics| and
" |g:dn_help_data|) and function @function(dn#util#help) that together
" constitute an extensible help system.
"
" This variable is a |List| that shows the plugins that have added to the help
" variables. It is purely informative and plays no part in displaying help.
"
" This variable is not created by the @plugin(name) plugin so any contributor
" should first ensure it exists:
" >
"   if !exists('g:dn_help_plugins')
"       let g:dn_help_plugins = []
"   endif
" <
" See |g:dn_help_data| for a complete example of adding to the help system.

""
" @setting g:dn_help_topics
" One of three variables (|g:dn_help_plugins|, |g:dn_help_topics| and
" |g:dn_help_data|) and function @function(dn#util#help) that together
" constitute an extensible help system.
"
" This variable is a |Dictionary| that defines a multi-level menu which is
" submitted to the function @function(dn#menu#menuSelect) for the user to
" select a help topic. See the help for that function for details of how to
" structure the menu. By convention |g:dn_help_topics| is a |Dictionary|. Each
" contributor to the plugin should provide a new unique top-level key whose
" value contains a sub-menu containing all the options for that contributor.
"
" The |g:dn_help_data| variable is a |Dictionary| whose keys are the help
" topics which are provided by |g:dn_help_topics| and @function(dn#util#help).
" For that reason they must be unique. Each contributor to the help system is
" encouraged to use a unique prefix for their help topics to help avoid
" namespace collisions.
"
" This variable is not created by the @plugin(name) plugin so any contributor
" should first ensure it exists:
" >
"   if !exists('g:dn_help_topics')
"       let g:dn_help_topics = {}
"   endif
" <
" See |g:dn_help_data| for a complete example of adding to the help system.

""
" @setting g:dn_help_data
" One of three variables (|g:dn_help_plugins|, |g:dn_help_topics| and
" |g:dn_help_data|) and function @function(dn#util#help) that together
" constitute an extensible help system.
"
" The |g:dn_help_topics| variable is used to enable the user to select a
" unique help topic. |g:dn_help_data| is a |Dictionary| whose keys are the
" unique help topics from |g:dn_help_topics|. The value for each key is a
" |List| of lines which are displayed as concatenated text. To insert a
" newline use an empty element (''). To insert a blank line use to consecutive
" empty elements.
"
" This variable is not created by the @plugin(name) plugin so any contributor
" should first ensure it exists.
"
" What follows is a complete example of adding to the help system taken from
" the |dn_md_utils| plugin. The prefix "markdown_utils_" is used for help
" topics to ensure they are unique and do not collide with help topics
" supplied by other contributors.
" >
"   if !exists('g:dn_help_plugins')
"       let g:dn_help_plugins = []
"   endif
"   if !exists('g:dn_help_topics')
"       let g:dn_help_topics = {}
"   endif
"   if !exists('g:dn_help_data')
"       let g:dn_help_data = {}
"   endif
"   if count(g:dn_help_plugins, 'dn-md-utils') == 0
"       call add(g:dn_help_plugins, 'dn-md-utils')
"       if !has_key(g:dn_help_topics, 'markdown utils ftplugin')
"           let g:dn_help_topics['markdown utils ftplugin'] = {}
"       endif
"       let g:dn_help_topics['markdown utils ftplugin']['refs']
"                   \ = 'markdown_utils_refs'
"       let g:dn_help_data['markdown_utils_refs'] = [
"           \ 'Format for equations (Eq), figures (Fig), tables (Tbl):',
"           \ '',
"           \ '',
"           \ '',
"           \ 'Eq:  $$ y = mx + b $$ {#eq:id}',
"           \ '',
"           \ '',
"           \ '',
"           \ '     See @eq:id or {@eq:id}.',
"           \ '',
"           \ '',
"           \ '',
"           \ 'Fig: ![Caption.][imageref]',
"           \ '',
"           \ '',
"           \ '',
"           \ '     See @fig:id or {@fig:id}.',
"           \ '',
"           \ '',
"           \ '',
"           \ '        [imageref]: image.png "Alt text" {#fig:id}',
"           \ '',
"           \ '',
"           \ '',
"           \ 'Tbl: A B',
"           \ '',
"           \ '     - -',
"           \ '',
"           \ '     0 1',
"           \ '',
"           \ '',
"           \ '',
"           \ '     Table: Caption. {#tbl:id}',
"           \ '',
"           \ '',
"           \ '',
"           \ '     See @tbl:id or {@tbl:id}.',
"           \ ]
"       let g:dn_help_topics['markdown utils ftplugin']['utilities']
"                   \ = 'markdown_utils_util'
"       let g:dn_help_data['markdown_utils_util'] = [
"           \ 'This markdown ftplugin has the following utility features:',
"           \ '',
"           \ '',
"           \ '',
"           \ 'Feature                     Mapping  Command',
"           \ '',
"           \ '--------------------------  -------  -----------------',
"           \ '',
"           \ 'add metadata boilerplate    \ab      MUAddBoilerplate',
"           \ '',
"           \ 'clean output                \co      MUCleanOutput',
"           \ '',
"           \ 'insert figure               \fig     MUInsertFigure',
"           \ '',
"           \ 'convert metadata to panzer  \pm      MUPanzerifyMetadata',
"           \ ]
"   endif
" <

""
" @public
" Display a menu of help topics for the user to select from. When a topic is
" selected the associated help text for that topic is displayed. The boolean
" [insert] option is true if this function is called from |Insert-mode|.
" @default insert=false
"
" The help menu is constructed dynamically at invocation from the variables
" |g:dn_help_plugins|, |g:dn_help_topics| and |g:dn_help_data|. See these
" variables and @section(config) for an explanation of how to configure them.
" This help system is designed to be extensible. In particular, other plugins,
" and even individual users, can add to the help variables.
function! dn#util#help(...) abort
    echo '' | " clear command line
    " variables
    let l:insert = (a:0 > 0 && a:1) ? v:true : v:false
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

" dn#util#insertCurrentDate([insert_mode])    {{{1

""
" @public
" Insert current date in ISO format (yyyy-mm-dd). The optional [insert]
" argument indicates whether the function was called from |Insert-mode|.
" @default insert=false
function! dn#util#insertCurrentDate(...) abort
    " if call from command line then move cursor left
    if !(a:0 > 0 && a:1) | execute 'normal! h' | endif
    " insert date
    execute 'normal! a' . s:currentIsoDate()
    " if finishing in insert mode move cursor to right
    if a:0 > 0 && a:1 | execute 'normal! l' | startinsert | endif
endfunction

" dn#util#insertMode([skip])    {{{1

""
" @public
" Switch to |Insert-mode|. The right [skip] is an integer number of spaces to
" the right the cursor should be moved before entering |Insert-mode|. This
" function is often used by other functions if they were called from insert
" mode. In such cases it will usually be invoked with one right skip to
" compensate for the left skip that occured when initially escaping from
" |Insert-mode|.
" @default skip=0
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

" dn#util#insertString(string, [paste])    {{{1

""
" @public
" Insert {string} at current cursor location. The [paste] argument is a
" boolean indicating whether to use the 'paste' setting.
" @default paste=true
function! dn#util#insertString(inserted_text, ...) abort
    let l:restrictive = v:true
    if a:0 > 1 && ! a:1 | let l:restrictive = v:false | endif
    if l:restrictive | let l:paste_setting = &paste | set paste | endif
    silent execute 'normal! a' . a:inserted_text
    if l:restrictive && ! l:paste_setting | set nopaste | endif
endfunction

" dn#util#isWindows()    {{{1

""
" @public
" Whether operating system is windows. Returns a bool.
function! dn#util#isWindows() abort
    return dn#util#os() ==# 'windows'
endfunction

" dn#util#isUnix()    {{{1

""
" @public
" Whether operating system is unix-like. Returns a bool.
function! dn#util#isUnix() abort
    return dn#util#os() ==# 'unix'
endfunction

" dn#util#listExchangeItems(list, index1, index2)    {{{1

""
" @public
" Exchange two elements in the same {list}. The |List| locations of the
" elements to exchange are given by {index1} and {index2}. The {list} is
" modified in place. The function's boolean return value indicates whether the
" exchange occurred successfully. No error message is displayed in the event
" of failure.
"
" This function short-circuits a lot of error-checking by using the value
" ":INVALID:" as an error token. If one of the {list} elements to be swapped
" has this precise value the exchange operation will fail and the function
" returns a failure value.
function! dn#util#listExchangeItems(list, index1, index2) abort
    if get(a:list, a:index1, ':INVALID:') ==# ':INVALID:' | return | endif
    if get(a:list, a:index2, ':INVALID:') ==# ':INVALID:' | return | endif
    let l:item1 = a:list[a:index1]
    let a:list[a:index1] = a:list[a:index2]
    let a:list[a:index2] = l:item1
    return v:true
endfunction

" dn#util#listSubtract(list_1, list_2)    {{{1

""
" @public
" Subtracts {list_2} from {list_1} and returns a new |List|.
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

" dn#util#listToScreen(list, [width[, indent[, delimiter]]])    {{{1

""
" @public
" Formats {list} for screen display. Three optional arguments affect the
" format of the display: [width] is the preferred maximum width of text,
" [indent] is the size of the left index, and [delimiter] is used to join list
" items. There is no restriction on the length of [delimiter], but it is
" assumed to be a single character so longer delimiters may give unexpected
" results.
" @default width=60
" @default indent=0
" @default delimiter=' '
"
" This function is intended for use with short strings. It does not break long
" string elements. Even worse, it resets the maximum width to equal that of
" the longest {list} item. Consider using @function(dn#util#wrap) if it is
" important to limit the maximum text width as that function breaks a string
" at sensible locations.
"
" This function short-circuits a lot of error-checking by using the value
" ":INVALID:" as an error token. If one of the {list} elements has this
" precise value, processing may stop prematurely.
"
" Returns a single formatted string containing newlines.
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

" dn#util#listToScreenColumns(list, [width[, padding[, indent]]])    {{{1

""
" @public
" Formats {list} for screen display in columns. The optional arguments affect
" formatting: [width] is the preferred maximum width of text, [padding] is the
" size of column padding (column width = length of the longest {list} item +
" padding), and [indent] is the size of the indent at the start of each line.
" This function is intended for use with short strings, e.g., single words.
" @default width=60
" @default padding=1
" @default indent=0
"
" This function short-circuits a lot of error-checking by using the value
" ":INVALID:" as an error token. If one of the {list} elements has this
" precise value the formatting will break down.
"
" Returns a single formatted string containing newlines.
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
        let l:max_len = (l:item_len > l:max_len) ? l:item_len : l:max_len
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

" dn#util#localGitRepoFetch(git_path, [prefix])    {{{1

""
" @public
" Perform a fetch on a local git repository. The {git_path} is the path to the
" ".git" subdirectory in the repository. The [prefix] is an optional string
" that is prepended to all shell output, and must include any additional
" punctuation, e.g., ': '. Returns a boolean indicating whether the fetch
" operation was successful, as reported by git (using vim boolean semantics).
" @default prefix='dn-utils: '
function! dn#util#localGitRepoFetch(git_path, ...) abort
    echo '' | " clear command line
    " set prefix
    let l:prefix = 'dn-utils: '
    if a:0 > 0 && strlen(a:1) > 0
        let l:prefix = a:1
    endif
    " check directory
    let l:dir = resolve(expand(a:git_path))
    if ! isdirectory(l:dir)
        echoerr l:prefix . "invalid repository '.git' directory ('"
                    \ . a:git_path . "')"
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
                    \ . a:git_path . "'"
        if len(l:err) > 0
            echoerr l:prefix . 'error message:'
            for l:line in l:err | echoerr '  ' . l:line | endfor
        endif
        return
    endif  " v:shell_error
    " success if still here
    return v:true
endfunction

" dn#util#localGitRepoUpdatedRecently(git_path, time, [prefix])    {{{1

""
" @public
" Check that a local git repository has been updated within a given time
" period. More specifically, it checks on the time since the last git "fetch"
" operation was performed (which includes git "pull" operations). The
" {git_path} is the path to the ".git" subdirectory in the repository. The
" {time} period is specified in seconds. For example, a week is 604800
" seconds. The [prefix] is an optional string that is prepended to all shell
" output, and must include any additional punctuation, e.g., ': '.
"
" Uses |python-commands| and requires python modules "os" and "time".
"
" Returns a boolean value indicating whether the repository has been updated
" within the specified time period. The function is designed to determine
" whether a repository needs to be updated so if it fails it returns false,
" presumably triggering an update,  i.e., update on failure is safer than not
" updating on a failure. The function can fail if it cannot find the
" ".git/FETCH_HEAD" file, the {time} value is invalid, python is not
" available, or a python command fails or returns unexpected output. In all of
" these cases an error message is displayed.
" @default prefix='dn-utils: '
function! dn#util#localGitRepoUpdatedRecently(git_path, time, ...) abort
    " check parameters
    " - set prefix
    let l:prefix = 'dn-utils: '
    if a:0 > 0 && strlen(a:1) > 0
        let l:prefix = a:1
    endif
    " - check directory
    let l:dir = resolve(expand(a:git_path))
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
    if l:diff < a:time | return v:true | else | return | endif
endfunction

" dn#util#matchCount(haystack, needle)    {{{1

""
" @public
" Finds number of occurrences of {needle} substring in a {haystack} string.
function! dn#util#matchCount(haystack, needle) abort
    " variables
    " - stridx provides informative errors for wrongly typed
    "   haystack and needle values
    let l:matches = 0  " number of searches performed
    let l:pos = -1   " position to search from
    " do progressive search
    while v:true
        let l:pos = stridx(a:haystack, a:needle, l:pos + 1)
        " stop searching when run out of matches
        if l:pos == -1 | break | endif
        " if still here then search was successful
        let l:matches += 1
    endwhile
    " return count
    return l:matches
endfunction

" dn#util#menuAddOption(menu, option, [return_value])    {{{1

""
" @public
" Add {option} to a {menu} intended for use with
" @function(dn#util#menuSelect). The {menu} can be a |List| or |Dict|. The
" {option} can be a |String|, |Number| or |Float|. The menu {option} can
" return either its own value or an alternative [return_value]. No
" [return_value] needs to be provided if the menu option is intended to return
" its own value when selected.
"
" The {menu} variable is edited in place. The function does not return any
" value. Error messages are displayed if invalid arguments are provided.
function! dn#util#menuAddOption(menu, option, ...) abort
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
    if !s:menuSubmenuType(a:menu)
        let l:msg = "Invalid menu variable:\n\n"
        call dn#util#error(l:msg . dn#util#stringify(a:menu))
        return
    endif
    if !s:menuSimpleType(a:option)
        let l:msg = 'Invalid option (data type ' . type(a:option) . "):\n\n"
        call dn#util#error(l:msg . dn#util#stringify(a:option))
        return
    endif
    let l:retval = (a:0 == 3) ? a:3 : a:option
    if !s:menuSimpleType(l:retval)
        let l:msg = 'Invalid return value (data type ' . type(l:retval)
                    \ . "):\n\n"
        call dn#util#error(l:msg . dn#util#stringify(l:retval))
        return
    endif
    " add option
    let l:item =    {}
    let l:item[a:option] = l:retval
    if   type(a:menu) == type([]) | call add(a:menu, l:item)     " list
    else                          | call extend(a:menu, l:item)  " dict
    endif
endfunction

" dn#util#menuAddSubmenu(menu, header, submenu)    {{{1

""
" @public
" Add {submenu} to a {menu} intended for use with
" @function(dn#util#menuSelect). The {submenu} had a {header} which is added
" to the {menu} and which, when selected, opens the {submenu}. Both {menu} and
" {submenu} can be either a |List| or a |Dict|, independently of each other.
"
" The {menu} variable is edited in place. The function does not return any
" value. Error messages are displayed if invalid arguments are provided.
function! dn#util#menuAddSubmenu(menu, header, submenu) abort
    " process parameters
    if empty(a:submenu) | call dn#util#error('No submenu provided') | endif
    if empty(a:header)  | call dn#util#error('No header provided')  | endif
    if empty(a:submenu) | call dn#util#error('No menu provided')    | endif
    if !s:menuSubmenuType(a:submenu)
        let l:msg = "Invalid submenu variable:\n\n"
        call dn#util#error(l:msg . dn#util#stringify(a:submenu))
        return
    endif
    if !s:menuSimpleType(a:header)
        let l:msg = 'Invalid header variable:' . dn#util#stringify(a:header)
        call dn#util#error(l:msg)
        return
    endif
    if !s:menuSubmenuType(a:menu)
        let l:msg = "Invalid menu variable:\n\n"
        call dn#util#error(l:msg . dn#util#stringify(a:menu))
        return
    endif
    " add submenu
    if   type(a:menu) == type([])  " list
        let l:item = [s:submenu_token, a:header, a:submenu]
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

" dn#util#menuSelect(menu, [prompt])    {{{1

""
" @public
" Select an option from a multi-level |List| or |Dict| {menu}. An optional
" [prompt] can be provided. The selected menu option (or its associated value)
" is returned, with "" indicating no items was selected. This means it is
" possible to provide an empty menu item which can be selected and returned,
" and there is no way to distinguish this from a cancelled selection.
" @default prompt='Select an option:'
"
" In the following discussion a "simple" menu is one without any submenus, and
" "simple" variables are |String|, |Number|, |Float|, boolean (|v:true| or
" |v:false|), and null (|v:null|). A "simple" List has elements which are all
" either simple variables or single key-value Dicts whose values are also
" simple variables. A "simple" Dict has values which are all simple variables.
"
" If a simple List {menu} is provided, its simple elements are displayed in
" the menu and returned if selected, while for single key-value elements the
" key is displayed in the menu and, if selected, its value is returned.
"
" If a simple Dict {menu} is provided, its Dict keys form the menu items and
" when an item is selected its corresponding value is returned.
"
" Submenus can be added to both List and Dict menus. In such a case the header
" for the submenu, or child menu, is indicated in the parent menu by appending
" an arrow ( ->) to the header option in the parent menu. Adding a submenu to
" a Dict is easy - the new submenu is added as a new key-value pair to the
" parent menu. The new key is the submenu header in the parent menu while the
" new value is a List or Dict defining the new submenu options. The situation
" is more complicated when adding a submenu to a List. Before adding the List
" or Dict submenu two elements must be added to the parent List: an element
" consisting of the submenu token "__!_SUBMENU_!_TOKEN_!__" followed by an
" element containing the submenu header.
"
" A single menu can contain a mixture of List and Dict elements, and
" multi-level menus can become complex. The functions
" @function(dn#util#menuAddSubmenu) and @function(dn#util#menuAddOption)
" assist with "top-down" menu construction.
function! dn#util#menuSelect(menu, ...) abort
    " set menu type
    if     type(a:menu) == type([]) | let l:menu_type = 'list'
    elseif type(a:menu) == type({}) | let l:menu_type = 'dict'
    else
        call dn#util#error('Parent menu must be List or Dict')
        return ''
    endif
    " - check supplied menu items
    if len(a:menu) == 0 | return '' | endif |    " must have menu items
    " - prompt
    let l:prompt = 'Select an option:'    " default used if none provided
    if a:0 > 0 && a:1 !=? '' | let l:prompt = dn#util#stringify(a:1) | endif
    " process items to build parallel lists of options and return values
    let l:state = (l:menu_type ==# 'list') ? 'list_expecting-option'
                \                          : 'dict_expecting-option'
    let l:items = (l:menu_type ==# 'list') ? deepcopy(a:menu)
                \                          : keys(a:menu)
    let l:submenu_header = ''
    let l:options = [l:prompt] | let l:return_values = []
    for l:Item in l:items
        " what kind of item do we have?
        if     s:menuSimpleType(l:Item)  | let l:item_type = 'simple'
        elseif s:menuSubmenuType(l:Item) | let l:item_type = 'submenu'
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
            unlet l:Item  " in case a:menu elements are of different types
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
            unlet l:Item  " a:menu elements may be of different types
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
                unlet l:Item  " a:menu elements may be of different types
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
                if !s:menuSimpleType(l:retval)
                    let l:msg = "Menu item return value is not simple:\n\n"
                    call dn#util#error(l:msg . dn#util#stringify(l:retval))
                    return ''
                endif
                " okay, looks good
                call add(l:options, dn#util#stringify(l:option))
                call add(l:return_values, l:retval)
                unlet l:Item  " a:menu elements may be of different types
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
            let l:retval = a:menu[l:Item]
            if !s:menuType(l:retval)
                let l:msg = "Invalid menu dict value:\n\n"
                call dn#util#error(l:msg . dn#util#stringify(l:retval))
                return ''
            endif
            " modify menu option if it is a submenu header
            let l:option = l:Item
            if s:menuSubmenuType(l:retval) | let l:option .= ' ->' | endif
            " add option and return value
            call add(l:options, dn#util#stringify(l:option))
            call add(l:return_values, l:retval)
            unlet l:Item  " a:menu elements may be of different types
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
    if s:menuSubmenuType(l:Selection)
        return dn#util#menuSelect(l:Selection, l:prompt)  " recurse
    else
        return l:Selection
    endif
endfunction

" dn#util#nowDay()    {{{1

""
" @public
" Get integer number of current day in the current month. There is no leading
" zero.
function! dn#util#nowDay() abort
    return substitute(strftime('%d'), '^0', '', '')
endfunction

" dn#util#nowMonth()    {{{1

""
" @public
" Get integer number of current month in the current year There is no leading
" zero.
function! dn#util#nowMonth() abort
    return substitute(strftime('%m'), '^0', '', '')
endfunction

" dn#util#nowYear()    {{{1

""
" @public
" Get current year as four-digit integer.
function! dn#util#nowYear() abort
    return strftime('%Y')
endfunction

" dn#util#os()    {{{1

""
" @public
" Determine operating system in use. Returns "windows", "unix" or "other".
function! dn#util#os() abort
    if has('win32') || has ('win64') || has('win95') || has('win32unix')
        return 'windows'
    elseif has('unix') | return 'unix'
    else               | return 'other'
    endif
endfunction

" dn#util#padInternal(string, start, finish[, char])    {{{1

""
" @public
" Insert character [char] into {string} at the given {start} position until
" the initial location is shifted to the desired {finish} location. If {start}
" and {finish} are non-integers or are not sensible, an error message is
" displayed and the original {string} is returned. If [char] is longer than a
" single character only the first character is used.
" @default char=' '
"
" As an example:
" >
"   let l:string1 = 'Column Twenty & Column Twenty One'
"   let l:string2 = dn#util#padInternal(l:string1, 14, 4)
" <
" results in string2 being "Column Twenty     & Column Twenty One".
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

" dn#util#padLeft(string, length[, char])    {{{1

""
" @public
" Add [char] to start of {string} until the it is the target {length}. If
" [char] is longer than a single character only the first character is used.
" If an error occurs a message is displayed and the original {string} is
" returned.
" @default char=' '
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

" dn#util#padRight(string, length, [char])    {{{1

""
" @public
" Add [char] to the end of {string} until the it is the target {length}. If
" [char] is longer than a single character only the first character is used.
" If an error occurs a message is displayed and the original {string} is
" returned.
" @default char=' '
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
    let l:char = (a:0 && a:1 !=? '') ? strpart(a:1, 0, 1) : ' '
    " right pad
    let l:string = copy(a:string)
    while len(l:string) < a:length | let l:string .= l:char | endwhile
    return l:string
endfunction

" dn#util#prompt([prompt])    {{{1

""
" @public
" Display [prompt] |String| using |hl-MoreMsg| highlighting.
" @default prompt='Press [Enter] to continue...'
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

" dn#util#rev()    {{{1

""
" @public
" Return the current revision number of this plugin. The revision number is
" the date of the most recent revision in "yyyymmdd" form. This function
" should be used in testing for the presence of the @plugin(name) plugin:
" >
"   if exists('*dn#util#rev')
" <
" or, more robustly:
" >
"   if exists('*dn#util#rev') && dn#util#rev() =~? '\v^\d{8,}$'
" <
" or, if trying to detect when the @plugin(name) plugin is missing:
" >
"   if !(exists('*dn#util#rev') && dn#util#rev() =~? '\v^\d{8,}$')
" <
" The |exists()| function does not load autoloaded functions so it is possible
" for this test to fail if the function has not yet been loaded. This can be
" forced:
" >
"   silent! call dn#util#rev()  " load function if available
"   if !(exists('*dn#util#rev') && dn#util#rev() =~? '\v^\d{8,}$')
" <
function! dn#util#rev()
    return s:rev
endfunction

" dn#util#runtimepaths()    {{{1

""
" @public
" Get |List| of runtime paths.
function! dn#util#runtimepaths() abort
    return split(&runtimepath, ',')
endfunction

" dn#util#scriptNumber(script)    {{{1

""
" @public
" Gets the dynamically assigned number (SID, SNR) of {script}. In the event of
" an error a message is displayed and |v:null| is returned. If no {script}
" file name is provided |v:null| is silently returned. The file name for
" {script} must be complete, i.e., "base.ext", but wildcards can be used as if
" |/\V| "very nomagic" is in effect. This is adapted from a Stack Overflow
" answer at https://stackoverflow.com/a/39216373.
function! dn#util#scriptNumber(script) abort
    " check param
    if empty(a:script) | return v:null | endif
    if type(a:script) != type('')
        let l:err = 'Expected string script name, got '
        call dn#util#error(l:err . dn#util#varType(a:script))
        return v:null
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

" dn#util#selectWord()    {{{1

""
" @public
" Selects |<cword>| under cursor (must be only 0-9a-zA-Z_). Returns selected
" text |String|, or  "" if no text is currently selected selected.
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

" dn#util#showFiletypes()    {{{1

""
" @public
" Display available filetypes in the echo area.
function! dn#util#showFiletypes() abort
    " get filetype list
    let l:filetypes = dn#util#filetypes()
    " prepare for display
    let l:display = dn#util#listToScreenColumns(
                \ l:filetypes, winwidth(0)-3)
    " display
    echo l:display
endfunction

" dn#util#showRuntimepaths()    {{{1

""
" @public
" Display runtime paths in the echo area.
function! dn#util#showRuntimepaths() abort
    " get filetype list
    let l:runtimepaths = dn#util#runtimepaths()
    " prepare for display
    for l:path in l:runtimepaths
        call dn#util#wrap(l:path)
    endfor
endfunction

" dn#util#showMsg(message[, type])    {{{1

""
" @public
" Display {message} to user via gui dialog, if available and running a gui
" version of vim, or the console. The optional message [type] can be
" "generic", "warning", "info", "question", or "error". Any other value is
" ignored. If no {message} is provided an error message is displayed instead.
" @default type='generic'
function! dn#util#showMsg(message, ...) abort
    " process args
    let l:msg = a:message
    let l:valid_types = ['generic', 'warning', 'info', 'question', 'error']
    let l:type = (a:0 && count(l:valid_types, tolower(a:1))) ? tolower(a:1)
                \                                            : 'generic'
    " sanity check
    if l:msg ==? ''
        let l:msg = "No message supplied to 'dn#util#showMsg'"
        let l:type = 'error'
    endif
    " for non-gui environment add message type to output
    if !has ('gui_running') && l:type !=? ''
        let l:msg = toupper(strpart(l:type, 0, 1))
                    \ . tolower(strpart(l:type, 1)) . ': ' . l:msg
    endif
    " display message
    call confirm(l:msg, '&OK', 1, l:type)
endfunction

" dn#util#stringify(variable[, quote])    {{{1

""
" @public
" Convert {variable} to |String| and return the converted string. If [quote]
" is true strings in {variable} will be enclosed in single quotes in the
" output, with internal single quotes doubled. For |Dictionaries| perl-like
" "big-arrow" (" => ") notation is used between keys and values. Consider
" using |string()| instead of this function.
" @default quote=false
function! dn#util#stringify(variable, ...) abort
    " l:Var and l:Item are capitalised because they can be funcrefs
    " and local funcref variables must start with a capital letter
    let l:Var = deepcopy(a:variable)
    " are we quoting string output?
    let l:quoting_strings = (a:0 && a:1)
    " string
    if     type(a:variable) == type('')
        let l:Var = strtrans(l:Var)  " ensure all chars printable
        if l:quoting_strings
            " double all single quotes
            let l:Var = substitute(l:Var, "'", "''", 'g')
            " enclose in single quotes
            let l:Var = "'" . l:Var . "'"
        endif
        return l:Var
    " integer
    elseif type(a:variable) == type(0)
        return printf('%d', a:variable)
    " float
    elseif type(a:variable) == type(0.0)
        return printf('%g', a:variable)
    " List
    elseif type(a:variable) == type([])
        let l:out = []
        for l:Item in l:Var
            call add(l:out, dn#util#stringify(l:Item, v:true))
            unlet l:Item
        endfor
        return '[ ' . join(l:out, ', ') . ' ]'
    " Dictionary
    " - use perl-style 'big arrow' notation
    elseif type(a:variable) == type({})
        let l:out = []
        for l:key in sort(keys(l:Var))
            let l:val = dn#util#stringify(l:Var[l:key], v:true)
            call add(l:out, "'" . l:key . "' => " . l:val)
        endfor
        return '{ ' . join(l:out, ', ') . ' }'
    " Funcref
    elseif type(a:variable) == type(function('tr'))
        return string(l:Var)
    " Boolean
    elseif type(a:variable) == type(v:true)
        return string(l:Var)
    " Null
    elseif a:variable is v:null
        return string(l:Var)
    " have now covered all seven variable types
    else
        call dn#util#error('invalid variable type')
        return v:false
    endif
endfunction

" dn#util#stripLastChar(string)    {{{1

""
" @public
" Removes last character from {string}. Return altered {string}.
function! dn#util#stripLastChar(string) abort
    return strpart(
                \ 	a:string,
                \ 	0,
                \ 	strlen(a:string) - 1
                \ )
endfunction

" dn#util#testFn()    {{{1

""
" @public
" Utility function used for testing purposes only
" params: varies
" insert: varies
" return: varies
function! dn#util#testFn() range abort
    let l:var = 'A RABBIT AND A DOG SHOW'
    call dn#util#showMsg(string(l:var))
endfunction

" dn#util#trimChar(string[, char])    {{{1

""
" @public
" Removes leading and trailing [char] from {string}. If [char] in longer than
" a single character only the first character is used. Returns the trimmed
" {string}.
" @default char=' '
function! dn#util#trimChar(string, ...) abort
    " set trim character
    let l:char = (a:0 && a:1 !=? '') ? strpart(a:1, 0, 1) : ' '
    " build match terms
    let l:left_match_str = '^' . l:char . '\+'
    let l:right_match_str = l:char . '\+$'
    " do trimming
    let l:string = substitute(a:string, l:left_match_str, '', '')
    return substitute(l:string, l:right_match_str, '', '')
endfunction

" dn#util#unusedFunctions([silent[, lower[, upper]]])    {{{1

""
" @public
" Checks for uncalled vim functions in the current buffer. Fails with error
" message if buffer |filetype| is not "vim". Displays feedback to user about
" any uncalled functions, and also returns a |List| of unused functions. If
" [silent] is true no feedback is displayed. The whole of the buffer is
" analysed by default, but [lower] and [upper] line numbers can be provided to
" limit the search area.
" @default lower=1
" @default upper=line('$')
"
" This function is most definitely unreliable. Double-check its results before
" taking any action based on its output!
function! dn#util#unusedFunctions(...) abort
    " only intended for vim scripts
    if &filetype !=# 'vim'
        echoerr 'dn#util#unusedFunctions() work only on vim scripts'
        return ''
    endif
    try
        " variables
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
            throw 'Upper bound must be greater then lower bound'
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
                throw "Could not find 'endfunction' for function '"
                            \ . l:func_name . "'"
            endif
            " now find whether function ever called
            call cursor(l:lower, 1)
            let l:called = v:false
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
                        let l:called = v:true
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
        if !l:silent | echomsg l:msg | endif
    catch
        call dn#util#showMsg(dn#util#exceptionError(v:exception), 'Error')
    finally
        return l:unused
    endtry
endfunction

" dn#util#updateUserHelpTags()    {{{1

""
" @public
" Individually updates user vim helpdocs.
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

" dn#util#validPosInt(val)    {{{1

""
" @public
" Determines whether {val} is a valid positive integer. Zero is not considered
" a positive integer. Returns a bool.
function! dn#util#validPosInt(value) abort
    return a:value =~# '^[1-9]\{1}[0-9]\{}$'
endfunction

" dn#util#varType(variable)    {{{1

""
" @public
" Get type of {variable} as a string rather than a numeric code as given by
" |type()|. The possible return values are "number", "string", "funcref",
" "List", "Dictionary", "float", "boolean" (for |v:true| and |v:false|),
" "null" (for |v:null|) and "unknown".
function! dn#util#varType(variable) abort
    if     type(a:variable) == type(0)              | return 'number'
    elseif type(a:variable) == type('')             | return 'string'
    elseif type(a:variable) == type(function('tr')) | return 'funcref'
    elseif type(a:variable) == type([])             | return 'List'
    elseif type(a:variable) == type({})             | return 'Dictionary'
    elseif type(a:variable) == type(0.0)            | return 'float'
    elseif type(a:variable) == type(v:true)         | return 'boolean'
    elseif type(a:variable) == type(v:null)         | return 'null'
    else                                            | return 'unknown'
    endif
endfunction

" dn#util#warn(msg)    {{{1

""
" @public
" Display a warning message with |hl-WarningMsg| highlighting.
function! dn#util#warn(msg) abort
    if mode() ==# 'i' | execute "normal! \<Esc>" | endif
    echohl WarningMsg
    for l:msg in s:listifyMsg(a:msg) | echomsg l:msg | endfor
    echohl Normal
endfunction

" dn#util#wrap(message[, hang])    {{{1

""
" @public
" Echoes text but wraps it sensibly. A hanging indent (which applies to all
" output lines except the first) can be applied, in which case the size of the
" indent is specified with [hang].
" @default hang=0
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
    let l:first_line = v:true
    while l:msg !=? ''
        " exit on last output line
        if len(l:msg) <= l:width
            if !l:first_line
                let l:msg = l:hang_indent . l:msg
            endif
            echomsg l:msg
            break
        endif
        " find wrap point
        let l:break = -1 | let l:count = 1 | let l:done = v:false
        while !l:done
            let l:index = match(l:msg, '[!@*\-+;:,./?\\ \t]', '', l:count)
            if     l:index == -1     | let l:done = v:true
            elseif l:index < l:width | let l:break = l:index
            endif
            let l:count += 1
        endwhile
        " if no wrap point then have ugly situation where no breakpoint
        " exists so just output whole thing (ick!)
        if l:break == -1 | echomsg l:msg | break | endif
        " let's wrap!
        let l:break += 1
        let l:output = strpart(l:msg, 0, l:break)
        if !l:first_line
            let l:output = l:hang_indent . l:output
        endif
        echomsg l:output
        let l:msg = strpart(l:msg, l:break)
        " - if broke line on punctuation mark may now have leading space
        if strpart(l:msg, 0, 1) ==? ' '
            let l:msg = strpart(l:msg, 1)
        endif
        let l:first_line = v:false
    endwhile
endfunction
" }}}1

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: set foldmethod=marker :
