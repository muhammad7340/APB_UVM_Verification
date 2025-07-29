module AMBA_APB(PSEL, PENABLE, PADDR, PWRITE, PRESET, PWDATA, PCLK, PREADY, PRDATA, PSLVERR);

    input  bit         PSEL;//select
    input  bit         PENABLE;//enable
    input  bit [31:0]  PADDR;//address
    input  bit         PWRITE;//write enable
    input  bit [31:0]  PWDATA;//write data
    input  bit         PCLK;//clock
    // input  [3:0]  PSTRB;
    input  bit         PRESET; //Active low

    output reg  [31:0] PRDATA;//read data
    output reg         PREADY;//ready signal
    output reg         PSLVERR;//slave error signal

    // State encoding
    parameter IDLE   = 2'b00;
    parameter SETUP  = 2'b01;
    parameter ACCESS = 2'b10;

    reg [1:0]  ps, ns;//ps: present state, ns: next state
    reg [31:0] mem [31:0];//memory array
    
    // Address range check
    wire address_valid = (PADDR >= 0) && (PADDR <= 31);

    always @(posedge PCLK) begin
        if (PRESET)
            ps = IDLE;
        else
            ps = ns;
    end
    // State transition logic
    always @(*) begin
        case (ps)
            IDLE: begin
                if (PSEL == 1 & PENABLE == 0)
                    ns = SETUP;
                if (PSEL == 0 & PENABLE == 0)
                    ns = IDLE;
            end
            SETUP: begin
                if (PSEL == 1 & PENABLE == 1) begin
                    ns = ACCESS;
                    PREADY = 1;
                    if (PWRITE) begin
                        if (address_valid) begin
                            mem[PADDR] = PWDATA;
                            PSLVERR = 0; // No error for valid address
                        end else begin
                            PSLVERR = 1; // Error for invalid address
                        end
                    end
                    else begin
                        if (address_valid) begin
                            PRDATA = mem[PADDR];
                            PSLVERR = 0; // No error for valid address
                        end else begin
                            PRDATA = 32'hDEADBEEF; // Error data for invalid address
                            PSLVERR = 1; // Error for invalid address
                        end
                    end
                    //ns = SETUP;
                end
                if (PSEL == 0 & PENABLE == 0)
                    ns = IDLE;
            end
            ACCESS: begin
                if (PSEL == 0 & PENABLE == 0)
                    ns = IDLE;
                PREADY = 0;
                if (PSEL == 1 & PENABLE == 1)
                    ns = ACCESS;
            end
        endcase
    end

endmodule