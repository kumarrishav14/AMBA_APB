class scoreboard;
    mailbox #(transaction) rm2sb;
    mailbox #(transaction) opmon2sb;
    event TEST_DONE;

    bit err_occ;

    transaction transFrmOP, transFrmRm;
    const int no_of_testcases;
    int i;
    function new(mailbox #(transaction) rm2sb, mailbox #(transaction) opmon2sb,
                    int no_of_testcases);
        this.rm2sb = rm2sb;
        this.opmon2sb = opmon2sb;
        this.no_of_testcases = no_of_testcases;

        transFrmOP = new;
        transFrmRm = new;
    endfunction //new()

    function void compare();
        if(transFrmOP.compare(transFrmRm)) begin
            $display("Packet ID %0d: \tPASSED", transFrmOP.p_id);
        end
        else begin
            $display("Packet ID %0d: \tFAILED", transFrmOP.p_id);
        end
    endfunction //void compare

    task start();
        fork
            forever begin
                rm2sb.get(transFrmRm);
                opmon2sb.get(transFrmOP);
                compare();
                i++;
                if(i >= no_of_testcases) 
                    ->TEST_DONE;
            end
        join_none
    endtask

    function bit combine(ref transaction tr1, transaction tr2);
        if(tr1.p_id != tr2.p_id) begin
            $display("Packet id of transaction recieved from OPMON and REF MODEL is not same");
            return 1;
        end
        
    endfunction
endclass //scoreboardq  d