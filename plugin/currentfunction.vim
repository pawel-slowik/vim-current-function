if !exists('g:current_function_ctags_path')
	let g:current_function_ctags_path='ctags'
endif

if !exists('g:current_function_ctags_args')
	let g:current_function_ctags_args='--python-kinds=cfm --php-kinds=cif --vim-kinds=f --c++-kinds=cfgsu --c-kinds=fgsu'
endif

augroup CurrentFunction
	autocmd!
	autocmd BufEnter *.c,*.cpp,*.h,*.py,*.php,*.vim call currentfunction#CreateTags()
	autocmd BufWritePost *.c,*.cpp,*.h,*.py,*.php,*.vim call currentfunction#UpdateTags()
augroup end
