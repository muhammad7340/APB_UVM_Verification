interface intf (input bit PCLK,input bit PRESET);

 bit           PSEL;
 bit           PENABLE;
 bit           PWRITE;
 bit   [0:3]   PSTRB;

 logic [31:0]  PADDR;
 logic [31:0]  PWDATA;     
 logic [31:0]  PRDATA;

 bit           PREADY;
 bit           PSLVERR;
 
 initial begin
    $display("APB Interface instantiated at time %0t", $time);
 end
endinterface:intf
