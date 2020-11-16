`include "environment.sv"
class write_transaction extends transaction;
    function new();
        PWRITE.rand_mode(0);
        PWRITE = 1;
    endfunction //new()
endclass //write_transaction extends transaction
class read_transaction extends transaction;
    function new();
        PWRITE.rand_mode(0);
        PWRITE = 0;
    endfunction //new()
endclass //write_transaction extends transaction
class test;
    environment env;

    virtual APB_intf intf;

    const int no_of_testcases = 50;

    write_transaction wr_trans;
    read_transaction rd_trans;
    function new(virtual APB_intf intf);
        this.intf = intf;
        env = new(intf, no_of_testcases);
        wr_trans = new();
        rd_trans = new();
    endfunction //new()

    task run_test();
        env.build();
        env.gen.trans = wr_trans;
        env.run();
        env.build();
        env.gen.trans = rd_trans;
        env.run();
        #20 $finish;
    endtask //run_test()
endclass //test