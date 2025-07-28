class environment extends uvm_env;
    `uvm_component_utils(environment)
    
    // Components that the environment contains
    agent agt;                // Agent instance (contains driver, monitor, sequencer)
    scoreboard sb;            // Scoreboard instance
    
    // Virtual Interface
    virtual intf vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("ENVIRONMENT created: %s at time %0t", name, $time), UVM_LOW)
    endfunction
    
    // Build Phase - Create sub-components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config_db
        if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
        end
        
        // Create agent and scoreboard
        agt = agent::type_id::create("agt", this);
        sb = scoreboard::type_id::create("sb", this);
        
        `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
    endfunction
    
    // Connect Phase - Establish TLM connections between Monitor -> Scoreboard
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Set virtual interface for agent
        uvm_config_db#(virtual intf)::set(this, "agt", "vif", vif);
        
        // Set virtual interface for scoreboard
        uvm_config_db#(virtual intf)::set(this, "sb", "vif", vif);
        
        // TLM Connections: Monitor → Scoreboard
        // Connect monitor's write analysis port to scoreboard's write export
        agt.mon.wap.connect(sb.sb_export_write);
        
        // Connect monitor's read analysis port to scoreboard's read export
        agt.mon.rap.connect(sb.sb_export_read);
        
        `uvm_info(get_full_name(), "TLM connections established:", UVM_LOW)
        `uvm_info(get_full_name(), "Monitor.wap → Scoreboard.sb_export_write", UVM_LOW)
        `uvm_info(get_full_name(), "Monitor.rap → Scoreboard.sb_export_read", UVM_LOW)
        `uvm_info(get_full_name(), "Connect phase completed", UVM_LOW)
    endfunction
    
endclass: environment
