import uvm_pkg::*;
class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    //  Group: Variables
    rnd_sequence seq;
    driver drv;
    uvm_sequencer#(transaction) seqr;

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

    //  Function: end_of_elaboration_phase
    extern function void end_of_elaboration_phase(uvm_phase phase);
    
    //  Function: run_phase
    extern task run_phase(uvm_phase phase);
    
endclass //agent extends uvm_agent

function void agent::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    //super.build_phase(phase);

    seq = rnd_sequence::type_id::create("seq");
    drv = driver::type_id::create("drv", this);
    seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
    
endfunction: build_phase

function void agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv.seq_item_port.connect(seqr.seq_item_export);
endfunction: connect_phase

function void agent::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
endfunction: end_of_elaboration_phase


task agent::run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(seqr);
    phase.drop_objection(this);
endtask: run_phase


