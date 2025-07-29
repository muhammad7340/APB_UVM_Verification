class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  // Virtual interface handle
  virtual intf vif;

  //* Analysis port declaration: to send transactions to scoreboard
  uvm_analysis_port#(sequence_item) wap;//write analysis port
  uvm_analysis_port#(sequence_item) rap;//read analysis port

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("MONITOR created: %s at time %0t", name, $time), UVM_LOW)
    wap = new("wap", this);//*
    rap = new("rap", this);//*  
  endfunction

  // Build phase: get the virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase started", UVM_LOW)
    if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
    end
    `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
  endfunction

  // Run phase: sample the APB bus and send observed transactions
  virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        fork
            wr_phase();//write phase task
            rd_phase();//read  phase task
        join
  endtask

  // Write phase task - Simplified approach
  task wr_phase();
      sequence_item trans_write;
      
      forever begin
          // Wait for write transaction start (PSEL=1, PWRITE=1)
          @(posedge vif.PCLK);
          if(vif.PSEL && vif.PWRITE) begin
              // Create new transaction
              trans_write = sequence_item::type_id::create("trans_write");
              
              // Sample all signals
              trans_write.PRESET = vif.PRESET;
              trans_write.PENABLE = vif.PENABLE;
              trans_write.PSEL = vif.PSEL;
              trans_write.PWDATA = vif.PWDATA;
              trans_write.PWRITE = vif.PWRITE;
              trans_write.PADDR = vif.PADDR;
              trans_write.PREADY = vif.PREADY;
              trans_write.PSLVERR = vif.PSLVERR;
              
              // Wait for PREADY to complete transaction
              while(!vif.PREADY) begin
                  @(posedge vif.PCLK);
              end
              
              // Send to scoreboard
              wap.write(trans_write);
              `uvm_info(get_full_name(), $sformatf("WRITE: Address 0x%0h, Data 0x%0h", trans_write.PADDR, trans_write.PWDATA), UVM_LOW)
          end
      end
  endtask

  // Read phase task - Simplified approach
  task rd_phase();
      sequence_item trans_read;
      
      forever begin
          // Wait for read transaction start (PSEL=1, PWRITE=0)
          @(posedge vif.PCLK);
          if(vif.PSEL && !vif.PWRITE) begin
              // Create new transaction
              trans_read = sequence_item::type_id::create("trans_read");
              
              // Sample all signals except PRDATA
              trans_read.PRESET = vif.PRESET;
              trans_read.PENABLE = vif.PENABLE;
              trans_read.PSEL = vif.PSEL;
              trans_read.PADDR = vif.PADDR;
              trans_read.PWRITE = vif.PWRITE;
              trans_read.PREADY = vif.PREADY;
              trans_read.PSLVERR = vif.PSLVERR;
              
              // Wait for PREADY to complete transaction
              while(!vif.PREADY) begin
                  @(posedge vif.PCLK);
              end
              
              // Sample PRDATA when PREADY is high
              trans_read.PRDATA = vif.PRDATA;
              
              // Send to scoreboard
              rap.write(trans_read);
              `uvm_info(get_full_name(), $sformatf("READ: Address 0x%0h, Data 0x%0h", trans_read.PADDR, trans_read.PRDATA), UVM_LOW)
          end
      end
  endtask

endclass: monitor