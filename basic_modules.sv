//////////////////////////////////////////////////////
//                                                  //
// The DSP48E1 Slice supports a 25 x 18 multiplier. //
//                                                  //
//  - Multiplication must be fixed-point.           //
//  - The result is sign-extended to 48 bits.       //
//  - The XC7VX485T contains 2800 DSP48E1 Slices.   //
//  - The slices support up to 741 MHz operation.   //
//                                                  //
//////////////////////////////////////////////////////
module Inferred_DSP48E1_multiplier
  (output logic [47:0] result, 
    input logic [24:0] operand_a, // 2 bits before fixed-point and 23 after
    input logic [17:0] operand_b);

    logic [43:0] product;
    logic        sign;

    assign product = operand_a * operand_b;

    assign sign = result[47];
    assign result = { {4{sign}}, result};

endmodule: Inferred_DSP48E1_multiplier


/////////////////////////////////////////////////////
//                                                 //
// Rounder module converts fixed-point to integer. //
//                                                 //
//  - Parameters specify width and point location. //
//  - Rounds up if first truncated bit == 1.       //
//                                                 //
/////////////////////////////////////////////////////
module Round_to_Coords #(parameter  IN_WIDTH = 48,
                         parameter   FXD_PNT = 23,
                         parameter OUT_WIDTH = 32) // Only 25 bits have value though
  (output logic [OUT_WIDTH-1:0] result,
    input logic [ IN_WIDTH-1:0] value);

    logic [IN_WIDTH-FXD_PNT-1:0] truncated; // 25 bits
    logic                        round_up;

    assign truncated = value[IN_WIDTH-1:FXD_PNT];
    assign round_up = value[FXD_PNT-1];

    assign result = truncated + round_up;

endmodule: Round_to_Coords


///////////////////////////////////////////////////////////////
//                                                           //
// Coordinate Calculator Block Transforms x, y to x0, y0.    //
//                                                           //
//  - Receives H matrix and coordinates as integers.         //
//  - Assumes fixed-point representation of H matrix values. //
//  - Rounds and formats results for easy integer lookup.    //
//                                                           //
///////////////////////////////////////////////////////////////
module Coordinate_calculator // TODO NOTE: This might need pipelined
  (output int x_result, y_result,
    input int x, y,
    input int a, b, c, d, e, f, g, h);

    logic [47:0] ax, by, dx, ey, gx, hy;
    logic [47:0] xw, yw, w;
    logic [47:0] x_norm, y_norm;

    ////////////////////////////////////////////
    // MULTIPLIERS FOR VECTOR MATRIX MULTIPLY //
    ////////////////////////////////////////////

    Inferred_DSP48E1_multiplier m0(.result(ax),
                                   .operand_a(a[24:0]),  // MAKE SURE TO GET THIS INDEXING RIGHT. CHECK WITH uBLAZE ABOUT REPRESENTATION
                                   .operand_b(x[17:0])); // MAKE SURE TO GET THIS INDEXING RIGHT. CHECK WITH CONTROLLER ABOUT REPRESENTATION

    Inferred_DSP48E1_multiplier m1(.result(by),
                                   .operand_a(b[24:0]),
                                   .operand_b(y[17:0]));

    Inferred_DSP48E1_multiplier m2(.result(dx),
                                   .operand_a(d[24:0]),
                                   .operand_b(x[17:0]));

    Inferred_DSP48E1_multiplier m3(.result(ey),
                                   .operand_a(e[24:0]),
                                   .operand_b(y[17:0]));

    Inferred_DSP48E1_multiplier m4(.result(gx),
                                   .operand_a(g[24:0]),
                                   .operand_b(x[17:0]));

    Inferred_DSP48E1_multiplier m5(.result(hy),
                                   .operand_a(h[24:0]),
                                   .operand_b(y[17:0]));

    ///////////////////////////////////////
    // ADDERS FOR VECTOR MATRIX MULTIPLY //
    ///////////////////////////////////////

    assign xw = ax + by + {{16{c[31]}},c};
    assign yw = dx + ey + {{16{f[31]}},f};
    assign  w = gx + hy + 48'b1;

    ///////////////////////////////////////////
    // DIVIDERS FOR HOMOGENOUS NORMALIZATION //
    ///////////////////////////////////////////

    // TODO NOTE: Wow, how are we going to implement this???
    assign x_norm = xw / w;
    assign y_norm = yw / w;

    ///////////////////////////////////////////
    // ROUNDERS TO CONVERT TO INT FOR LOOKUP //
    ///////////////////////////////////////////

    Round_to_Coords r0(.result(x_result),
                       .value(x_norm));

    Round_to_Coords r1(.result(y_result),
                       .value(y_norm));

