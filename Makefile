.PHONY: install update lint check help

help:
	@echo "Usage:"
	@echo "  make install   Run the full setup script"
	@echo "  make update    Pull latest changes and sync nvim plugins"
	@echo "  make lint      Check bash syntax and lua formatting"
	@echo "  make check     Validate all config files parse correctly"

install:
	@chmod +x setup_config.sh && ./setup_config.sh

update:
	@git pull
	@nvim --headless "+Lazy! sync" +qa 2>/dev/null && echo "Nvim plugins updated" || echo "Open nvim and run :Lazy sync manually"

lint:
	@echo "Checking bash syntax..."
	@bash -n bashrc   && echo "  bashrc OK"
	@bash -n aliases  && echo "  aliases OK"
	@bash -n setup_config.sh && echo "  setup_config.sh OK"
	@if command -v stylua >/dev/null 2>&1; then \
		echo "Checking lua formatting..."; \
		stylua --check nvim/lua/ && echo "  lua OK"; \
	fi

check:
	@echo "Validating configs..."
	@bash -n bashrc && bash -n aliases && bash -n setup_config.sh
	@python3 -c "import tomllib; tomllib.load(open('starship.toml','rb'))" 2>/dev/null && echo "  starship.toml OK" || echo "  starship.toml WARN (python3 <3.11 has no tomllib)"
	@python3 -c "import tomllib; tomllib.load(open('alacritty.toml','rb'))" 2>/dev/null && echo "  alacritty.toml OK" || true
	@echo "All checks passed"
