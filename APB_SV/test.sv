
/* Directed test cases. Overriding the default transaction class to make it directed 
   More cases can be added in here*/
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
// *************************************************************************************************

class test;
    environment env;

    virtual APB_intf intf;

    int no_of_testcases = 50;

    // Handle creation for child classes
    write_transaction wr_trans;
    read_transaction rd_trans;
    function new(virtual APB_intf intf);
        this.intf = intf;
        env = new(intf, no_of_testcases);
        // Handle creation for child classes
        wr_trans = new();
        rd_trans = new();
    endfunction //new()

    /* Replace the below task with following statement to run random test cases:
       env.build();
       env.run();*/
    task run_test();
        env.no_of_testcases = 800;
        env.build();
        env.run();
        // env.no_of_testcases = 50;
        // env.build();
        // env.gen.trans = wr_trans;
        // env.run();
        // env.build();
        // env.gen.trans = rd_trans;
        // env.run();
        #20 $finish;
    endtask //run_test()
endclass //test