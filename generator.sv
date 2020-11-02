`include "transaction.sv"
class generator;
    mailbox #(transaction) gen2drv;
    event drv_done;
    
    transaction trans, trans2drv;

    const int no_of_testcases;
    function new(mailbox #(transaction) gen2drv, event drv_done, 
                    int no_of_testcases);
        this.gen2drv = gen2drv;
        this.drv_done = drv_done;

        trans = new;
        this.no_of_testcases = no_of_testcases;
    endfunction //new()

    task run();
        trans.randomize();
    endtask

    task start();
        fork
            for (int i = 0; i < no_of_testcases; i++) begin
                run();
                trans2drv = new trans;
                trans2drv.printf("TO DRV");
                gen2drv.put(trans2drv);
                @(drv_done);
            end
        join_none
    endtask
endclass //generator