class test extends uvm_test;
  `uvm_component_utils(test)

  driver       drv;
  sequencer    seqr;
  sequence_one seq;
  virtual intf vif;
  
  // Constructor
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

 // build_phase: create driver and sequencer
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = driver::type_id::create("drv", this);
    seqr = sequencer::type_id::create("seqr", this);
  endfunction

  // connect_hase: connect sequencer to driver
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("CONNECT_PHASE", "Connecting sequencer to driver", UVM_LOW)

    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

  // end_of_elaboration_phase: print topology
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology;
    `uvm_info(get_full_name,$sformatf("In end of elaboration  phase"),UVM_HIGH)
  endfunction

  // run_phase: start the sequence
  task run_phase(uvm_phase phase);
    seq = sequence_one::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(seqr);
    phase.drop_objection(this);
  endtask

endclass