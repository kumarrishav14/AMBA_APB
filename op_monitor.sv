class op_monitor;
// Interface and communication variables
    virtual APB_intf.OPMON opmon_intf;
    mailbox #(transaction) ipmon2opmon;
    event drv_done;

    transaction trans, trans2sb;

    // Helper variables
    int i;
    bit sampled;

    function new(virtual APB_intf.OPMON opmon_intf, mailbox #(transaction) ipmon2opmon, event drv_done);
        this.opmon_intf = opmon_intf;
        this.ipmon2opmon = ipmon2opmon;
        this.drv_done = drv_done;

        trans = new;
    endfunction //new()

    /*  monitor task will sample the signals only when the PENABLE is HIGH (all signals are stable). Also
        as the PENABLE can be HIGH for more than 1 cycle due to wait cycles, the data is sampled only once
        per PENABLE high. 
        NOTE: $rose() does not work. To make $rose() work, implementation is complicated*/
    task monitor();
        @(opmon_intf.opmon_cb);
        if(opmon_intf.opmon_cb.PREADY == 1 && opmon_intf.opmon_cb.PENABLE == 1) begin
            trans.PSLVERR = opmon_intf.opmon_cb.PSLVERR;
            trans.PRDATA[i]  = opmon_intf.opmon_cb.PRDATA;
            i++;
        end      
    endtask

    // Starts the monitor. sends the packet to the Scoreboard only when driver completes
    // the transfer (indicated by drv_done)
    task start();
        fork
            i = 0;
            forever begin
                monitor();
                if(drv_done.triggered) begin
                    trans2sb = new trans;
                    trans2sb.printf("SAMPLED PACKET IN OPMON");
                    ipmon2opmon.put(trans2sb);
                    trans = new;
                    i = 0;
                end
            end
        join_none
    endtask
endclass //op_monitor
