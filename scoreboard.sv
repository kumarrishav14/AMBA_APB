class scoreboard;
    // Communication variables
    mailbox #(transaction) rm2sb;
    mailbox #(transaction) opmon2sb;
    event TEST_DONE;

    // Transaction class objects
    transaction transFrmOP, transFrmRm;

    // Constants to be used in the code
    const int no_of_testcases;
    const string f_name = "log.txt";

    int i;
    int file_id;

    // Covergroup for Functional coverage
    covergroup apb_cg; 
        PSEL1: coverpoint transFrmRm.PSEL1 { bins psel1[] = {0, 1}; }
        PWRITE: coverpoint transFrmRm.PWRITE { bins pwrite[] = {0, 1}; }
        PWDATA: coverpoint transFrmRm.PWDATA { bins pwdata[16] = {[0:32'bffffffff]}; }
        PADDR: coverpoint transFrmRm.PADDR { bins paddr[] = {[0:32'bffffffff]}; }
        PREADY: coverpoint transFrmRm.PREADY { bins pready[] = {0, 1}; }
        PRDATA: coverpoint transFrmRm.PRDATA { bins prdata[16] = {[0:32'bffffffff]}; }
        PSLVERR: coverpoint transFrmRm.PSLVERR { bins pslverr[] = {0, 1}; }
        PSEL1xPWRITE: cross PSEL1, PWRITE;
        PSEL1xPWRITExPADDR: cross PSEL1, PWRITE, PADDR;
    endgroup
    apb_cg cg;

    function new(mailbox #(transaction) rm2sb, mailbox #(transaction) opmon2sb,
                    int no_of_testcases);
        this.rm2sb = rm2sb;
        this.opmon2sb = opmon2sb;
        this.no_of_testcases = no_of_testcases;

        file_id = $fopen(f_name, "w");
        cg = new();
        transFrmOP = new;
        transFrmRm = new;
    endfunction //new()

    function void compare();
        if(transFrmOP.compare(transFrmRm)) begin
            $display("Packet ID %0d: \tPASSED", transFrmOP.p_id);
            $fdisplay(file_id, "Packet ID %0d: \tPASSED", transFrmOP.p_id);
        end
        else begin
            $display("Packet ID %0d: \tFAILED", transFrmOP.p_id);
            $fdisplay(file_id, "Packet ID %0d: \tFAILED", transFrmOP.p_id);
        end
    endfunction //void compare

    task start();
        fork
            forever begin
                rm2sb.get(transFrmRm);
                opmon2sb.get(transFrmOP);
                compare();
                cg.sample();
                i++;
                if(i >= no_of_testcases) 
                    ->TEST_DONE;
            end
        join_none
    endtask
endclass //scoreboardq  d