module Simple_Filter (
    //////////////////////////
    // AXI STREAM BEFORE IP //
    //////////////////////////
    input wire  [23:0] s_axis_video_tdata_in,
    input wire         s_axis_video_tvalid_in,
    input wire         m_axis_video_tready_in,
    input wire         s_axis_video_tuser_in,
    input wire         s_axis_video_tlast_in,
    /////////////////////////
    // AXI STREAM AFTER IP //
    /////////////////////////
   output wire [23:0] m_axis_video_tdata_out,
   output wire        m_axis_video_tvalid_out,
   output wire        s_axis_video_tready_out,
   output wire        m_axis_video_tuser_out,
   output wire        m_axis_video_tlast_out,
    ///////////////////////
    // AXI STREAM TIMING //
    ///////////////////////
    input wire         aclk, aclken, aresetn,
    ////////////
    // BYPASS //
    ////////////
    input wire bypass
    );

    logic [23:0] color_val;
    int count;

    always_comb begin
        color_val = '0;
        color_val[7:0] = 8'hFF;
        color_val[15:8] = 8'hFF;
    end

    assign m_axis_video_tdata_out  = (count[5] & ~bypass) ? color_val : s_axis_video_tdata_in;
    assign m_axis_video_tvalid_out = s_axis_video_tvalid_in;
    assign s_axis_video_tready_out = m_axis_video_tready_in;
    assign m_axis_video_tuser_out  = s_axis_video_tuser_in;
    assign m_axis_video_tlast_out  = s_axis_video_tlast_in;

    always_ff @(posedge aclk) begin
        if(~aresetn | s_axis_video_tlast_in) begin
            count <= 0;
        end else if(s_axis_video_tvalid_in & m_axis_video_tready_in & aclken) begin
            count <= count + 1;
        end
    end

endmodule: Simple_Filter