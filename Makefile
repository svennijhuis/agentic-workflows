# Same shape as githubnext/agentics: gh aw compile is the gate. The gh-aw pin lives in .github/aw.json.
GH_AW_VERSION := $(shell jq -r '.["gh-aw"]' .github/aw.json)

.PHONY: all install compile verify help

all: compile

# Install the pinned github/gh-aw extension
install:
	gh extension install github/gh-aw --pin $(GH_AW_VERSION) || gh extension upgrade github/gh-aw --pin $(GH_AW_VERSION)

# gh aw compile --strict on workflows/ and on .github/workflows (when it holds agentic .md files)
compile:
	@have=$$(gh aw version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1); \
	  [ "$$have" = "$(GH_AW_VERSION)" ] || { echo "gh-aw is $${have:-missing}, pin is $(GH_AW_VERSION) (make install)"; exit 2; }
	gh aw compile --strict --dir workflows
	@if grep -lx -m1 -- '---' .github/workflows/*.md 2>/dev/null | grep -v README.md | grep -q .; then gh aw compile --strict; \
	  else echo "no agentic .md in .github/workflows, skipped"; fi

# compile plus the two repo checks POL25 and POL31 and their fixtures
verify:
	bash scripts/verify.sh

help:
	@echo "Targets:"
	@echo "  install  install the pinned gh-aw extension ($(GH_AW_VERSION))"
	@echo "  compile  gh aw compile --strict on workflows/ and .github/workflows"
	@echo "  verify   compile, then POL25 and POL31 on the repo and on their fixtures"
