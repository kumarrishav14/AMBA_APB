class transaction;
    static bit [8:0] p_id;
    static bit [3:0] f_id;
    rand bit PWRITE;
    rand bit[31:0] PWDATA [];
    rand bit[31:0] PADDR [];
    rand bit PRESETn;
    rand bit PSEL1;
    rand bit error_case;
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
    constraint err_case_dist { error_case dist {1:=5, 0:=100}; }

    // Constraint for a specific memory of 4KB, can be commented for general use
    constraint paddr_val {
        !error_case -> 
            foreach(PADDR[i]) 
                PADDR[i] inside {[0:(2**5)-1]};
    }

    function void pre_randomize();
        p_id++;
    endfunction

    function void post_randomize();
        if(!PRESETn)
            f_id = 5;
        else if (PWRITE && PADDR.size() == 1)
            f_id = 1;
        else if (PWRITE && PADDR.size() > 1)
            f_id = 2;
        else if (!PWRITE && PADDR.size() == 1)
            f_id = 3;
        else if (!PWRITE && PADDR.size() > 1)
            f_id = 4;
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

    function bit compare(transaction trans);
        if(this.PREADY == trans.PREADY && this.PSLVERR == trans.PSLVERR) begin
        //if(this.PSLVERR == trans.PSLVERR) begin
            foreach(this.PRDATA[i]) begin
                if(this.PRDATA[i] != trans.PRDATA[i])
                    return 0;
            end
            return 1;
        end
        else
            return 0;
    endfunction //bit compare (transaction)
endclass //transaction
