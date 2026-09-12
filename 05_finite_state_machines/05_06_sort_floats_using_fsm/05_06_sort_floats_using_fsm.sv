//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    enum logic [2:0]
    {
        IDLE  = 3'b000,
        S1    = 3'b001,
        S2    = 3'b010,
        S3    = 3'b011,
        ERROR = 3'b100
    }
    state, new_state;

    logic [FLEN - 1:0] a_r, b_r, c_r;
    logic [FLEN - 1:0] min_ab, max_ab;
    logic [FLEN - 1:0] min_abc, max_abc;

    logic f_le_res_s0;
    logic f_le_res_s1;
    logic f_le_res_s2;
    logic err_r;

    always_comb begin
        new_state = state;

        case (state)
            IDLE  : if      (valid_in) new_state = S1;

            S1    : if      (f_le_err) new_state = ERROR;
                    else               new_state = S2;

            S2    : if      (f_le_err) new_state = ERROR;
                    else               new_state = S3;

            S3    : if      (f_le_err) new_state = ERROR;
                    else               new_state = IDLE;

            ERROR :                    new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk)
        if (rst) state <= IDLE;
        else     state <= new_state;

    always_ff @(posedge clk)
        if      (rst)                         { a_r, b_r, c_r } <= '0;
        else if ((state == IDLE) && valid_in) { a_r, b_r, c_r } <= unsorted;

    always_comb begin
        f_le_a = '0;
        f_le_b = '0;

        case (state)
            IDLE : begin
                f_le_a = unsorted [0];
                f_le_b = unsorted [1];
            end
            S1   : begin
                f_le_a = max_ab;
                f_le_b = c_r;
            end
            S2   : begin
                f_le_a = min_ab;
                f_le_b = min_abc;
            end
        endcase
    end

    assign min_ab = (f_le_res_s0) ? a_r : b_r;
    assign max_ab = (f_le_res_s0) ? b_r : a_r;

    assign min_abc = (f_le_res_s1) ? max_ab : c_r;
    assign max_abc = (f_le_res_s1) ? c_r : max_ab;

    always_ff @(posedge clk)
        if (rst) begin
            f_le_res_s0 <= '0;
            f_le_res_s1 <= '0;
            f_le_res_s2 <= '0;
        end
        else begin
            if ((state == IDLE) && valid_in) f_le_res_s0 <= f_le_res;
            if ((state == S1) && !f_le_err ) f_le_res_s1 <= f_le_res;
            if ((state == S2) && !f_le_err ) f_le_res_s2 <= f_le_res;
        end

    always_comb begin
        sorted = '0;

        if ((state == S3) && !f_le_err) begin
            sorted[0] = (f_le_res_s2) ? min_ab : min_abc;
            sorted[1] = (f_le_res_s2) ? min_abc : min_ab;
            sorted[2] = max_abc;
        end
    end

    always_ff @(posedge clk)
        if      (rst          ) err_r <= 1'b0;
        else if (state == IDLE) err_r <= (valid_in && f_le_err === 1'b1);
        else if (f_le_err     ) err_r <= 1'b1;

    assign valid_out = (state == S3) || (state == ERROR);
    assign err = err_r;
    assign busy = (state != IDLE);

endmodule