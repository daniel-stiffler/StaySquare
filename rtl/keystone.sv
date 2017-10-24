/* 
   Anthony Kuntz, Adam Pinson, Daniel Stiffler
   SystemVerilog implementation of Keystone Correction IP block. 
*/

//////////////////////////////////////////////////////
//                                                  //
// Rounder module converts fixed-point to integer.  //
//                                                  //
//  - Assumes fixed-point = 2 bits, point, 23 bits. //
//  - Rounds up if first truncated bit == 1.        //
//                                                  //
//////////////////////////////////////////////////////
module Round_to_Coords 
  (output int          result,
    input logic [42:0] value);

    logic [19:0] truncated; // 43 bits - 23 bits
    
    int truncated_int;
    int round_up_int;

    assign truncated     = value[42:23];
    assign truncated_int = {{12{truncated[19] ,truncated}}};
    assign round_up_int  = value[FXD_PNT-1];

    assign result = truncated_int + round_up_int;

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
module Coordinate_calculator // TODO NOTE: This might need further pipelining
 #(parameter WIDTH=1920, HEIGHT=1080)
  (output int x_result, y_result,
    input logic clock,
    input int x, y,
    input int a, b, c, d, e, f, g, h);

    logic [42:0] ax, by, dx, ey, gx, hy;
    logic [42:0] xw, yw, w;
    logic [42:0] x_norm, y_norm;
    logic [42:0] x_adjust, y_adjust;

    ////////////////////////////////////////////
    // MULTIPLIERS FOR VECTOR MATRIX MULTIPLY //
    ////////////////////////////////////////////

    base_mb_xbip_dsp48_macro_0_0 m0(.CLK(clock),
                                    .P(ax),
                                    .A(a[24:0]),  // GET INDEXING RIGHT!!
                                    .B(x[17:0])); // GET INDEXING RIGHT!!

    base_mb_xbip_dsp48_macro_0_0 m1(.CLK(clock),
                                    .P(by),
                                    .A(b[24:0]),
                                    .B(y[17:0]));

    base_mb_xbip_dsp48_macro_0_0 m2(.CLK(clock),
                                    .P(dx),
                                    .A(d[24:0]),
                                    .B(x[17:0]));

    base_mb_xbip_dsp48_macro_0_0 m3(.CLK(clock),
                                    .P(ey),
                                    .A(e[24:0]),
                                    .B(y[17:0]));

    base_mb_xbip_dsp48_macro_0_0 m4(.CLK(clock),
                                    .P(gx),
                                    .A(g[24:0]),
                                    .B(x[17:0]));

    base_mb_xbip_dsp48_macro_0_0 m5(.CLK(clock),
                                    .P(hy),
                                    .A(h[24:0]),
                                    .B(y[17:0]));

    ///////////////////////////////////////
    // ADDERS FOR VECTOR MATRIX MULTIPLY //
    ///////////////////////////////////////

    assign xw = ax + by + {{11{c[31]}},c};
    assign yw = dx + ey + {{11{f[31]}},f};
    assign  w = gx + hy + 43'b1;

    ///////////////////////////////////////////
    // DIVIDERS FOR HOMOGENOUS NORMALIZATION //
    ///////////////////////////////////////////

    // TODO NOTE: Wow, how are we going to implement this???
    assign x_norm = xw / w;
    assign y_norm = yw / w;

    //////////////////////////////////////
    // ADDERS FOR COORDINATE ADJUSTMENT //
    //////////////////////////////////////

    // Division evaluated at compile-time
    assign x_adjust = x_norm +  WIDTH / 2;
    assign y_adjust = y_norm + HEIGHT / 2;

    ///////////////////////////////////////////
    // ROUNDERS TO CONVERT TO INT FOR LOOKUP //
    ///////////////////////////////////////////

    Round_to_Coords r0(.result(x_result),
                       .value(x_adjust));

    Round_to_Coords r1(.result(y_result),
                       .value(y_adjust));

endmodule: Coordinate_calculator

module Transformation_datapath
  (output int         x_location, y_location,
   output logic [7:0] r, g, b,
   output int         x_lookup, y_lookup,
    input int         x, y,
    input int         a, b, c, d, e, f, g, h,
    input logic [7:0] r_source, g_source, b_source,
    input logic       valid_coords,
    input logic       clock);

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
                             .*); // x,y,a,b,c,d,e,f,g,h,clock

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
module Input_RAM_Handler #(parameter WIDTH=1920, HEIGHT=1080) 
// TODO NOTE: Needs status, control, and timing signals
  (output logic [7:0] r_out[1:0], g_out[1:0], b_out[1:0],
   output logic       valid_coords[1:0],
    input int         x_write[1:0], y_write[1:0],
    input int         x_read[1:0],  y_read[1:0],
    input logic [7:0] r_in[1:0], g_in[1:0], b_in[1:0]);

    ////////////////////////////////////
    // CHECK FOR VALID OUTPUT REQUEST //
    ////////////////////////////////////

    assign valid_coords[0] = (0<=x_read[0]<WIDTH) && (0<=y_read[0]<HEIGHT);
    assign valid_coords[1] = (0<=x_read[1]<WIDTH) && (0<=y_read[1]<HEIGHT);

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
    int   current_x_input[1:0], current_y_input[1:0]; // TODO NOTE: drive these
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

    Transformation_datapath d0(.x_location(),    // TODO NOTE: hook this up
                               .y_location(),    // TODO NOTE: same ^
                               .r(), .g(), .b(), // TODO NOTE: same ^^
                               .x_lookup(x_lookup[0]), 
                               .y_lookup(y_lookup[0]),
                               .x(current_x_calc), // TODO NOTE: Drive this
                               .y(current_y_calc), // TODO NOTE: same
                               .r_source(r_out[0]),
                               .g_source(g_out[0]),
                               .b_source(b_out[0]),
                               .valid_coords(valid_coords[0]),
                               .clock(clock));

    Transformation_datapath d1(.x_location(),    // TODO NOTE: hook this up
                               .y_location(),    // TODO NOTE: same ^
                               .r(), .g(), .b(), // TODO NOTE: same ^^
                               .x_lookup(x_lookup[1]), 
                               .y_lookup(y_lookup[1]),
                               .x(current_x_calc), // TODO NOTE: Drive this
                               .y(current_y_calc), // TODO NOTE: same
                               .r_source(r_out[1]),
                               .g_source(g_out[1]),
                               .b_source(b_out[1]),
                               .valid_coords(valid_coords[1]),
                               .clock(clock));

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
