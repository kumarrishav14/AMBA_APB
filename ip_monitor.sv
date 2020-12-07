/*  Input monitor will make the transaction packet from the sampled APB signals (MASTER -> SLAVE).
    As some packets may have mutiple transfer cycle in one packet, packet construction is bit complicated
    Whenever driver completes transfer of one packet it triggers drv_done event which is used in monitor 
    as a signal that one packet has completed and send it to scoreboard. */

class ip_monitor;
    // Interface and communication variables
    virtual APB_intf.IPMON ipmon_intf;
    mailbox #(transaction) ipmon2rm;
    event drv_done;

    transaction trans, trans2rm;

    // Helper variables
    int i;
    bit sampled;

    function new(virtual APB_intf.IPMON ipmon_intf, mailbox #(transaction) ipmon2rm, event drv_done);
        this.ipmon_intf = ipmon_intf;
        this.ipmon2rm = ipmon2rm;
        this.drv_done = drv_done;

        trans = new;
    endfunction //new()

    /*  monitor task will sample the signals only when the PENABLE is HIGH (all signals are stable). Also
        as the PENABLE can be HIGH for more than 1 cycle due to wait cycles, but the values needs to be sampled 
        only once per PENABLE high. 
        NOTE: $rose() does not work. To make $rose() work, implementation is complicated*/
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

    // Starts the monitor. sends the packet to the Scoreboard only when driver completes
    // the transfer (indicated by drv_done)
    task start();
        fork
            i = 0;
            forever begin
                monitor();
                if(drv_done.triggered) begin
                    trans2rm = new trans;
                    // trans2rm.printf("SAMPLED DATA BY IPMON");
                    ipmon2rm.put(trans2rm);
                    trans = new;
                    i = 0;
                end
            end
        join_none
    endtask
endclass //ip_moitorn