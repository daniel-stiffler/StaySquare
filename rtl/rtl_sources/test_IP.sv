module Simple_Filter
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
    input wire         aclk, aclken, aresetn);

    logic [63:0] color_val;
    int count;

    always_comb begin
        color_val = '0;
        color_val[9:2] = 8'hFF;
        color_val[19:12] = 8'hFF;
    end

    assign s_axis_video_tdata_out  = (count[4]) ? color_val : s_axis_video_tdata_in;
    assign s_axis_video_tvalid_out = s_axis_video_tvalid_in;
    assign s_axis_video_tready_out = s_axis_video_tready_in;
    assign s_axis_video_tuser_out  = s_axis_video_tuser_in;
    assign s_axis_video_tlast_out  = s_axis_video_tlast_in;

    always_ff @(posedge aclk) begin
        if(~aresetn | s_axis_video_tlast_in) begin
            count <= 0;
        end else if(s_axis_video_tvalid_in & s_axis_video_tready_in & aclken) begin
            count <= count + 1;
        end
    end

endmodule: Simple_Filter