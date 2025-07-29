class driver extends uvm_driver #(sequence_item);
 //type parameter passed `packet/transaction`
`uvm_component_utils(driver)
 
 virtual intf vif;// Interface handle
 sequence_item trans;//sequence_item handle

 // Constructor
 function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("DRIVER created: %s at time %0t", name, $time), UVM_LOW)
 endfunction: new

  //build_phase
 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase started", UVM_LOW)
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))begin
        `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
    end
    `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
 endfunction: build_phase
 


 // run_phase
 virtual task run_phase(uvm_phase phase);
 
    super.run_phase(phase);
    `uvm_info(get_full_name(), "Run phase started", UVM_LOW)

    trans=sequence_item::type_id::create("trans");//transaction creation
    
    // Wait for reset to be deasserted
    wait(!vif.PRESET);
    `uvm_info(get_full_name(), "Reset deasserted, initializing interface signals", UVM_LOW);
    
    forever begin
        @(posedge vif.PCLK);  //driver runs forever doing 1 transaction/cycle
        `uvm_info(get_full_name(), "Waiting for transaction from sequencer...", UVM_DEBUG);
        seq_item_port.get_next_item(trans);// Get the next item from the sequencer
        `uvm_info(get_full_name(), "Got transaction from sequencer", UVM_DEBUG);
        drive_task(); //drive the transaction to the interface
        seq_item_port.item_done();// Indicate to sequencer that the item is done
        `uvm_info(get_full_name(), "Transaction Done", UVM_DEBUG);
    end
 endtask:run_phase

 // drive_task
 // Assignment of Transaction Packet Signals into Pin level Format of Interface 
 //Interface will get data from driver from here
 virtual task drive_task();
    int timeout_count; // Declare timeout variable at the beginning

    if(trans.PWRITE) begin //PWRITE==1: Write
    `uvm_info(get_full_name(), $sformatf("WRITE: %s", trans.convert2string()), UVM_DEBUG)
    // Drive the transaction to the interface
    //Setup Phase
    vif.PWRITE = trans.PWRITE;
    vif.PSEL   = trans.PSEL;
    vif.PADDR  = trans.PADDR;
    vif.PWDATA = trans.PWDATA;
    vif.PSTRB  = trans.PSTRB;
 
    // Access Phase: After 1 clk, assert PENABLE to start the access phase
    @(posedge vif.PCLK)
    vif.PENABLE = trans.PENABLE;

    // Wait for PREADY signal from the slave to set it high when ready to accept/provide data
    // Add timeout for protocol violations
    timeout_count = 0;
    while(!vif.PREADY && timeout_count < 10) begin
        @(posedge vif.PCLK);
        timeout_count++;
        `uvm_info(get_full_name(), $sformatf("WRITE: Waiting for ready signal, timeout_count=%0d", timeout_count), UVM_DEBUG)
    end
    
    if(timeout_count >= 10) begin
        `uvm_warning(get_full_name(), "WRITE: Protocol violation detected - PREADY timeout")
    end

    // Check for PSLVERR signal from slave to determine if the write operation was successful
    if(vif.PSLVERR)
        `uvm_info(get_full_name(), "WRITE: Operation UNSUCCESSFUL", UVM_DEBUG)
    else  
        `uvm_info(get_full_name(), "WRITE: Operation SUCCESSFUL", UVM_DEBUG)

    //DeAssert Control Signals: `PENABLE & PSEL`  after the access phase
    @(posedge vif.PCLK);
    vif.PENABLE = 0;
    vif.PSEL    = 0;
    end
    
    
    else begin //PWRITE==0: read
    `uvm_info(get_full_name(), $sformatf("READ: %s", trans.convert2string()), UVM_DEBUG);

    // Drive the transaction to the interface
    //Setup Phase
    vif.PWRITE = trans.PWRITE;
    vif.PSEL   = trans.PSEL;
    vif.PADDR  = trans.PADDR;

    // Access Phase: After 1 clk, assert PENABLE to start the access phase
    @(posedge vif.PCLK)
    vif.PENABLE = trans.PENABLE;

    // Wait for PREADY signal from the slave to set it high when ready to accept/provide data
    // Add timeout for protocol violations
    timeout_count = 0;
    while(!vif.PREADY && timeout_count < 10) begin
        @(posedge vif.PCLK);
        timeout_count++;
        `uvm_info(get_full_name(), $sformatf("READ: Waiting for ready signal, timeout_count=%0d", timeout_count), UVM_DEBUG)
    end
    
    if(timeout_count >= 10) begin
        `uvm_warning(get_full_name(), "READ: Protocol violation detected - PREADY timeout")
    end

    // Check for PSLVERR signal from slave to determine if the read operation was successful
    if(vif.PSLVERR)
        `uvm_info(get_full_name(), "READ: Operation UNSUCCESSFUL", UVM_DEBUG)
    else  
        `uvm_info(get_full_name(), "READ: Operation SUCCESSFUL", UVM_DEBUG)

    //DeAssert Control Signals: `PENABLE & PSEL`  after the access phase
    @(posedge vif.PCLK);
    vif.PENABLE = 0;
    vif.PSEL    = 0;

    end
 endtask: drive_task

endclass: driver