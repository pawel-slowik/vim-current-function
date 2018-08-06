This [Vim](https://www.vim.org/) micro-plugin provides a function that returns
the name of the current function. This can be used to display the function
name in the status line.

The function name is retrieved using `ctags`. It is recommended to use
[universal-ctags](https://github.com/universal-ctags/ctags) instead of other,
older `ctags` implementations.

## Usage

Example configuration:

	let g:current_function_ctags_path='/usr/local/bin/universal-ctags'
	let g:current_function_ctags_args='--fields=+es'

Display the function name in the status line:

	set statusline+=%(\ %{currentfunction#GetCurrentTag()}\ %)

## Similar / alternative plugins

- [Tagbar](https://github.com/majutsushi/tagbar) - look up `tagbar-statusline`
- [current-func-info.vim](https://github.com/tyru/current-func-info.vim)
