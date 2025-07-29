import uvm_pkg::*;//contain all uvm base classes
import pkg::*;
`include "uvm_macros.svh"//contain all uvm macros

// Global clock and reset signals
bit PCLK;
bit PRESET; // Active low

module top();
    // Generate clock and reset signals
    initial begin
        PCLK = 1'b0;
        forever #5 PCLK = ~PCLK;
    end

    initial begin
        PRESET = 1'b1;
        `uvm_info("TOP", $sformatf("RESET is applied"), UVM_LOW);
        #15;
        PRESET = 1'b0;
        `uvm_info("TOP", $sformatf("RESET is released"), UVM_LOW);
    end

    // Instantiate interface with clock and reset connections
    intf intf(.PCLK(PCLK), .PRESET(PRESET));

    AMBA_APB dut (         //Instantiate  dut
        .PCLK(intf.PCLK),
        .PRESET(intf.PRESET),
        .PSEL(intf.PSEL),
        .PENABLE(intf.PENABLE),
        .PWRITE(intf.PWRITE),
        .PADDR(intf.PADDR),
        .PWDATA(intf.PWDATA),
        .PRDATA(intf.PRDATA),
        .PREADY(intf.PREADY),
        .PSLVERR(intf.PSLVERR)
    );

    initial begin
        uvm_config_db#(virtual intf)::set(null, "*", "vif", intf);
        //set interface into config db, virtual int, to get access in dynamic class
        //virual is type,fifo_interface is class name, nulll path because we are at top module
        //* means all lower componenets get access to it, "vif" is key through which any component can access
        //in (value) is handle/instance of interface.
        run_test();  // Specify the test class name
    end
endmodule