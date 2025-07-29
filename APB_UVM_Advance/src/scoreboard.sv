class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    
    // Virtual Interface (for clock-based comparison)
    virtual intf vif;

    // Transaction Item Declaration
    sequence_item trans_read;
    sequence_item trans_write;

    // Analysis import declarations for write and read transactions
    `uvm_analysis_imp_decl(_W)  // Declare Write Import Type
    `uvm_analysis_imp_decl(_R)  // Declare Read Import Type

    // EXPORTS/IMPS - for receiving data IN from monitor
    uvm_analysis_imp_W #(sequence_item, scoreboard) sb_export_write;
    uvm_analysis_imp_R #(sequence_item, scoreboard) sb_export_read;
    
     // Storage Queues (FIFO - First In, First Out)
    bit [31:0] write_q[$];     // Queue to store write data
    bit [31:0] read_q[$];      // Queue to store read data
    
    // Error Status Tracking
    bit WPSLVERR, RPSLVERR;    // Track write/read error status

    // Comparison Variables
    bit [31:0] write_data, read_data;  // Current data being compared
    int compare_pass = 0, compare_fail = 0;  // Pass/fail counters
    
    //** Enhanced Transaction Tracking
    typedef struct {
        bit [31:0] addr;
        bit [31:0] data;
        bit [31:0] time_stamp;
        string transaction_type;
    } transaction_record_t;
    
    transaction_record_t write_transactions[$];
    transaction_record_t read_transactions[$];
    int transaction_id = 1;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("SCOREBOARD created: %s at time %0t", name, $time), UVM_LOW)
    endfunction
    
    // build_phase - for creating sub-components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create reciever objects
        sb_export_write = new("sb_export_write", this);  
        sb_export_read = new("sb_export_read", this);    // Create read import
        if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", $sformatf("Virtual interface must be set for: %s.vif", get_full_name()))
        end
        `uvm_info(get_full_name(), "Build phase completed", UVM_LOW)
    endfunction

    //** Enhanced Write Transaction Handler
    virtual function void write_W(input sequence_item trans);
        transaction_record_t write_rec;
        
        // Store write data in queue `write_q`
        write_q.push_back(trans.PWDATA);//Store write data at end of queue
        WPSLVERR = trans.PSLVERR;  // Store error status
        
        // Store transaction details for enhanced reporting
        write_rec.addr = trans.PADDR;
        write_rec.data = trans.PWDATA;
        write_rec.time_stamp = $time;
        write_rec.transaction_type = "WRITE";
        write_transactions.push_back(write_rec);
        
        // Concise logging
        `uvm_info(get_full_name(), $sformatf("WRITE[%0d]: ADDR=0x%0h, DATA=0x%0h, TIME=%0t", 
            write_transactions.size(), trans.PADDR, trans.PWDATA, $time), UVM_LOW)          
    endfunction

    //** Enhanced Read Transaction Handler
    virtual function void write_R(input sequence_item trans);
        transaction_record_t read_rec;
        
        // Store read data in queue
        read_q.push_back(trans.PRDATA);
        RPSLVERR = trans.PSLVERR;  // Store error status
        
        // Store transaction details for enhanced reporting
        read_rec.addr = trans.PADDR;
        read_rec.data = trans.PRDATA;
        read_rec.time_stamp = $time;
        read_rec.transaction_type = "READ";
        read_transactions.push_back(read_rec);
        
        // Concise logging
        `uvm_info(get_full_name(), $sformatf("READ[%0d]:  ADDR=0x%0h, DATA=0x%0h, TIME=%0t", 
            read_transactions.size(), trans.PADDR, trans.PRDATA, $time), UVM_LOW)
    endfunction

    //** Test Type Detection Function
    virtual function bit is_error_test();
        // Check if this is an error test by looking at transaction patterns
        // Error tests typically have invalid addresses or protocol violations
        if(write_transactions.size() > 0) begin
            // Check if any write transaction has invalid address (> 31)
            if(write_transactions[write_transactions.size()-1].addr > 31) begin
                return 1; // This is an error test
            end
        end
        if(read_transactions.size() > 0) begin
            // Check if any read transaction has invalid address (> 31)
            if(read_transactions[read_transactions.size()-1].addr > 31) begin
                return 1; // This is an error test
            end
        end
        return 0; // Normal test
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.PCLK) begin
                #1;
                // Handle error cases first 
                if(WPSLVERR || RPSLVERR) begin
                    if(is_error_test()) begin
                        // For error tests: Report the error but still do comparison
                        if(WPSLVERR) begin
                            `uvm_warning(get_full_name(), "WRITE ERROR: PSLVERR detected for invalid address")
                        end
                        if(RPSLVERR) begin
                            `uvm_warning(get_full_name(), "READ ERROR: PSLVERR detected for invalid address")
                        end
                        // Still do comparison for error tests
                        if(write_q.size() >0 && read_q.size() >0) begin 
                            read_data  = read_q.pop_front();
                            write_data = write_q.pop_front();
                            compare();
                        end
                    end else begin
                        // For normal tests: Remove errored transactions (existing behavior)
                        if(WPSLVERR) void'(write_q.pop_front());
                        if(RPSLVERR) void'(read_q.pop_front());
                    end
                    // Reset error flags
                    WPSLVERR = 0;
                    RPSLVERR = 0;
                end
                else begin
                    // Normal comparison: Check if both queues have data
                    if(write_q.size() >0 && read_q.size() >0) begin 
                        read_data  = read_q.pop_front();//Get oldest read data
                        write_data = write_q.pop_front();//Get oldest write data
                       compare();// Compare read and write data
                    end
                end
            end
        end
    endtask

    //** Enhanced Comparison Function with Transaction Tracking
    virtual function void compare();
        if(write_data == read_data) begin
            `uvm_info(get_full_name(), $sformatf("COMPARE[%0d]:  PASS - W=0x%0h, R=0x%0h", 
                transaction_id, write_data, read_data), UVM_LOW)
            compare_pass++;
        end
        else begin
            `uvm_error(get_full_name(), $sformatf("COMPARE[%0d]:  FAIL - W=0x%0h, R=0x%0h", 
                transaction_id, write_data, read_data))
            compare_fail++;
        end
        transaction_id++;
    endfunction

    //** ENHANCED REPORT PHASE - Professional Format
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(get_type_name(), "|==============================================================|", UVM_NONE)
        `uvm_info(get_type_name(), "|                    APB SCOREBOARD REPORT                     |", UVM_NONE)
        `uvm_info(get_type_name(), "|==============================================================|", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("| SIMULATION TIME:    %0t ns                                   |", $time), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("| TOTAL TRANSACTIONS: %0d (Write)+ %0d(Read)=%0dTotal               |", 
            write_transactions.size(), read_transactions.size(), 
            write_transactions.size() + read_transactions.size()), UVM_NONE)
        `uvm_info(get_type_name(), "|==============================================================|", UVM_NONE)
        
        // Transaction Summary Table
        `uvm_info(get_type_name(), "| TRANSACTION SUMMARY:                                         |", UVM_NONE)
        `uvm_info(get_type_name(), "| |====|=========|===========|==========|==================|   |", UVM_NONE)
        `uvm_info(get_type_name(), "| | ID |  TYPE   |  ADDRESS  |  DATA    |      TIME        |   |", UVM_NONE)
        `uvm_info(get_type_name(), "| |====|=========|===========|==========|==================|   |", UVM_NONE)

        // Show first 4 write transactions
        for(int i = 0; i < 4 && i < write_transactions.size(); i++) begin
            `uvm_info(get_type_name(), $sformatf("| | %0d  |  WRITE  |   0x%0h     |0x%0h|      %0t         |    |", 
                i+1, write_transactions[i].addr, write_transactions[i].data, write_transactions[i].time_stamp), UVM_NONE)
        end
        
        // Show first 4 read transactions
        for(int i = 0; i < 4 && i < read_transactions.size(); i++) begin
            `uvm_info(get_type_name(), $sformatf("| | %0d  |  READ   |   0x%0h     |0x%0h|      %0t         |    |", 
                i+5, read_transactions[i].addr, read_transactions[i].data, read_transactions[i].time_stamp), UVM_NONE)
        end

        `uvm_info(get_type_name(), "| |====|=========|===========|==========|==================|    |", UVM_NONE)
        `uvm_info(get_type_name(), "|==========================================================|    |", UVM_NONE)

        // Results Section
        `uvm_info(get_type_name(), "| VERIFICATION RESULTS:                                         |", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("|  PASS COUNT: %0d                                                |", compare_pass), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("|  FAIL COUNT: %0d                                                |", compare_fail), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("|  SUCCESS RATE: %0d%%                                           |", 
            (compare_pass * 100) / (compare_pass + compare_fail)), UVM_NONE)
        
        if(compare_fail == 0) begin
            `uvm_info(get_type_name(), "|  STATUS: ALL TESTS PASSED!                                    |", UVM_NONE)
        end else begin
            `uvm_error(get_type_name(), $sformatf("|  STATUS: %0d TESTS FAILED!                    |", compare_fail))
        end

        `uvm_info(get_type_name(), "|===============================================================|", UVM_NONE)
    endfunction
    
endclass: scoreboard


