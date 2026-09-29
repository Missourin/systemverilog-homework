//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                    clk,
    input                    rst,

    input                    up_valid,
    output                   up_ready,
    input   [ 2*width - 1:0] up_data,

    output                   down_valid,
    input                    down_ready,
    output  [   width - 1:0] down_data
);

    // Task:
    // Implement a module that generates tokens from of one token.
    // Example:
    // "0110" => "01", "10"
    //
    // The module must use signals valid-ready for transfer tokens.

    enum logic [1:0]
    {
        IDLE    = 2'b00,
        SEND_HI = 2'b01,
        SEND_LO = 2'b10
    } state, new_state;

    logic [2*width - 1:0] buf_data;

    assign up_ready   = (state == IDLE);
    assign down_valid = (state == SEND_HI) | (state == SEND_LO);

    assign down_data  = (state == SEND_HI) ? buf_data [2*width - 1 : width]
                                           : buf_data [  width - 1 : 0];

    always_comb begin
        new_state = state;

        case (state)
            IDLE    : if (up_valid & up_ready) new_state = SEND_HI;
            SEND_HI : if (down_ready)          new_state = SEND_LO;
            SEND_LO : if (down_ready)          new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge rst)
        if (rst) state <= IDLE;
        else     state <= new_state;

    always_ff @(posedge clk)
        if (up_valid & up_ready) buf_data <= up_data;

endmodule
