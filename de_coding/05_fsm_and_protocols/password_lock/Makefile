# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := password_lock
TEST_TARGETS := test_password_lock

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_password_lock:
	@mkdir -p $(BUILD)/password_lock
	cd $(BUILD)/password_lock && $(VCS) $(VCS_FLAGS) -top tb_password_lock_smoke $(ROOT)/password_lock.v $(ROOT)/tb_password_lock_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
