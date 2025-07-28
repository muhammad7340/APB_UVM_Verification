class driver extends uvm_driver #(sequence_item);
 //type parameter passed `packet/transaction`
`uvm_component_utils(driver)
 
 virtual intf vif;// Interface handle
 sequence_item trans;//sequence_item handle

 // Constructor
 function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER", $sformatf("Driver created: %s at time %0t", name, $time), UVM_LOW)
 endfunction: new

  //build_phase
 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER", $sformatf("Driver build phase at time %0t", $time), UVM_LOW)
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))begin
        `uvm_fatal("NO VIF", $sformatf("virtual interface must be set for: %s.vif", get_full_name()))
    end
 endfunction: build_phase
 


 // run_phase
 virtual task run_phase(uvm_phase phase);
 
    super.run_phase(phase);
    $display("Starting UVM Driver Run phase at time %0t...", $time);

    trans=sequence_item::type_id::create("trans");//transaction creation
    
    // Wait for reset to be deasserted
    wait(!vif.PRESET);
    `uvm_info("DRIVER", "Reset deasserted, initializing interface signals", UVM_LOW);
    
    forever begin
        @(posedge vif.PCLK);  //driver runs forever doing 1 transaction/cycle
        `uvm_info("DRIVER", "Waiting for transaction from sequencer...", UVM_DEBUG);
        seq_item_port.get_next_item(trans);// Get the next item from the sequencer
        `uvm_info("DRIVER", "Got transaction from sequencer", UVM_DEBUG);
        drive_task(); //drive the transaction to the interface
        seq_item_port.item_done();// Indicate to sequencer that the item is done
        `uvm_info("DRIVER",$sformatf("Transaction Done"),UVM_DEBUG);
    end
 endtask:run_phase

 // drive_task
 // Assignment of Transaction Packet Signals into Pin level Format of Interface 
 //Interface will get data from driver from here
 virtual task drive_task();

    if(trans.PWRITE) begin //PWRITE==1: Write
    `uvm_info("WRITE_DRIVER",trans.convert2string(),UVM_DEBUG)
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
    while(!vif.PREADY) begin
        @(posedge vif.PCLK);
        `uvm_info("WRITE_DRIVER",$sformatf("Waiting for ready signal"),UVM_DEBUG)
    end

    // Check for PSLVERR signal from slave to determine if the write operation was successful
    if(vif.PSLVERR)
        `uvm_info("WRITE_DRIVER",$sformatf("write operation UNSUCCESSFUL"),UVM_DEBUG)
    else  
        `uvm_info("WRITE_DRIVER",$sformatf("write operation SUCCESSFUL"),UVM_DEBUG)

    //DeAssert Control Signals: `PENABLE & PSEL`  after the access phase
    @(posedge vif.PCLK);
    vif.PENABLE = 0;
    vif.PSEL    = 0;
    end
    
    
    else begin //PWRITE==0: read
    `uvm_info("READ_DRIVER",trans.convert2string(),UVM_DEBUG);

    // Drive the transaction to the interface
    //Setup Phase
    vif.PWRITE = trans.PWRITE;
    vif.PSEL   = trans.PSEL;
    vif.PADDR  = trans.PADDR;

    // Access Phase: After 1 clk, assert PENABLE to start the access phase
    @(posedge vif.PCLK)
    vif.PENABLE = trans.PENABLE;

    // Wait for PREADY signal from the slave to set it high when ready to accept/provide data
    while(!vif.PREADY) begin
        @(posedge vif.PCLK);
        `uvm_info("READ_DRIVER",$sformatf("Waiting for ready signal"),UVM_DEBUG)
    end

    // Check for PSLVERR signal from slave to determine if the read operation was successful
    if(vif.PSLVERR)
        `uvm_info("READ_DRIVER",$sformatf("read operation UNSUCCESSFUL"),UVM_DEBUG)
    else  
        `uvm_info("READ_DRIVER",$sformatf("read operation SUCCESSFUL"),UVM_DEBUG)

    //DeAssert Control Signals: `PENABLE & PSEL`  after the access phase
    @(posedge vif.PCLK);
    vif.PENABLE = 0;
    vif.PSEL    = 0;

    end
 endtask: drive_task

endclass: driver