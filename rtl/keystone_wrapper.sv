module Keystone
    //////////////////////////
    // AXI STREAM BEFORE IP //
    //////////////////////////
   (input logic [63:0] s_axis_video_tdata_in,
    input logic        s_axis_video_tvalid_in,
   output logic        s_axis_video_tready_out,
    input logic        s_axis_video_tuser_in,
    input logic        s_axis_video_tlast_in,
    /////////////////////////
    // AXI STREAM AFTER IP //
    /////////////////////////
   output logic [63:0] s_axis_video_tdata_out,
   output logic        s_axis_video_tvalid_out,
    input logic        s_axis_video_tready_in,
   output logic        s_axis_video_tuser_out,
   output logic        s_axis_video_tlast_out,
    ///////////////////////
    // AXI STREAM TIMING //
    ///////////////////////
    input logic         aclk, aclken, aresetn,
    //////////////
    // AXI LITE //
    //////////////
    input logic [TODO1:0] AXI4_Lite
    );

    logic sw_en, sw_rst;

    assign sw_en = AXI4_Lite[TODO2];
    assign sw_rst = AXI4_Lite[TODO3];

    Keystone_Correction ip(.pixel_stream_out(s_axis_video_tdata_out),
                           .valid_out(s_axis_video_tvalid_out), 
                           .ready_out(s_axis_video_tready_out),
                           .start_of_frame_out(s_axis_video_tuser_out), 
                           .end_of_line_out(s_axis_video_tlast_out),
                           .status_and_debug(), // TODO NOTE: get this hooked up
                           .pixel_stream_in(s_axis_video_tdata_in),
                           .valid_in(s_axis_video_tvalid_in), 
                           .ready_in(s_axis_video_tready_in),
                           .start_of_frame_in(s_axis_video_tuser_in),
                           .end_of_line_in(s_axis_video_tlast_in),
                           .clock(aclk),
                           .clock_en(aclken & sw_en),
                           .reset(~aresetn | sw_rst),
                           .m_map_registers(AXI4_Lite[TODO4]));

endmodule: Keystone