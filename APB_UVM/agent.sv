import uvm_pkg::*;
class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    //  Group: Components
    driver drv;
    monitor mon;
    uvm_sequencer#(transaction) seqr;
    fun_cov fc;
    uvm_analysis_port#(transaction) ap;

    //  Group: Variables
    rnd_sequence seq;
    agent_config agnt_cfg;

    //  Group: Constraints


    //  Group: Functions

    //  Constructor: new
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    //  Function: build_phase
    extern function void build_phase(uvm_phase phase);
    
    //  Function: connect_phase
    extern function void connect_phase(uvm_phase phase);
    
endclass //agent extends uvm_agent

function void agent::build_phase(uvm_phase phase);
    if(!uvm_config_db#(agent_config)::get(this, "*", "agnt_cfg", agnt_cfg))
        `uvm_fatal(get_name(), "agnt_cfg cannot be found in ConfigDB!")
    
    mon = monitor::type_id::create("mon", this);
    if(agnt_cfg.active) begin
        drv = driver::type_id::create("drv", this);
        seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
    end
    
    if(agnt_cfg.has_fun_cov)
        fc = fun_cov::type_id::create("fc", this);
endfunction: build_phase

function void agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon.intf = agnt_cfg.intf;
    ap = mon.ap;

    if(agnt_cfg.active) begin
        drv.seq_item_port.connect(seqr.seq_item_export);
        drv.drv_intf = agnt_cfg.intf;
    end

    if(agnt_cfg.has_fun_cov)
        mon.ap.connect(fc.analysis_export);
endfunction: connect_phase


