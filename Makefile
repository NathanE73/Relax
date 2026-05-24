BINARIES_FOLDER=bin
TEMPORARY_FOLDER=tmp

SWIFT_BUILD_FLAGS=--arch arm64 --arch x86_64 --enable-dead-strip --configuration release

BUILD_PATH=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)

RELAX_EXECUTABLE=relax

VERSION_FILE=.version
VERSION_STRING=$(shell cat "$(VERSION_FILE)")

default:

bootstrap:
	mint bootstrap

clean:
	swift package clean

build:
	swift build $(SWIFT_BUILD_FLAGS)

test:
	swift test --parallel

install: build
	install -d "$(BINARIES_FOLDER)"
	install "$(BUILD_PATH)/$(RELAX_EXECUTABLE)" "$(BINARIES_FOLDER)"

release: clean install

get-version:
	@echo $(VERSION_STRING)

set-version:
	$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
	@echo "$(NEW_VERSION)" > "$(VERSION_FILE)"
	@sed -i '' '/        / s/"[^"][^"]*"/"$(NEW_VERSION)"/' Sources/RelaxFramework/Main/RelaxVersion.swift

format:
	mint run swiftformat .

lint:
	mint run swiftlint

%:
	@:
