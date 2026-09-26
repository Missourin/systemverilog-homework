//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module one_bit_wide_shift_register_with_reset
# (
    parameter depth = 8
)
(
    input  clk,
    input  rst,
    input  in_data,
    output out_data
);
    logic [depth - 1:0] data;

    always_ff @ (posedge clk)
        if (rst)
            data <= '0;
        else
            data <= { data [depth - 2:0], in_data };

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------

module shift_register
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);
    logic [width - 1:0] data [0:depth - 1];

    always_ff @ (posedge clk)
    begin
        data [0] <= in_data;

        for (int i = 1; i < depth; i ++)
            data [i] <= data [i - 1];
    end

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module shift_register_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input                in_vld,
    input  [width - 1:0] in_data,

    output               out_vld,
    output [width - 1:0] out_data
);

    // NOTHING TO DO HERE

        logic [width - 1:0] data  [0:depth - 1];
    logic               valid [0:depth - 1];

    logic               en    [0:depth - 1];

    always_comb begin
        en [0] = in_vld;

        for (int i = 1; i < depth; i++)
            en [i] = valid [i-1];
    end

    always_ff @(posedge clk)
        if (rst) begin
            for (int i = 0; i < depth; i++) begin
                data [i]  <= '0;
                valid [i] <= '0;
            end
        end
        else begin
            valid[0] <= in_vld;

            for (int i = 1; i < depth; i++)
                valid [i] <= valid [i-1];

            for (int i = 0; i < depth; i++)
                if (en [i])
                    data [i] <= (i == 0) ? in_data : data [i-1];
        end

    assign out_vld  = valid [depth-1];
    assign out_data = data  [depth-1];

endmodule
