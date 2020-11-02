class transaction;
    bit [8:0] p_id;
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
        PWDATA.size() inside {[1:3]}; 
        PADDR.size() inside {[1:3]};
        PWDATA.size() == PADDR.size();
    }
    constraint reset_dist { PRESETn dist {0:=10, 1:=90}; }
    constraint sel_dist { PSEL1 dist {0:=10, 1:=90}; }
    function new();
        
    endfunction //new()

    function void printf(string message);
        $display("[%0t] %s", $time, message);
        $displayh("Input to DUT: PWRITE = %b, PRESETn = %b, PSEL1 = %b, PWDATA = %p, PADDR = %p", PWRITE, PRESETn, PSEL1, PWDATA, PADDR);
        $displayh("OUPUT from DUT: PREADY = %b, PRDATA = %p, PSLVERR = %b", PREADY, PRDATA, PSLVERR);
    endfunction
endclass //transaction
