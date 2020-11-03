class ip_monitor;
    virtual APB_intf.IPMON ipmon_intf;

    mailbox #(transaction) ipmon2opmon;
    event drv_done;
    transaction trans, trans2opmon;

    int i;
    bit sampled;
    function new(virtual APB_intf.IPMON ipmon_intf, mailbox #(transaction) ipmon2opmon, event drv_done);
        this.ipmon_intf = ipmon_intf;
        this.ipmon2opmon = ipmon2opmon;
        this.drv_done = drv_done;

        trans = new;
    endfunction //new()

    task monitor();
        @(ipmon_intf.ipmon_cb);
        if(ipmon_intf.ipmon_cb.PENABLE == 1 && !sampled) begin
            trans.PWRITE    = ipmon_intf.ipmon_cb.PWRITE;
            trans.PSEL1     = ipmon_intf.ipmon_cb.PSEL1;
            trans.PRESETn   = ipmon_intf.ipmon_cb.PRESETn;
            trans.increaseSize();
            trans.PADDR[i]  = ipmon_intf.ipmon_cb.PADDR;
            trans.PWDATA[i] = ipmon_intf.ipmon_cb.PWDATA;
            i++;
            sampled = 1;
        end
        if(ipmon_intf.ipmon_cb.PENABLE == 0) sampled = 0;                  
    endtask

    task start();
        fork
            i = 0;
            forever begin
                monitor();
                if(drv_done.triggered) begin
                    trans2opmon = new trans;
                    trans2opmon.printf("TO OPMON");
                    ipmon2opmon.put(trans2opmon);
                    trans = new;
                    i =0;
                end
            end
        join_none
    endtask
endclass //ip_moitorn