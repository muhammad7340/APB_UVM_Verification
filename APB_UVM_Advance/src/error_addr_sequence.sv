class error_addr_sequence extends uvm_sequence#(sequence_item);
  `uvm_object_utils(error_addr_sequence)
  
  // Constructor
  function new(string name = "error_addr_sequence");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("ERROR_ADDR_SEQUENCE created: %s at time %0t", name, $time), UVM_LOW)
  endfunction 
  
  virtual task body();
    sequence_item error_write_trans;
    sequence_item error_read_trans;
    
    // Generate write transaction with invalid address (outside constraint range)
    error_write_trans = sequence_item::type_id::create("error_write_trans");
    error_write_trans.PSEL = 1;
    error_write_trans.PWRITE = 1;
    error_write_trans.PENABLE = 1;
    error_write_trans.PADDR = 32'd100; // Invalid address outside 0-31 range :100 in decimal
    
    start_item(error_write_trans);
    `uvm_info(get_full_name(), $sformatf("ERROR_WRITE_SEQUENCE: %s", error_write_trans.convert2string()), UVM_LOW)
    finish_item(error_write_trans);
    #5;

    // Generate read transaction with invalid address
    error_read_trans = sequence_item::type_id::create("error_read_trans");
    error_read_trans.PSEL = 1;
    error_read_trans.PWRITE = 0;
    error_read_trans.PENABLE = 1;
    error_read_trans.PADDR = 32'd200; // Another invalid address :200 in decimal
    
    start_item(error_read_trans);
    `uvm_info(get_full_name(), $sformatf("ERROR_READ_SEQUENCE: %s", error_read_trans.convert2string()), UVM_LOW)
    finish_item(error_read_trans);

  endtask
endclass: error_addr_sequence 