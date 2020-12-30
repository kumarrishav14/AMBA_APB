`include "package.svh"
`include "apb_mem.sv"

module top;
    bit clk;

    APB_intf intf(clk);

    apb_mem dut(._PCLK(clk), ._PRESETn(intf.PRESETn), ._PSEL1(intf.PSEL1), ._PWRITE(intf.PWRITE), 
                ._PENABLE(intf.PENABLE), ._PADDR(intf.PADDR), ._PWDATA(intf.PWDATA),
                ._PRDATA(intf.PRDATA), ._PREADY(intf.PREADY), ._PSLVERR(intf.PSLVERR));

    always #5 clk = ~clk;

    initial begin
        uvm_config_db#(virtual APB_intf)::set(null, "*", "vif", intf);
        run_test("base_test");
    end
endmodule