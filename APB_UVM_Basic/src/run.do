vlib work
vlog interface.sv design.sv pkg.sv top.sv
vsim work.top +define+UVM_REPORT_DISABLE_FILE_LINE +UVM_TESTNAME=test -l logs/simulation.log
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