#!/usr/bin/env make -f

TOPDIR := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SELF := $(abspath $(lastword $(MAKEFILE_LIST)))

help: ## Show help message (list targets)
	@awk 'BEGIN {FS = ":.*##"; printf "\nTargets:\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-17s\033[0m %s\n", $$1, $$2}' $(SELF)

.PHONY: lint
lint: ## Run shellcheck linter
	shellcheck *.sh

.PHONY: install-binary
install-binary: ## Install watchdog script to /usr/bin
	install -m 755 rpi_network_watchdog.sh /usr/bin/

.PHONY: install-service
install-service: ## Install watchdog service to /etc/systemd/system
	install -m 644 rpi_network_watchdog.service /etc/systemd/system/
	systemctl daemon-reload

.PHONY: install-default
install-default: ## Install default watchdog config to /etc/default
	[ -e /etc/default/rpi_network_watchdog ] && \
	( \
		echo "/etc/default/rpi_network_watchdog already exists; diff follows:" ; \
		diff -u rpi_network_watchdog.default /etc/default/rpi_network_watchdog ; \
		exit 2 ; \
	)
	install -m 644 rpi_network_watchdog.default /etc/default/rpi_network_watchdog

.PHONY: install
install: install-binary install-service install-default ## Install script, service, and default config

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
