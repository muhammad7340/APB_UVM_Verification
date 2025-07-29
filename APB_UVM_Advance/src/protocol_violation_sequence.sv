// Protocol Violation Sequence - Tests APB protocol violations
// This sequence intentionally violates APB protocol rules to test error handling
class protocol_violation_sequence extends uvm_sequence#(sequence_item);
  `uvm_object_utils(protocol_violation_sequence)
  
  // Constructor
  function new(string name = "protocol_violation_sequence");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("PROTOCOL_VIOLATION_SEQUENCE created: %s at time %0t", name, $time), UVM_LOW)
  endfunction 
  
  virtual task body();
    sequence_item trans;

    // VIOLATION 1: PENABLE=1 without PSEL=1
    // APB Rule: PENABLE should only be asserted when PSEL=1
    // This violation tests if the DUT properly handles this protocol error
    `uvm_info(get_full_name(), "=== TESTING VIOLATION 1: PENABLE=1 without PSEL=1 ===", UVM_LOW)
    
    trans = sequence_item::type_id::create("penable_without_psel");
    trans.PSEL = 0;              // PSEL is LOW (should not be selected)
    trans.PENABLE = 1;           // PENABLE is HIGH (violation!)
    trans.PWRITE = 1;            // Write operation
    trans.PADDR = 32'h5;         // Some address
    trans.PWDATA = 32'hA5A5A5A5; // Some data
    
    start_item(trans);
    `uvm_info(get_full_name(), $sformatf("VIOLATION1: PSEL=%0d, PENABLE=%0d, PWRITE=%0d, ADDR=0x%0h", 
        trans.PSEL, trans.PENABLE, trans.PWRITE, trans.PADDR), UVM_LOW)
    finish_item(trans);
    #10; // Wait for response

  endtask: body
    
endclass: protocol_violation_sequence








