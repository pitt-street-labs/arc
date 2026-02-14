# Lab Manual Build System
# Generates professional PDF manuals from Markdown using Pandoc + XeLaTeX.
#
# Usage:
#   make all          Build all defined manuals
#   make MY_MANUAL    Build a single manual by target name
#   make clean        Remove all generated PDFs
#   make single N=1   Build manual by number (if using numbered scheme)

PANDOC    := pandoc
ENGINE    := xelatex
TEMPLATE  := templates/lab-manual.latex
SRC_DIR   := src
OUT_DIR   := out

# Common pandoc flags
PFLAGS := --pdf-engine=$(ENGINE) \
          --template=$(TEMPLATE) \
          --number-sections \
          --toc \
          --toc-depth=3 \
          --top-level-division=chapter \
          --variable=documentclass:report \
          --variable=papersize:a4 \
          --highlight-style=tango \
          --lua-filter=filters/callouts.lua

# ──────────────────────────────────────────────────────────
# Manual Definitions
# ──────────────────────────────────────────────────────────
# To add a new manual:
#   1. Add its name to the MANUALS list
#   2. Define YOURNAME_SRC (path to source markdown)
#   3. Define YOURNAME_OUT (path to output PDF)
#   4. Add a phony target and a build rule (follow the pattern below)
#
# Example: To add a manual called "SECURITY":
#   - Add SECURITY to MANUALS
#   - Set SECURITY_SRC := $(SRC_DIR)/security-policy.md
#   - Set SECURITY_OUT := $(OUT_DIR)/Security-Policy.pdf
#   - Add the SECURITY target and build rule
# ──────────────────────────────────────────────────────────

# List all manual targets here
MANUALS := OVERVIEW NETWORK SERVICES

# --- Manual 1: Overview / Master Reference ---
OVERVIEW_SRC := $(SRC_DIR)/overview-master-reference.md
OVERVIEW_OUT := $(OUT_DIR)/Overview-Master-Reference.pdf

# --- Manual 2: Network Infrastructure ---
NETWORK_SRC := $(SRC_DIR)/network-infrastructure.md
NETWORK_OUT := $(OUT_DIR)/Network-Infrastructure.pdf

# --- Manual 3: Applications & Services ---
SERVICES_SRC := $(SRC_DIR)/applications-services.md
SERVICES_OUT := $(OUT_DIR)/Applications-Services.pdf

# ──────────────────────────────────────────────────────────
# Targets
# ──────────────────────────────────────────────────────────

.PHONY: all clean $(MANUALS)

all: $(MANUALS)

OVERVIEW: $(OVERVIEW_OUT)
NETWORK:  $(NETWORK_OUT)
SERVICES: $(SERVICES_OUT)

# ──────────────────────────────────────────────────────────
# Build Rules
# ──────────────────────────────────────────────────────────
# Each rule:
#   - Creates the output directory if needed
#   - Runs pandoc with the common flags
#   - Prints the output path on success
#
# Add one rule block per manual, following this pattern:
#
#   $(YOURNAME_OUT): $(YOURNAME_SRC) $(TEMPLATE)
#   	@mkdir -p $(OUT_DIR)
#   	$(PANDOC) $(PFLAGS) -o $@ $<
#   	@echo "Built: $@"
# ──────────────────────────────────────────────────────────

$(OVERVIEW_OUT): $(OVERVIEW_SRC) $(TEMPLATE)
	@mkdir -p $(OUT_DIR)
	$(PANDOC) $(PFLAGS) -o $@ $<
	@echo "Built: $@"

$(NETWORK_OUT): $(NETWORK_SRC) $(TEMPLATE)
	@mkdir -p $(OUT_DIR)
	$(PANDOC) $(PFLAGS) -o $@ $<
	@echo "Built: $@"

$(SERVICES_OUT): $(SERVICES_SRC) $(TEMPLATE)
	@mkdir -p $(OUT_DIR)
	$(PANDOC) $(PFLAGS) -o $@ $<
	@echo "Built: $@"

clean:
	rm -f $(OUT_DIR)/*.pdf
	@echo "Cleaned output directory."

# Build a single manual by number: make single N=1
# (Only useful if you adopt a numbered naming scheme)
single:
	@echo "Hint: Use 'make OVERVIEW' or 'make NETWORK' to build by name."
	@echo "      Or rename targets to M0, M1, etc. for numbered access."
