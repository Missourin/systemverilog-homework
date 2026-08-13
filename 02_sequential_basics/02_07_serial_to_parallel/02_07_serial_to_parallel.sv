//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [$clog2(width):0]  cnt;
    logic [width - 1    :0]  shift_reg;
    logic                    last_bit;

    assign last_bit = serial_valid & (cnt == width - 1);

    always_ff @ (posedge clk)
        if (rst)
        begin
            cnt            <= '0;
            shift_reg      <= '0;
            parallel_valid <= '0;
            parallel_data  <= '0;
        end

        else
        begin
            parallel_valid <= '0;

            if (serial_valid)
            begin
                shift_reg <= { serial_data, shift_reg [width-1:1] };

                if (last_bit)
                begin
                    cnt            <= '0;
                    parallel_valid <= '1;
                    parallel_data  <= { serial_data, shift_reg [width-1:1] };
                end
                else
                begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
endmodule