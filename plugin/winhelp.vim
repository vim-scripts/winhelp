" This script lets you setup a collection of help files in Windows .hlp and
" .chm format and search for the word under the cursor in them. The current
" files and state is stored in the scricpt file for further sessions. Use the
" new winhelp dropdown menu to add or remove files.
" Check out tip #506
" http://www.vim.org/tips/tip.php?tip_id=506
" and tip #232
" http://www.vim.org/tips/tip.php?tip_id=232
" 
" The default keymappings for normal mode are: 
" Ctrl+Shift+F1 - pops up a menu with the help files and search the selected
" file for the word under the cursor.
" Ctrl+F1 - search the current help file for the word. Use the winhelp menu
" for setting the current help file.
"
" INSTALLATION
" The script must be in the $VIM/vimfiles/plugin/ directory.
" For the .hlp files is the script using Windows winhelp program. You can test with
" a "winhelp helpfile.hlp" from the command line. If no luck can you try to
" replace winhelp with winhlp32 in the script but I belive this is the same.
" For the .chm files is keyhh from this page used
" http://www.keyworks.net/keyhh.htm 
" It worked for me but I dont know if you need the HTML workshop installed?
" My suggestion is to visit MSDN in case of problems. Here is a direct
" link to the HTML help downloads from MSDN
" http://msdn.microsoft.com/library/default.asp?url=/library/en-us/htmlhelp/html/hwMicrosoftHTMLHelpDownloads.asp
"
" MSDN is also the main source for .chm files. The Platform SDK has a complete
" set of .chm files for Windows. Borland has some .hlp files here
" http://info.borland.com/techpubs/bcppbuilder/v5/updates/ent.html
" there the most interesting are
" B5MS.ZIP - Win32 API documentation old but useful with stuff like
" OpenGL1.1, a similar file can be downloaded from the lcc compiler page
" B5SCL.ZIP - Standard C++ library help with STL
" B5RTL.ZIP - C lib reference
" 
" Java users should take a look at tip #232 mentioned above. 
"
" The key maps
nmap <C-F1> :silent! WinHelp <C-R><C-W><CR>
nmap <C-S-F1> :silent! popup ]pophelp<CR>

"commands the intended use is from menus
command! -nargs=0 BrowseHelpAdd call s:BrowseHelpAdd()
command! -nargs=1 OpenHelpFile call s:OpenHelpFile(<f-args>)
command! -nargs=1 SetCurrentHelpFile call s:SetCurrentHelpFile(<f-args>)
command! -nargs=1 WinHelp call s:WinHelp(<f-args>)
command! -nargs=1 RemoveMenuItem call s:RemoveMenuItem(<f-args>)
command! -nargs=* WinHelpSearch call s:WinHelpSearch (<f-args>)

" since the modifies itself should some care be taken if you alters it
" this is a hack and not a model for something good. :)
function! s:BrowseHelpAdd()
	let browseFile=""
	" stupid fix because browse() does not always returns the full
	" path
	let cwdCur=getcwd()
	cd $VIM
	let browseFile=browse(0,"Help file to add","","")
	execute "cd " . cwdCur
	if browseFile!=""
		let browseFile=expand(browseFile, ":p")
		call s:MakeMenuEntry(browseFile)
	endif
endfunction

function! s:HiddenLoad()
	if (!bufexists("$VIM/vimfiles/plugin/winhelp.vim"))
		execute "silent! edit! $VIM/vimfiles/plugin/winhelp.vim"
		let &buflisted=0
		let &bufhidden="hide"
		let &swapfile=0
	else
		execute "buffer winhelp.vim"
	endif
	normal! gg^
endfunction

