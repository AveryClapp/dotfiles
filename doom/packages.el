;; -*- no-byte-compile: t; -*-
;;; packages.el
;; Extra packages beyond what the modules in init.el already pull in.
;; (consult, embark, wgrep, evil-surround, evil-textobj-tree-sitter,
;;  yasnippet, dap-mode, magit, etc. come free with the modules above.)

(package! kanagawa-themes)     ; Kanagawa Wave theme (provides `kanagawa-wave`)
(package! harpoon)             ; ThePrimeagen harpoon, exact same model
(package! vundo)               ; undotree analog (visual undo tree)
(package! avy)                 ; flash.nvim analog (label jump); usually bundled, pinned for safety
(package! evil-goggles)        ; "highlight on yank" + visual op feedback
(package! topsy)               ; treesitter-context analog (sticky function header)
(package! consult-flycheck)    ; feeds diagnostics into the trouble-style list
(package! cmake-mode)          ; CMakeLists syntax
(package! gendoxy              ; neogen analog: signature-aware doxygen generation (SPC n c)
  :recipe (:host github :repo "mp81ss/gendoxy"))
(package! combobulate           ; treesitter structural nav (approximates treesj/SSR jump)
  :recipe (:host github :repo "mickeynp/combobulate"))
