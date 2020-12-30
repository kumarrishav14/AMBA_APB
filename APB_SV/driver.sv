/*  Driver is implemeted using the different operating states of the APB Protocol. The different states are 
    implemented as task. The drive task switches between different state according to the PREADY signal and 
    the no of transfers that needs to be done. */
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

    // idle task - IDLE operating state
    task idle();
        drv_intf.drv_cb.PSEL1   <= 0;
        drv_intf.drv_cb.PENABLE <= 0;
    endtask //idle

    // setup task - SETUP operating state (Sets all the input for the slave)
    task setup();
        // #2;
        drv_intf.drv_cb.PSEL1   <= 1;
        drv_intf.drv_cb.PENABLE <= 0;
        drv_intf.drv_cb.PRESETn <= trans.PRESETn;
        drv_intf.drv_cb.PWRITE  <= trans.PWRITE;
        drv_intf.drv_cb.PWDATA  <= trans.PWDATA[i];
        drv_intf.drv_cb.PADDR   <= trans.PADDR[i];
    endtask

    // access task - ACCESS operating state
    task access();
        drv_intf.drv_cb.PSEL1   <= 1;
        drv_intf.drv_cb.PENABLE <= 1;
    endtask

    // drive task - Switches b/w different operating states
    task drive();
        if(!trans.PRESETn) begin
            @(drv_intf.drv_cb);
            drv_intf.drv_cb.PRESETn <= trans.PRESETn;
            #10;
            drv_intf.drv_cb.PRESETn <= 1;
        end
        else begin  
            @(drv_intf.drv_cb);
            for(i=0; i<trans.PADDR.size(); i++) begin
                setup();
                @(drv_intf.drv_cb);
                access();
                wait(drv_intf.drv_cb.PREADY == 1);
            end
        end
        idle();
    endtask

    // Entry point of the driver class. Starts driver and triggers event that a
    // particular packet transfer is completed.
    task start();
        fork
            forever begin
                idle();
                gen2drv.get(trans);
                // trans.printf("FROM GENERATOR");
                drive();
                ->drv_done;
            end
        join_none
    endtask
endclass //driver