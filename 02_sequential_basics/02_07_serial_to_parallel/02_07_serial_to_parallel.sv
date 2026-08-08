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

    logic [width - 1:0    ]   register;
    logic [$clog2(width):0]   counter;
    logic                     last_bit;

    assign last_bit = serial_valid & (counter == width - 1);

    always_ff @ (posedge clk) begin
        if (rst)
        begin
            counter        <= '0;
            register       <= '0;
            parallel_valid <= '0;
            parallel_data  <= '0;
        end

        else
        begin
            parallel_valid <= '0;

            if (serial_valid)
            begin
                register <= { serial_data, register [width - 1:1] };

                if (last_bit)
                begin
                    counter        <= '0;
                    parallel_valid <= '1;
                    parallel_data  <= { serial_data, register [width - 1:1] };
                end
                else
                begin
                    counter  <= counter + 1'b1;
                end
            end
        end
    end
endmodule