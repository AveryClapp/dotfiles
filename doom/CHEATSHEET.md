# Doom Cheatsheet

Everything to get started and fiddle. Leader is `SPC` (the spacebar). Your Neovim
evil motions/operators/text-objects/macros/`:w` all work unchanged — this is the Doom
layer on top. `⚠` marks a binding that deviates from your nvim config.

---

# PART 1 — Getting started

## Reading the key notation

| Written | Means | On your Mac |
|---|---|---|
| `SPC` | the **spacebar** | space |
| `RET` | Return / Enter | ⏎ |
| `TAB` | Tab | ⇥ |
| `C-x` | hold **Control**, tap `x` | ⌃x |
| `M-x` | hold **Meta** = **Option**, tap `x` | ⌥x |
| `S-` | Shift | ⇧ |
| `gd` | press `g` then `d` (Vim-style, no modifier) | |
| `C-c C-c` | Ctrl-c, then Ctrl-c (a sequence) | |

`SPC f f` = tap **space, f, f**. That's the leader, same as `<leader>` in your nvim.

## Launching (the daemon is always running)

A background Emacs daemon starts at login (launchd). You don't open the app — you
attach frames to the warm daemon, so it's instant and LSP servers stay loaded:

```bash
e                 # GUI frame (returns to shell)
e file.rs         # GUI frame opening a file
et                # terminal frame in this pane (blocks like an editor)
prefix + e        # (in tmux) terminal Emacs in a new window at cwd
ekill             # stop the daemon (launchd restarts it)
```

## The 3 keys that keep you safe

| Key | Action |
|-----|--------|
| `SPC` (then **wait**) | which-key pops up showing every next key. Your map of the editor |
| `C-g` | **Cancel / escape anything.** Panic button — mash it when stuck |
| `Esc` | back to Normal mode (same as Vim) |

## First 2 minutes

