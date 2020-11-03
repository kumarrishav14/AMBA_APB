class driver;
    virtual APB_intf.DRV drv_intf;
    mailbox #(transaction) gen2drv;

    event drv_done;

    transaction trans;
    int i;
    function new(virtual APB_intf.DRV drv_intf, mailbox #(transaction) gen2drv, event drv_done);
        this.drv_intf = drv_intf;
        this.gen2drv = gen2drv;
        this.drv_done = drv_done;

        trans = new;
    endfunction //new()

    task drive();
        for(i=0; i<trans.PADDR.size(); i++) begin
            @(drv_intf.drv_cb);
            setup();
            @(drv_intf.drv_cb);
            access();
            wait(drv_intf.drv_cb.PREADY == 1);
            if (!(i == trans.PADDR.size()-1))
                setup();
        end
        idle();
    endtask

    task idle();
        drv_intf.drv_cb.PSEL1   <= 0;
        drv_intf.drv_cb.PENABLE <= 0;
    endtask //idle

    task setup();
        drv_intf.drv_cb.PSEL1   <= 1;
        drv_intf.drv_cb.PENABLE <= 0;
        drv_intf.drv_cb.PRESETn <= trans.PRESETn;
        drv_intf.drv_cb.PWRITE  <= trans.PWRITE;
        drv_intf.drv_cb.PWDATA  <= trans.PWDATA[i];
        drv_intf.drv_cb.PADDR   <= trans.PADDR[i];
    endtask

    task access();
        drv_intf.drv_cb.PSEL1   <= 1;
        drv_intf.drv_cb.PENABLE <= 1;
    endtask
    task start();
        fork
            forever begin
                idle();
                gen2drv.get(trans);
                trans.printf("FROM GENERATOR");
                drive();
                ->drv_done;
            end
        join_none
    endtask
endclass //driver