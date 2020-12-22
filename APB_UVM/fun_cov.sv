import uvm_pkg::*;

class fun_cov extends uvm_subscriber#(transaction);
    `uvm_component_utils(fun_cov)
    
    // Variables
    transaction trans;
    bit [31:0] _tempPADDR, _tempPWDATA, _tempRDATA;

    // Covergroup for Functional coverage
    covergroup apb_cg; 
        PSEL1: coverpoint trans.PSEL1 { bins psel1[] = {0, 1}; }
        PWRITE: coverpoint trans.PWRITE { bins pwrite[] = {0, 1}; }
        PWDATA: coverpoint _tempPWDATA { bins pwdata[16] = {[0:32'hffffffff]}; }
        PADDR: coverpoint _tempPADDR { bins paddr[] = {[0:32'h0000001f]}; 
                                       illegal_bins il_paddr = default; }
        PREADY: coverpoint trans.PREADY { bins pready[] = {0, 1}; }
        PRDATA: coverpoint _tempRDATA { bins prdata[16] = {[0:32'hffffffff]}; }
        PSLVERR: coverpoint trans.PSLVERR { bins pslverr[] = {0, 1}; }
        PSEL1xPWRITE: cross PSEL1, PWRITE { ignore_bins ig_bins = binsof(PSEL1) intersect{0}; }
        PSEL1xPWRITExPADDR: cross PSEL1, PWRITE, PADDR { ignore_bins ig_bins = binsof(PSEL1) intersect{0}; }
    endgroup

    /* Function for sampling data for coverage
       It has to be done because the trans.PADDR and other data signals are unpacked array as they have to 
       store more than one element for multiple transfer packet. Thus a loop is used and each element is stored 
       in temperory variable and then sampled.
       Advantage - Easy to implement Disadvantage - Lot of signals will be sampled more than once for same value */
    function void cov_sample;
        for(int j = 0; j < trans.PADDR.size(); j++) begin
            _tempRDATA = trans.PRDATA[j];
            _tempPWDATA = trans.PWDATA[j];
            _tempPADDR = trans.PADDR[j];
            apb_cg.sample();
        end
    endfunction

    // Constructor: new
    function new(string name, uvm_component parent);
        super.new(name, parent);
        apb_cg = new();
    endfunction //new()

    function void write(T t);
        trans = t;
        cov_sample();
    endfunction

    function void build_phase(uvm_phase phase);
        trans = new("cov_trans");
    endfunction: build_phase
    
endclass //fun_cov extends uvm_subscriber#(transaction)