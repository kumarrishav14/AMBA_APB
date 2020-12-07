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

    int feature_status [bit[4:0]][2];   // feature_status[][0] - Fail count; feature_status[][1] - Pass count

    //*****************************************************************************************************************************
    // Temp variables for coverage
    bit [31:0] _tempPADDR, _tempPWDATA, _tempRDATA;

    // Covergroup for Functional coverage
    covergroup apb_cg; 
        PSEL1: coverpoint transFrmRm.PSEL1 { bins psel1[] = {0, 1}; }
        PWRITE: coverpoint transFrmRm.PWRITE { bins pwrite[] = {0, 1}; }
        PWDATA: coverpoint _tempPWDATA { bins pwdata[16] = {[0:32'hffffffff]}; }
        PADDR: coverpoint _tempPADDR { bins paddr[] = {[0:32'h0000001f]}; 
                                       illegal_bins il_paddr = default; }
        PREADY: coverpoint transFrmRm.PREADY { bins pready[] = {0, 1}; }
        PRDATA: coverpoint _tempRDATA { bins prdata[16] = {[0:32'hffffffff]}; }
        PSLVERR: coverpoint transFrmRm.PSLVERR { bins pslverr[] = {0, 1}; }
        PSEL1xPWRITE: cross PSEL1, PWRITE { ignore_bins ig_bins = binsof(PSEL1) intersect{0}; }
        PSEL1xPWRITExPADDR: cross PSEL1, PWRITE, PADDR { ignore_bins ig_bins = binsof(PSEL1) intersect{0}; }
    endgroup

    /* Function for sampling data for coverage
       It has to be done because the transFrmRm.PADDR and other data signals are unpacked array as they have to 
       store more than one element for multiple transfer packet. Thus a loop is used and each element is stored 
       in temperory variable and then sampled.
       Advantage - Easy to implement */
    function void cov_sample;
        for(int j = 0; j < transFrmRm.PADDR.size(); j++) begin
            _tempRDATA = transFrmRm.PRDATA[j];
            _tempPWDATA = transFrmRm.PWDATA[j];
            _tempPADDR = transFrmRm.PADDR[j];
            if(j==0)
                apb_cg.sample();
        end
    endfunction
    //*****************************************************************************************************************************

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
            feature_status[transFrmOP.f_id][1]++;
            pass_cases++;
        end
        else begin
            $display("Packet ID %0d: \tFAILED", transFrmOP.p_id);
            $fdisplay(file_id, "Packet ID %0d: \tFAILED", transFrmOP.p_id);
            feature_status[transFrmOP.f_id][0]++;
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

    //*****************************************************************************************************************************
    // Report generation
    function void print_report;
        real total;
        $display("\n******************************* TEST REPORT ********************************");
        $display("Total no of test cases: %0d", no_of_testcases);
        $display("Total no of passed test cases: %0d", pass_cases);
        $display("Failure rate: %0.02f %%", ((no_of_testcases-pass_cases)/no_of_testcases)*100.0);
        $display("\nFunction coverage is: %0.2f %% ", apb_cg.get_inst_coverage());
        $display("\nFEATURE WISE DETAITLS");
        $display("Feature id\t\tTotal Cases\t\tPass Cases\t\tFail Cases\t\tFailure Rate");
        foreach(feature_status[i]) begin
            total = feature_status[i][0]+feature_status[i][1];
            $display("%0d\t\t%0d\t\t%0d\t\t%0d\t\t%0.2f %%", i, total, feature_status[i][1], 
                        feature_status[i][0], (feature_status[i][0]/total)*100 );
        end
        $display("******************************************************************************");
        $fdisplay(file_id, "\n******************************* TEST REPORT ********************************");
        $fdisplay(file_id, "Total no of test cases: %0d", no_of_testcases);
        $fdisplay(file_id, "Total no of passed test cases: %0d", pass_cases);
        $fdisplay(file_id, "Failure rate: %0.02f %%", ((no_of_testcases-pass_cases)/no_of_testcases)*100.0);
        $fdisplay(file_id, "\nFunction coverage is: %0.2f %% ", apb_cg.get_inst_coverage());
        $fdisplay(file_id, "\nFEATURE WISE DETAITLS");
        $fdisplay(file_id, "Feature id\t\tTotal Cases\t\tPass Cases\t\tFail Cases\t\tFailure Rate");
        foreach(feature_status[i]) begin
            total = feature_status[i][0]+feature_status[i][1];
            $fdisplay(file_id, "%0d\t\t%0d\t\t%0d\t\t%0d\t\t%0.2f %%", i, total, feature_status[i][1], 
                        feature_status[i][0], (feature_status[i][0]/total)*100 );
        end
        $fdisplay(file_id, "******************************************************************************");
    endfunction
endclass //scoreboard