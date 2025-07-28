class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    // Components that the agent contains
    driver drv;           // Driver instance
    monitor mon;          // Monitor instance  
    sequencer seqr;       // Sequencer instance
    
    // Virtual Interface
    virtual intf vif;
    
    // Configuration - determines if agent is active or passive
    uvm_active_passive_enum is_active = UVM_ACTIVE; 

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("AGENT created: %s at time %0t", name, $time), UVM_LOW)//use get_type_name() for dynamic name resolution in constructors
    endfunction
    
    // Build Phase - Create sub-components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config_db
        if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
        end
        
        // Create monitor (always needed for both active/passive)
        mon = monitor::type_id::create("mon", this);
        
        // Create driver and sequencer only if agent is active
        if (is_active == UVM_ACTIVE) begin
            drv = driver::type_id::create("drv", this);
            seqr = sequencer::type_id::create("seqr", this);
        end
        
        `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)//use get_full_name() for full path in logs in phases
    endfunction
    
    // Connect Phase - Connect driver to sequencer using TLM ports
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Set virtual interface for monitor
        uvm_config_db#(virtual intf)::set(this, "mon", "vif", vif);
        
        // Connect driver and sequencer only if agent is active
        if (is_active == UVM_ACTIVE) begin
            // Set virtual interface for driver
            uvm_config_db#(virtual intf)::set(this, "drv", "vif", vif);
            
            // Connect driver's TLM port to sequencer's TLM export
            drv.seq_item_port.connect(seqr.seq_item_export);
            
            `uvm_info(get_full_name(), "Driver-Sequencer connection established", UVM_LOW)
        end
        
        `uvm_info(get_full_name(), "Connect phase completed", UVM_LOW)
    endfunction
    
endclass: agent