endmodule: Coordinate_calculator

module Transformation_datapath
  (output int         x_location, y_location,
   output logic [7:0] r, g, b,
   output int         x_lookup, y_lookup,
    input int         x, y,
    input int         a, b, c, d, e, f, g, h,
    input logic [7:0] r_source, g_source, b_source,
    input logic       valid_coords);

    //////////////////////////////////
    // PASS THROUGH FOR COORDINATES //
    //////////////////////////////////

    // Datapath will find color for location by calculating a source location,
    // but that color will be displayed at the originally provided location!
    // As such, pass this value through.
    assign x_location = x;
    assign y_location = y;

    ////////////////////////////////////////////
    // CALCULATE COORDINATES FOR COLOR LOOKUP //
    ////////////////////////////////////////////

    Coordinate_calculator c0(.x_result(x_lookup),
                             .y_result(y_lookup),
                             .*); // x,y,a,b,c,d,e,f,g,h

    //////////////////////////////////////////////
    // MULTIPLEXOR TO SELECT OUTPUT COLOR VALUE //
    //////////////////////////////////////////////

    {r,g,b} = (valid_coords) ? {r_source,g_source,b_source} : 24'b0;

endmodule: Transformation_datapath

/////////////////////////////////////////////////////////////////////
//                                                                 //
// Input Ram Handler services read / write requests for block RAM. //
//                                                                 //
//  - Handler input dual-ported to service both incoming pixels.   //
//  - Handler output dual-ported to service both datapath insts.   //
//  - Handler reports whether the output request address is valid. //
//                                                                 //
/////////////////////////////////////////////////////////////////////
module Input_RAM_Handler #(parameter WIDTH = 1920, HEIGHT = 1080) // TODO NOTE: Needs status, control, and timing signals
  (output logic [7:0] r_out[1:0], g_out[1:0], b_out[1:0],
   output logic       valid_coords[1:0],
    input int         x_write[1:0], y_write[1:0],
    input int         x_read[1:0],  y_read[1:0],
    input logic [7:0] r_in[1:0], g_in[1:0], b_in[1:0]);

    ////////////////////////////////////
    // CHECK FOR VALID OUTPUT REQUEST //
    ////////////////////////////////////

    assign valid_coords[0] = (0 <= x_read[0] < WIDTH) && (0 <= y_read[0] < HEIGHT);
    assign valid_coords[1] = (0 <= x_read[1] < WIDTH) && (0 <= y_read[1] < HEIGHT);

    // TODO NOTE: CHANGE THESE DRIVERS LATER
    assign r_out[0] = 8'hFF;
    assign r_out[1] = 8'hFF;
    assign g_out[0] = 8'h00;
    assign g_out[1] = 8'h00;
    assign b_out[0] = 8'h00;
    assign b_out[1] = 8'h00;

    ////////////////
    // BLOCK RAMS //
    ////////////////

    // TODO NOTE: INSTANTIATE RAMS HERE

endmodule: Input_RAM_Handler

