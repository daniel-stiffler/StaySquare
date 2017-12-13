module Keystone
    //////////////////////////
    // AXI STREAM BEFORE IP //
    //////////////////////////
   (input wire  [23:0] s_axis_video_tdata_in,
    input wire         s_axis_video_tvalid_in,
   output logic        s_axis_video_tready_out,
    input wire         s_axis_video_tuser_in,
    input wire         s_axis_video_tlast_in,
    /////////////////////////
    // AXI STREAM AFTER IP //
    /////////////////////////
   output logic [23:0] m_axis_video_tdata_out,
   output logic        m_axis_video_tvalid_out,
    input wire         m_axis_video_tready_in,
   output logic        m_axis_video_tuser_out,
   output logic        m_axis_video_tlast_out,
    ///////////////////////
    // AXI STREAM TIMING //
    ///////////////////////
    input wire         aclk, aclken, aresetn);

    logic [63:0] data_in, data_out;

    always_comb begin
        data_in = '0;    
        data_in[29:22] = s_axis_video_tdata_in[23:16];
        data_in[19:12] = s_axis_video_tdata_in[15:8];
        data_in[ 9: 2] = s_axis_video_tdata_in[7:0];
    end

    assign m_axis_video_tdata_out = {data_out[29:22],
                                     data_out[19:12],
                                     data_out[ 9: 2]};

    Keystone_Correction ip(.pixel_stream_out(data_out),
                           .valid_out(m_axis_video_tvalid_out), 
                           .ready_out(s_axis_video_tready_out),
                           .start_of_frame_out(m_axis_video_tuser_out), 
                           .end_of_line_out(m_axis_video_tlast_out),
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
