%: %.sv
	verilator -Wall --lint-only $<
