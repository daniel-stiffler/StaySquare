/* 
   Anthony Kuntz, Adam Pinson, Daniel Stiffler
   SystemVerilog implementation of Keystone Correction IP block. 
*/

`default_nettype none
`define BRAM_ROWS 16
`define NUM_DIVS 31
`define WIDTH 1920
`define HEIGHT 1080
`define FIXED_POINT 16
`define INT_SIZE 32

typedef struct{
    logic valid;
    int x;
    int y;
} packet;

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
    input wire reset, clock,
    input wire clear, incr);

    always_ff @(posedge clock or posedge reset) begin
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
  (output int         result,
    input wire [47:0] value);

    /////////////////////////////
    // ROUND UP DIVIDER RESULT //
    /////////////////////////////

    logic [15:0] fractional_remainder;
    int div_res;
    int round_up_div_res;
    int rounded_div_res;

    assign fractional_remainder = value[15:0];
    assign div_res = value[47:16];
    assign round_up_div_res = fractional_remainder[15];
    assign rounded_div_res = div_res + round_up_div_res;

    ////////////////////////////////////////////////
    // GRAB AND ROUND INTEGER HALF OF FIXED POINT //
    ////////////////////////////////////////////////

    logic [FIXED_POINT-1:0] dropped;
    int upper;
    int round_up_upper;
    
    assign dropped = rounded_div_res[15:0];
    assign upper = {{16{rounded_div_res[31]}}, rounded_div_res[31:16]};
    assign round_up_upper = dropped[15];
    assign result = upper + round_up_upper;

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
    (input wire [31:0] input_A, input_B,
     input packet dest_pixel_in,
     input wire  ready_in,
    output logic [47:0] out,
    output packet dest_pixel_out,
     input wire clock, reset, enable,
    output logic done);

    int          in_pointer, out_pointer;
    
    logic        b_valid[0:`NUM_DIVS - 1];
    logic        b_ready[0:`NUM_DIVS - 1];
    logic [31:0] b_data[0:`NUM_DIVS - 1];
    logic        a_valid[0:`NUM_DIVS - 1];
    logic        a_ready[0:`NUM_DIVS - 1];
    logic [31:0] a_data[0:`NUM_DIVS - 1];
    logic        out_valid[0:`NUM_DIVS - 1];
    logic [47:0] out_data[0:`NUM_DIVS - 1];
    
    logic [47:0]  out_data_reg[0:`NUM_DIVS - 1];
    packet        dest_pixel_in_reg[0:`NUM_DIVS - 1];
    
    // TODO: Lots of divider handling logic needed here

    //////////////
    // DIVIDERS //
    //////////////
    generate
        genvar k;
        for (k = 0; k < `NUM_DIVS; k = k + 1) begin : divs
            div_gen_0 d(.aclk(clock),
                        .aclken(enable),
                        .aresetn(~reset),
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

    /////////////
    // CONTROL //
    /////////////
    always_ff @(posedge clock) begin
        if(reset)
            in_pointer <= 0;
        else if(in_pointer == `NUM_DIVS-1 && dest_pixel_in.valid == 1'b1) 
            in_pointer <= 0;
        else if(dest_pixel_in.valid)
            in_pointer <= in_pointer + 1;
    end
    
    int i;
    always_comb begin
        for(i = 0; i < `NUM_DIVS; i = i + 1) begin
            if(i == in_pointer) begin
                a_data[i]  = input_A;
                a_valid[i] = dest_pixel_in.valid;
                b_data[i]  = input_B;
                b_valid[i] = dest_pixel_in.valid;
            end else begin
                a_data[i]  = '0;
                a_valid[i] = 1'b0;
                b_data[i]  = '0;
                b_valid[i] = 1'b0;
            end
        end
    end
    
    always_ff @(posedge clock) begin
            if(reset)
                out_pointer <= 0;
            else if(out_pointer == `NUM_DIVS-1 && ready_in == 1'b1) 
                out_pointer <= 0;
            else if(ready_in)
                out_pointer <= out_pointer + 1;
    end
    
    assign        out =      out_data[out_pointer];
    assign dest_pixel_out = dest_pixel_in_reg[out_pointer];
    
    ////////////////////////
    // DEST LOCATION REGS //
    ////////////////////////
    int v;
    always_ff @(posedge clock) begin
        for(v = 0; v < `NUM_DIVS; v = v + 1) begin
            if(reset) begin
                dest_pixel_in_reg[v] = '0;
            end else if(in_pointer == v && enable == 1'b1) begin
                dest_pixel_in_reg[v] <= dest_pixel_in;
            end
        end
    end
    
    //////////////////////
    // OUTPUT REGISTERS //
    //////////////////////
    int u;
    always_ff @(posedge clock) begin
        for(u = 0; u < `NUM_DIVS; u = u + 1) begin
            if(reset)
                out_data_reg[u] <= '0;
            else if(enable & out_valid[u])
                out_data_reg[u] <= out_data[u];
        end
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
    (input wire clock, reset, enable,
    output logic [63:0] P, 
     input wire [31:0] A, B,
     input wire request,
    output logic done);

    logic req_1, req_2, req_3, req_4, req_5;

    mult_gen_0 m(.CLK(clock), .CE(enable), .*);

    assign done = req_5;

    // Delay request by 5 cycles to indicate end of 6 stage pipeline
    always_ff @(posedge clock) begin
        if(reset) begin
        
            {req_1,req_2,req_3,req_4,req_5} <= 5'b00000;
            
        end else if (enable) begin
        
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
// Transformation Datapath Transforms x, y to x0, y0.        //
//                                                           //
//  - Receives H matrix and coordinates as integers.         //
//  - Assumes fixed-point representation of H matrix values. //
//  - Rounds and formats results for easy integer lookup.    //
//                                                           //
///////////////////////////////////////////////////////////////
module Transformation_Datapath
  (output logic [7:0] red, green, blue,
   output int         x_result, y_result,
   output logic       ready,
    input packet      dest_pixel_in,
   output packet      dest_pixel_out,
    input int         a, b, c, d, e, f, g, h,
    input wire [7:0] r_source, g_source, b_source,
    input wire       valid_coords,
    input wire       clock, reset);

    ////////////////////////////////////////////
    // CALCULATE COORDINATES FOR COLOR LOOKUP //
    ////////////////////////////////////////////

    logic [63:0] ax, by, dx, ey, gx, hy;
    logic [63:0] xw, yw, w;
    logic [47:0] x_norm, y_norm;
    int          x, y;
    int          x_round, y_round;
    logic        x_div_done, y_div_done;
    logic        done_ax, done_by, done_dx;
    logic        done_ey, done_gx, done_hy;

    packet dest_pixel_1, dest_pixel_2, dest_pixel_3;
    packet dest_pixel_4, dest_pixel_5;
    packet dest_pixel_from_mults;

    assign x = dest_pixel_in.x;
    assign y = dest_pixel_in.y;

    ////////////////////////////////////////////
    // MULTIPLIERS FOR VECTOR MATRIX MULTIPLY //
    ////////////////////////////////////////////

    assign dest_pixel_from_mults = dest_pixel_5;

    Multiplier_Handler m0(.clock(clock),
                          .reset(reset),
                          .P(ax),
                          .A(a),
                          .B(x),
                          .request(dest_pixel_in.valid),
                          .done(done_ax));

    Multiplier_Handler m1(.clock(clock),
                          .reset(reset),
                          .P(by),
                          .A(b),
                          .B(y),
                          .request(dest_pixel_in.valid),
                          .done(done_by));

    Multiplier_Handler m2(.clock(clock),
                          .reset(reset),
                          .P(dx),
                          .A(d),
                          .B(x),
                          .request(dest_pixel_in.valid),
                          .done(done_dx));

    Multiplier_Handler m3(.clock(clock),
                          .reset(reset),
                          .P(ey),
                          .A(e),
                          .B(y),
                          .request(dest_pixel_in.valid),
                          .done(done_ey));

    Multiplier_Handler m4(.clock(clock),
                          .reset(reset),
                          .P(gx),
                          .A(g),
                          .B(x),
                          .request(dest_pixel_in.valid),
                          .done(done_gx));

    Multiplier_Handler m5(.clock(clock),
                          .reset(reset),
                          .P(hy),
                          .A(h),
                          .B(y),
                          .request(dest_pixel_in.valid),
                          .done(done_hy));

    always_ff @(posedge clock) begin
        if(reset) begin
            dest_pixel_1 <= '0;
            dest_pixel_2 <= '0;
            dest_pixel_3 <= '0;
            dest_pixel_4 <= '0;
            dest_pixel_5 <= '0;
        end else begin
            dest_pixel_1 <= dest_pixel_in;
            dest_pixel_2 <= dest_pixel_1;
            dest_pixel_3 <= dest_pixel_2;
            dest_pixel_4 <= dest_pixel_3;
            dest_pixel_5 <= dest_pixel_4;
        end
    end

    ///////////////////////////////////////
    // ADDERS FOR VECTOR MATRIX MULTIPLY //
    ///////////////////////////////////////

    assign xw = ax + by + {{32{c[31]}},c};
    assign yw = dx + ey + {{32{f[31]}},f};
    assign  w = gx + hy + 64'd1;

    ///////////////////////////////////////////
    // DIVIDERS FOR HOMOGENOUS NORMALIZATION //
    ///////////////////////////////////////////

    Divider_Handler dh0(.input_A(xw[FIXED_POINT/2+INT_SIZE-1:FIXED_POINT/2]),
                        .input_B(w[FIXED_POINT/2+INT_SIZE-1:FIXED_POINT/2]),
                        .dest_pixel_in(dest_pixel_from_mults),
                        .out(x_norm),
                        .done(x_div_done),
                        .dest_pixel_out(dest_pixel_out),
                        .ready_in(),
                        .clock(clock),
                        .reset(reset));

    Divider_Handler dh1(.input_A(yw[FIXED_POINT/2+INT_SIZE-1:FIXED_POINT/2]),
                        .input_B(w[FIXED_POINT/2+INT_SIZE-1:FIXED_POINT/2]),
                        .dest_pixel_in(dest_pixel_from_mults),
                        .out(y_norm),
                        .done(y_div_done),
                        .dest_pixel_out(dest_pixel_out),
                        .ready_in(),
                        .clock(clock),
                        .reset(reset));    

    ///////////////////////////////////////////
    // ROUNDERS TO CONVERT TO INT FOR LOOKUP //
    ///////////////////////////////////////////

    Round_to_Coords r0(.result(x_norm),
                       .value(x_round));

    Round_to_Coords r1(.result(y_norm),
                       .value(y_round));

    //////////////////////////////////////
    // ADDERS FOR COORDINATE ADJUSTMENT //
    //////////////////////////////////////

    assign x_result = x_round +  `WIDTH / 2;
    assign y_result = y_round + `HEIGHT / 2;

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
    input wire  [7:0] r_in, g_in, b_in,
    input wire        write_request, read_request,
    input wire        reset, clock, done_dest_frame);

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
    wire  [31:0] write_value;
    logic [31:0] read_value;

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

    int row, col;
    
    assign write_value = {pass_count_write, r_in, g_in, b_in};
    
    always_comb begin
    
        read_value = '0;
    
        for (row = 0; row < `BRAM_ROWS; row = row + 1) begin
            for (col = 0; col < 2; col = col + 1) begin
            
                if(row == bram_row_write && col == bram_col_write) begin
                
                    data_in[row][col] = write_value;
                    write_addr[row][col] = {22'b0,pos_bram_write};
                    write_en[row][col] = write_request;
                    read_addr[row][col] = {22'b0,pos_bram_read};
                    read_en[row][col] = read_request;
                    
                    read_value = data_out[row][col];
                    
                end else begin
                
                    data_in[row][col] = '0;
                    write_addr[row][col] = '0;
                    write_en[row][col] = 1'b0;
                    read_addr[row][col] = '0;
                    read_en[row][col] = 1'b0;
                    
                end
            end
        end
        
        pass_count_reported = read_value[31:24];
        
    end


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
            for (j = 0; j < 2; j = j + 1) begin : cols_of_bram

                BRAM_1024x32_Header bram(.DO(data_out[i][j]), 
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
    input wire [63:0] pixel_stream_in,
    input wire        valid_in, ready_in,
    input wire        start_of_frame_in, end_of_line_in,
////////////////////
// INPUT AXI LITE //
////////////////////
    input wire clock, clock_en, reset,
    input wire [31:0] H11,H12,H13,H21,H22,H23,H31,H32);

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////

    logic [63:0] output_pixel_packet;
    logic [7:0] r_in,  g_in,  b_in;
    logic [7:0] r_out_from_bram, g_out_from_bram, b_out_from_bram;
    logic [7:0] r_calc, g_calc, b_calc;
    logic valid_coords, read_done;
    logic last_col_done, last_row_done;
    logic done_dest_frame;
    int   current_x_input, current_y_input;
    int   x_lookup, y_lookup;
    int   current_x_calc, current_y_calc;
    int   done_pix_loc_x, done_pix_loc_y;

    int a,b,c,d,e,f,g,h;

    packet datapath_request, datapath_answer;
    logic calculating;

    /////////////////////////////////////
    // PARSE PIXEL COLOR DATA FROM BUS //
    /////////////////////////////////////

    assign g_in = pixel_stream_in[9:2];
    assign b_in = pixel_stream_in[19:12];
    assign r_in = pixel_stream_in[29:22];

    assign output_pixel_packet[9:2]   = g_calc;
    assign output_pixel_packet[19:12] = b_calc;
    assign output_pixel_packet[29:22] = r_calc;    

    //////////////////////////////////
    // RAM HANDLER FOR INPUT BUFFER //
    //////////////////////////////////

    assign done_dest_frame = ( (datapath_answer.x ==  (`WIDTH-1)) &&
                               (datapath_answer.y == (`HEIGHT-1)) );

    Input_BRAM_Controller c0(.r_out(r_out_from_bram), 
                             .g_out(g_out_from_bram), 
                             .b_out(b_out_from_bram),
                             .valid_coords(valid_coords), 
                             .done(read_done),
                             .x_write(current_x_input), 
                             .y_write(current_y_input),
                             .x_read(x_lookup), 
                             .y_read(y_lookup),
                             .r_in(r_in), 
                             .g_in(g_in), 
                             .b_in(b_in),
                             .write_request(valid_in), 
                             .read_request(datapath_answer.valid),
                             .reset(reset), 
                             .clock(clock), 
                             .done_dest_frame(done_dest_frame));

    /////////////////////////////////////
    // DATAPATHS FOR COLOR CALCULATION //
    /////////////////////////////////////

    always_ff @(posedge clock) begin
        if(reset) begin
            calculating <= valid_in;
        end else if(done_dest_frame) begin
            calculating <= 1'b0;
        end else if(start_of_frame_in) begin
            calculating <= 1'b1;
        end
    end

    assign datapath_request.x = current_x_calc;
    assign datapath_request.y = current_y_calc;
    assign datapath_request.valid = calculating;

    Transformation_Datapath d0(.red(r_calc), .green(g_calc), .blue(b_calc),
                               .x_result(x_lookup), 
                               .y_result(y_lookup),
                               .ready(ready_out),
                               .dest_pixel_in(datapath_request),
                               .dest_pixel_out(datapath_answer),
                               .a(a), .b(b), 
                               .c(c), .d(d), 
                               .e(e), .f(f), 
                               .g(g), .h(h),
                               .r_source(r_out_from_bram),
                               .g_source(g_out_from_bram),
                               .b_source(b_out_from_bram),
                               .valid_coords(valid_coords),
                               .clock(clock),
                               .reset(reset));

    ////////////////
    // CONTROLLER //
    ////////////////

    assign last_col_done = ((read_done==1'b1) && (current_x_calc==`WIDTH-1));
    assign last_row_done = ((read_done==1'b1) && (current_y_calc==`HEIGHT-1));

    Counter #(32) xc(.value(current_x_calc),
                     .reset(reset),
                     .clock(clock),
                     .clear(last_col_done),
                     .incr(read_done));

    Counter #(32) yc(.value(current_y_calc),
                     .reset(reset),
                     .clock(clock),
                     .clear(last_row_done),
                     .incr(last_col_done));
                    
    Counter #(32) xi(.value(current_x_input),
                     .reset(reset),
                     .clock(clock),
                     .clear(current_x_input == `WIDTH -1 && valid_in == 1'b1), // TODO: verify these
                     .incr(valid_in));
                
    Counter #(32) yi(.value(current_y_input),
                     .reset(reset),
                     .clock(clock),
                     .clear(end_of_line_in),
                     .incr(current_x_input == `WIDTH -1 && valid_in == 1'b1));

    /////////////
    // H LATCH //
    /////////////

    always_ff @(posedge clock) begin
        if(reset) begin
            a <= 0;
            b <= 0;
            c <= 0;
            d <= 0;
            e <= 0;
            f <= 0;
            g <= 0;
            h <= 0;
        end else if(start_of_frame_in) begin
            a <= H11;
            b <= H12;
            c <= H13;
            d <= H21;
            e <= H22;
            f <= H23;
            g <= H31;
            h <= H32;
        end
    end

    //////////////////
    // OUTPUT QUEUE //
    //////////////////

    // TODO: put a queue here
    assign pixel_stream_out = output_pixel_packet;

endmodule: Keystone_Correction