package pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // Include all UVM components in proper order without interface
  `include "sequence_item.sv" 
  `include "sequence.sv"
  `include "write_read_sequence.sv"
  `include "error_addr_sequence.sv"
  `include "sequencer.sv"
  `include "driver.sv"
  `include "monitor.sv"
  `include "scoreboard.sv"
  `include "agent.sv"
  `include "environment.sv"
  `include "test.sv"

endpackage