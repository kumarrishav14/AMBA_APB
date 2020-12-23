import uvm_pkg::*;

class environment extends uvm_env;
    `uvm_component_utils(environment)

    // Components
    agent agnt;
    scoreboard scb;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        agnt = agent::type_id::create("agnt", this);
        scb = scoreboard::type_id::create("scb", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agnt.ap.connect(scb.ap_exp);
    endfunction: connect_phase
    
    
endclass //environment extends uvm_env