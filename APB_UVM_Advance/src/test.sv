// Default test - uses burst sequence (sequence_one)
class test extends uvm_test;
    `uvm_component_utils(test)
    
    // Components that the test contains
    environment env;          // Environment instance
    sequence_one seq;         // Sequence instance
    
    // Virtual Interface
    virtual intf vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("TEST created: %s at time %0t", name, $time), UVM_LOW)
    endfunction
    
    // Build Phase - Create environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config_db
        if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
        end
        
        // Create environment
        env = environment::type_id::create("env", this);
        `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
    endfunction
    
    // Connect Phase - Set virtual interface for environment
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Set virtual interface for environment
        uvm_config_db#(virtual intf)::set(this, "env", "vif", vif);
        `uvm_info(get_full_name(), "Connect phase completed", UVM_LOW)
    endfunction
    
    // Run Phase - Start the test sequence
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // Raise objection to keep test running
        phase.raise_objection(this, "Starting APB burst test sequence");
        `uvm_info(get_full_name(), "Starting APB Burst Protocol Test", UVM_LOW)
        
        // Create and start sequence
        seq = sequence_one::type_id::create("seq");
        seq.start(env.agt.seqr);
        
        // Add some delay for final transactions to complete
        #1;
        `uvm_info(get_full_name(), "APB Burst Protocol Test Completed", UVM_LOW)
        // Drop objection to end test
        phase.drop_objection(this, "APB burst test sequence completed");
    endtask
    
    // End of elaboration phase - print test hierarchy
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_full_name(), "Test hierarchy created:", UVM_LOW)
        uvm_top.print_topology();
    endfunction
    
    // Report phase - print final test results
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "                    |===============================================================|", UVM_NONE)
        `uvm_info(get_type_name(), "                    |                   APB BURST TEST COMPLETED                    |",  UVM_NONE)
        `uvm_info(get_type_name(), "                    |===============================================================|", UVM_NONE)
    endfunction
    
endclass: test

// Write-Read test - uses write_read_sequence
class write_read_test extends uvm_test;
    `uvm_component_utils(write_read_test)
    
    // Components that the test contains
    environment env;          // Environment instance
    write_read_sequence seq;  // Sequence instance
    
    // Virtual Interface
    virtual intf vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("WRITE_READ_TEST created: %s at time %0t", name, $time), UVM_LOW)
    endfunction
    
    // Build Phase - Create environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config_db
        if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
        end
        
        // Create environment
        env = environment::type_id::create("env", this);
        `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
    endfunction
    
    // Connect Phase - Set virtual interface for environment
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Set virtual interface for environment
        uvm_config_db#(virtual intf)::set(this, "env", "vif", vif);
        `uvm_info(get_full_name(), "Connect phase completed", UVM_LOW)
    endfunction
    
    // Run Phase - Start the test sequence
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // Raise objection to keep test running
        phase.raise_objection(this, "Starting APB write-read test sequence");
        `uvm_info(get_full_name(), "Starting APB Write-Read Protocol Test", UVM_LOW)
        
        // Create and start sequence
        seq = write_read_sequence::type_id::create("seq");
        seq.start(env.agt.seqr);
        
        // Add some delay for final transactions to complete
        #1;
        `uvm_info(get_full_name(), "APB Write-Read Protocol Test Completed", UVM_LOW)
        // Drop objection to end test
        phase.drop_objection(this, "APB write-read test sequence completed");
    endtask
    
    // End of elaboration phase - print test hierarchy
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_full_name(), "Test hierarchy created:", UVM_LOW)
        uvm_top.print_topology();
    endfunction
    
    // Report phase - print final test results
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(get_type_name(), "        |===============================================================|", UVM_NONE)
        `uvm_info(get_type_name(), "        |                   APB WRITE-READ TEST COMPLETED               |",  UVM_NONE)
        `uvm_info(get_type_name(), "        |===============================================================|", UVM_NONE)
    endfunction
    
endclass: write_read_test

// Error Address test - uses error_addr_sequence
class error_addr_test extends uvm_test;
    `uvm_component_utils(error_addr_test)
    
    // Components that the test contains
    environment env;          // Environment instance
    error_addr_sequence seq;  // Sequence instance
    
    // Virtual Interface
    virtual intf vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("ERROR_ADDR_TEST created: %s at time %0t", name, $time), UVM_LOW)
    endfunction
    
    // Build Phase - Create environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config_db
        if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
        end
        
        // Create environment
        env = environment::type_id::create("env", this);
        `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
    endfunction
    
    // Connect Phase - Set virtual interface for environment
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Set virtual interface for environment
        uvm_config_db#(virtual intf)::set(this, "env", "vif", vif);
        `uvm_info(get_full_name(), "Connect phase completed", UVM_LOW)
    endfunction
    
    // Run Phase - Start the test sequence
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // Raise objection to keep test running
        phase.raise_objection(this, "Starting APB error address test sequence");
        `uvm_info(get_full_name(), "Starting APB Error Address Protocol Test", UVM_LOW)
        
        // Create and start sequence
        seq = error_addr_sequence::type_id::create("seq");
        seq.start(env.agt.seqr);
        
        // Add some delay for final transactions to complete
        #1;
        `uvm_info(get_full_name(), "APB Error Address Protocol Test Completed", UVM_LOW)
        // Drop objection to end test
        phase.drop_objection(this, "APB error address test sequence completed");
    endtask
    
    // End of elaboration phase - print test hierarchy
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_full_name(), "Test hierarchy created:", UVM_LOW)
        uvm_top.print_topology();
    endfunction
    
    // Report phase - print final test results
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "        |===============================================================|", UVM_NONE)
        `uvm_info(get_type_name(), "        |              APB ERROR ADDRESS TEST COMPLETED                 |",  UVM_NONE)
        `uvm_info(get_type_name(), "        |===============================================================|", UVM_NONE)
    endfunction
    
endclass: error_addr_test