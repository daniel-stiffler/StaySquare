`define C_S_AXI_DATA_WIDTH 32

module Keystone
    //////////////////////////
    // AXI STREAM BEFORE IP //
    //////////////////////////
   (input wire  [63:0] s_axis_video_tdata_in,
    input wire         s_axis_video_tvalid_in,
   output logic        s_axis_video_tready_out,
    input wire         s_axis_video_tuser_in,
    input wire         s_axis_video_tlast_in,
    /////////////////////////
    // AXI STREAM AFTER IP //
    /////////////////////////
   output logic [63:0] s_axis_video_tdata_out,
   output logic        s_axis_video_tvalid_out,
    input wire         s_axis_video_tready_in,
   output logic        s_axis_video_tuser_out,
   output logic        s_axis_video_tlast_out,
    ///////////////////////
    // AXI STREAM TIMING //
    ///////////////////////
    input wire         aclk, aclken, aresetn,
    //////////////
    // AXI LITE //
    //////////////
    input wire ENABLE_KEYSTONE,
    input wire SW_RESET,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H11,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H12,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H13,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H21,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H22,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H23,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H31,
    input wire [`C_S_AXI_DATA_WIDTH-1 : 0] H32
    );

    Keystone_Correction ip(.pixel_stream_out(s_axis_video_tdata_out),
                           .valid_out(s_axis_video_tvalid_out), 
                           .ready_out(s_axis_video_tready_out),
                           .start_of_frame_out(s_axis_video_tuser_out), 
                           .end_of_line_out(s_axis_video_tlast_out),
                           .pixel_stream_in(s_axis_video_tdata_in),
                           .valid_in(s_axis_video_tvalid_in), 
                           .ready_in(s_axis_video_tready_in),
                           .start_of_frame_in(s_axis_video_tuser_in),
                           .end_of_line_in(s_axis_video_tlast_in),
                           .clock(aclk),
                           .clock_en(aclken & ENABLE_KEYSTONE),
                           .reset(~aresetn | SW_RESET),
                           .H11(H11), .H12(H12), .H13(H13),
                           .H21(H21), .H22(H22), .H23(H23),
                           .H31(H31), .H32(H32));

endmodule: Keystone