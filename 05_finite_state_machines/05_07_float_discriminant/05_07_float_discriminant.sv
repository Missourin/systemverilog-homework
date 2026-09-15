//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    enum logic [2:0]
    {
        IDLE      = 3'b000,
        WAIT_MUL1 = 3'b001,
        SAVE_MUL1 = 3'b010,
        WAIT_MUL2 = 3'b011,
        SAVE_MUL2 = 3'b100,
        WAIT_SUB  = 3'b101,
        DONE      = 3'b110
    }
    state, new_state;

    logic [FLEN - 1:0] bb_res, ac_res, fourac_res, sub_res;
    logic [FLEN - 1:0] b_sq, a_c, four_ac;

    logic bb_up, ac_up, fourac_up, sub_up;
    logic bb_down, ac_down, fourac_down, sub_down;
    logic bb_err, ac_err, fourac_err, sub_err;

    logic err_r;


    always_comb begin
        new_state = state;

        case (state)
            IDLE      : if (arg_vld)            new_state = WAIT_MUL1;
            WAIT_MUL1 : if (bb_down && ac_down) new_state = SAVE_MUL1;
            SAVE_MUL1 :                         new_state = WAIT_MUL2;
            WAIT_MUL2 : if (fourac_down)        new_state = SAVE_MUL2;
            SAVE_MUL2 :                         new_state = WAIT_SUB;
            WAIT_SUB  : if (sub_down)           new_state = DONE;
            DONE      :                         new_state = IDLE;
        endcase
    end

    always_ff @(posedge clk)
        if (rst) state <= IDLE;
        else     state <= new_state;

    assign bb_up     = (state == IDLE) && arg_vld;
    assign ac_up     = (state == IDLE) && arg_vld;
    assign fourac_up = (state == SAVE_MUL1);
    assign sub_up    = (state == SAVE_MUL2);

    always_ff @(posedge clk)
        if      (rst)                           b_sq <= '0;
        else if (state == WAIT_MUL1 && bb_down) b_sq <= bb_res;

    always_ff @(posedge clk)
        if      (rst)                           a_c <= '0;
        else if (state == WAIT_MUL1 && ac_down) a_c <= ac_res;

    always_ff @(posedge clk)
        if      (rst)                               four_ac <= '0;
        else if (state == WAIT_MUL2 && fourac_down) four_ac <= fourac_res;

    always_ff @(posedge clk)
        if (rst)
            err_r <= '0;
        else if (state == IDLE)
            err_r <= '0;
        else if ((bb_down && bb_err)         ||
                 (ac_down && ac_err)         ||
                 (fourac_down && fourac_err) ||
                 (sub_down && sub_err))
            err_r <= '1;

    assign res_vld      = (state == DONE);
    assign res          = sub_res;
    assign res_negative = sub_res [FLEN - 1];
    assign err          = err_r;
    assign busy         = (state != IDLE);

    f_mult mult_bb (
        .clk        ( clk     ),
        .rst        ( rst     ),
        .a          ( b       ),
        .b          ( b       ),
        .up_valid   ( bb_up   ),
        .res        ( bb_res  ),
        .down_valid ( bb_down ),
        .busy       (         ),
        .error      ( bb_err  )
    );

    f_mult mult_ac (
        .clk        ( clk     ),
        .rst        ( rst     ),
        .a          ( a       ),
        .b          ( c       ),
        .up_valid   ( ac_up   ),
        .res        ( ac_res  ),
        .down_valid ( ac_down ),
        .busy       (         ),
        .error      ( ac_err  )
    );

    f_mult mult_4ac (
        .clk        ( clk         ),
        .rst        ( rst         ),
        .a          ( four        ),
        .b          ( a_c         ),
        .up_valid   ( fourac_up   ),
        .res        ( fourac_res  ),
        .down_valid ( fourac_down ),
        .busy       (             ),
        .error      ( fourac_err  )
    );

    f_sub sub_d (
        .clk        ( clk      ),
        .rst        ( rst      ),
        .a          ( b_sq     ),
        .b          ( four_ac  ),
        .up_valid   ( sub_up   ),
        .res        ( sub_res  ),
        .down_valid ( sub_down ),
        .busy       (          ),
        .error      ( sub_err  )
    );

endmodule
