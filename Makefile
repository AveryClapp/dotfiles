.PHONY: install agent-install sync agent-sync update doctor agent-doctor tools hooks lint check help

help:
	@echo "Usage:"
	@echo "  make install   Run the full setup script"
	@echo "  make agent-install  Install the CLI agent profile"
	@echo "  make sync      Sync repo config to this machine"
	@echo "  make agent-sync     Sync agent config without installing packages"
	@echo "  make update    Pull latest changes and sync nvim plugins"
	@echo "  make doctor    Diagnose config drift and shell/git issues"
	@echo "  make tools     Install pinned project tools with mise"
	@echo "  make hooks     Install the staged-secret pre-commit hook"
	@echo "  make lint      Check bash syntax and lua formatting"
	@echo "  make check     Validate all config files parse correctly"

install:
	@chmod +x setup_config.sh && ./setup_config.sh $(ARGS)

agent-install:
	@chmod +x setup_config.sh && ./setup_config.sh --profile agent $(ARGS)

sync:
	@bash update.sh $(ARGS)

agent-sync:
	@bash update.sh --profile agent $(ARGS)

update:
	@git pull
	@bash update.sh $(ARGS)
	@nvim --headless "+Lazy! sync" +qa 2>/dev/null && echo "Nvim plugins updated" || echo "Open nvim and run :Lazy sync manually"
	@[ -x ~/.config/emacs/bin/doom ] && ~/.config/emacs/bin/doom sync && echo "Doom packages synced" || echo "Doom not installed; skipping doom sync"

doctor:
	@bash bin/dotfiles-doctor

agent-doctor:
	@bash bin/agent-doctor

tools:
	@mise install

hooks:
	@just hooks

lint:
	@command -v just >/dev/null 2>&1 || { echo "just is required; run 'mise install'" >&2; exit 1; }
	@just lint

check:
	@command -v just >/dev/null 2>&1 || { echo "just is required; run 'mise install'" >&2; exit 1; }
	@just check
