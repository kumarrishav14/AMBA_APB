class transaction;
    static bit [8:0] p_id;
    bit [3:0] f_id;
    rand bit PWRITE;
    rand bit[31:0] PWDATA [];
    rand bit[31:0] PADDR [];
    rand bit PRESETn;
    rand bit PSEL1;
    bit PENABLE;

    bit PREADY;
    bit [31:0] PRDATA [int];
    bit PSLVERR;

    //constraint data_val { !PWRITE -> PWDATA == 0}
    constraint arr_size {
        if(!PRESETn) {
            PWDATA.size() == 1; 
            PADDR.size() == 1;
        }
        else {
            PWDATA.size() inside {[1:3]}; 
            PADDR.size() inside {[1:3]};
        }
        PWDATA.size() == PADDR.size();
    }
    constraint reset_dist { PRESETn dist {0:=10, 1:=90}; }
    constraint sel_dist { PSEL1 dist {0:=10, 1:=90}; }

    function void pre_randomize();
        p_id++;
    endfunction

    function new();
        
    endfunction //new()

    // Increases the size of the dynamic array. Helper function for IP/OP monitor which needs to
    // sample data and store in array (as monitor does not know the size of the transfer thus needs
    // to increase and add value dynamically)
    function void increaseSize();
        if(PWDATA.size() == 0)
            PWDATA = new[1];
        else
            PWDATA = new[PWDATA.size()+1] (PWDATA);
        if(PADDR.size() == 0)
            PADDR = new[1];
        else
            PADDR = new[PADDR.size()+1] (PADDR);    
    endfunction

    function void printf(string message);
        $display("[%0t] %s", $time, message);
        $display("Packet ID: %0d, Feature ID: %0d", p_id, f_id);
        $displayh("Input to DUT: PWRITE = %b, PRESETn = %b, PSEL1 = %b, PWDATA = %p, PADDR = %p", PWRITE, PRESETn, PSEL1, PWDATA, PADDR);
        $displayh("OUPUT from DUT: PREADY = %b, PRDATA = %p, PSLVERR = %b", PREADY, PRDATA, PSLVERR);
    endfunction
endclass //transaction
