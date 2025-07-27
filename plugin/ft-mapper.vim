" Title:        ft-mapper.nvim
" Description:  A plugin to extend 'f' & 't' motion for multibyte.
" Last Change:  8 November 2025
" Maintainer:   s-show <https://github.com/s-show>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_ft_mapper")
    finish
endif
let g:loaded_ft_mapper = 1
