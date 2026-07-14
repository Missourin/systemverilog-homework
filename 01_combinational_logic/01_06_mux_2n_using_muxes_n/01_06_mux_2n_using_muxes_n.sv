//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  // Task:
  // Implement mux_4_1 using three instances of mux_2_1

  wire [3:0] out_low;
  wire [3:0] out_high;

  mux_2_1 im_0_mux_2_1 (.d0(d0), .d1(d1), .sel(sel[0]), .y(out_low));
  mux_2_1 im_1_mux_2_1 (.d0(d2), .d1(d3), .sel(sel[0]), .y(out_high));

  mux_2_1 final_mux_2_1 (.d0(out_low), .d1(out_high), .sel(sel[1]), .y(y));
endmodule
