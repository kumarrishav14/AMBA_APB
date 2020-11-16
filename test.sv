`include "environment.sv"

class test;
    environment env;

    virtual APB_intf intf;

    const int no_of_testcases = 150;
    function new(virtual APB_intf intf);
        this.intf = intf;
        env = new(intf, no_of_testcases);
    endfunction //new()

    task run_test();
        env.build();
        env.run();
        #20 $finish;
    endtask //run_test()
endclass //test