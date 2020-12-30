import uvm_pkg::*;
//  Class: rnd_sequence
//  Generates random sequence
class rnd_sequence extends uvm_sequence;
    `uvm_object_utils(rnd_sequence);

    //  Group: Variables
    transaction trans;
    int no_of_testcases;
    //  Group: Constraints


    //  Group: Functions

    //  Constructor: new
    function new(string name = "rnd_seq");
        super.new(name);
        trans = transaction::type_id::create("trans");
        if(!uvm_config_db#(int)::get(null, "seq.", "no_cases", no_of_testcases)) begin
            `uvm_warning(get_name(), "Cant get no of testcases, Using default no of test cases = 10")
            no_of_testcases = 10;
        end
    endfunction: new

    //  Task: pre_body
    //  This task is a user-definable callback that is called before the execution 
    //  of <body> ~only~ when the sequence is started with <start>.
    //  If <start> is called with ~call_pre_post~ set to 0, ~pre_body~ is not called.
    extern virtual task pre_body();

    //  Task: body
    //  This is the user-defined task where the main sequence code resides.
    extern virtual task body();
    
endclass: rnd_sequence

task rnd_sequence::pre_body();
    start_item(trans);
    trans.p_id = 1;
    trans.f_id = 5; 
    trans.PRESETn = 0;
    trans.PADDR = {32'h0};
    trans.PWDATA = {32'h0};
    finish_item(trans);
endtask

task rnd_sequence::body();
    for (int i = 0; i < no_of_testcases-1; i++) begin
        start_item(trans);
        if(!trans.randomize())
            `uvm_fatal(get_name(), "Randomization failed");
        `uvm_info(get_name(), trans.convert2string(), UVM_MEDIUM)
        
        finish_item(trans);
    end
endtask: body
