class scoreboard;
    // Communication variables
    mailbox #(transaction) rm2sb;
    mailbox #(transaction) opmon2sb;
    event TEST_DONE;

    // Transaction class objects
    transaction transFrmOP, transFrmRm;

    // Constants to be used in the code
    const real no_of_testcases;
    const string f_name = "log.txt";

    int i, pass_cases;
    int file_id;

    bit [31:0] _tempPADDR, _tempPWDATA, _tempRDATA;

    // Covergroup for Functional coverage
    covergroup apb_cg; 
        PSEL1: coverpoint transFrmRm.PSEL1 { bins psel1[] = {0, 1}; }
        PWRITE: coverpoint transFrmRm.PWRITE { bins pwrite[] = {0, 1}; }
        PWDATA: coverpoint _tempPWDATA { bins pwdata[16] = {[0:32'hffffffff]}; }
        PADDR: coverpoint _tempPADDR { bins paddr[16] = {[0:32'hffffffff]}; }
        PREADY: coverpoint transFrmRm.PREADY { bins pready[] = {0, 1}; }
        PRDATA: coverpoint _tempRDATA { bins prdata[16] = {[0:32'hffffffff]}; }
        PSLVERR: coverpoint transFrmRm.PSLVERR { bins pslverr[] = {0, 1}; }
        PSEL1xPWRITE: cross PSEL1, PWRITE;
        PSEL1xPWRITExPADDR: cross PSEL1, PWRITE, PADDR;
    endgroup

    /* Function for sampling data for coverage
       It has to be done because the transFrmRm.PADDR and other data signals are unpacked array as they have to 
       store more than one element for multiple transfer packet. Thus a loop is used and each element is stored 
       in temperory variable and then sampled.
       Advantage - Easy to implement    Disadvantage - Lot of signals will be sampled more than once for same value */
    function void cov_sample;
        for(int j = 0; j < transFrmRm.PADDR.size(); j++) begin
            _tempRDATA = transFrmRm.PRDATA[j];
            _tempPWDATA = transFrmRm.PWDATA[j];
            _tempPADDR = transFrmRm.PADDR[j];
            apb_cg.sample();
        end
    endfunction

    function new(mailbox #(transaction) rm2sb, mailbox #(transaction) opmon2sb,
                    int no_of_testcases);
        this.rm2sb = rm2sb;
        this.opmon2sb = opmon2sb;
        this.no_of_testcases = no_of_testcases;

        file_id = $fopen(f_name, "w");
        apb_cg = new();
        transFrmOP = new;
        transFrmRm = new;

        pass_cases = 0;
    endfunction //new()

    function void compare();
        if(transFrmOP.compare(transFrmRm)) begin
            $display("Packet ID %0d: \tPASSED", transFrmOP.p_id);
            $fdisplay(file_id, "Packet ID %0d: \tPASSED", transFrmOP.p_id);
            pass_cases++;
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
                transFrmRm.printf("RECIVED FROM RM IN SB");
                transFrmOP.printf("RECIVED FROM OP IN SB");
                $display("size: %0d", transFrmOP.PADDR.size());
                compare();
                cov_sample;
                i++;
                if(i >= no_of_testcases) 
                    ->TEST_DONE;
            end
        join_none
    endtask

    function void print_report;
        $display("\n********************** TEST REPORT *********************");
        $display("Total no of test cases: %0d", no_of_testcases);
        $display("Total no of passed test cases: %0d", pass_cases);
        $display("Failure rate: %0.02f %%", ((no_of_testcases-pass_cases)/no_of_testcases)*100.0);
        $display("\nFunction coverage is: %0.2f %% ", apb_cg.get_inst_coverage());
        $display("********************************************************");
        
    endfunction
endclass //scoreboard