# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := handshake_master
TEST_TARGETS := test_handshake_master

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_handshake_master:
	@mkdir -p $(BUILD)/handshake_master
	cd $(BUILD)/handshake_master && $(VCS) $(VCS_FLAGS) -top tb_handshake_master_smoke $(ROOT)/req_ack_handshake.v $(ROOT)/tb_handshake_master_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
