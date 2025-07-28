import uvm_pkg::*;//contain all uvm base classes
import pkg::*;
`include "uvm_macros.svh"//contain all uvm macros

// Global Instantiation
bit PCLK;
bit PRESET; // Active low

module top();
    intf intf();//Instantiate intf

    AMBA_APB dut (         //Instantiate  dut
        .PCLK(intf.PCLK),
        .PRESET(intf.PRESET),
        .PSEL(intf.PSEL),
        .PENABLE(intf.PENABLE),
        .PWRITE(intf.PWRITE),
        .PADDR(intf.PADDR),
        .PWDATA(intf.PWDATA),
        .PRDATA(intf.PRDATA),
        .PREADY(intf.PREADY)
    );

    initial begin
        intf.PCLK = 1'b0;
        forever #5 intf.PCLK = ~intf.PCLK;
    end

    initial begin
        intf.PRESET = 1'b1;
        `uvm_info("APB TOP", $sformatf("RESET is applied"), UVM_LOW);
        #15;
        intf.PRESET = 1'b0;
        `uvm_info("APB TOP", $sformatf("RESET is released"), UVM_LOW);
    end

    initial begin
        uvm_config_db#(virtual intf)::set(null, "*", "vif", intf);
        //set interface into config db, virtual int, to get access in dynamic class
        //virual is type,fifo_interface is class name, nulll path because we are at top module
        //* means all lower componenets get access to it, "vif" is key through which any component can access
        //in (value) is handle/instance of interface.
        run_test("test");  // Specify the test class name
    end
endmodule