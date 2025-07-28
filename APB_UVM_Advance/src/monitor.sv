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



  // Write phase task
  task wr_phase();
      //Creating new transaction object to send data from monitor to scoreboard
      sequence_item trans_write = sequence_item::type_id::create("trans_write");
      int pr_addr = 0, pa_addr = 0;      // present_addr, past_addr
      integer pr_data, pa_data;          // present_data, past_data
      int write_count =0;                // timeout counter
      
      forever begin
          //wait for rising edge of clock 
          @(posedge vif.PCLK) begin 
              
              // STEP 1: Wait for Valid Write Transaction
              while((!vif.PSEL && !vif.PENABLE) || !vif.PWRITE) begin //Remain in loop untill PSEL=1, PENABLE=1, PWRITE=1
                  @(posedge vif.PCLK)
                  `uvm_info(get_full_name(), "WRITE: Waiting for write mode...", UVM_DEBUG) 
              end
              
              // STEP 2: Sample/Capture All Interface Signals
              trans_write.PRESET = vif.PRESET;
              trans_write.PENABLE = vif.PENABLE;
              trans_write.PSEL = vif.PSEL;

              trans_write.PWDATA = vif.PWDATA;
              trans_write.PWRITE = vif.PWRITE;
              trans_write.PADDR = vif.PADDR;
            
              trans_write.PREADY = vif.PREADY;
              trans_write.PSLVERR = vif.PSLVERR;
            

              // STEP 3: Check for New Transaction (avoid duplicates)
              pr_data = trans_write.PWDATA;//present data
              pr_addr = trans_write.PADDR;
              if((pr_addr != pa_addr) || pr_data !== pa_data) begin
                  // Send to scoreboard only if it's a NEW transaction
                  // Usage: Send data to scoreboard
                  wap.write(trans_write);
                  pa_addr = pr_addr;  //Update previous values
                  pa_data = pr_data;
              end
              else
                  `uvm_info(get_full_name(), "WRITE: Writing same data on same address", UVM_DEBUG)

              // STEP 4: Wait  for Transaction Completion (PREADY to be asserted by slave)
              while(!vif.PREADY && write_count<=20) begin // Wait max 20 clocks for ready signal
                  @(posedge vif.PCLK);
                  `uvm_info(get_full_name(), "WRITE: Ready signal is not high", UVM_DEBUG)
                  write_count++;
              end

              // STEP 5: Timeout Protection (Prevent infinite wait if slave never asserts PREADY)
              if(write_count>100) begin
                  `uvm_error(get_full_name(), "WRITE: Ready signal was not high since 20 clock cycles")
                  write_count =0;
              end 
          end
          #1;  // Small delay to prevent race conditions
      end
  endtask
















  // Read phase task
  task rd_phase();
      //Creating new transaction object to send data from monitor to scoreboard
      sequence_item trans_read = sequence_item::type_id::create("trans_read");
      int pr_addr = 0, pa_addr = 0;      // present_addr, past_addr  
      integer pr_data, pa_data;          // present_data, past_data
      int read_count = 0;                // timeout counter
      
      forever begin
          //wait for rising edge of clock 
          @(posedge vif.PCLK) begin 
          @(posedge vif.PCLK) begin 
              
              // STEP 1: Wait for Valid Read Transaction
              while((!vif.PSEL && !vif.PENABLE) || vif.PWRITE) begin //Remain in loop until PSEL=1, PENABLE=1, PWRITE=0
                  @(posedge vif.PCLK)
                  `uvm_info(get_full_name(), "READ: Waiting for read mode...", UVM_DEBUG) 
              end
              
              // STEP 2: Sample/Capture All Interface Signals (except PRDATA - sample after PREADY)
              trans_read.PRESET = vif.PRESET;
              trans_read.PENABLE = vif.PENABLE;
              trans_read.PSEL = vif.PSEL;

              trans_read.PADDR = vif.PADDR;
              trans_read.PWRITE = vif.PWRITE;
              
              trans_read.PREADY = vif.PREADY;
              trans_read.PSLVERR = vif.PSLVERR;
              

              // STEP 3: Wait for Transaction Completion (PREADY to be asserted by slave)
              while(!vif.PREADY && read_count<=10) begin // Wait max 10 clocks for ready signal
                  @(posedge vif.PCLK);
                  `uvm_info(get_full_name(), "READ: Ready signal is not high", UVM_DEBUG)
                  read_count++;
              end

              // STEP 4: Timeout Protection (Prevent infinite wait if slave never asserts PREADY)
              if(read_count>100) begin
                  `uvm_error(get_full_name(), "READ: Ready signal was not high since 100 clock cycles")
                  read_count = 0;
              end
              
              // STEP 5: Sample PRDATA 
              trans_read.PRDATA = vif.PRDATA;
              
              // STEP 6: Check for New Transaction (avoid duplicates)
              pr_data = trans_read.PRDATA; // present data
              pr_addr = trans_read.PADDR;
              if((pr_addr != pa_addr) || pr_data !== pa_data) begin
                  // Send to scoreboard only if it's a NEW transaction
                  rap.write(trans_read);
                  pa_addr = pr_addr;  // Update previous values
                  pa_data = pr_data;
                  `uvm_info(get_full_name(), "READ: Sent read transaction to scoreboard", UVM_DEBUG)
              end
              else
                  `uvm_info(get_full_name(), "READ: Reading same data from same address", UVM_DEBUG)
          end
          #1;  // Small delay to prevent race conditions
      end
      end
  endtask



endclass: monitor