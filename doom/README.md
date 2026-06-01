# Doom Emacs config

A port of `../nvim` to Doom Emacs at **exact-keybinding parity**. Same Space leader,
same `gd`/`gr`, same `<leader>ff`, Kanagawa Wave theme, C++/Rust/Python/OCaml/Lua.

This is a *parallel* editor, not a replacement — your shell/tmux/alacritty layer is
unchanged and Emacs runs inside it.

## Install

```bash
# 1. Install Emacs (use a GUI build for fonts/ligatures) + Doom
brew install --cask emacs           # or emacs-plus with native-comp
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# 2. Point Doom at this config
ln -sfn "$PWD/doom" ~/.config/doom

# 3. Build it
~/.config/emacs/bin/doom sync
```

Then `emacs`. First launch compiles packages (a few minutes). `doom sync` after any
edit to `init.el`/`packages.el`. `doom doctor` diagnoses problems.

## Files

| File | Role | nvim analog |
|------|------|-------------|
| `init.el` | enabled modules ("layers") | which plugin files exist |
| `packages.el` | extra packages | lazy.nvim specs |
| `config.el` | options, theme, keybinds | `init.lua` + per-plugin config |
| `competitive.el` | competitive-programming listener | `comp-prog.lua` |

## What mapped cleanly (Tier 1)

Magit (Neogit's original), evil-surround, harpoon.el (`SPC a/h/1-4`), vertico+consult
(Telescope `ff/fg/fr/fb`), dirvish+wdired (Oil), `.dir-locals.el` (`.nvim.lua`),
vundo (undotree), which-key, hl-todo, indent guides, zen, `ff-find-other-file`
(`SPC hh`), vterm (toggleterm), native evil macros (`qa`/`@a`), direnv, persistent undo,
format-on-save, LSP for all five languages, corfu+yasnippet (cmp+LuaSnip).

## What's approximate (Tier 2) — works, slightly different

| Feature | Port | Difference |
|---------|------|------------|
| Flash `s` | avy `avy-goto-char-timer` | label jump only |
| Flash `SPC S` (TS node) | `combobulate-avy` | jumps treesit nodes, not by-type menu |
| mini.ai/treesitter `af/if/ac/ic` | evil-textobj-tree-sitter | targets.vim **next/last** (`cin,`) not ported |
| Aerial `SPC o`, `[s`/`]s` | consult-imenu, `treesit-{beg,end}-of-defun` | no live sidebar |
| grug-far `SPC sr` | consult-ripgrep → `embark-export` → wgrep | edit results buffer, then `C-c C-c` |
| inc-rename `SPC rn` | `lsp-rename` | prompt-based, no live keystroke preview |
| treesitter-context | topsy sticky header | function header only |
| Trouble `SPC x*` | consult-flycheck / flycheck list | no quickfix/loclist split (both → error list) |
| Sessions `SPC q*` | `doom/quickload-session` + workspaces | per-workspace, not strictly per-directory |
| DAP / CMake / Rust runnables | dap-mode, compile wrappers, rustic | more manual than your nvim setup |
| neotest `SPC tt/tf/ts` | rustic-cargo-test / ctest dispatch | no unified summary panel |
| neogen doxygen `SPC nc` | gendoxy `gendoxy-tag` | signature-aware @brief/@param/@return; C-focused, C++ ok |

## What can't be done cleanly (Tier 3) — FLAGGED

1. **SSR — structural search/replace (`SPC sR`)** — no treesitter SSR in Emacs.
   Bound to a message. Closest options: `combobulate` (structural *editing*) or the
   external `comby` tool shelled out.
2. **treesj split/join (`gS`/`gJ`/`gM`)** — no clean toggle, and (verified 2026) no
   packaged equivalent exists. The closest is meain's custom `tree-surgeon-split-join`
   elisp (Go/Rust/JSON only, lives in his dotfiles, not on MELPA). Not worth vendoring
   fragile code. **Not bound.**
3. **nvim-recorder extras** — native evil macros cover record/play, but named slots,
   `##` breakpoints, and edit-as-text are not ported.
4. **Competitive submit (`SPC tS`)** — `cp-submit` only opens the problem URL.
   Programmatic Codeforces submission needs auth/automation, out of scope for a config.
5. **nvim-notify popups** — Emacs uses the minibuffer/echo area. Cosmetic only.

## Binding overrides you should know about

Exact parity means some Doom defaults are sacrificed. The notable ones:

| Key | Now does (yours) | Doom default it replaced |
|-----|------------------|--------------------------|
| `J` / `K` | 10 lines down/up | join lines / lookup-doc |
| `H` / `L` | line start / end | screen top / bottom |
| `s` | avy jump | evil-snipe / substitute char |
| `SPC b` | toggle breakpoint | **buffer menu** (use `SPC f b` / `consult-buffer`) |
| `SPC o` | outline | "open" prefix |
| `SPC 1-4` | harpoon jump | workspace switch (use `SPC TAB`) |
| `SPC h` | harpoon menu | **help prefix** (Emacs help still on `C-h`) |
| `SPC x` | diagnostics prefix | org-capture |

**Header/source switch moved `SPC h h` → `SPC c h`.** Emacs can't bind a command and a
prefix on the same key, and `SPC h` is the harpoon menu (a command). Vim allows this via
key-timeout; Emacs does not. This is the one keybinding that couldn't keep exact parity.

## Competitive programming

`SPC t c` starts a one-shot listener on port **27121** — set that as the port in the
Competitive Companion browser extension. Click its button on a problem page and samples
land in `./tests/`. `SPC t r` compiles (`.cpp`/`.rs`/`.py`) and diffs against every
sample, printing PASS/FAIL in `*cp-run*`. `SPC t a` adds a case, `SPC t e` edits them.

## Not ported by design (lives in your shell, not Emacs)

eza/bat/zoxide/fzf, tmux sessionizer + worktree switcher, alacritty. Emacs runs *inside*
that environment. If you ever want them in-editor: `projectile` + `persp-mode` cover
project/session switching and `magit-worktree` covers worktrees.