1. `e` → a frame opens (Doom dashboard). You're in **Normal mode** — Vim keys live.
2. Tap **space**, wait → the which-key menu appears. `C-g` to dismiss.
3. `SPC p p` → pick a project (scans your `~/Documents/Coding` repos), `RET`.
4. `SPC f f` → fuzzy-find a file, `RET`.
5. Edit (it's Vim: `i` insert, `Esc` normal). Save with `:w`.
6. `SPC g g` → Magit. Spend 10 minutes here; it's the best part.

## Getting help (help is on `C-h`, ⚠ NOT `SPC h`)

| Key | Action |
|-----|--------|
| `C-h k` then a key | "What does this key do?" |
| `C-h f` | Describe a function (search by name) |
| `C-h v` | Describe a variable |
| `M-x` (or `SPC :`) | Run any command by name (fuzzy) |
| `SPC :` `view-echo-area-messages` | Open `*Messages*` (errors/log live here) |

## Mental model

- **Buffer** = anything open in memory (files, but also Magit, `*Messages*`, a terminal). Closing a split does **not** kill the buffer.
- **Window** = a split. **Frame** = an OS window.
- Switch buffers: `SPC ,` or `SPC f b`.

---

# PART 2 — Keybinding reference

## Files, project, search

| Key | Action |
|-----|--------|
| `SPC p p` | Switch project |
| `SPC SPC` / `SPC f f` | Find file in project |
| `SPC f g` | Live grep across project |
| `SPC f r` | Recent files |
| `SPC f b` / `SPC ,` | Switch buffer |
| `SPC f s` / `:w` | Save |
| `SPC s r` | Search → replace (`embark-export` `C-c C-l` → edit in wgrep → `C-c C-c`) |
| `SPC s w` | Search word under cursor |
| `SPC s R` | ⚠ SSR — not ported (message; see README) |

## Navigation

| Key | Action |
|-----|--------|
| `s<chars>` | Flash/avy label jump (⚠ overrides evil-snipe) |
| `SPC S` | Jump to treesitter node |
| `SPC a` | Harpoon: add current file |
| `SPC h` | Harpoon: menu (⚠ overrides help — help is on `C-h`) |
| `SPC 1`–`4` | Harpoon: jump to file 1–4 (⚠ overrides workspace switch — use `SPC TAB`) |
| `SPC o` | Outline / symbol list (⚠ overrides "open" prefix) |
| `]s` / `[s` | Next / prev function |
| `J` / `K` | ⚠ Down / up 10 lines |
| `H` / `L` | ⚠ Line start / end |

## LSP (auto-attaches per language)

| Key | Action |
|-----|--------|
| `gd` | Definition |
| `gr` | References |
| `gh` | Hover docs |
| `SPC c a` | Code action |
| `SPC r n` | Rename |
| `]d` / `[d` | Next / prev diagnostic |
| `SPC e` | Diagnostic at point |
| `SPC c h` | ⚠ Header ↔ source (moved from `hh`) |
| `SPC n c` | Doxygen skeleton (basic) |

## Diagnostics list (`SPC x`)

`SPC x x` project · `x X` buffer · `x s` symbols · `x r` references · `x q`/`x l` error list

## Git — Magit (`SPC g g`)

`SPC g g` status · `g d` diff file · `g h` file history · `g p` preview hunk
**Inside Magit:** `s` stage · `u` unstage · `TAB` expand · `c c` commit (`C-c C-c` confirm) · `P p` push · `F p` pull · `b b` branch · `?` help · `q` quit

## C++ / CMake / debug

| Key | Action |
|-----|--------|
| `SPC c g` / `c b` / `c r` | CMake generate / build / run |
| `SPC c t` / `c d` | CMake tests / debug |
| `F5` · `F10` · `F11` · `F12` | Debug continue · step over · in · out |
| `SPC b` / `SPC B` | Toggle / conditional breakpoint (⚠ overrides buffer menu) |
| `SPC d u` | DAP UI |

## Rust

`SPC r r` cargo run · `r d` cargo debug · `r e` explain error

## Testing

`SPC t t` nearest · `t f` file · `t s` summary

## Competitive programming (port 27121)

`SPC t c` start listener (then click Competitive Companion) · `t r` compile + diff samples (`*cp-run*`) · `t a` add test · `t e` edit tests · `t S` submit (opens URL)

## Utilities & windows

| Key | Action |
|-----|--------|
| `SPC U` | Undo tree |
| `SPC z` | Zen mode |
| `SPC T` | Toggle terminal (vterm) |
| `SPC w` (pause) | Window/split management |
| `SPC q s` / `q l` | Restore session / last |
| `gc` / `gcc` | Comment motion / line |

---

# PART 3 — Fiddling & customizing

## The files (`~/.config/doom` → symlinked to your dotfiles repo)

| File | Holds | To apply a change |
|------|-------|-------------------|
| `config.el` | options, keybinds, theme | **reload** (instant) |
| `competitive.el` | CP listener | **reload** |
| `init.el` | which modules are on | **sync + restart daemon** |
| `packages.el` | extra packages | **sync + restart daemon** |

## Apply changes

```
Reload config.el / competitive.el:   SPC r l                (⚠ not SPC h r r — SPC h is harpoon)
After editing init.el / packages.el:  doom sync              (in a terminal: ~/.config/emacs/bin/doom sync)
Then restart the daemon:              launchctl kickstart -k gui/$(id -u)/com.averyclapp.emacs
Something broken on boot:             ~/.config/emacs/bin/doom doctor
See the error:                        SPC : view-echo-area-messages   (or open *Messages*)
```

## Common edits (in `config.el`)

**Change a setting:**
```elisp
(setq scroll-margin 8)                 ; was 5
```

**Rebind a key** (find the `map!` block and edit, or add your own):
```elisp
(map! :leader :desc "My thing" "m t" #'some-command)
(map! :n "gh" #'other-command)         ; normal-mode key
```
To find the command name for a key: `C-h k` then press the key. To find a command to
bind: `M-x` and browse, or `C-h f`.

**Add a package:** put it in `packages.el`, then `doom sync` + restart:
```elisp
;; packages.el
(package! some-package)
```
…then configure it in `config.el`:
```elisp
(use-package! some-package
  :config (setq some-package-option t))
;; or tweak one already loaded:
(after! magit (setq magit-diff-refine-hunk 'all))
```

**Toggle a language/tool:** edit `init.el`'s `(doom! ...)` block (uncomment a module or
add a `+flag`), then `doom sync` + restart.

## Discovery habits (lean on these instead of memorizing)

- `SPC` + pause → which-key shows everything. Drill in: `SPC g`, `SPC c`, `SPC t`.
- `C-h k <key>` → exactly what a key runs and where it's defined.
- `M-x` → fuzzy-run any command; great for "is there a command for…?"
- In Magit / Dired / most modes: `?` shows that mode's keys.

## Our dev loop (you + me on this config)

Edit files in `dotfiles/doom/` (they're live via the symlink). `config.el` changes →
`SPC r l`. `init.el`/`packages.el` → `doom sync` then kickstart the daemon.
When something misbehaves, tell me the key or command and I'll fix it against the repo.
