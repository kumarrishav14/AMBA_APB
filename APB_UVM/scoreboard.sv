import uvm_pkg::*;

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // Components
    ref_model rm;
    uvm_analysis_imp#(transaction, scoreboard) ap_exp;

    // Variable
    transaction act_trans, exp_trans;
    int passCnt, failCnt;
    
    // Function:check()
    function void check();
        if(act_trans.compare(exp_trans)) begin
            `uvm_info("SCB", $sformatf("%s\nStatus -> PASSED", act_trans.convert2string()), UVM_NONE)
            passCnt++;
        end
        else begin
            `uvm_error("SCB", $sformatf("Actual Packet: %s\nExpected Packet: %s\nStatus -> FAILED", 
                    act_trans.convert2string(), exp_trans.convert2string()))
            failCnt++;
        end
    endfunction
    
    // Constructor: new
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    //  Function: build_phase
    extern function void build_phase(uvm_phase phase);
    
    //  Function: connect_phase
    extern function void connect_phase(uvm_phase phase);
    
endclass //scoreboard extends uvm_scoreboard

function void scoreboard::build_phase(uvm_phase phase);
    rm = ref_model::type_id::create("rm", this);
    act_trans = new("act_trans");
    ap_exp = new("ap_exp", this);
endfunction: build_phase
