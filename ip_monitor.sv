class ip_monitor;
    virtual APB_intf.IPMON ipmon_intf;

    mailbox #(transaction) ipmon2opmon;

    transaction trans, trans2opmon;
    function new(virtual APB_intf.IPMON ipmon_intf, mailbox #(transaction) ipmon2opmon);
        this.ipmon_intf = ipmon_intf;
        this.ipmon2opmon = ipmon2opmon;

        trans = new;
    endfunction //new()

    task monitor();
        forever begin
            if(ipmon_intf.ipmon_cb.PSEL1 == 1) begin
                wait(ipmon_intf.ipmon_cb.PENABLE == 1);
                trans.PWRITE = ipmon_intf.ipmon_cb.PWRITE;
                if(ipmon_intf.ipmon_cb.PSEL1 == 1) break;
            end      
        end
        

    endtask

    task start();
        fork
            forever begin
                monitor();
                trans2opmon = new trans;
                trans2opmon.printf("TO OPMON");
                ipmon2opmon.put(trans2opmon);
            end
        join
    endtask
endclass //ip_moitorn