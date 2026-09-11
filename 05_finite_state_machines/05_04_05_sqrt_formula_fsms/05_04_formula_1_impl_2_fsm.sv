//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [1:0]
    {
        IDLE    = 2'b00,
        WAIT_AB = 2'b01,
        WAIT_C  = 2'b11
    }
    state, new_state;

    logic [31:0] sum_ab;

    always_comb begin
        new_state = state;

        case (state)
            IDLE    : if (arg_vld)                       new_state = WAIT_AB;
            WAIT_AB : if (isqrt_1_y_vld & isqrt_2_y_vld) new_state = WAIT_C;
            WAIT_C  : if (isqrt_1_y_vld)                 new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk)
        if (rst) state <= IDLE;
        else     state <= new_state;

    assign isqrt_1_x_vld = (state == IDLE && arg_vld) ||
                           ((state == WAIT_AB) && isqrt_1_y_vld && isqrt_2_y_vld);

    assign isqrt_2_x_vld = ((state == IDLE) && arg_vld);

    assign isqrt_1_x = (state == IDLE) ? a : c;
    assign isqrt_2_x = b;

    always_ff @(posedge clk)
        if (rst)
            sum_ab <= '0;
        else if ((state == WAIT_AB) && isqrt_1_y_vld && isqrt_2_y_vld)
            sum_ab <= { 16'b0, isqrt_1_y } + { 16'b0, isqrt_2_y };

    assign res_vld = ((state == WAIT_C) && isqrt_1_y_vld);
    assign res = sum_ab + { 16'b0, isqrt_1_y };

endmodule
