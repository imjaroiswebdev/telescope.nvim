" Sets the highlight for selected items within the picker.
highlight default link TelescopeSelection Visual
highlight default link TelescopeSelectionCaret TelescopeSelection
highlight default link TelescopeMultiSelection Type

" "Normal" in the floating windows created by telescope.
highlight default link TelescopeNormal Normal

" Border highlight groups.
"   Use TelescopeBorder to override the default.
"   Otherwise set them specifically
highlight default link TelescopeBorder TelescopeNormal
highlight default link TelescopePromptBorder TelescopeBorder
highlight default link TelescopeResultsBorder TelescopeBorder
highlight default link TelescopePreviewBorder TelescopeBorder

" Used for highlighting characters that you match.
highlight default link TelescopeMatching Special

" Used for the prompt prefix
highlight default link TelescopePromptPrefix Identifier

" Used for highlighting the matched line inside Previewer. Works only for (vim_buffer_ previewer)
highlight default link TelescopePreviewLine Visual
highlight default link TelescopePreviewMatch Search

" Used for Picker specific Results highlighting
highlight default link TelescopeResultsClass Function
highlight default link TelescopeResultsConstant Constant
highlight default link TelescopeResultsField Function
highlight default link TelescopeResultsFunction Function
highlight default link TelescopeResultsMethod Method
highlight default link TelescopeResultsOperator Operator
highlight default link TelescopeResultsStruct Struct
highlight default link TelescopeResultsVariable SpecialChar

highlight default link TelescopeResultsLineNr LineNr
highlight default link TelescopeResultsIdentifier Identifier
highlight default link TelescopeResultsNumber Number
highlight default link TelescopeResultsComment Comment
highlight default link TelescopeResultsSpecialComment SpecialComment

" Used for git status Results highlighting
highlight default link TelescopeResultsDiffChange DiffChange
highlight default link TelescopeResultsDiffAdd DiffAdd
highlight default link TelescopeResultsDiffDelete DiffDelete

" This is like "<C-R>" in your terminal.
"   To use it, do `cmap <C-R> <Plug>(TelescopeFuzzyCommandSearch)
cnoremap <silent> <Plug>(TelescopeFuzzyCommandSearch) <C-\>e
      \ "lua require('telescope.builtin').command_history {
        \ default_text = [=[" . escape(getcmdline(), '"') . "]=]
        \ }"<CR><CR>

" Telescope builtin lists
function! s:telescope_complete(...)
  let l:builtin_list = luaeval('vim.tbl_keys(require("telescope.builtin"))')
  let l:extensions_list = luaeval('vim.tbl_keys(require("telescope._extensions").manager)')
  return join(extend(l:builtin_list,l:extensions_list),"\n")
endfunction

" TODO: If the lua datatype contains complex type,It will cause convert to
" viml datatype failed. So current doesn't support config telescope.themes
function! s:load_command(builtin,...) abort
  let opts = {}
  let type = ''

  " range command args
  " if arg in lua code is table type,we split command string by `,` to vimscript
  " list type.
  for arg in a:000
    if stridx(arg,'=') < 0
      let type = arg
      continue
    endif

    let opt = split(arg,'=')
    if opt[0] == 'find_command' || opt[0] == 'vimgrep_arguments'
      let opts[opt[0]] = split(opt[1],',')
    else
      let opts[opt[0]] = opt[1]
    endif
  endfor

  let telescope = v:lua.require('telescope.builtin')
  let extensions = v:lua.require('telescope._extensions').manager
  if has_key(telescope,a:builtin)
    call telescope[a:builtin](opts)
    return
  endif

  if has_key(extensions,a:builtin)
    if has_key(extensions[a:builtin],a:builtin)
      call extensions[a:builtin][a:builtin](opts)
      return
    endif

    if has_key(extensions[a:builtin],type)
      call extensions[a:builtin][type](opts)
    endif
  endif

endfunction

" Telescope Commands with complete
command! -nargs=+ -complete=custom,s:telescope_complete Telescope          call s:load_command(<f-args>)
