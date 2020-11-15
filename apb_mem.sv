module apb_mem #(parameter DEPTH = 5) (
    input PCLK, PRESETn, PSEL1, PWRITE, 
    input [31:0] PADDR, PWDATA,
    output reg [31:0] PREADY, 
    output reg PRDATA, PSLVERR
);
    // logic PCLK, PRESETn, PSEL1, PWRITE, PREADY, PSLVERR;
    // logic [31:0] PWDATA, PRDATA, PADDR;

    reg [31:0] mem [DEPTH-1:0];

    always @(posedge PCLK or negedge PRESETn) begin
        if(!PRESETn) begin
            foreach(mem[i]) mem[i] = 32'hffffffff;
            PREADY <= 0;
            PRDATA <= 32'hz;
            PSLVERR <= 0;
        end
        if(PSEL1) begin
            PREADY <= 1;
            PSLVERR <= 0;
            if(PENABLE) begin
                if(PADDR >= 2**DEPTH) begin
                    PSLVERR <= 1;
                    $error("Memory Address more than limits");
                end
                    
                else begin
                    if (PWRITE) begin
                        if(PWDATA === 32'hx || PWDATA === 32'hz) begin
                            PSLVERR <= 1;
                            $error("Invalid data in PWDATA line");
                        end
                        else
                            mem[PADDR[DEPTH-1:0]] = PWDATA;
                    end
                    else begin
                        if(mem[PADDR[DEPTH-1:0]] == 32'hffffffff)
                            PSLVERR <= 1;
                        else begin
                            PRDATA <= mem[PADDR[DEPTH-1:0]];
                        end
                    end
                end
            end
            else begin
                PREADY <= 0;
            end
        end
    end
endmodule