import uvm_pkg::*;

class ref_model#(parameter DEPTH = 5) extends uvm_component;
    `uvm_component_utils(ref_model)

    // Variables
    const int ram_depth = 2**DEPTH;
    bit [31:0] ram_mem [];  // Memory for DEPTH defined

    // Function: get_ref_val()
    function transaction get_ref_val(transaction trans);
        if(trans.PRESETn == 0) begin
            foreach (ram_mem[i]) ram_mem[i] = 32'hffffffff;
            trans.PSLVERR = 0;
            //trans.PRDATA[0] = 32'b0;
            trans.PREADY = 0;
            return trans;
        end
        for(int i=0; i<trans.PADDR.size(); i++) begin
            if(trans.PADDR[i] >= ram_depth) begin
                trans.PSLVERR = 1;
                trans.PRDATA[i] = 32'b0;
                trans.PREADY = 1;
                continue;
            end

            if(trans.PWRITE == 1) begin
                if(trans.PWDATA[i] === 32'hx || trans.PWDATA[i] === 32'hz ) begin
                    trans.PRDATA[i] = 32'b0;
                    trans.PREADY = 1;
                    trans.PSLVERR = 1;
                    continue;
                end
                ram_mem [trans.PADDR[i]] = trans.PWDATA[i];
                trans.PRDATA[i] = 32'b0;
                trans.PREADY = 1;
                trans.PSLVERR = 0;
            end
            else begin
                if(ram_mem[trans.PADDR[i]] == 32'hffffffff) begin
                    trans.PRDATA[i] = 32'hffffffff;
                    trans.PREADY = 1;
                    trans.PSLVERR = 1;
                    continue;
                end
                trans.PRDATA[i] = ram_mem [trans.PADDR[i]];
                trans.PREADY = 1;
                trans.PSLVERR = 0;
            end
        end
        return trans;
    endfunction

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ram_mem = new[ram_depth];
    endfunction //new()
endclass //ref_model extends uvm_component