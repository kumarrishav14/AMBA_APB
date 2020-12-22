import uvm_pkg::*;

//  Class: transaction
//
class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction);

    //  Group: Variables
    static bit [9:0] p_id;      // Packet id
    static bit [3:0] f_id;      // Feature id
    rand bit PWRITE;            // Read/Write
    rand bit[31:0] PWDATA [];   
    rand bit[31:0] PADDR [];   
    rand bit PRESETn;
    
    rand bit error_case;        // To generate random error case
    bit PSEL1;
    bit PENABLE;

    bit PREADY;
    bit [31:0] PRDATA [int];
    bit PSLVERR;

    //  Group: Constraints
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
    constraint reset_dist { PRESETn dist {0:=1, 1:=200}; }
    constraint sel_dist { PSEL1 dist {0:=10, 1:=90}; }
    constraint err_case_dist { error_case dist {1:=5, 0:=100}; } // Generates error test cases

    // Constraint for a specific memory size, can be commented for general use
    constraint paddr_val {
        !error_case -> 
            foreach(PADDR[i]) 
                PADDR[i] inside {[0:(2**5)-1]};
    }

    //  Group: Functions
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

    //  Constructor: new
    function new(string name = "transaction");
        super.new(name);
    endfunction: new

    //  Function: do_copy
    extern function void do_copy(uvm_object rhs);
    //  Function: do_compare
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  Function: convert2string
    extern function string convert2string();
    //  Function: do_print
    extern function void do_print(uvm_printer printer);
    
endclass: transaction

/*----------------------------------------------------------------------------*/
/*  Functions                                                                 */
/*----------------------------------------------------------------------------*/
function void transaction::do_copy(uvm_object rhs);
    transaction _rhs;
    if(!$cast(_rhs, rhs))
        `uvm_fatal(get_type_name(), "Passed object is not compatible with transaction class")
    
    PWRITE      = _rhs.PWRITE;            
    PWDATA      = _rhs.PWDATA;   
    PADDR       = _rhs.PADDR;   
    PRESETn     = _rhs.PRESETn;
    PSEL1       = _rhs.PSEL1;
    error_case  = _rhs.error_case;        
    PENABLE     = _rhs.PENABLE;

    PREADY      = _rhs.PREADY;
    PRDATA      = _rhs.PRDATA;
    PSLVERR     = _rhs.PSLVERR;    
endfunction

function void transaction::do_print(uvm_printer printer);
    string temp_addr;
    /*  chain the print with parent classes  */
    super.do_print(printer);
    
    $swriteh(temp_addr, "%0p", PADDR);
    /*  list of local properties to be printed:  */
    printer.print_field("PWRITE", PWRITE, $bits(PWRITE), UVM_BIN);
    printer.print_generic("PWDATA", "array", $bits(PWDATA), $sformatf("%p", PWDATA));
    printer.print_generic("PADDR", "array", $bits(PADDR), temp_addr);
    printer.print_field("PRESETn", PRESETn, $bits(PRESETn), UVM_BIN);
    printer.print_generic("PRDATA", "array", $bits(PRDATA), $sformatf("%p", PRDATA));
    printer.print_field("PSLVERR", PSLVERR, $bits(PSLVERR), UVM_BIN);
endfunction: do_print

function bit transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
    transaction rhs_;

    if (!$cast(rhs_, rhs)) begin
        `uvm_fatal({this.get_name(), ".do_compare()"}, "Cast failed!");
    end

    do_compare = super.do_compare(rhs, comparer);

    /*  list of local properties to be compared:  */
    do_compare &= (
        this.PSLVERR == rhs_.PSLVERR &&
        this.PREADY == rhs_.PREADY
    );
    foreach ( PRDATA[i] ) begin
        do_compare &= (this.PRDATA[i] == rhs_.PRDATA[i]);
    end

    // return do_compare;
endfunction: do_compare

function string transaction::convert2string();
    string s;
    s = super.convert2string();

    /*  list of local properties to be printed:  */
    s = {s, $sformatf("Packet ID: %0d, Feature ID: %0d\n", p_id, f_id)};
    s = {s, $sformatf("Input to DUT: PWRITE = %b, PRESETn = %b, PSEL1 = %b, PWDATA = %p, PADDR = %p\n", PWRITE, PRESETn, PSEL1, PWDATA, PADDR)};
    s = {s, $sformatf("OUPUT from DUT: PREADY = %b, PRDATA = %p, PSLVERR = %b", PREADY, PRDATA, PSLVERR)};

    return s;
endfunction: convert2string
