all: main

%: %.sv
	verilator -Wall --lint-only $<
