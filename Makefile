SHELL := /bin/bash
.DEFAULT_GOAL := all

BUILD_DIR ?= build
CMAKE_BUILD_DIR ?= $(BUILD_DIR)/cmake
NPM ?= npm
DOTNET ?= dotnet
PORT_C ?= 5092
PORT_FSHARP ?= 5093
PORT_HASKELL ?= 5094

.PHONY: all help build build-native build-c-browser build-fsharp-browser \
	build-haskell-browser test test-native test-parity parity-deps \
	serve serve-c serve-fsharp serve-haskell stop stop-c stop-fsharp \
	stop-haskell status

all: build

help:
	@echo 'make build          Build C core and all three browser demos'
	@echo 'make test           Run native C tests and browser parity checks'
	@echo 'make test-parity    Launch all demos in temporary servers and compare them in a browser'
	@echo 'make parity-deps    Install the Playwright dependency for browser parity checks'
	@echo 'make serve          Build and supervise all three managed demo servers'
	@echo 'make stop           Stop all servers started by make serve*'
	@echo 'make status         Show managed server status'
	@echo 'make serve-c / serve-fsharp / serve-haskell    Start one managed server'
	@echo 'make stop-c / stop-fsharp / stop-haskell       Stop one managed server'

build: build-native build-c-browser build-fsharp-browser build-haskell-browser

build-native:
	cmake -S . -B $(CMAKE_BUILD_DIR)
	cmake --build $(CMAKE_BUILD_DIR)

build-c-browser:
	bash examples/c/browser/build.sh

build-fsharp-browser:
	$(DOTNET) build examples/fsharp/browser/ElmishClay.Browser.fsproj

build-haskell-browser:
	bash examples/haskell/browser/build.sh

test: test-native test-parity

test-native: build-native
	ctest --test-dir $(CMAKE_BUILD_DIR) --output-on-failure

parity-deps:
	$(NPM) install --prefix examples/browser

test-parity: build-c-browser build-fsharp-browser build-haskell-browser parity-deps
	bash examples/browser/run-parity.sh

serve: build-c-browser build-fsharp-browser build-haskell-browser
	PORT_C=$(PORT_C) PORT_FSHARP=$(PORT_FSHARP) PORT_HASKELL=$(PORT_HASKELL) bash examples/browser/servers.sh start all

serve-c: build-c-browser
	PORT_C=$(PORT_C) bash examples/browser/servers.sh start c

serve-fsharp: build-fsharp-browser
	PORT_FSHARP=$(PORT_FSHARP) bash examples/browser/servers.sh start fsharp

serve-haskell: build-haskell-browser
	PORT_HASKELL=$(PORT_HASKELL) bash examples/browser/servers.sh start haskell

stop:
	bash examples/browser/servers.sh stop all

stop-c:
	PORT_C=$(PORT_C) bash examples/browser/servers.sh stop c

stop-fsharp:
	PORT_FSHARP=$(PORT_FSHARP) bash examples/browser/servers.sh stop fsharp

stop-haskell:
	PORT_HASKELL=$(PORT_HASKELL) bash examples/browser/servers.sh stop haskell

status:
	PORT_C=$(PORT_C) PORT_FSHARP=$(PORT_FSHARP) PORT_HASKELL=$(PORT_HASKELL) bash examples/browser/servers.sh status all
