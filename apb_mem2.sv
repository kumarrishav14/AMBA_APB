`define IDLE 0
`define SETUP 1
`define ACCESS 2
module apb_mem2 #(parameter DEPTH = 5) (
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
    always @(posedge _PCLK or negedge _PRESETn) begin
        _next_state = _state;
        #2
        case (_state)
            0:
                if(_PSEL1) _next_state = `SETUP; 
            1:
                if(_PENABLE) _next_state = `ACCESS;
            2:
                _next_state = `IDLE;
            default: 
                _next_state = _state;
        endcase
        _state = _next_state;
    end

    always @(_state) begin
        case (_state)
.0                begin
                    delay = $urandom;
                    _PSLVERR <= 0;
                    _PREADY <= 0;
                    _PRDATA <= 32'hz;
                end
                
            2:
                begin
                    repeat(delay) @(posedge _PCLK);
                    _PREADY <= 1;
                    if(_PADDR >= 2**DEPTH) begin
                        _PSLVERR <= 1;
                        $error("Memory Address more than limits");
                    end
                        
                    else begin
                        if (_PWRITE) begin
                            if(_PWDATA === 32'hx || _PWDATA === 32'hz) begin
                                _PSLVERR <= 1;
                                $error("Invalid data in PWDATA line");
                            end
                            else
                                mem[_PADDR[DEPTH-1:0]] = _PWDATA;
                        end
                        else begin
                            if(mem[_PADDR[DEPTH-1:0]] == 32'hffffffff)
                                _PSLVERR <= 1;
                            else begin
                                _PRDATA <= mem[_PADDR[DEPTH-1:0]];
                            end
                        end
                    end
                end 
        endcase
    end

endmodule