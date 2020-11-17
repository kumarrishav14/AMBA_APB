`define IDLE 0
`define SETUP 1
`define ACCESS 2
module apb_mem #(parameter DEPTH = 5) (
    input _PCLK, _PRESETn, _PSEL1, _PWRITE, _PENABLE,
    input [31:0] _PADDR, _PWDATA,
    output reg [31:0] _PRDATA, 
    output reg _PREADY, _PSLVERR
);
    reg [1:0] _state, _next_state;
    reg [1:0] delay;

    reg [31:0] mem [2**DEPTH-1:0];
    initial begin
        _state = `IDLE;
    end

    always @(posedge _PCLK or negedge _PRESETn ) begin
        if(!_PRESETn) begin
            _state <= `IDLE;
            foreach(mem[i]) mem[i] = 32'hffffffff;
        end
        else
            _state <= _next_state;
    end

    always @(_state, _PSEL1, _PENABLE) begin
        case (_state)
            `IDLE:                
            begin
                //$display("[%0t] In Idle State", $time);
                delay = $urandom;
                _PSLVERR <= 0;
                _PREADY <= 0;
                _PRDATA <= 32'h0;
                if(_PSEL1) _next_state <= `SETUP;
                else _next_state <= `IDLE;
            end
                
            `SETUP:
            begin
                //$display("[%0t] In Setup State", $time);
                _PREADY <= 0;
                _PSLVERR<=0;
                if(_PENABLE) begin
                    repeat(delay) @(posedge _PCLK);
                    _PREADY <= 1;
                    if(_PADDR >= 2**DEPTH) begin
                        _PSLVERR <= 1;
                        $error("Memory Address more than limits");
                    end
                    else if(_PWRITE && (_PWDATA === 32'hx || _PWDATA === 32'hz)) begin
                        _PSLVERR <= 1;
                        $error("Invalid data in PWDATA line");
                    end
                    else if(!_PWRITE) begin
                        _PRDATA <= mem[_PADDR[DEPTH-1:0]];
                        if(mem[_PADDR[DEPTH-1:0]] == 32'hffffffff) begin
                            $display("PADDR is %h and content is %h", _PADDR, mem[_PADDR[DEPTH-1:0]]);
                            _PSLVERR <= 1;
                            $error("Reading data from unwritten address");
                        end
                        // else
                        //     _PRDATA <= mem[_PADDR[DEPTH-1:0]];
                    end
                    _next_state <= `ACCESS;
                end   
                else
                    _next_state <= _state;
            end

            `ACCESS:
            begin
                //$display("[%0t] In Access State", $time);
                if(_PWRITE && !_PSLVERR) begin
                    mem[_PADDR[DEPTH-1:0]] = #0 _PWDATA;
                end
                _PREADY <= 0;
                if(!_PSEL1)
                    _next_state <= `IDLE;
                else
                    _next_state <= `SETUP;
            end 
        endcase
    end

endmodule