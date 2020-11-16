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
            begin
                trans.p_id = 1;
                trans.f_id = 5; 
                trans.PRESETn = 0;
                trans.PADDR = {32'h0};
                trans.PWDATA = {32'h0};
                trans2drv = new trans;
                trans2drv.printf("TO DRV");
                gen2drv.put(trans2drv);
                @(drv_done); #2;
                for (int i = 0; i < no_of_testcases-1; i++) begin
                    run();
                    trans2drv = new trans;
                    trans2drv.printf("TO DRV");
                    gen2drv.put(trans2drv);
                    @(drv_done); #2;
                end
            end
        join_none
    endtask
endclass //generator