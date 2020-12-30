import uvm_pkg::*;

class agent_config extends uvm_object;
    `uvm_object_utils(agent_config)

    //    Knobs & Variables
    //------------------------

    // Virtual Interface
    virtual APB_intf intf;

    // active
    uvm_active_passive_enum active = UVM_ACTIVE;

    // has_fun_cov
    bit has_fun_cov = 1;
    
    function new(string name = "agent_config");
        super.new(name);
    endfunction //new()
endclass //agent_config extends uvm_object