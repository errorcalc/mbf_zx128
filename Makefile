# Project name
PROJECT_NAME = tbf

# Listing the parts that should be assembled automatically
PARTS=part.box

NAME_SUFFIX = $(shell date +%Y%m%d)-$(shell git log --format="%h" -n 1)

ifeq ($(COPY_SNAPSHOT_TO),)
	COPY_SNAPSHOT_TO = C:\Temp
endif

.PHONY: all build clean clean-% help

all: build

build: build/part.intro.bin $(PARTS:%=build/%.bin.zx0) ## Default: build project
	@printf "\033[32mBuilding '$(PROJECT_NAME)'\033[0m\n"

	rm -f build/$(PROJECT_NAME)*.sna
	rm -f build/*.trd
	rm -f build/*.c
	
	sjasmplus --fullpath --color=off --inc=src/. \
		-DSNA_FILENAME=\"build/$(PROJECT_NAME)-$(NAME_SUFFIX).sna\" \
		-DTRD_FILENAME=\"build/$(PROJECT_NAME).trd\" \
		src/main.asm

	cp --force build/$(PROJECT_NAME)-$(NAME_SUFFIX).sna $(COPY_SNAPSHOT_TO)

	@printf "\033[32mDone\033[0m\n"

	$(EMULATOR_BINARY) build/$(PROJECT_NAME)-$(NAME_SUFFIX).sna

build/%.bin.zx0: build/%.bin
	@printf "\033[32mBuilding '$@'\033[0m\n"

	rm -f $@
	zx0 $(subst .zx0,,$@)
	
	@printf "\033[32mdone\033[0m\n\n"

build/%.bin: clean-%
	@printf "\033[32mCompiling '$(patsubst build/%.bin,%,$@)'\033[0m\n"

	@echo $(subst part.,,$@)
	@echo $@
	mkdir -p build

	sjasmplus --fullpath --color=off \
		-DSNA_FILENAME=\"$(patsubst %.bin,%,$@)-$(NAME_SUFFIX).sna\" \
		-DBIN_FILENAME=\"$@\" \
		src/$(patsubst build/%.bin,%,$@)/main.asm

	cp --force $(patsubst %.bin,%,$@)-$(NAME_SUFFIX).sna $(COPY_SNAPSHOT_TO)

	@printf "\033[32mdone\033[0m\n\n"

	$(EMULATOR_BINARY) $(patsubst %.bin,%,$@)-$(NAME_SUFFIX).sna

clean-%:
	rm -f build/$(subst clean-,,$@)*

clean: ## Remove all artifacts
	rm -f build/*

help: 	## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-8s\033[0m %s\n", $$1, $$2}' 
