#!/usr/bin/env make -f

TOPDIR := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SELF := $(abspath $(lastword $(MAKEFILE_LIST)))

help: ## Show help message (list targets)
	@awk 'BEGIN {FS = ":.*##"; printf "\nTargets:\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-17s\033[0m %s\n", $$1, $$2}' $(SELF)

.PHONY: lint
lint: ## Run shellcheck linter
	shellcheck *.sh

.PHONY: install-binary
install-binary:
	install -m 755 rpi_network_watchdog.sh /usr/bin/

.PHONY: install-service
install-service:
	install -m 644 rpi_network_watchdog.service /etc/systemd/system/
	systemctl daemon-reload

.PHONY: install-default
install-default:
	install -m 644 rpi_network_watchdog.default /etc/default/rpi_network_watchdog

.PHONY: install
install: install-binary install-service install-default ## Install watchdog

.PHONY: enable-service
enable-service: ## Enable watchdog service
	systemctl enable rpi_network_watchdog.service

.PHONY: disable-service
disable-service: ## Disable watchdog service
	systemctl disable rpi_network_watchdog.service

.PHONY: start
start: ## Start watchdog
	systemctl start rpi_network_watchdog.service

.PHONY: stop
stop: ## Stop watchdog
	systemctl stop rpi_network_watchdog.service
