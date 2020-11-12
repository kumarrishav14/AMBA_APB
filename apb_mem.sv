module apb_mem #(parameter DEPTH = 5); (
    input PCLK, PRESETn, PSEL1, PWRITE, PADDR, PWDATA;
    output PREADY, PRDATA, PSLVERR;
);
    logic PCLK, PRESETn, PSEL1, PWRITE, PREADY, PSLVERR;
    logic [31:0] PWDATA, PRDATA, PADDR;

    reg [31:0] mem [DEPTH-1:0];

    always @(posedge PCLK or negedge PRESETn) begin
        if(!PRESETn) begin
            foreach(mem[i]) mem[i] = 32'hffffffff;
        end
        if(PSEL1) begin
            PREADY <= 1;
            PSLVERR <= 0;
            if(PADDR >= 2**DEPTH)
                PSLVERR <= 1;
            else begin
                if (PWRITE) begin
                    mem[PADDR[DEPTH-1:0]] = PWDATA;
                end
                else begin
                    if(mem[PADDR[DEPTH-1:0]] == 32'hffffffff])
                        PSLVERR <= 1;
                    else begin
                        PRADTA <= mem[PADDR[DEPTH-1:0]];
                    end
                end
            end
        end
    end
endmodule