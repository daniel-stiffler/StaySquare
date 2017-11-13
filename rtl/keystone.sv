/* 
   Anthony Kuntz, Adam Pinson, Daniel Stiffler
   SystemVerilog implementation of Keystone Correction IP block. 
*/

`default_nettype none
`define NUM_BRAMS 8

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
    input logic [63:0] value);

    // logic [19:0] truncated; // 43 bits - 23 bits
    
    // int truncated_int;
    // int round_up_int;

    // assign truncated     = value[42:23];
    // assign truncated_int = {{12{truncated[19] ,truncated}}};
    // assign round_up_int  = value[FXD_PNT-1];

    // assign result = truncated_int + round_up_int;

    // TODO: Rewrite this based on FIXED POINT LOCATION

endmodule: Round_to_Coords

module Divider_Handler
    (input logic [31:0] input_A, input_B,
    output logic [47:0] out,
     input logic request, clock, reset,
    output logic done);

    int cycle;

    // TODO: a lot of arrays here

    generate
        genvar j;
        for (j = 0; j < `NUM_DIVS; j = j + 1) begin : divs
            base_mb_div_gen_0_0 d(.aclk(clock),
                          .s_axis_divisor_tvalid(b_valid[j]),
                          .s_axis_divisor_tready(b_ready[j]),
                          .s_axis_divisor_tdata(b_data[j]),
                          .s_axis_dividend_tvalid(a_valid[j]),
                          .s_axis_dividend_tready(a_ready[j]),
                          .s_axis_dividend_tdata(a_data[j]),
                          .m_axis_dout_tvalid(out_valid[j]),
                          .m_axis_dout_tdata(out_data[j]));
        end // divs
    endgenerate

    always_ff @(posedge clock) begin
             if(reset)      cycle <= 0;
        else if(cycle == 5) cycle <= 0;
        else                cycle <= cycle + 1;
    end

endmodule: Divider_Handler

module Multiplier_Handler
    (input logic clock, reset, 
    output logic [63:0] P, 
     input logic [31:0] A, B, 
     input logic request, 
    output logic done);

    logic req_1, req_2, req_3;
    logic req_4, req_5;

    base_mb_mult_gen_0_0 m(.CLK(clock), .*);

    assign done = req_5;

    // Delay request by 5 cycles to indicate end of 6 stage pipeline
    always_ff @(posedge clock) begin
        if(reset) begin
            {req_1,req_2,req_3,req_4,req_5} <= 5'b00000;
        end else begin
            req_1 <= request;
            req_2 <= req_1;
            req_3 <= req_2;
            req_4 <= req_3;
            req_5 <= req_4;
        end
    end

endmodule: Multiplier_Handler

///////////////////////////////////////////////////////////////
//                                                           //
// Coordinate Calculator Block Transforms x, y to x0, y0.    //
//                                                           //
//  - Receives H matrix and coordinates as integers.         //
//  - Assumes fixed-point representation of H matrix values. //
//  - Rounds and formats results for easy integer lookup.    //
//                                                           //
///////////////////////////////////////////////////////////////
module Coordinate_Calculator // TODO NOTE: This might need further pipelining
 #(parameter WIDTH=1920, HEIGHT=1080)
  (output int x_result, y_result,
    input logic clock, reset,
    input int x, y,
    input int a, b, c, d, e, f, g, h);

    logic [63:0] ax, by, dx, ey, gx, hy;
    logic [63:0] xw, yw, w;
    logic [63:0] x_norm, y_norm;
    logic [63:0] x_adjust, y_adjust;
    logic        x_div_done, y_div_done;
    logic        done_ax, done_by, done_dx;
    logic        done_ey, done_gx, done_hy;

    ////////////////////////////////////////////
    // MULTIPLIERS FOR VECTOR MATRIX MULTIPLY //
    ////////////////////////////////////////////

    Multiplier_Handler m0(.clock(clock),
                          .reset(reset),
                          .P(ax),
                          .A(a),  // GET INDEXING RIGHT!!
                          .B(x),
                          .request(1'b1),
                          .done(done_ax)); // GET INDEXING RIGHT!!

    Multiplier_Handler m1(.clock(clock),
                          .reset(reset),
                          .P(by),
                          .A(b),
                          .B(y),
                          .request(1'b1),
                          .done(done_by));

    Multiplier_Handler m2(.clock(clock),
                          .reset(reset),
                          .P(dx),
                          .A(d),
                          .B(x),
                          .request(1'b1),
                          .done(done_dx));

    Multiplier_Handler m3(.clock(clock),
                          .reset(reset),
                          .P(ey),
                          .A(e),
                          .B(y),
                          .request(1'b1),
                          .done(done_ey));

    Multiplier_Handler m4(.clock(clock),
                          .reset(reset),
                          .P(gx),
                          .A(g),
                          .B(x),
                          .request(1'b1),
                          .done(done_gx));

    Multiplier_Handler m5(.clock(clock),
                          .reset(reset),
                          .P(hy),
                          .A(h),
                          .B(y),
                          .request(1'b1),
                          .done(done_hy));

    ///////////////////////////////////////
    // ADDERS FOR VECTOR MATRIX MULTIPLY //
    ///////////////////////////////////////

    assign xw = ax + by + {{32{c[31]}},c};
    assign yw = dx + ey + {{32{f[31]}},f};
    assign  w = gx + hy + 64'd1;

    ///////////////////////////////////////////
    // DIVIDERS FOR HOMOGENOUS NORMALIZATION //
    ///////////////////////////////////////////

    Divider_Handler dh0(.input_A(xw),
                        .input_B(w),
                        .out(x_norm),
                        .request(1'b1), // TODO: fix this
                        .done(x_div_done),
                        .clock(clock),
                        .reset(reset));

    Divider_Handler dh1(.input_A(yw),
                        .input_B(w),
                        .out(y_norm),
                        .request(1'b1), // TODO: fix this
                        .done(y_div_done),
                        .clock(clock),
                        .reset(reset));    

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

endmodule: Coordinate_Calculator

module Transformation_Datapath
  (output int         x_location, y_location,
   output logic [7:0] red, green, blue,
   output int         x_lookup, y_lookup,
    input int         x, y,
    input int         a, b, c, d, e, f, g, h,
    input logic [7:0] r_source, g_source, b_source,
    input logic       valid_coords,
    input logic       clock, reset);

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

    assign {red,green,blue} = (valid_coords)?{r_source,g_source,b_source}:24'b0;

endmodule: Transformation_Datapath

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
  (output logic [7:0] r_out, g_out, b_out,
   output logic       valid_coords,
    input int         x_write, y_write,
    input int         x_read,  y_read,
    input logic [7:0] r_in, g_in, b_in,
    input logic       reset, clock);

    ////////////////////////////////////
    // CHECK FOR VALID OUTPUT REQUEST //
    ////////////////////////////////////

    assign valid_coords[0] = (0<=x_read[0]<WIDTH) && (0<=y_read[0]<HEIGHT);
    assign valid_coords[1] = (0<=x_read[1]<WIDTH) && (0<=y_read[1]<HEIGHT);

    /////////////////////
    // BLOCK RAM SETUP //
    /////////////////////

    logic [`NUM_BRAMS-1:0][31:0] data_out, data_in;
    logic [`NUM_BRAMS-1:0] [9:0] read_addr, write_addr;
    logic [`NUM_BRAMS-1:0]       write_en, read_en;

    logic [9:0] read_address, write_address;      
    int         read_position,  read_index;
    int        write_position, write_index;

    // Flatten the read request address
    always_comb begin
        assert(`NUM_BRAMS == 8);
        case(y_read[2:0]) // Only do 8 rows at a time
            3'd0: read_position = WIDTH*0 + x_read;
            3'd1: read_position = WIDTH*1 + x_read;
            3'd2: read_position = WIDTH*2 + x_read;
            3'd3: read_position = WIDTH*3 + x_read;
            3'd4: read_position = WIDTH*4 + x_read;
            3'd5: read_position = WIDTH*5 + x_read;
            3'd6: read_position = WIDTH*6 + x_read;
            3'd7: read_position = WIDTH*7 + x_read;
            default: read_position = 'X;
        endcase // y_read[2:0]
    end // always_comb

    // Flatten the write request address
    always_comb begin
        assert(`NUM_BRAMS == 8);
        case(y_write[2:0]) // Only do 8 rows at a time
            3'd0: write_position = WIDTH*0 + x_write;
            3'd1: write_position = WIDTH*1 + x_write;
            3'd2: write_position = WIDTH*2 + x_write;
            3'd3: write_position = WIDTH*3 + x_write;
            3'd4: write_position = WIDTH*4 + x_write;
            3'd5: write_position = WIDTH*5 + x_write;
            3'd6: write_position = WIDTH*6 + x_write;
            3'd7: write_position = WIDTH*7 + x_write;
            default: write_position = 'X;
        endcase // y_read[2:0]
    end // always_comb

    // Determine which BRAM and what address for it
    assign  read_address = read_position[9:0];
    assign  read_index   = {10'b0, read_position[31:10]};
    assign write_address = write_position[9:0];
    assign write_index   = {10'b0, write_position[31:10]};

    // Set up BRAM values
    assign  read_addr[read_index]  = read_address;
    assign  read_en[read_index]    = 1'b1;
    assign write_addr[write_index] = write_address;
    assign write_en[write_index]   = 1'b1;

    // Grab the values
    assign {r_out, g_out, b_out} = data_out[read_index][23:0];
    assign data_in[write_index][31:0] = {8'b0, r_in, g_in, b_in};

    ////////////////
    // BLOCK RAMS //
    ////////////////    

    generate
        genvar i;
        for (i = 0; i < `NUM_BRAMS; i = i + 1) begin : brams

            bram BRAM_1024x32_Header(.DO(data_out[i]), 
                                     .DI(data_in[i]),
                                     .RDADDR(read_addr[i]), 
                                     .RDCLK(clock), 
                                     .RDEN(read_en[i]), 
                                     .RST(reset),
                                     .WRADDR(write_addr[i]), 
                                     .WRCLK(clock), 
                                     .WREN(write_en[i]));
        end
    endgenerate

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
module Keystone_Correction
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

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////

    logic [7:0] r_in,  g_in,  b_in;
    logic [7:0] r_out, g_out, b_out;
    logic valid_coords;
    int   current_x_input, current_y_input; // TODO NOTE: drive these
    int   x_lookup, y_lookup;
    int   current_x_calc, current_y_calc;

    /////////////////////////////////////
    // PARSE PIXEL COLOR DATA FROM BUS //
    /////////////////////////////////////

    assign g_in = pixel_stream_in[9:2];
    assign b_in = pixel_stream_in[19:12];
    assign r_in = pixel_stream_in[29:22];

    //////////////////////////////////
    // RAM HANDLER FOR INPUT BUFFER //
    //////////////////////////////////

    Input_RAM_Handler h0(.r_out(), .g_out(), .b_out(),
                         .valid_coords(valid_coords),
                         .x_write(current_x_input), .y_write(current_y_input),
                         .x_read(x_lookup), .y_read(y_lookup),
                         .r_in(r_in), .g_in(g_in), .b_in(b_in),
                         .reset(reset), .clock(clock));

    ///////////////////////////////////
    // RAM HANDLER FOR OUTPUT BUFFER //
    ///////////////////////////////////

    // TODO NOTE: Write this  

    /////////////////////////////////////
    // DATAPATHS FOR COLOR CALCULATION //
    /////////////////////////////////////

    Transformation_Datapath d0(.x_location(),    // TODO NOTE: hook this up
                               .y_location(),    // TODO NOTE: same ^
                               .red(), .green(), .blue(), // TODO NOTE: same ^^
                               .x_lookup(x_lookup), 
                               .y_lookup(y_lookup),
                               .x(current_x_calc), // TODO NOTE: Drive this
                               .y(current_y_calc), // TODO NOTE: same
                               .r_source(r_out),
                               .g_source(g_out),
                               .b_source(b_out),
                               .valid_coords(valid_coords),
                               .clock(clock),
                               .reset(reset));

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

endmodule: Keystone_Correction 
