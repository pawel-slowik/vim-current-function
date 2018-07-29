function! currentfunction#CreateTags() abort
	if exists('b:line_tag_map')
		return
	endif
	if !filereadable(expand('<afile>'))
		return
	endif
	call currentfunction#UpdateTags()
endfunction

function! currentfunction#UpdateTags() abort
	let b:line_tag_map = {}
	let ctags_pattern = "^\\(.\\{-}\\)\t.\\{-}\t\\(\\d*\\).*"
	let ctags_obligatory_args = '-n --sort=no -o -'
	let buffer_last_line_num = line('$')
	let cmd = g:current_function_ctags_path . ' ' . ctags_obligatory_args
	let cmd = cmd . ' ' . g:current_function_ctags_args
	let cmd = cmd . ' ' . shellescape(expand('%'))
	let cmd = cmd . ' | sort -t "	" -k 3 -n'
	let output = system(cmd)
	let len = strlen(output)
	let offset = 0
	while offset < len
		let one_tag = matchstr(output, "[^\n]*", offset)
		let tag_name = substitute(one_tag, ctags_pattern, '\1', '')
		let tag_name = currentfunction#GetContext(one_tag) . tag_name
		let tag_name = currentfunction#PostProcessTag(tag_name)
		let tag_line_num = str2nr(substitute(one_tag, ctags_pattern, '\2', ''))
		let tag_end_line_num = currentfunction#GetEndLine(one_tag)
		if tag_end_line_num <= 0
			let tag_end_line_num = buffer_last_line_num
		endif
		let offset = offset + strlen(one_tag) + 1
		let map_line_num = tag_line_num
		while map_line_num <= tag_end_line_num
			let b:line_tag_map[map_line_num] = tag_name
			let map_line_num = map_line_num + 1
		endwhile
	endwhile
endfunction

function! currentfunction#GetCurrentTag() abort
	if !exists('b:line_tag_map')
		return ''
	endif
	let current_line_num = line('.')
	if !has_key(b:line_tag_map, current_line_num)
		return ''
	endif
	return b:line_tag_map[current_line_num]
endfunction

function! currentfunction#GetContext(one_tag_line) abort
	let contexts = [
		\{'separator': '.', 'word': 'class'},
		\{'separator': '.', 'word': 'function'},
		\{'separator': '.', 'word': 'member'},
		\{'separator': '\', 'word': 'namespace'},
	\]
	for context in contexts
		let word_str = matchstr(a:one_tag_line, context.word . ':.*')
		if word_str ==# ''
			continue
		endif
		let word_str = substitute(word_str, '^' . context.word . ':', '', '')
		let word_str = substitute(word_str, "\t.*$", '', '')
		return word_str . context.separator
	endfor
	return ''
endfunction

function! currentfunction#PostProcessTag(tag_name) abort
	" For PHP, universal-ctags outputs method scope with two
	" backslashes as separators:
	" class:Namespace\\Class
	" but the proper PHP syntax has only one backslash. Therefore,
	" replace multiple backslashes with one.
	return substitute(a:tag_name, "\\\\\\+", "\\", 'g')
endfunction

function! currentfunction#GetEndLine(one_tag_line) abort
	let end_line_str = matchstr(a:one_tag_line, 'end:.*')
	if end_line_str ==# ''
		return 0
	endif
	let end_line_str = substitute(end_line_str, '^end:', '', '')
	let end_line_str = substitute(end_line_str, "\t.*$", '', '')
	return str2nr(end_line_str)
endfunction
