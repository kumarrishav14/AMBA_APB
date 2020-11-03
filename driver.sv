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
endclass //driver