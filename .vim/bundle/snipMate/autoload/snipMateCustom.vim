" Used to generate PHP class name automatically from the filename
fun! snipMateCustom#AutoClassName()
    let filename = expand('%:p')
    if filename == ''
        return 'ClassName'
    endif
    let filename = substitute(filename, '\\', '/', 'g')
    if match(filename, '/classes/') > -1
        " /classes/A/B/C.php -> "A_B_C"
        let filename = substitute(filename, '^.*/classes/', '', '')
        let filename = substitute(filename, '/', '_', 'g')
        let filename = substitute(filename, '\.php$', '', '')
    else
        " /A/B/C.php -> "C"
        let filename = expand('%:t:r')
    endif
    return filename
endf

" HTML snippet common to PHP, Smarty and HTML
fun! snipMateCustom#HTML()
   return "
       \<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n
       \<html lang=\"en-GB\" xml:lang=\"en-GB\" dir=\"ltr\" xmlns=\"http://www.w3.org/1999/xhtml\">\n
       \	<head>\n
       \\n
       \		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n
       \		<meta http-equiv=\"Content-Language\" content=\"en-GB\" />\n
       \\n
       \		<title>${1:Untitled Document}</title>\n
       \\n
       \		<link rel=\"stylesheet\" href=\"/css/main.css\" type=\"text/css\" />\n
       \\n
       \	</head>\n
       \	<body>\n
       \\n
       \		${2}\n
       \\n
       \	</body>\n
       \</html>"
endf

" Doesn't insert anything, but sets the filetype for the current file
fun! snipMateCustom#SetFileTypeKnowledgebase()
    set filetype=knowledgebase
    return ""
endf
