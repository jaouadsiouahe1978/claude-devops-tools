BINARY    := devops-tools
CMD       := ./cmd/devops-tools
VERSION   := $(shell git describe --tags --always --dirty 2>/dev/null || echo "0.1.0")
COMMIT    := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE      := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS   := -ldflags "-X github.com/jaouadsiouahe1978/claude-devops-tools/internal/version.Version=$(VERSION) \
                        -X github.com/jaouadsiouahe1978/claude-devops-tools/internal/version.GitCommit=$(COMMIT) \
                        -X github.com/jaouadsiouahe1978/claude-devops-tools/internal/version.BuildDate=$(DATE)"

.PHONY: build test lint clean fmt vet

build:
	go build $(LDFLAGS) -o bin/$(BINARY) $(CMD)

test:
	go test ./...

lint: vet fmt
	@echo "lint done"

vet:
	go vet ./...

fmt:
	gofmt -l -w .

clean:
	rm -rf bin/