function! s:SetCurrentHelpFile(fileNameWithPath)
	let s:currentHelpFile=a:fileNameWithPath
	split
	call s:HiddenLoad()
	let @c="call s:SetCurrentHelpFile('" . a:fileNameWithPath . "')"
	let @c=substitute(@c,'\','/','g')
	normal! G
	call search(":BrowseHelpAdd",'b')
	if a:fileNameWithPath!=""
		silent! normal! o
		silent! normal! "cp==$
	endif
	if search("s:SetCurrentHelpFile",'W')!=0
		silent! normal! dd
	endif
	silent! write!
	quit!

endfunction
function! s:RemoveMenuItem(fileNameWithPath)
	execute "aunmenu w&inhelp.&open\\ help." . fnamemodify(a:fileNameWithPath,":t:r")  
	execute "aunmenu w&inhelp.&set\\ current." . fnamemodify(a:fileNameWithPath,":t:r")
	execute "aunmenu w&inhelp.&remove\\ help." . fnamemodify(a:fileNameWithPath,":t:r")
	execute "aunmenu ]pophelp." . fnamemodify(a:fileNameWithPath,":t:r") 
	if s:currentHelpFile==a:fileNameWithPath
		call s:SetCurrentHelpFile("")
	endif
	split
	call s:HiddenLoad()
	let @c="call s:MakeMenuEntry('" . a:fileNameWithPath . "')"
	let @c=substitute(@c,'\','/','g')
	if (search(@c)!=0)
		silent! normal! dd
		silent! write!
	endif
	quit!
endfunction

function! s:MakeMenuEntry(fileNameWithPath)
	execute "amenu w&inhelp.&open\\ help." . fnamemodify(a:fileNameWithPath,":t:r") . " :OpenHelpFile " . a:fileNameWithPath . "<CR>"
	execute "amenu w&inhelp.&set\\ current." . fnamemodify(a:fileNameWithPath,":t:r") . " :SetCurrentHelpFile " . a:fileNameWithPath . "<CR>"
	execute "amenu w&inhelp.&remove\\ help." . fnamemodify(a:fileNameWithPath,":t:r") . " :RemoveMenuItem " . a:fileNameWithPath . "<CR>"
	execute "amenu ]pophelp." . fnamemodify(a:fileNameWithPath,":t:r") . " :WinHelpSearch " . a:fileNameWithPath . " <C-R><C-W><CR>"
	if s:currentHelpFile==""
		call s:SetCurrentHelpFile(a:fileNameWithPath)
	endif
	split
	call s:HiddenLoad()
	let @c="call s:MakeMenuEntry('" . a:fileNameWithPath . "')"
	let @c=substitute(@c,'\','/','g')
	if (search(@c)==0)
		silent! normal! G
		call search(":BrowseHelpAdd",'b')
		silent! normal! o
		silent! normal! "cp
		silent! normal! ==
		silent! write!
	endif
	quit!
endfunction
function! s:OpenHelpFile(fileNameWithPath)
	if fnamemodify(a:fileNameWithPath,":e")=="chm"
		silent! execute "!start keyhh " . a:fileNameWithPath 
	elseif fnamemodify(a:fileNameWithPath,":e")=="hlp"
		silent! execute "!start winhelp " . a:fileNameWithPath 
	else
		" generate some warning
	endif
endfunction
	
function! s:WinHelp(keyToLookup)
	if (s:currentHelpFile=="")
		call confirm("No current help file.","&OK",1,"Error")
		return
	endif
	call s:WinHelpSearch(s:currentHelpFile, a:keyToLookup)
endfunction
function! s:WinHelpSearch(fileNameWithPath, keyToLookup)
	if fnamemodify(a:fileNameWithPath,":e")=="chm"
		silent! execute "!start keyhh -\\#klink " . a:keyToLookup . " " . a:fileNameWithPath 
	elseif fnamemodify(a:fileNameWithPath,":e")=="hlp"
		silent! execute "!start winhelp -k " . a:keyToLookup . " " . a:fileNameWithPath 
	else
		call confirm("Not an .chm or .hlp file","&OK",1,"Error")
	endif
endfunction
		
if has("gui_running")
	set mousemodel=popup
	silent! aunmenu w&inhelp
	silent! aunmenu pophelp
	let s:currentHelpFile=""
	amenu w&inhelp.&Add\ help\ file<TAB>:BrowseHelpAdd	:BrowseHelpAdd<CR>
endif
