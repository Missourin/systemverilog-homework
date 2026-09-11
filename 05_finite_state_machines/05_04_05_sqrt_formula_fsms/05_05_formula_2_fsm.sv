//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [1:0]
    {
        IDLE     = 2'b00,
        WAIT_C   = 2'b01,
        WAIT_BC  = 2'b11,
        WAIT_ABC = 2'b10
    }
    state, new_state;

    always_comb begin
        new_state = state;

        case (state)
            IDLE     : if (arg_vld)     new_state = WAIT_C;
            WAIT_C   : if (isqrt_y_vld) new_state = WAIT_BC;
            WAIT_BC  : if (isqrt_y_vld) new_state = WAIT_ABC;
            WAIT_ABC : if (isqrt_y_vld) new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk)
        if (rst) state <= IDLE;
        else     state <= new_state;

    assign isqrt_x_vld = ((state == IDLE) && arg_vld) ||
                         (isqrt_y_vld && ((state == WAIT_C) || (state == WAIT_BC)));

    always_comb
        if      (state == IDLE   ) isqrt_x = c;
        else if (state == WAIT_C ) isqrt_x = (b + { 16'b0, isqrt_y });
        else if (state == WAIT_BC) isqrt_x = (a + { 16'b0, isqrt_y });
        else                       isqrt_x = '0;

    assign res_vld = ((state == WAIT_ABC) && isqrt_y_vld);
    assign res = { 16'b0, isqrt_y };
endmodule
