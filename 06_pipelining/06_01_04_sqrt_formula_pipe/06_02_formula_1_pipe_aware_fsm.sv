//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    enum logic [2:0]
    {
        IDLE    = 3'b000,
        SEND_B  = 3'b001,
        SEND_C  = 3'b010,
        WAIT_Y1 = 3'b011,
        WAIT_Y2 = 3'b100,
        WAIT_Y3 = 3'b101,
        DONE    = 3'b110
    }
    state, new_state;

    logic [31:0] sqrt_a;
    logic [31:0] sum_ab;
    logic [31:0] res_r;

    always_comb begin
        new_state = state;

        case (state)
            IDLE    : if (arg_vld)     new_state = SEND_B;
            SEND_B  :                  new_state = SEND_C;
            SEND_C  :                  new_state = WAIT_Y1;
            WAIT_Y1 : if (isqrt_y_vld) new_state = WAIT_Y2;
            WAIT_Y2 : if (isqrt_y_vld) new_state = WAIT_Y3;
            WAIT_Y3 : if (isqrt_y_vld) new_state = DONE;
            DONE    :                  new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk)
        if (rst) state <= IDLE;
        else     state <= new_state;

    always_comb begin
        isqrt_x_vld = '0;
        isqrt_x     = '0;

        case (state)
            IDLE : begin
                isqrt_x_vld = arg_vld;
                isqrt_x     = a;
            end
            SEND_B : begin
                isqrt_x_vld = 1'b1;
                isqrt_x     = b;
            end
            SEND_C : begin
                isqrt_x_vld = 1'b1;
                isqrt_x = c;
            end
        endcase
    end

    always_ff @(posedge clk)
        if      (rst)                             sqrt_a <= '0;
        else if (state == WAIT_Y1 && isqrt_y_vld) sqrt_a <= { 16'b0, isqrt_y };

    always_ff @(posedge clk)
        if      (rst)                             sum_ab <= '0;
        else if (state == WAIT_Y2 && isqrt_y_vld) sum_ab <= sqrt_a + { 16'b0, isqrt_y };

    always_ff @(posedge clk)
        if      (rst)                             res_r <= '0;
        else if (state == WAIT_Y3 && isqrt_y_vld) res_r <= sum_ab + { 16'b0, isqrt_y };

    assign res_vld = (state == DONE);
    assign res     = res_r;

endmodule
