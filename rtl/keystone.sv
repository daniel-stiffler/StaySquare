/* 
   Anthony Kuntz, Adam Pinson, Daniel Stiffler
   SystemVerilog implementation of Keystone Correction IP block. 
*/

`default_nettype none
`define BRAM_ROWS 16
`define NUM_DIVS 31
`define WIDTH 1920
`define HEIGHT 1080

//////////////////////////////////////////////////////
//                                                  //
// Counter module increments a stored 32-bit value. //
//                                                  //
//  - On clear & incr, will set next value to 0.    //
//  - Asynchronous reset.                           //
//                                                  //
//////////////////////////////////////////////////////
module Counter #(parameter SIZE = 32)
  (output logic [SIZE-1:0] value,
    input logic reset, clock,
    input logic clear, incr);

    always_ff @(posedge clock or posedge reset)
             if( reset == 1'b1 ) value <= '0;
        else if( clear & ~incr ) value <= '0;
        else if(~clear &  incr ) value <= value + 1;
        else if( clear &  incr ) value <= '0; // !!!
        else                     value <= value;
    end

endmodule: Counter

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

/////////////////////////////////////////////////////////
//                                                     //
// Divider handler assigns requests to open dividers.  //
//                                                     //
//  - Xilinx High Radix algorithm.                     //
//    - Each divider has maximum 31 cycles of latency. //
//    - Returns 48 bit result.                         //
//      - 32 bit quotient.                             //
//      - 16 bit fractional remainder.                 //
//                                                     //
/////////////////////////////////////////////////////////
module Divider_Handler
    (input logic [31:0] input_A, input_B,
    output logic [47:0] out,
     input logic request, clock, reset,
    output logic done);

    int cycle;

    // TODO: a lot of arrays here

    generate
        genvar k;
        for (k = 0; k < `NUM_DIVS; k = k + 1) begin : divs
            base_mb_div_gen_0_0 d(.aclk(clock),
                          .s_axis_divisor_tvalid(b_valid[k]),
                          .s_axis_divisor_tready(b_ready[k]),
                          .s_axis_divisor_tdata(b_data[k]),
                          .s_axis_dividend_tvalid(a_valid[k]),
                          .s_axis_dividend_tready(a_ready[k]),
                          .s_axis_dividend_tdata(a_data[k]),
                          .m_axis_dout_tvalid(out_valid[k]),
                          .m_axis_dout_tdata(out_data[k]));
        end // divs
    endgenerate

    always_ff @(posedge clock) begin
             if(reset)              cycle <= 0;
        else if(cycle == `NUM_DIVS) cycle <= 0;
        else                        cycle <= cycle + 1;
    end

endmodule: Divider_Handler

//////////////////////////////////////////////////////////
//                                                      //
// Multiplier handler wraps multipliers for pipelining. //
//                                                      //
//  - Xilinx 32 x 32 bit multiplier.                    //
//    - Six-stage pipeline.                             //
//    - Returns 64 bit result.                          //
//                                                      //
//////////////////////////////////////////////////////////
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
    assign x_adjust = x_norm +  `WIDTH / 2;
    assign y_adjust = y_norm + `HEIGHT / 2;

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
/////////////////////////////////////////////////////////////////////
module Input_BRAM_Controller
  (output logic [7:0] r_out, g_out, b_out,
   output logic       valid_coords, done,
    input int         x_write, y_write,
    input int         x_read,  y_read,
    input logic [7:0] r_in, g_in, b_in,
    input logic       write_request, read_request,
    input logic       reset, clock, done_dest_frame);

    //////////////////////////////////
    // CHECK FOR VALID READ REQUEST //
    //////////////////////////////////

    assign valid_coords = (0<=x_read<`WIDTH) && (0<=y_read<`HEIGHT);

    /////////////////////
    // BLOCK RAM SETUP //
    /////////////////////

    logic [31:0] data_out[0:`BRAM_ROWS-1][0:1];
    logic [31:0]  data_in[0:`BRAM_ROWS-1][0:1];

    logic  [9:0]  read_addr[0:`BRAM_ROWS-1][0:1];
    logic  [9:0] write_addr[0:`BRAM_ROWS-1][0:1];

    logic        write_en[0:`BRAM_ROWS-1][0:1];
    logic         read_en[0:`BRAM_ROWS-1][0:1];

    logic [$clog2(`BRAM_ROWS)-1:0] bram_row_write, bram_row_read;
    logic                    [9:0] pos_bram_write, pos_bram_read;
    logic                          bram_col_write, bram_col_read;
    logic [31:0] write_value, read_value;

    logic [7:0] pass_count_read;
    logic [7:0] pass_count_write;
    logic [7:0] pass_count_reported;

    assign bram_row_write = y_write[$clog2(`BRAM_ROWS)-1:0]; // y % BRAM_ROWS
    assign bram_row_read  = y_read[$clog2(`BRAM_ROWS)-1:0];  // y % BRAM_ROWS
    assign bram_col_write = x_write[10];  // x / 1024;
    assign bram_col_read  = x_read[10];  
    assign pos_bram_write = x_write[9:0]; // x % 1024;
    assign pos_bram_read  = x_read[9:0];

    //////////////////
    // PASS COUNTER //
    //////////////////

    logic clear_count, done_src_frame;

    assign done_src_frame = ( (x_write ==  (`WIDTH-1)) &&
                              (y_write == (`HEIGHT-1)) );

    Counter #(8) p(.value(pass_count_write),
                   .reset(reset),
                   .clock(clock),
                   .clear(1'b0),
                   .incr(done_src_frame));

    Counter #(8) c(.value(pass_count_read),
                   .reset(reset),
                   .clock(clock),
                   .clear(1'b0),
                   .incr(done_dest_frame));

    /////////////////
    // BRAM VALUES //
    /////////////////

    assign write_value = {pass_count_write, r_in, g_in, b_in};
    assign data_in[bram_row_write][bram_col_write] = write_value;
    assign write_addr[bram_row_write][bram_col_write] = {22'b0,pos_bram_write};
    assign write_en[bram_row_write][bram_col_write] = write_request;

    assign read_value = data_out[bram_row_read][bram_col_read];
    assign pass_count_reported = read_value[31:24];
    assign read_addr[bram_row_read][bram_col_read] = {22'b0,pos_bram_read};
    assign read_en[bram_row_read][bram_col_read] = read_request;

    always_comb begin
        if(pass_count_reported == pass_count_read) begin
            r_out = read_value[23:16];
            g_out = read_value[15: 8];
            b_out = read_value[ 7: 0];
            done  = (((x_read < x_write) && (y_read == y_write)) 
                                         || (y_read  < y_write));
        end else begin // hot pink
            r_out = 8'hFF;
            g_out = 8'h1E;
            b_out = 8'hA6;
            done  = 1'b1;
        end
    end

    ////////////////
    // BLOCK RAMS //
    ////////////////    

    generate
        genvar i;
        genvar j;
        for (i = 0; i < `BRAM_ROWS; i = i + 1) begin : rows_of_bram
            for (j = 0; j < 2; j = j + 1) begin cols_of_bram

                bram BRAM_1024x32_Header(.DO(data_out[i][j]), 
                                         .DI(data_in[i][j]),
                                         .RDADDR(read_addr[i][j]), 
                                         .RDCLK(clock), 
                                         .RDEN(read_en[i][j]), 
                                         .RST(reset),
                                         .WRADDR(write_addr[i][j]), 
                                         .WRCLK(clock), 
                                         .WREN(write_en[i][j]));
            end // rows_of_bram
        end // cols_of_bram
    endgenerate

endmodule: Input_BRAM_Controller

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
   output logic        valid_out, ready_out,
   output logic        start_of_frame_out, end_of_line_out,
/////////////////////
// OUTPUT AXI LITE //
/////////////////////
   output logic  [7:0] status_and_debug, // TODO NOTE: DETERMINE WHAT THESE ARE
//////////////////////
// INPUT AXI STREAM //
//////////////////////
    input logic [63:0] pixel_stream_in,
    input logic        valid_in, ready_in,
    input logic        start_of_frame_in, end_of_line_in,
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
    logic valid_coords, read_done;
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

    assign done_dest_frame = ( (current_x_calc ==  (`WIDTH-1)) &&
                               (current_y_calc == (`HEIGHT-1)) );

    Input_BRAM_Controller c0(.r_out(), .g_out(), .b_out(),
                            .valid_coords(valid_coords), .done(read_done),
                            .x_write(current_x_input), .y_write(current_y_input),
                            .x_read(x_lookup), .y_read(y_lookup),
                            .r_in(r_in), .g_in(g_in), .b_in(b_in),
                            .reset(reset), .clock(clock), 
                            .done_dest_frame(done_dest_frame));

    ///////////////////////////////////
    // RAM HANDLER FOR OUTPUT BUFFER //
    ///////////////////////////////////

    // TODO NOTE: What should this be? 

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
                               .a(), .b(), 
                               .c(), .d(), 
                               .e(), .f(), 
                               .g(), .h(),
                               .r_source(r_out),
                               .g_source(g_out),
                               .b_source(b_out),
                               .valid_coords(valid_coords),
                               .clock(clock),
                               .reset(reset));

    ////////////////
    // CONTROLLER //
    ////////////////

    enum logic [1:0] {WAIT_FOR_PIX, VALID_PIX, PRESSURE} currState, nextState;

    always_ff @(posedge clock) begin
        if(reset) currState <= WAIT_FOR_PIX;
        else      currState <= nextState;
    end

    always_comb begin

        nextState = currState;
        ready_out = ready_from_datapath_start;
        valid_to_datapath_start = 1'b0

        case(currState)
            WAIT_FOR_PIX: begin
                if(~ready_from_datapath_start) nextState = PRESSURE;
                else nextState = (valid_in & start_of_frame_in) ? VALID_PIX : WAIT_FOR_PIX;
                valid_to_datapath_start = 1'b1;
            end
            VALID_PIX: begin
                if(~ready_from_datapath_start) nextState = PRESSURE;
                else nextState = (valid_in & ~end_of_line_in) ? VALID_PIX : WAIT_FOR_PIX;
            end
            PRESSURE: begin
                if(~ready_from_datapath_start) nextState = PRESSURE;
                else nextState = (valid_in) ? VALID_PIX : WAIT_FOR_PIX;
            end
        endcase // currState
    end

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
