module Keystone (
    //////////////////////////
    // AXI STREAM BEFORE IP //
    //////////////////////////
    input wire  [23:0] s_axis_video_tdata_in,
    input wire         s_axis_video_tvalid_in,
   output wire         s_axis_video_tready_out,
    input wire         s_axis_video_tuser_in,
    input wire         s_axis_video_tlast_in,
    /////////////////////////
    // AXI STREAM AFTER IP //
    /////////////////////////
   output wire [23:0] m_axis_video_tdata_out,
   output wire        m_axis_video_tvalid_out,
    input wire        m_axis_video_tready_in,
   output wire        m_axis_video_tuser_out,
   output wire        m_axis_video_tlast_out,
    ///////////////////////
    // AXI STREAM TIMING //
    ///////////////////////
    input wire         aclk, aclken, aresetn,
    ////////////
    // BYPASS //
    ////////////
    input wire         bypass
    );
    
    ////////////////////
    // KEYSTONE PORTS //
    ////////////////////
    logic [63:0] data_in;
    logic [9:0] data_in_red, data_in_green, data_in_blue;
    logic [63:0] data_out;
    logic [7:0] data_out_red, data_out_green, data_out_blue;
    
    assign data_in_red = {s_axis_video_tdata_in[23:16], 2'b00};
    assign data_in_green = {s_axis_video_tdata_in[15:8], 2'b00};
    assign data_in_blue = {s_axis_video_tdata_in[7:0], 2'b00};
    assign data_in = {44'b0, data_in_red, data_in_green, data_in_blue};

    assign data_out_red = data_out[29:22];
    assign data_out_green = data_out[19:12];
    assign data_out_blue = data_out[9:2];
    
    logic key_valid_out, key_ready_out, key_start_of_frame_out, key_end_of_line_out;
    
    ///////////////////
    // BYPASS MUXING //
    ///////////////////
    assign s_axis_video_tready_out = bypass ? m_axis_video_tready_in : key_ready_out;
    
    assign m_axis_video_tdata_out = bypass ? s_axis_video_tdata_in : {data_out_red, data_out_green, data_out_blue};
    assign m_axis_video_tvalid_out = bypass ? s_axis_video_tvalid_in : key_valid_out;
    assign m_axis_video_tuser_out = bypass ? s_axis_video_tuser_in : key_start_of_frame_out;
    assign m_axis_video_tlast_out = bypass ? s_axis_video_tlast_in : key_end_of_line_out;
    
    ///////////////////
    // IP Connection //
    ///////////////////
    Keystone_Correction ip(.pixel_stream_out(data_out),
                           //.valid_out(m_axis_video_tvalid_out),
                           .valid_out(key_valid_out), 
                           //.ready_out(s_axis_video_tready_out),
                           .ready_out(key_ready_out),
                           //.start_of_frame_out(m_axis_video_tuser_out),
                           .start_of_frame_out(key_start_of_frame_out), 
                           //.end_of_line_out(m_axis_video_tlast_out),
                           .end_of_line_out(key_end_of_line_out),
                           .pixel_stream_in(data_in),
                           .valid_in(s_axis_video_tvalid_in), 
                           .ready_in(m_axis_video_tready_in),
                           .start_of_frame_in(s_axis_video_tuser_in),
                           .end_of_line_in(s_axis_video_tlast_in),
                           .clock(aclk),
                           .clock_en(aclken),
                           .reset(~aresetn),
                           .H11(32'd9907479), 
                           .H12(32'd0), 
                           .H13(32'd2),
                           .H21(32'd0), 
                           .H22(32'd9822719), 
                           .H23(32'd0),
                           .H31(32'd0), 
                           .H32(32'd608), 
                           .H33(32'd9318318));

endmodule: Keystone
