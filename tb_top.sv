`include "test.sv"
`include "interface.sv"
`include "apb_mem.sv"

module tb_top;
    bit clk;

    APB_intf intf(clk);

    test exp;

    apb_mem dut(._PCLK(clk), ._PRESETn(intf.PRESETn), ._PSEL1(intf.PSEL1), ._PWRITE(intf.PWRITE), 
                ._PENABLE(intf.PENABLE), ._PADDR(intf.PADDR), ._PWDATA(intf.PWDATA),
                ._PRDATA(intf.PRDATA), ._PREADY(intf.PREADY), ._PSLVERR(intf.PSLVERR));

    always #5 clk = ~clk;

    initial begin
        @(posedge clk);
        intf.drv_cb.PRESETn <= 0;
        #10;
        intf.drv_cb.PRESETn <= 1;
        exp = new(intf);
        exp.run_test();
    end
endmodule