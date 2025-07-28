class sequencer extends uvm_sequencer#(sequence_item);//type parameter passed `packet/transaction`
  `uvm_component_utils(sequencer)
  
  
  //Constructor
  function new(string name,uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(), $sformatf("SEQUENCER created: %s at time %0t", name, $time), UVM_LOW)
  endfunction
  
endclass