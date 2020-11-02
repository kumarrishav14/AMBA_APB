interface APB_intf (input logic clk);
    logic PWRITE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic [31:0] PADDR;
    logic PREADY;
    logic PRESETn;
    logic PENABLE;
    logic PSLVERR;
    logic PSEL1;

    clocking drv_cb @(posedge clk);
        output PWRITE, PWDATA, PADDR, PENABLE, PRESETn, PSEL1; 
    endclocking
    clocking ipmon_cb @(posedge clk);
        input PWRITE, PWDATA, PADDR, PENABLE, PRESETn, PSEL1; 
    endclocking
    clocking opmon_cb @(posedge clk);
        input PRDATA, PREADY, PSLVERR; 
    endclocking

    modport DRV (clocking drv_cb);
    modport IPMON(clocking ipmon_cb);
    modport OPMON(clocking opmon_cb);

    property enable_ch;
        @(posedge clk) $rose(PSEL1) |=> PENABLE;
    endproperty
    property stable_ch;
        @(posedge clk) $rose(PENABLE) |-> $stable(PADDR) ##0 $stable(PWDATA) ##0 $stable(PWRITE) ##0 $stable(PSEL1);
    endproperty
    property p1;
        $rose(PENABLE) |-> PREADY |=> $fell(PENABLE);
    endproperty
    property p2;
        $rose(PENABLE) |-> ##[0:$] $rose(PREADY) |=> $fell(PENABLE);
    endproperty
    property enable_deassert_ch;
        @(posedge clk) p1 and p2;
    endproperty
    /* property enable_deassert_ch;
        @(posedge clk) PREADY |=> $fell(PENABLE);
    endproperty */

    assert property (enable_ch) 
        $info("ENABLE DRIVED 1 CYCLE AFTER PSEL1");
    else
        $error("ENABLE NOT DRIVED 1 CYCLE AFTER PSEL1");

    assert property (stable_ch) 
        $info("ALL SIGANLS STABLE DURING PENABLE");
    else
        $error("ALL SIGANLS NOT STABLE DURING PENABLE");

    assert property (enable_deassert_ch) 
        $info("PENABLE DEASSERTED 1 CLK AFTER PREADY");
    else
        $error("PENABLE NOT DEASSERTED 1 CLK AFTER PREADY");
endinterface