;;; config.el -*- lexical-binding: t; -*-
;; Ports ../nvim (init.lua + lua/custom/plugins/* + GUIDE.md) to Doom.
;; Goal: exact-parity keybindings. Where Doom's default binding differs, it is
;; OVERRIDDEN. Overrides that sacrifice a Doom default are noted inline and in README.

;;; ---------------------------------------------------------------------------
;;; Identity / theme / fonts  (init.lua options + colorscheme.lua)
;;; ---------------------------------------------------------------------------
(setq user-full-name "Avery Clapp"
      user-mail-address "avery.clapp@gmail.com")

(setq doom-theme 'kanagawa-wave)                         ; Kanagawa Wave
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14))
(setq display-line-numbers-type 'relative)               ; number + relativenumber

;;; ---------------------------------------------------------------------------
;;; Editor options  (init.lua: tabstop/shiftwidth/scrolloff/splits/case)
;;; ---------------------------------------------------------------------------
(setq-default tab-width 4 indent-tabs-mode nil)          ; tabstop=4, expandtab
(setq scroll-margin 5                                    ; scrolloff=5
      evil-split-window-below t                          ; splitbelow
      evil-vsplit-window-right t)                        ; splitright

(after! evil
  (setq evil-ex-search-case 'smart                       ; ignorecase + smartcase
        evil-want-Y-yank-to-eol t))

;; highlight-on-yank (init.lua TextYankPost autocmd)
(after! evil-goggles
  (setq evil-goggles-duration 0.15))
(add-hook 'doom-first-input-hook #'evil-goggles-mode)

;; sticky function/class header on scroll (treesitter-context.nvim)
(add-hook 'prog-mode-hook #'topsy-mode)

;;; ---------------------------------------------------------------------------
;;; Global motion remaps  (init.lua keymaps)
;;; ---------------------------------------------------------------------------
;; NOTE: these override evil defaults -- J(join), K(lookup), H/L(screen top/bottom).
;; That mirrors your nvim config, which also discards them.
(map! :n "J" (cmd! (evil-next-line 10))                  ; 10j
      :n "K" (cmd! (evil-previous-line 10))              ; 10k
      :n "H" #'evil-beginning-of-line                    ; 0
      :n "L" #'evil-end-of-line                          ; $
      ;; flash.nvim `s` -> avy label jump. Overrides evil-snipe/evil-substitute `s`.
      :nvm "s" #'avy-goto-char-timer)

;;; ---------------------------------------------------------------------------
;;; LSP keys  (init.lua LspAttach + GUIDE "LSP")
;;; ---------------------------------------------------------------------------
(defun +my/diagnostic-at-point ()
  "Float the diagnostic on the current line (nvim <leader>e)."
  (interactive)
  (if (fboundp 'flycheck-explain-error-at-point)
      (flycheck-explain-error-at-point)
    (flycheck-display-error-at-point)))

(map! :n "gd" #'+lookup/definition                       ; go to definition
      :n "gr" #'+lookup/references                       ; references (vertico list)
      :n "gh" #'+lookup/documentation                    ; hover docs (Doom's K)
      :n "]d" #'flycheck-next-error                      ; next diagnostic
      :n "[d" #'flycheck-previous-error)                 ; prev diagnostic

;;; ---------------------------------------------------------------------------
;;; Leader map  (GUIDE.md, exact parity)
;;; ---------------------------------------------------------------------------
(map! :leader
      ;; -- Telescope ----------------------------------------------------------
      :desc "Find files"        "f f" #'projectile-find-file
      :desc "Live grep"         "f g" #'+default/search-project
      :desc "Recent files"      "f r" #'consult-recent-file
      :desc "Buffers"           "f b" #'consult-buffer

      ;; -- LSP actions --------------------------------------------------------
      :desc "Code action"       "c a" #'lsp-execute-code-action   ; matches Doom default
      :desc "Rename"            "r n" #'lsp-rename                ; inc-rename (prompt, not live)
      :desc "Reload config"     "r l" #'doom/reload              ; SPC h r r is harpoon, so reload lives here
      :desc "Diagnostic float"  "e"   #'+my/diagnostic-at-point

      ;; -- Flash treesitter node jump (SPC S) --------------------------------
      :desc "TS node jump"      "S"   (cmd! (if (fboundp 'combobulate-avy)
                                                (combobulate-avy)
                                              (avy-goto-word-1)))

      ;; -- Harpoon (overrides Doom workspace-switch on SPC 1-4) --------------
      :desc "Harpoon add"       "a"   #'harpoon-add-file
      :desc "Harpoon menu"      "h"   #'harpoon-toggle-quick-menu
      :desc "Harpoon 1"         "1"   #'harpoon-go-to-1
      :desc "Harpoon 2"         "2"   #'harpoon-go-to-2
      :desc "Harpoon 3"         "3"   #'harpoon-go-to-3
      :desc "Harpoon 4"         "4"   #'harpoon-go-to-4

      ;; -- Outline (aerial). Overrides Doom's SPC o "open" prefix -----------
      :desc "Outline"           "o"   #'consult-imenu

      ;; -- Search & replace ---------------------------------------------------
      ;; grug-far: search project, then `embark-export` (C-c C-l) -> wgrep to replace.
      :desc "Search/replace"    "s r" #'+default/search-project
      :desc "Search word"       "s w" #'+default/search-project-for-symbol-at-point
      :desc "SSR (see README)"  "s R" (cmd! (message "SSR not ported; use combobulate or comby (README)"))

      ;; -- Trouble / diagnostics  (unbind Doom's SPC x org-capture, then prefix)
      "x" nil
      (:prefix ("x" . "diagnostics")
       :desc "Diagnostics (proj)" "x" #'consult-flycheck
       :desc "Diagnostics (buf)"  "X" #'flycheck-list-errors
       :desc "Symbols"            "s" #'consult-imenu
       :desc "References"         "r" #'+lookup/references
       :desc "Quickfix"           "q" #'flycheck-list-errors
       :desc "Location list"      "l" #'flycheck-list-errors)

      ;; -- Git (Neogit -> Magit) ---------------------------------------------
      :desc "Magit status"      "g g" #'magit-status              ; matches Doom default
      :desc "Diff file"         "g d" #'magit-diff-buffer-file
      :desc "File history"      "g h" #'magit-log-buffer-file
      :desc "Preview hunk"      "g p" #'diff-hl-show-hunk

      ;; -- C++ : CMake (custom compile wrappers) -----------------------------
      :desc "CMake generate"    "c g" #'+my/cmake-generate
      :desc "CMake build"       "c b" #'+my/cmake-build
      :desc "CMake run"         "c r" #'+my/cmake-run
      :desc "CMake debug"       "c d" #'+my/cmake-debug
      :desc "CMake tests"       "c t" #'+my/cmake-test

      ;; -- C++ : misc --------------------------------------------------------
      ;; header-switch moved from `h h` -> `c h`: SPC h is harpoon menu (a command),
      ;; and Emacs can't bind a command and a prefix on the same key (README).
      :desc "Header/source"     "c h" #'ff-find-other-file        ; native
      :desc "Doxygen (basic)"   "n c" #'+my/doxygen-skeleton

      ;; -- Rust (rustic) -----------------------------------------------------
      :desc "Cargo run"         "r r" #'rustic-cargo-run
      :desc "Cargo debug"       "r d" #'dap-debug
      :desc "Explain error"     "r e" #'+my/diagnostic-at-point

      ;; -- Debug (nvim-dap). NOTE: overrides Doom's SPC b buffer prefix ------
      :desc "Toggle breakpoint" "b"   #'dap-breakpoint-toggle
      :desc "Cond. breakpoint"  "B"   #'dap-breakpoint-condition
      :desc "Toggle DAP UI"     "d u" #'dap-hydra

      ;; -- Testing (neotest -> per-language) ---------------------------------
      :desc "Test nearest"      "t t" #'+my/test-nearest
      :desc "Test file"         "t f" #'+my/test-file
      :desc "Test summary"      "t s" #'+my/test-summary

      ;; -- Competitive programming (custom, competitive.el) ------------------
      :desc "CP receive"        "t c" #'cp-receive
      :desc "CP run tests"      "t r" #'cp-run
      :desc "CP add test"       "t a" #'cp-add-test
      :desc "CP edit test"      "t e" #'cp-edit-tests
      :desc "CP submit"         "t S" #'cp-submit

      ;; -- Utilities ---------------------------------------------------------
      :desc "Undotree"          "U"   #'vundo
      :desc "Zen mode"          "z"   #'+zen/toggle
      :desc "Toggle terminal"   "T"   #'+vterm/toggle

      ;; -- Sessions (persistence.nvim) ---------------------------------------
      :desc "Restore session"   "q s" #'doom/quickload-session
      :desc "Restore last"      "q l" #'doom/quickload-session
      :desc "Disable autosave"  "q d" (cmd! (setq +my/session-autosave nil)
                                            (message "Session autosave disabled")))

;; aerial symbol nav  ([s / ]s)
(map! :n "]s" #'+lookup/definition   ; placeholder; see treesit nav below
      :n "[s" #'+lookup/definition)
(after! treesit
  (map! :n "]s" #'treesit-end-of-defun
        :n "[s" #'treesit-beginning-of-defun))

;;; ---------------------------------------------------------------------------
;;; DAP function keys  (GUIDE "C++ Debug")
;;; ---------------------------------------------------------------------------
(map! :n "<f5>"  (cmd! (if (and (featurep 'dap-mode) (dap--cur-session))
                           (dap-continue)
                         (call-interactively #'dap-debug)))
      :n "<f10>" #'dap-next
      :n "<f11>" #'dap-step-in
      :n "<f12>" #'dap-step-out)

;;; ---------------------------------------------------------------------------
;;; CMake helpers  (overseer/cmake-tools analog -- shells out to cmake)
;;; ---------------------------------------------------------------------------
(defvar +my/cmake-build-dir "build")

(defun +my/cmake--root ()
  (or (projectile-project-root) default-directory))

(defun +my/cmake-generate ()
  (interactive)
  (let ((default-directory (+my/cmake--root)))
    (compile (format "cmake -S . -B %s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON" +my/cmake-build-dir))))

(defun +my/cmake-build ()
  (interactive)
  (let ((default-directory (+my/cmake--root)))
    (compile (format "cmake --build %s" +my/cmake-build-dir))))

(defun +my/cmake-run ()
  (interactive)
  (let ((default-directory (+my/cmake--root)))
    (compile (format "cmake --build %s && ./%s/$(basename $(pwd))"
                     +my/cmake-build-dir +my/cmake-build-dir))))

(defun +my/cmake-test ()
  (interactive)
  (let ((default-directory (+my/cmake--root)))
    (compile (format "ctest --test-dir %s --output-on-failure" +my/cmake-build-dir))))

(defun +my/cmake-debug ()
  (interactive)
  (call-interactively #'dap-debug))

(defun +my/doxygen-skeleton ()
  "Insert a minimal doxygen block. (Full neogen signature-aware gen not ported.)"
  (interactive)
  (insert "/**\n * @brief \n *\n */\n"))

;;; ---------------------------------------------------------------------------
;;; Test dispatch  (neotest analog -- no unified panel; per-language)
;;; ---------------------------------------------------------------------------
(defun +my/test-nearest ()
  (interactive)
  (pcase major-mode
    ((or 'rustic-mode 'rust-mode 'rust-ts-mode) (rustic-cargo-current-test))
    (_ (+my/test-file))))

(defun +my/test-file ()
  (interactive)
  (pcase major-mode
    ((or 'rustic-mode 'rust-mode 'rust-ts-mode) (rustic-cargo-test))
    ((or 'c++-mode 'c-mode 'c++-ts-mode 'c-ts-mode) (+my/cmake-test))
    (_ (message "No test runner for %s" major-mode))))

(defun +my/test-summary ()
  (interactive)
  (message "No unified test panel (neotest). See *cargo-test*/*compilation* buffers."))

;;; ---------------------------------------------------------------------------
;;; LSP tuning  (illuminate / fidget come free with lsp-mode)
;;; ---------------------------------------------------------------------------
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting t                 ; vim-illuminate
        lsp-headerline-breadcrumb-enable nil             ; topsy handles this
        ;; clangd args matching your nvim clangd setup
        lsp-clients-clangd-args
        '("--background-index" "--clang-tidy" "--header-insertion=never")))

;; format-on-save already handled by (:editor format +onsave)

;;; ---------------------------------------------------------------------------
;;; Competitive programming listener
;;; ---------------------------------------------------------------------------
(load! "competitive")
