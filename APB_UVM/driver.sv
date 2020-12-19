import uvm_pkg::*;
class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)
    
    //  Group: Variables
    transaction trans_drv;
    virtual APB_intf.DRV drv_intf;
    int i;
    
    //  Group: Functions
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
        drv_intf.drv_cb.PRESETn <= trans_drv.PRESETn;
        drv_intf.drv_cb.PWRITE  <= trans_drv.PWRITE;
        drv_intf.drv_cb.PWDATA  <= trans_drv.PWDATA[i];
        drv_intf.drv_cb.PADDR   <= trans_drv.PADDR[i];
    endtask

    // access task - ACCESS operating state
    task access();
        drv_intf.drv_cb.PSEL1   <= 1;
        drv_intf.drv_cb.PENABLE <= 1;
    endtask

    // drive task - Switches b/w different operating states
    task drive();
        if(!trans_drv.PRESETn) begin
            @(drv_intf.drv_cb);
            drv_intf.drv_cb.PRESETn <= trans_drv.PRESETn;
            #10;
            drv_intf.drv_cb.PRESETn <= 1;
        end
        else begin  
            @(drv_intf.drv_cb);
            for(i=0; i<trans_drv.PADDR.size(); i++) begin
                setup();
                @(drv_intf.drv_cb);
                access();
                wait(drv_intf.drv_cb.PREADY == 1);
            end
        end
        idle();
    endtask

    //  Constructor: new
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    //  Function: build_phase
    extern function void build_phase(uvm_phase phase);
    
    //  Function: run_phase
    extern task run_phase(uvm_phase phase);
    
endclass //drvier extends uvm_driver#(transaction)

function void driver::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual APB_intf)::get(this, "*", "vif", drv_intf))
        `uvm_fatal(get_name(), "Cant get interface")    
endfunction: build_phase

task driver::run_phase(uvm_phase phase);
    forever begin
        seq_item_port.get_next_item(trans_drv);
        drive();
        seq_item_port.item_done();
    end
endtask: run_phase