////////////////////////////////////////////////////////////
//                                                        //
// Keystone Correction module determines new pixel colors //
//                                                        //
//  - Connected to AXI Stream for HDMI.                   //
//  - Connected to AXI Lite for microBlaze.               //
//  - Receives incoming pixels two at a time.             //
//  - Outputs newly colored pixels two at a time.         //
//                                                        //
////////////////////////////////////////////////////////////
module Keystone_correction
///////////////////////
// OUTPUT AXI STREAM //
///////////////////////
  (output logic [63:0] pixel_stream_out,
   output logic        ready,
/////////////////////
// OUTPUT AXI LITE //
/////////////////////
   output logic  [7:0] status_and_debug, // TODO NOTE: DETERMINE WHAT THESE ARE
//////////////////////
// INPUT AXI STREAM //
//////////////////////
    input logic [63:0] pixel_stream_in,
    input logic        valid, start_of_frame, end_of_line,
////////////////////
// INPUT AXI LITE //
////////////////////
    input logic clock, clock_en, reset,
    input logic [31:0] m_map_registers[7:0]); // H Matrix

    logic [7:0] r_in[1:0],  g_in[1:0],  b_in[1:0];
    logic [7:0] r_out[1:0], g_out[1:0], b_out[1:0];
    logic valid_coords[1:0];
    int   current_x_input[1:0], current_y_input[1:0]; // TODO NOTE: drive these from controller with some sort of counter
    int   x_lookup[1:0], y_lookup[1:0];

    /////////////////////////////////////
    // PARSE PIXEL COLOR DATA FROM BUS //
    /////////////////////////////////////

    assign g_in[0] = pixel_stream_in[9:2];
    assign b_in[0] = pixel_stream_in[19:12];
    assign r_in[0] = pixel_stream_in[29:22];
    assign g_in[1] = pixel_stream_in[39:32];
    assign b_in[1] = pixel_stream_in[49:42];
    assign r_in[1] = pixel_stream_in[59:52];

    //////////////////////////////////
    // RAM HANDLER FOR INPUT BUFFER //
    //////////////////////////////////

    Input_RAM_Handler h0(.r_out(), .g_out(), .b_out(),
                         .valid_coords(valid_coords),
                         .x_write(current_x_input), .y_write(current_y_input),
                         .x_read(x_lookup), .y_read(y_lookup),
                         .r_in(r_in), .g_in(g_in), .b_in(b_in));

    ///////////////////////////////////
    // RAM HANDLER FOR OUTPUT BUFFER //
    ///////////////////////////////////

    // TODO NOTE: Write this  

    /////////////////////////////////////
    // DATAPATHS FOR COLOR CALCULATION //
    /////////////////////////////////////

    Transformation_datapath d0(.x_location(),    // TODO NOTE: hook this up to output buffer
                               .y_location(),    // TODO NOTE: same ^
                               .r(), .g(), .b(), // TODO NOTE: same ^^
                               .x_lookup(x_lookup[0]), 
                               .y_lookup(y_lookup[0]),
                               .x(current_x_calc), // TODO NOTE: Drive this from controller
                               .y(current_y_calc), // TODO NOTE: same
                               .r_source(r_out[0]),
                               .g_source(g_out[0]),
                               .b_source(b_out[0]),
                               .valid_coords(valid_coords[0]));

    Transformation_datapath d1(.x_location(),    // TODO NOTE: hook this up to output buffer
                               .y_location(),    // TODO NOTE: same ^
                               .r(), .g(), .b(), // TODO NOTE: same ^^
                               .x_lookup(x_lookup[1]), 
                               .y_lookup(y_lookup[1]),
                               .x(current_x_calc), // TODO NOTE: Drive this from controller
                               .y(current_y_calc), // TODO NOTE: same
                               .r_source(r_out[1]),
                               .g_source(g_out[1]),
                               .b_source(b_out[1]),
                               .valid_coords(valid_coords[1]));

    ////////////////
    // CONTROLLER //
    ////////////////

    // TODO NOTE: Write this

    /////////////
    // H LATCH //
    /////////////

    // TODO NOTE: Write this

    /////////////////////////
    // OUTPUT DATA HANDLER //
    /////////////////////////

    // TODO NOTE: Either write this or implement it as part of CONTROLLER
    //            At the very least, assign colors of output bus stream

endmodule: Keystone_correction 