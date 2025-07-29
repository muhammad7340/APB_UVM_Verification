//Single Write and Read Transaction //Same address access pattern

class write_read_sequence extends uvm_sequence#(sequence_item);
  `uvm_object_utils(write_read_sequence)
  
  int last_addr;
  
  // Constructor
  function new(string name = "write_read_sequence");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("WRITE_READ_SEQUENCE created: %s at time %0t", name, $time), UVM_LOW)
  endfunction 
  
  virtual task body();
    sequence_item write_trans;
    sequence_item read_trans;
    
    // Generate the write transaction 
    write_trans = sequence_item::type_id::create("write_trans");
    write_trans.PSEL = 1;
    write_trans.PWRITE = 1;
    write_trans.PENABLE = 1;
    
    start_item(write_trans);
    assert(write_trans.randomize());
    last_addr = write_trans.PADDR;
    `uvm_info(get_full_name(), $sformatf("WRITE_SEQUENCE: %s", write_trans.convert2string()), UVM_LOW)
    finish_item(write_trans);
    #5;

    // Generate read transaction 
    read_trans = sequence_item::type_id::create("read_trans");
    read_trans.PSEL = 1;
    read_trans.PWRITE = 0;
    read_trans.PENABLE = 1;
    read_trans.PADDR = last_addr;
    
    start_item(read_trans);
    `uvm_info(get_full_name(), $sformatf("READ_SEQUENCE: %s", read_trans.convert2string()), UVM_LOW)
    finish_item(read_trans);

  endtask
endclass: write_read_sequence 