//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output logic               busy,
    output logic               serial_valid,
    output logic               serial_data
);
    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [width - 2    :0] shift_reg;
    logic [$clog2(width):0] cnt;

    assign serial_data  = parallel_valid ? parallel_data[0] : shift_reg[0];
    assign serial_valid = parallel_valid | busy;

    always_ff @ (posedge clk)
        if (rst)
        begin
            cnt          <= '0;
            shift_reg    <= '0;
            busy         <= '0;
        end

        else
        begin
            if (parallel_valid)
            begin
                busy      <= '1;
                cnt       <= '0;
                shift_reg <= parallel_data[width - 1:1];
            end
            else if (busy)
            begin
                shift_reg <= { 1'b0, shift_reg[width - 2:1] };

                if (cnt == width - 2)
                begin
                    busy <= '0;
                end
                else
                begin
                    cnt  <= cnt + 1'b1;
                end
            end
        end

endmodule
