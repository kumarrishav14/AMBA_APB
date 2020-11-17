`include "generator.sv"
`include "driver.sv"
`include "ip_monitor.sv"
`include "op_monitor.sv"
`include "ref_model.sv"
`include "scoreboard.sv"

class environment;
    transaction trans;
    generator gen;
    driver drv;
    ip_monitor ipmon;
    op_monitor opmon;
    ref_model rm;
    scoreboard sb;

    virtual APB_intf.DRV drv_intf;
    virtual APB_intf.IPMON ipmon_intf;
    virtual APB_intf.OPMON opmon_intf;

    mailbox #(transaction) gen2drv;
    mailbox #(transaction) ipmon2rm;
    mailbox #(transaction) opmon2sb;
    mailbox #(transaction) rm2sb;
    event drv_done;

    int no_of_testcases;
    function new(virtual APB_intf intf, int no_of_testcases);
        drv_intf = intf;
        ipmon_intf = intf;
        opmon_intf = intf;

        gen2drv = new();
        ipmon2rm = new();
        opmon2sb = new();
        rm2sb = new();

        this.no_of_testcases = no_of_testcases;
    endfunction //new()

    task build();
        gen = new(gen2drv, drv_done, no_of_testcases);
        drv = new(drv_intf, gen2drv, drv_done);
        ipmon = new(ipmon_intf, ipmon2rm, drv_done);
        opmon = new(opmon_intf, opmon2sb, drv_done);
        rm = new(ipmon2rm, rm2sb);
        sb = new(rm2sb, opmon2sb, no_of_testcases);
    endtask //build()

    task start();   
        gen.start();
        drv.start();
        ipmon.start();
        opmon.start();
        rm.start();
        sb.start();
    endtask //start()

    task stop();
        wait(sb.TEST_DONE.triggered);
        $display("TEST COMPLETED");
        sb.print_report;
    endtask //stop()

    task run();
        start();
        stop();
    endtask //run()
endclass //environment