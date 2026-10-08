//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module generate_tokens_by_number_with_flow_control
#(
    WIDTH = 4
)
(
    input                 clk,
    input                 rst,

    input                 up_valid,
    output                up_ready,
    input  [WIDTH-1 : 0]  n_tokens,

    output                down_valid,
    input                 down_ready,
    output                down_token
);

    // Task:
    // Implement a module that recive an integer N_tokens and generate N_tokens pulses. The module must use signals valid-ready for
    // transfer tokens.

    enum logic {
        IDLE = 1'b0,
        SEND = 1'b1
    } state, new_state;

    logic [WIDTH - 1:0] cnt;

    assign up_ready   = (state == IDLE);
    assign down_valid = (state == SEND) && (cnt > '0);
    assign down_token = 1'b1;

    always_comb begin
        new_state = state;

        case (state)
            IDLE : if (up_valid & up_ready)      new_state = SEND;
            SEND : if (down_ready & (cnt == '0)) new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge rst)
        if (rst) state <= IDLE;
        else     state <= new_state;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            cnt <= '0;
        else if ((state == IDLE) & up_valid & up_ready)
            cnt <= n_tokens;
        else if ((state == SEND) & down_valid & down_ready & (cnt != '0))
            cnt <= cnt - 1'b1;

endmodule
