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
" OpenGL1.1. A similar file can be downloaded from the lcc and mingw 
" compiler pages but that file is smaller and I dont think it has the OpenGL
" help file. If you add Win32sdk.hlp to the script will also the other hlp
" files from that archive be found.
" B5SCL.ZIP - Standard C++ library help with STL
" B5RTL.ZIP - C lib reference
" 
" Java users should take a look at tip #232 mentioned above. 
"
" BUGS/Features
" -If the path to a.chm file has any spaces does not keyhh or hh works
" properly. I think this is a known issue with Windows HTML help. Bob solved
" it by linking directories and I think that is the only way.
" -If you do an ALT+TAB to get away from a .chm file may you see an temporary
"  extra copy in the taskbar. Note that the icons for .chm is the ones
"  normally used for .hlp files.
"  -It will probably take some time before you get used to how keyhh works. 
"  In my experience does it work very well but sometimes do you have to look twice to see it. :)   
" -The popup menu can be incorrect after removing a file from  the collection. After a restart is it OK. 
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

function! IsHelpFile(fName)
	if a:fName==""
		return 0
	elseif tolower(fnamemodify(a:fName,":e"))=="chm"
		return 1
	else
		return tolower(fnamemodify(a:fName,":e"))=="hlp"
	endif
endfunction
		
function! s:BrowseHelpAdd()
	let browseFile=""
	" stupid fix because browse() does not always returns the full
	" path
	let cwdCur=getcwd()
	cd $VIM
	let browseFile=browse(0,"Help file to add","","")
	execute "cd " . cwdCur
	if IsHelpFile(browseFile)
		let browseFile=expand(browseFile, ":p")
		call s:MakeMenuEntry(browseFile)
	else
		call confirm("Not an .chm or .hlp file","&OK",1,"Error")
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
	if (! s:writeStuff)
		return
	endif
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
	execute "amenu ]pophelp." . fnamemodify(a:fileNameWithPath,":t:r") . " :WinHelpSearch " . substitute(a:fileNameWithPath,' ','\\ ','g')  . " <C-R><C-W><CR><CR>"
	if s:currentHelpFile==""
		call s:SetCurrentHelpFile(a:fileNameWithPath)
	endif
	if (! s:writeStuff)
		return
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
	let cwdCur=getcwd()
	cd $VIM
	if tolower(fnamemodify(a:fileNameWithPath,":e"))=="chm"
		silent! execute "silent! !start keyhh " . a:fileNameWithPath 
	elseif tolower(fnamemodify(a:fileNameWithPath,":e"))=="hlp"
		silent! execute "silent! !start winhelp " . a:fileNameWithPath 
	else
		call confirm("Not an .chm or .hlp file","&OK",1,"Error")
	endif
	execute "cd " . cwdCur
endfunction
	
function! s:WinHelp(keyToLookup)
	if (s:currentHelpFile=="")
		call confirm("No current help file.","&OK",1,"Error")
		return
	endif
	call s:WinHelpSearch(s:currentHelpFile, a:keyToLookup)
endfunction
function! s:WinHelpSearch(fileNameWithPath, keyToLookup)
	let cwdCur=getcwd()
	cd $VIM
	if tolower(fnamemodify(a:fileNameWithPath,":e"))=="chm"
		silent! execute "silent! !start keyhh -\\#klink " . a:keyToLookup . " " . a:fileNameWithPath
	elseif tolower(fnamemodify(a:fileNameWithPath,":e"))=="hlp"
		silent! execute "silent! !start winhelp -k " . a:keyToLookup . " " . a:fileNameWithPath 
	else
		call confirm("Not an .chm or .hlp file","&OK",1,"Error")
	endif
	execute "cd " . cwdCur
endfunction
		
function! s:ReLoadStuff() 
	silent! aunmenu! winhelp.*
	silent! aunmenu! ]pophelp.*
	let s:currentHelpFile=""
	amenu w&inhelp.&Add\ help\ file<TAB>:BrowseHelpAdd	:BrowseHelpAdd<CR>
endfunction

if has("gui_running") && (has("win32") || has("win16"))
	set mousemodel=popup
	let s:writeStuff=0
	call s:ReLoadStuff()
	let s:writeStuff=1
endif
