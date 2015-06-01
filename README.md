Dn Utilities for Vim
====================

Table of Contents
-----------------

[Overview](#overview)

[Variables](#variables)

[Templates](#templates)

[Date functions](#date)

[File/directory functions](#file)

[User interactive functions](#user)

[List functions](#list)

[Programming functions](#programming)

[Version control functions](#version)

[String functions](#string)

[Number functions](#number)

[Miscellaneous functions](#miscfunc)

[Miscellaneous mappings](#miscmap)

[Templates](#templates)

Overview<a id="overview"></a>
--------

A plugin to provide useful generic functions. It is intended to be available to all files being edited.

These functions were developed over time by the author and later combined into a library.

All functions in this library are global. They all have the prefix 'DNU\_' to try and avoid namespace collisions.

Some mappings and autocommands are also provided.

Variables<a id="variables"></a>
---------

The plugin provides some useful convenience variables that can be used by other plugins.

* Boolean buffer variables *b:dn\_true* and *b:dn\_false* save script writers from having to remember the boolean values used by vim. \(Note: false = 0 and true = non-zero integer.\)

* The extensible help system relies on buffer Dictionary variables b:dn\_help\_plugins, b:dn\_help\_topics and b:dn\_help\_data.

Templates<a id="templates"></a>
---------

This utility provides templates that can be loaded into new files, or inserted into empty existing files.

The file to load/insert is selected by providing the file's 'key'. Here are the available templates and their keys:
    
    Template           | Key
    -------------------|-------------
    Configuration file | configfile
    Makefile.am file   | makefile.am
    Man page           | manpage
    Markdown file      | markdown
    Perl module file   | perlmod
    Perl script file   | perlscript
    Shellscript.sh     | shellscript
    Html               | html
    Xhtml              | xhtml

After a template is loaded the file is examined for a number of tokens.
Most tokens are replaced with generated text. Here are the tokens and
their significance:

    Token               | Use
    --------------------|--------------------------------------------------
    \<FILENAME\>        | replaced with file name
    \<BASENAME\>        | replaced with file basename
    \<NAME\>            | replaced with file basename
    \<DATE\>            | replaced with current date in iso format
    \<HEADER_NAME\>     | manpage header name, replaced with file basename
    \<HEADER_SECTION\>  | manpage section, replaced with numeric file extension, e.g., '1' from file name 'command.1'
    \<TITLE_NAME\>      | manpage title name element, replaced with file basename in initial caps
    \<START\>           | this is the last token processed and it marks the location at which to to start editing: the cursor is positioned at the token location, the token deleted, and insert mode activated

Templates do not have to contain all, or even any, tokens.

                                                         *DNU-LoadTemplate*
DNU_LoadTemplate(template_key)
    purpose: load template file into current buffer
    params:  1 - template file key <required> [string]
                 see above for key values
    insert:  template file contents
    return:  nil
    note:    designed for use with autocommands triggered by the
             BufNewFile event
    usage:   here is how this function might be used in a vim
             configuration file:
                 au BufNewFile *.[0-9] call DNU_LoadTemplate('manpage')
                
                                                       *DNU-InsertTemplate*
DNU_InsertTemplate(template_key)
    purpose: insert template file into current buffer
    params:  1 - template file key <required> [string]
                 see above for key values
    insert:  template file contents
    return:  nil
    note:    will insert template file contents only if current buffer is
             empty (one line of zero length only)
    note:    designed for use with autocommands triggered by the
             BufRead event
    usage:   here is how this function might be used in a vim
             configuration file:
                 au BufRead *.[0-9] call DNU_InsertTemplate('manpage')

Date functions<a id="date"></a>
--------------

A series of functions that manipulate dates.

### s:currentIsoDate\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>return current date in ISO format (yyyy-mm-dd)</td>
</tr>
</table>

### DNU\_InsertCurrentDate\(\[insert\_mode\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>insert current date in ISO format (yyyy-mm-dd)</td>
</tr>
</table>

### DNU\_NowYear\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get current year</td>
</tr>
</table>

### DNU\_NowMonth\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get current month</td>
</tr>
</table>

### DNU\_NowDay\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get current day in month</td>
</tr>
</table>

### DNU\_DayOfWeek\(year, month, day\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get name of weekday</td>
</tr>
</table>

These subsidiary functions are used by the date-related functions just described:

* s:centuryDoomsday\(year\)
* s:currentIsoDate\(\)
* s:dayValue\(day\_number\)
* s:leapYear\(year\)
* s:monthLength\(year, month\)
* s:monthValue\(year, month\)
* s:validCalInput\(year, month, day\)
* s:validDay\(year, month, day\)
* s:validMonth\(month\)
* s:validYear\(year\)
* s:yearDoomsday\(year\)

File/directory functions<a id="file"></a>
------------------------

These are functions that manipulate files and directories.

### DNU\_GetFilePath\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get filepath of file being edited</td>
</tr>
</table>

### DNU\_GetFileDir\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get directory of file being edited</td>
</tr>
</table>

### DNU\_GetFileName\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get name of file being edited</td>
</tr>
</table>

### DNU\_StripPath\(filepath\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>removes path from filepath</td>
</tr>
</table>

User interactive functions<a id="user"></a>
--------------------------

These are functions that interact with users.

### DNU\_ShowMsg\(message, \[type\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>display message to user</td>
</tr>
</table>

### DNU\_Error\(message\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>display error message</td>
</tr>
<tr valign="top">
<td>prints:</td>
<td>error msg in error highlighting accompanied by system bell</td>
</tr>
</table>

### DNU\_Warn\(message\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>display warning message</td>
</tr>
<tr valign="top">
<td>prints:</td>
<td>warning msg in warning highlighting accompanied by system bell</td>
</tr>
</table>

### DNU\_Prompt\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>display prompt message</td>
</tr>
</table>

### DNU\_Wrap\(message\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>echoes text but wraps it sensibly</td>
</tr>
</table>

### DNU\_MenuSelect\(items, \[prompt\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>select item from menu</td>
</tr>
</table>

### DNU\_ChangeHeaderCaps\(mode\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>changes capitalisation of line or visual selection</td>
</tr>
<tr valign="top">
<td>note:</td>
<td>if visual selection is present it will be processed, otherwise the current line will be processed</td>
</tr>
<tr valign="top">
<td>note:</td>
<td>user chooses capitalisation type: upper case, lower case, capitalise every word, sentence case, or title case</td>
</tr>
</table>

This function is mapped by default to '&lt;LocalLeader&gt;hc', usually '\hc', in Insert, Normal and Visual modes.

### DNU\_Help\(\[insert\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>user can select from help topics</td>
</tr>
<tr valign="top">
<td>note:</td>
<td>extensible help system relying on buffer Dictionary variables b:dn\_help\_plugins, b:dn\_help\_topics and b:dn\_help\_data</td>
</tr>
<tr valign="top">
<td>note:</td>
<td>other plugins can add to the help variables and so take advantage of the help system; the most friendly way to do this is for the b:dn\_help\_topics variable to have a single top-level menu item reflecting the plugin name/type, and for the topic values to be made unique by appending to each a prefix unique to its plugin</td>
</tr>
</table>

|         |                                |
|---------|--------------------------------|
|purpose: | user can select from help topics|
|note:    | extensible help system relying on buffer Dictionary variables b:dn\_help\_plugins, b:dn\_help\_topics and b:dn\_help\_data|
|note:    | other plugins can add to the help variables and so
            take advantage of the help system; the most friendly
            way to do this is for the b:dn\_help\_topics variable 
            to have a single top-level menu item reflecting the 
            plugin name/type, and for the topic values to be made
            unique by appending to each a prefix unique to its plugin|

This function is mapped by default to '&lt;LocalLeader&gt;hh', usually '\hh', in both Insert and Normal modes.

### DNU\_GetSelection\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>returns selected text</td>
</tr>
</table>

List functions<a id="list"></a>
--------------

These are utility functions that support Lists.

### DNU\_ListGetPartialMatch\(list, pattern\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>get the first element containing given pattern</td>
</tr>
</table>

### DNU\_ListExchangeItems\(list, index1, index2\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>exchange two elements in the same list</td>
</tr>
</table>

### DNU\_ListSubtract\(list\_1, list\_2\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>subtract one list from another</td>
</tr>
</table>

### DNU\_ListToScreen\(list, ...\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>formats list for screen display</td>
</tr>
</table>

### DNU\_ListToScreenColumns\(list, ...\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>formats list for screen display in columns</td>
</tr>
</table>

Programming functions<a id="programming"></a>
---------------------

These are utility functions that aid programming.

### DNU\_UnusedFunctions\(\[lower\], \[upper\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>checks for uncalled functions</td>
</tr>
</table>

### DNU\_InsertMode\(\[skip\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>switch to insert mode</td>
</tr>
</table>

Version control function<a id="version"></a>
------------------------

These functions enable version control from within vim.

The plugin [VCSCommand][] is recommended for version control. The function [dn-util-gitMake](#gitmake) is required because VCSCommand does not handle git repository creation.

[VCSCommand]: https://github.com/vim-scripts/vcscommand.vim

### DNU\_GitMake\(\)<a id="gitmake"></a>

<table>
<tr valign="top">
<td>purpose:</td>
<td>creates git repo in current directory and commits file</td>
</tr>
</table>

This function is mapped by default to '<LocalLeader>git', usually '\git', in both Insert and Normal modes.

String functions<a id="string"></a>
----------------

These functions manipulate strings.

### DNU\_StripLastChar\(text\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>removes last character from string</td>
</tr>
</table>

### DNU\_InsertString\(text, \[restrict\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>insert string at current cursor location</td>
</tr>
</table>

### DNU\_TrimChar\(text, \[char\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>removes leading and trailing chars from string</td>
</tr>
</table>

### DNU\_Entitise\(text\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>replace special html characters with entities</td>
</tr>
</table>

### DNU\_Deentitise\(text\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>replace entities with characters for special html characters</td>
</tr>
</table>

### DNU\_String\(var\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>convert variables to string</td>
</tr>
</table>

### DNU\_MatchCount\(haystack, needle\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>finds number of occurrences of a substring in a string</td>
</tr>
</table>

### DNU\_StridxNum\(haystack, needle, number\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>finds the X'th match of a substring in a string</td>
</tr>
</table>

### DNU\_PadInternal\(string, start, target, \[char\]\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>insert char at given position until initial location is at the desired location</td>
</tr>
</table>

### DNU\_ChangeHeaderCaps\(mode\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>change capitalisation of header</td>
</tr>
</table>

This subsidiary function is used by the header-related function just described:

* s:headerCapsEngine\(string, type\)

Number functions<a id="number"></a>
----------------

These functions manipulate numbers.

### DNU\_ValidPosInt\(int\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>check whether input is valid positive integer</td>
</tr>
<tr valign="top">
<td>note:</td>
<td>zero is not a positive integer</td>
</tr>
</table>

Miscellaneous functions<a id="miscfunc"></a>
-----------------------

Functions that cannot be placed in any other category.

### DNU\_JumpPlace\(start, end, direction\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>jump to placeholder</td>
</tr>
</table>

### DNU\_SelectWord\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>selects <cword> under cursor (must be only [0-9a-zA-Z\_])</td>
</tr>
</table>

### DNU\_TestFn\(\)

<table>
<tr valign="top">
<td>purpose:</td>
<td>utility function used for testing purposes only</td>
</tr>
</table>

Miscellaneous mappings<a id="miscmap"></a>
----------------------

Mappings not associated with functions.

### Initial capitals

Insert, normal and visual mappings for '&lt;LocalLeader&gt;ic', usually '\ic'.

In normal and insert mode the current line is converted to initial capitals.

In visual mode the selected text is converted to initial capitals.

Templates<a id="templates"></a>
---------

The following templates are provided in plugin directory `vim-dn-utils-templates`:

* configfile.rc

* Makefile.am

* manpage.1

* perlmod.pm

* perlscript.pl

* shellscript.sh

* template.html

* template.xhtml
