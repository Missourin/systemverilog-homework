//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module sort_two_floats_ab (
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,

    output logic [FLEN - 1:0] res0,
    output logic [FLEN - 1:0] res1,
    output                    err
);

    logic a_less_or_equal_b;

    f_less_or_equal i_floe (
        .a   ( a                 ),
        .b   ( b                 ),
        .res ( a_less_or_equal_b ),
        .err ( err               )
    );

    always_comb begin : a_b_compare
        if ( a_less_or_equal_b ) begin
            res0 = a;
            res1 = b;
        end
        else
        begin
            res0 = b;
            res1 = a;
        end
    end

endmodule

//----------------------------------------------------------------------------
// Example - different style
//----------------------------------------------------------------------------

module sort_two_floats_array
(
    input        [0:1][FLEN - 1:0] unsorted,
    output logic [0:1][FLEN - 1:0] sorted,
    output                         err
);

    logic u0_less_or_equal_u1;

    f_less_or_equal i_floe
    (
        .a   ( unsorted [0]        ),
        .b   ( unsorted [1]        ),
        .res ( u0_less_or_equal_u1 ),
        .err ( err                 )
    );

    always_comb
        if (u0_less_or_equal_u1)
            sorted = unsorted;
        else
              {   sorted [0],   sorted [1] }
            = { unsorted [1], unsorted [0] };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_three_floats (
    input        [0:2][FLEN - 1:0] unsorted,
    output logic [0:2][FLEN - 1:0] sorted,
    output                         err
);

    logic [FLEN-1:0] min_ab, max_ab;
    logic [FLEN-1:0] min_abc, max_abc;
    logic ab_le, max_ab_le_c, min_ab_le_min_abc;
    wire err1, err2, err3;

    f_less_or_equal i_cmp_ab (
        .a   ( unsorted[0]  ),
        .b   ( unsorted[1]  ),
        .res ( ab_le        ),
        .err ( err1         )
    );

    assign min_ab = ab_le ? unsorted[0] : unsorted[1];
    assign max_ab = ab_le ? unsorted[1] : unsorted[0];

    f_less_or_equal i_cmp_maxab_c (
        .a   ( max_ab      ),
        .b   ( unsorted[2] ),
        .res ( max_ab_le_c ),
        .err ( err2        )
    );

    assign max_abc = max_ab_le_c ? unsorted[2] : max_ab;
    assign min_abc = max_ab_le_c ? max_ab      : unsorted[2];

    f_less_or_equal i_cmp_minab_minabc (
        .a   ( min_ab            ),
        .b   ( min_abc           ),
        .res ( min_ab_le_min_abc ),
        .err ( err3              )
    );

    assign sorted[0] = min_ab_le_min_abc ? min_ab  : min_abc;
    assign sorted[1] = min_ab_le_min_abc ? min_abc : min_ab;
    assign sorted[2] = max_abc;

    assign err = err1 | err2 | err3;

endmodule