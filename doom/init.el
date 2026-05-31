;;; init.el -*- lexical-binding: t; -*-
;; Module flags = your nvim "layers". Run `doom sync` after any change here.
;; Mirrors the capabilities of ../nvim. See README.md for the full nvim->emacs map.

(doom! :input

       :completion
       (corfu +orderless +icons)     ; nvim-cmp analog (in-buffer completion)
       (vertico +icons)              ; Telescope analog (minibuffer + consult/embark/wgrep)

       :ui
       doom
       doom-dashboard                ; alpha-nvim analog
       hl-todo                       ; todo-comments analog
       indent-guides                 ; indent-blankline analog
       modeline                      ; lualine analog
       ophints
       (popup +defaults)
       vc-gutter                     ; gitsigns analog (diff-hl)
       vi-tilde-fringe
       workspaces                    ; persistence.nvim / session analog
       zen                           ; zen-mode analog

       :editor
       (evil +everywhere)            ; the whole reason this feels like nvim
       file-templates
       fold
       (format +onsave)              ; conform.nvim / format-on-save analog
       multiple-cursors
       snippets                      ; LuaSnip + friendly-snippets analog (yasnippet)
       word-wrap

       :emacs
       (dired +dirvish +icons)       ; oil.nvim analog (editable filesystem buffer)
       electric
       ibuffer
       undo                          ; persistent undo (undofile analog)
       vc

       :term
       vterm                         ; toggleterm analog

       :checkers
       (syntax +childframe)          ; trouble/diagnostics analog (flycheck)

       :tools
       (debugger +lsp)               ; nvim-dap analog (dap-mode)
       direnv                        ; matches your shell direnv
       (eval +overlay)
       (lookup +dictionary +docsets) ; telescope LSP refs/defs analog
       lsp                           ; nvim LSP analog (lsp-mode)
       magit                         ; Neogit analog (Magit is the original)
       make                          ; overseer/compile analog
       tree-sitter                   ; treesitter + textobjects analog

       :os
       (:if (featurep :system 'macos) macos)

       :lang
       (cc +lsp +tree-sitter)        ; clangd + dap + cmake
       (rust +lsp +tree-sitter)      ; rustaceanvim analog (rustic)
       (python +lsp +tree-sitter +pyright)
       (ocaml +lsp)                  ; matches your recent ocaml nvim work
       (lua +lsp)                    ; lua_ls
       emacs-lisp
       (sh +lsp)
       (json)
       (yaml)
       data
       markdown

       :config
       (default +bindings +smartparens))
