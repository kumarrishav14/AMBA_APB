import uvm_pkg::*;

class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    
    // Components
    uvm_analysis_port#(transaction) ap;

    // Variables
    virtual APB_intf.MON intf;
    transaction trans;
    int ip_pntr, op_pntr;
    bit sampled;
    bit pck_complete;

    //   Methods
    // -------------

    task ip_mon();
        @(intf.mon_cb);
        if(intf.mon_cb.PENABLE == 1 && !sampled) begin
            trans.PWRITE    = intf.mon_cb.PWRITE;
            trans.PSEL1     = intf.mon_cb.PSEL1;
            trans.PRESETn   = intf.mon_cb.PRESETn;
            trans.increaseSize();
            trans.PADDR[ip_pntr]  = intf.mon_cb.PADDR;
            trans.PWDATA[ip_pntr] = intf.mon_cb.PWDATA;
            ip_pntr++;
            sampled = 1;
        end
        if(intf.mon_cb.PENABLE == 0) sampled = 0;
    endtask

    task op_mon();
        @(intf.mon_cb);
        if(intf.mon_cb.PREADY == 1 && intf.mon_cb.PENABLE == 1) begin
            trans.PREADY = intf.mon_cb.PREADY;
            trans.PSLVERR = intf.mon_cb.PSLVERR;
            trans.PRDATA[op_pntr]  = intf.mon_cb.PRDATA;
            op_pntr++;
            pck_complete = 1;
        end 
    endtask

    // Constructor: new
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    //  Function: build_phase
    extern function void build_phase(uvm_phase phase);
    
    //  Function: run_phase
    extern task run_phase(uvm_phase phase);
    
endclass //monitor extends uvm_monitor

function void monitor::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual APB_intf)::get(this, "*", "vif", intf))
        `uvm_fatal(get_name(), "Cant get interface") 
    ap = new("ap", this);
    trans = new("sam_trans");
endfunction: build_phase

task monitor::run_phase(uvm_phase phase);
    forever begin
        fork
            ip_mon();
            op_mon();
        join
        `uvm_info(get_name(), $sformatf("pck_complete: %b, PSEL1: %b", pck_complete, intf.mon_cb.PSEL1), UVM_HIGH)
        if(pck_complete && !intf.mon_cb.PSEL1) begin
            `uvm_info(get_name(), $sformatf("Sampled Packet is: %s", trans.convert2string()), UVM_HIGH)
            ap.write(trans);
            trans = new("sam_trans");
            ip_pntr = 0;
            op_pntr = 0;
            pck_complete = 0;
        end
    end
endtask: run_phase

