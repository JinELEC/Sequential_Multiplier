module seq_multiplier #(
    parameter N = 4
)(
    input  logic             clk,
    input  logic             n_rst,
    input  logic [N-1:0]     Min,
    input  logic [N-1:0]     Qin,
    input  logic             start,
    output logic             ready,
    output logic [2*N-1:0]   AQ
);

enum {IDLE, EXECUTE, DONE} present_state, next_state;

// control signals
logic reset;
logic execute;

logic [N-1:0] M;   // latch Min
logic [N-1:0] Sum; // wire with adder
logic         C;   // wire with adder
logic         Creg;
logic         last_bit;

assign last_bit = AQ[0];

// counter
logic [N-1:0] count;
always_ff @(posedge clk, negedge n_rst) begin
    if(!n_rst) 
        count <= 4'b0;
    else if((present_state == IDLE) && start) 
        count <= 4'd4;
    else if((present_state == EXECUTE))
        count <= count - 1'b1;
end

// 1. State transition
always_ff @(posedge clk, negedge n_rst) begin
    if(!n_rst) 
        present_state <= IDLE;
    else 
        present_state <= next_state;
end

// 2. Control signals
always_comb begin
    reset   = 1'b0;
    execute = 1'b0;
    next_state = present_state; // prevent latch
    case(present_state)
        IDLE: begin // IDLE
            reset = 1'b1;
            if(start) next_state = EXECUTE;
        end

        EXECUTE: begin
            execute = 1'b1;
            if(count == 1'b1) next_state = DONE;
        end

        DONE: begin
            ready = 1'b1;
            if(start) next_state = IDLE;
            else next_state = DONE;
        end
    endcase
end

// 3. Logic
always_ff @(posedge clk, negedge n_rst) begin
    if(!n_rst) begin
        ready <= 1'b0;
        AQ    <= 0;
        M     <= 0;
        Creg  <= 1'b0;
    end
    else if(reset) begin
            M            <= Min;
            AQ[2*N-1:N]  <= 0;
            AQ[N-1:0]    <= Qin;
        end

    else if(execute) begin
        if(last_bit == 1'b1) begin
            {Creg, AQ} <= {1'b0, C, Sum, AQ[N-1:1]}; // add & shift
        end
        else {Creg, AQ} <= {1'b0, Creg, AQ[2*N-1:1]}; // shift only
    end
end

adder instantiation_adder(
    .a      (AQ[2*N-1:N]),
    .b      (M          ),
    .cin    (1'b0       ),
    .cout   (C          ),
    .sum    (Sum        )
);

endmodule