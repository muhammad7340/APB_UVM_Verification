vlib work
vlog interface.sv design.sv pkg.sv top.sv
# Default test - Burst sequence (sequence_one)
vsim work.top +UVM_TESTNAME=test +UVM_VERBOSITY=UVM_LOW

# Alternative test options (uncomment to use):
# Write-Read test (single write then read to same address)
#vsim work.top +UVM_TESTNAME=write_read_test +UVM_VERBOSITY=UVM_LOW
# Error Address test (invalid address testing)
#vsim work.top +UVM_TESTNAME=error_addr_test +UVM_VERBOSITY=UVM_LOW

# Protocol Violation test (intentional protocol violations)

vsim work.top +UVM_TESTNAME=protocol_violation_test +UVM_VERBOSITY=UVM_LOW

add wave -position insertpoint  \
sim:/top/intf/PADDR \
sim:/top/intf/PCLK \
sim:/top/intf/PENABLE \
sim:/top/intf/PRDATA \
sim:/top/intf/PREADY \
sim:/top/intf/PRESET \
sim:/top/intf/PSEL \
sim:/top/intf/PSLVERR \
sim:/top/intf/PSTRB \
sim:/top/intf/PWDATA \
sim:/top/intf/PWRITE
run -all