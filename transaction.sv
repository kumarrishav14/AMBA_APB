class transaction;
    rand bit PWRITE;
    rand bit[31:0] PWDATA [];
    rand bit[31:0] PADDR [];
    rand bit PRESETn;
    rand bit PSEL1;
    bit PENABLE;

    bit PREADY;
    bit [31:0] PRDATA [];
    bit PSLVERR;

    //constraint data_val { !PWRITE -> PWDATA == 0}
    constraint arr_size {
        PWDATA.size() inside {[0:3]}; 
        PADDR.size() inside {[0:3]};
        PWDATA.size() == PADDR.size();
    }
    constraint reset_dist { PRESETn dist {0:=10, 1:=90}; }
    constraint sel_dist { PSEL1 dist {0:=10, 1:=90}; }
    function new();
        
    endfunction //new()

    function printf(string message);
        $display("[%0t] %s", $time, message);
        $display("Input to DUT: PWRITE = %b, PRESETn = %b, PSEL1 = %b, PWDATA = %h, PADDR = %h", PWRITE, PRESETn, PSEL1, PWDATA, PADDR);
        $display("OUPUT from DUT: PREADY = %b, PRDATA = %h, PSLVERR = %b", PREADY, PRDATA, PSLVERR);
    endfunction
endclass //transaction
