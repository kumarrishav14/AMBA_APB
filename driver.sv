class driver;
    virtual APB_intf.DRV drv_intf;
    mailbox #(transaction) gen2drv;

    event drv_done;

    transaction trans;

    function new(virtual APB_intf.DRV drv_intf, mailbox #(transaction) gen2drv, event drv_done);
        this.drv_intf = drv_intf;
        this.gen2drv = gen2drv;
        this.drv_done = drv_done;

        trans = new;
    endfunction //new()

    task drive();
        @(drv_intf.drv_cb);
        drv_intf.drv_cb.PSEL1   <= trans.PSEL1;
        drv_intf.drv_cb.PWRITE  <= trans.PWRITE;
        drv_intf.drv_cb.PWDATA  <= trans.PWDATA;
        drv_intf.drv_cb.PADDR   <= trans.PADDR;
        drv_intf.drv_cb.PRESETn <= trans.PRESETn;
        for(int i=1; i<trans.PADDR.size(); i++) begin
            wait(PREADY == 1);
            drv_intf.drv_cb.PWRITE  <= trans.PWRITE;
            drv_intf.drv_cb.PWDATA  <= trans.PWDATA;
            drv_intf.drv_cb.PADDR   <= trans.PADDR;
            drv_intf.drv_cb.PRESETn <= trans.PRESETn;
        end
        @(drv_intf.drv_cb);
        
        drv_intf.drv_cb.PWRITE  <= trans.PWRITE;
        drv_intf.drv_cb.PWDATA  <= trans.PWDATA;
        drv_intf.drv_cb.PADDR   <= trans.PADDR;
        drv_intf.drv_cb.PRESETn <= trans.PRESETn;
        @(drv_intf.drv_cb);
        drv_intf.drv_cb.ENABLE  <= trans.PENABLE;
    endtask

    task start();
        fork
            forever begin
                gen2drv.get(trans);
                trans.printf("FROM GENERATOR");
                drive();
                ->drv_done;
            end
        join_none
    endtask
endclass //driver