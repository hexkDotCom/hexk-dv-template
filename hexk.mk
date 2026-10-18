# SPDX-License-Identifier: 0BSD
#
# hexk.mk - the external dependencies: hexk-sv-lib at a pinned release, and the UVM sources.
# Included by the Makefile. Nothing is vendored: 'make deps' fetches what is missing into
# $(BUILD_DIR). Point HEXK_SV_LIB_HOME or UVM_ROOT at your own copies to use those instead.

# hexk-sv-lib: a release tag, and the commit it must resolve to.
HEXK_SV_LIB_VERSION := 0.10.0
HEXK_SV_LIB_COMMIT  := d0c028e16e7c216a9c53e9cc24dbbc08a1b59c24
HEXK_SV_LIB_URL     := https://github.com/hexkDotCom/hexk-sv-lib.git
HEXK_SV_LIB_HOME    ?= $(BUILD_DIR)/hexk-sv-lib
export HEXK_SV_LIB_HOME

# UVM sources: <UVM_ROOT>/1.2 and <UVM_ROOT>/2020. The hexk-dv-toolbox image has them in
# $HEXK_UVM_ROOT; elsewhere they are downloaded and checked against these SHA-256 sums.
UVM_ROOT       ?= $(if $(HEXK_UVM_ROOT),$(HEXK_UVM_ROOT),$(BUILD_DIR)/uvm)
UVM_1_2_URL    := https://www.accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz
UVM_1_2_SHA256 := 502a2e605ce552bfd9767803c7e99a053715b00f7a9c4c511c3fbfddfb30157c
UVM_2020_URL   := https://github.com/accellera-official/uvm-core/archive/refs/tags/2020.3.1.tar.gz
UVM_2020_SHA256 := f55bdbc02cc500d4a2f41b31bad127653289eb2073f806ce156fb82662b362b8

$(HEXK_SV_LIB_HOME)/src/hexk_all.f:
	@echo "deps: hexk-sv-lib v$(HEXK_SV_LIB_VERSION) into $(HEXK_SV_LIB_HOME)"
	@git -c advice.detachedHead=false clone --quiet --depth 1 --branch v$(HEXK_SV_LIB_VERSION) \
	   $(HEXK_SV_LIB_URL) $(HEXK_SV_LIB_HOME)
	@test "$$(git -C $(HEXK_SV_LIB_HOME) rev-parse HEAD)" = "$(HEXK_SV_LIB_COMMIT)" || \
	   { echo "deps: tag v$(HEXK_SV_LIB_VERSION) is not commit $(HEXK_SV_LIB_COMMIT)"; rm -rf $(HEXK_SV_LIB_HOME); exit 1; }

# $(1) version directory, $(2) URL, $(3) SHA-256
define fetch_uvm
	@echo "deps: UVM $(1) into $(UVM_ROOT)/$(1)"
	@mkdir -p $(UVM_ROOT)/$(1)
	@curl -sSfL -o $(UVM_ROOT)/$(1).tar.gz $(2)
	@echo "$(3)  $(UVM_ROOT)/$(1).tar.gz" | sha256sum -c --quiet -
	@tar -xzf $(UVM_ROOT)/$(1).tar.gz -C $(UVM_ROOT)/$(1) --strip-components=1
	@rm $(UVM_ROOT)/$(1).tar.gz
endef

$(UVM_ROOT)/1.2/src/uvm_pkg.sv:
	$(call fetch_uvm,1.2,$(UVM_1_2_URL),$(UVM_1_2_SHA256))

$(UVM_ROOT)/2020/src/uvm_pkg.sv:
	$(call fetch_uvm,2020,$(UVM_2020_URL),$(UVM_2020_SHA256))

HEXK_DEPS := $(HEXK_SV_LIB_HOME)/src/hexk_all.f $(UVM_ROOT)/1.2/src/uvm_pkg.sv $(UVM_ROOT)/2020/src/uvm_pkg.sv
