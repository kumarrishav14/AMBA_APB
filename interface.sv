/*  4 Property of APB Protocol is asserted
    1. PENABLE should be HIGH one clock cycle after PSEL1 rise (0 -> 1)
    2. All signals are stable or not when PENABLE is ASSERTED 
    3. PENABLE should fall (1 -> 0) one cycle after PREADY is ASSERTED
    4. PENABLE should not fall, even if PREADY is not ASSERTED */
    
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
        output #1 PWRITE, PWDATA, PADDR, PENABLE, PRESETn, PSEL1;
        input PREADY; 
    endclocking
    clocking ipmon_cb @(posedge clk);
        input PWRITE, PWDATA, PADDR, PENABLE, PRESETn, PSEL1; 
    endclocking
    clocking opmon_cb @(posedge clk);
        input #1 PRDATA, PREADY, PSLVERR, PENABLE; 
    endclocking

    modport DRV (clocking drv_cb);
    modport IPMON(clocking ipmon_cb);
    modport OPMON(clocking opmon_cb);

    // Property to check whether PENABLE is asserted 1 clk after PSEL1 is asserted
    property enable_ch;
        @(posedge clk) $rose(PSEL1) |=> PENABLE;
    endproperty

    // Property to check whether all signal are stable or not during the PENABLE assertion
    property stable_ch;
        @(posedge clk) $rose(PENABLE) |-> $stable(PADDR) ##0 $stable(PWDATA) ##0 $stable(PWRITE) ##0 $stable(PSEL1);
    endproperty

    // Property to check whether the PENABLE is deasserted 1 clk after PREADY signal is asserted
    sequence s1;
        !($past(PENABLE, 2) && $past(PREADY, 2));
    endsequence
    property enable_deassert_ch;
        @(posedge clk) $fell(PENABLE) |-> s1;
    endproperty
    
    // Property to check whether the PENABLE is deasserted without PREADY being asserted
    property enable_deassert_ch2;
        @(posedge clk) 
        if(!$isunknown(PENABLE))
            $fell(PENABLE) |-> $past(PREADY) == 1;
    endproperty

    // All properties defined earlier are asserted here.
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

    assert property (enable_deassert_ch2) 
        $info("PENABLE DEASSERTED WHEN PREADY ASSERTED");
    else
        $error("PENABLE GETTING DEASSERTED WITHOUT PREADY BEING ASSERTED");
endinterface