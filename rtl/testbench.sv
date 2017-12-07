`define C_S_AXI_DATA_WIDTH 32

module top;

    logic [63:0] s_axis_video_tdata_in;
    logic        s_axis_video_tvalid_in;
    wire         s_axis_video_tready_out;
    logic        s_axis_video_tuser_in;
    logic        s_axis_video_tlast_in;
    wire  [63:0] s_axis_video_tdata_out; 
    logic [63:0] last_data;
    wire         s_axis_video_tvalid_out;
    logic        s_axis_video_tready_in;
    wire         s_axis_video_tuser_out;
    wire         s_axis_video_tlast_out;
    logic        aclk, aclken, aresetn;
    logic ENABLE_KEYSTONE;
    logic SW_RESET;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H11;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H12;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H13;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H21;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H22;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H23;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H31;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H32;

Keystone dut(.s_axis_video_tdata_in(s_axis_video_tdata_in),
             .s_axis_video_tvalid_in(s_axis_video_tvalid_in),
             .s_axis_video_tready_out(s_axis_video_tready_out),
             .s_axis_video_tuser_in(s_axis_video_tuser_in),
             .s_axis_video_tlast_in(s_axis_video_tlast_in),
             .s_axis_video_tdata_out(s_axis_video_tdata_out),
             .s_axis_video_tvalid_out(s_axis_video_tvalid_out),
             .s_axis_video_tready_in(s_axis_video_tready_in),
             .s_axis_video_tuser_out(s_axis_video_tuser_out),
             .s_axis_video_tlast_out(s_axis_video_tlast_out),
             .aclk(aclk), 
             .aclken(aclken), 
             .aresetn(aresetn),
             .ENABLE_KEYSTONE(ENABLE_KEYSTONE),
             .SW_RESET(SW_RESET),
             .H11(H11),
             .H12(H12),
             .H13(H13),
             .H21(H21),
             .H22(H22),
             .H23(H23),
             .H31(H31),
             .H32(H32));

    
    logic [7:0] r,g,b;
        
    int i;
    int pixels, pixels_out;
    logic correct, correct_reg;
    
    always_ff @(posedge aclk) begin
        if(~aresetn) correct_reg <= '0;
        else if(s_axis_video_tvalid_out) correct_reg <= correct;
    end
    
    /*
    assert property ( @(posedge aclk)
        s_axis_video_tvalid_out |-> 
        ( (s_axis_video_tdata_out[9:2] == last_data[9:2] + 1) &&
          (s_axis_video_tdata_out[19:12] == last_data[19:12] - 2) && 
          (s_axis_video_tdata_out[29:22] == last_data[29:22] - 1)) );
    */
    
    always_comb begin
    correct = 1'b1;
        if(s_axis_video_tvalid_out == 1'b1) begin
         
            if(s_axis_video_tdata_out != source[pixels_out])
                correct = 1'b0;
  
            $strobe("in: %x out: %x",s_axis_video_tdata_out,source[pixels_out]);
            
            
            if(~correct_reg) $strobe("DATA OUT NOT CORRECT >:(");
        end
        
    end
    
    logic [7:0] r_source[0:2073599];
    logic [7:0] g_source[0:2073599];
    logic [7:0] b_source[0:2073599];
    logic [7:0] r_answer[0:2073599];
    logic [7:0] g_answer[0:2073599];
    logic [7:0] b_answer[0:2073599];
    logic [63:0] source[0:2073599];
    logic [63:0] answer[0:2073599];
    
    int m;
    always_comb begin
        for(m = 0; m < 2073600; m = m + 1) begin
        
            source[m][63: 0] = '0;
            source[m][ 9: 2] = g_source[m]; 
            source[m][19:12] = b_source[m]; 
            source[m][29:22] = r_source[m]; 
            
            answer[m][63: 0] = '0;
            answer[m][ 9: 2] = g_answer[m]; 
            answer[m][19:12] = b_answer[m]; 
            answer[m][29:22] = r_answer[m]; 
            
        end
    end

    initial begin
        $readmemh("r_source.hex", r_source);
        $readmemh("g_source.hex", g_source);
        $readmemh("b_source.hex", b_source);
        $readmemh("r_source.hex", r_answer);
        $readmemh("g_source.hex", g_answer);
        $readmemh("b_source.hex", b_answer);
        aclk = 1'b0;
        aclken = 1'b1;
        aresetn = 1'b1;
        SW_RESET = 1'b0;
        ENABLE_KEYSTONE = 1'b1;
        pixels = 0;
        
        H11 = 32'h0100_0000;
        H22 = 32'h0100_0000;

        H12 = 32'h0;
        H13 = 32'h0;
        H21 = 32'h0;
        H23 = 32'h0;
        H31 = 32'h0;
        H32 = 32'h0;

        forever #5 aclk = ~aclk;
    end

    always_comb begin
        s_axis_video_tdata_in = '0;
        s_axis_video_tdata_in[9:2]   = g_source[pixels-1];
        s_axis_video_tdata_in[19:12] = b_source[pixels-1];
        s_axis_video_tdata_in[29:22] = r_source[pixels-1];
    end
    
    always_ff @(posedge aclk) begin
        if(~aresetn) pixels_out <= 0;
        else if(s_axis_video_tvalid_out) pixels_out <= pixels_out + 1;
    end
    
    initial begin

    	/*$monitor("data_in: %x, valid_in: %b, ready_out: %b, SOF_in: %b, EOL_in: %b\n",
    		 s_axis_video_tdata_in,s_axis_video_tvalid_in,s_axis_video_tready_out,s_axis_video_tuser_in,s_axis_video_tlast_in,
    		     "data_out: %x, valid_out: %b, ready_in: %b, SOF_out: %b, EOL_out: %b\n",
    		 s_axis_video_tdata_out,s_axis_video_tvalid_out,s_axis_video_tready_in,s_axis_video_tuser_out,s_axis_video_tlast_out,
    		     "current_x_calc: %d, current_y_calc: %d, current_x_input: %d, current_y_input: %d\n",
    		 dut.ip.current_x_calc, dut.ip.current_y_calc, dut.ip.current_x_input, dut.ip.current_y_input,
    		     "read_done: %b, r_in: %x, b_in: %x, g_in: %x, write_value: %x\n",
    		 dut.ip.read_done, dut.ip.r_in, dut.ip.b_in, dut.ip.g_in, dut.ip.c0.write_value,
    		     "pass_count_reported: %d, pass_count_read: %d\n",
    		 dut.ip.c0.pass_count_reported, dut.ip.c0.pass_count_read,
    		     "x_write: %d, y_write: %d, x_read: %d, y_read: %d\n",
    		 dut.ip.c0.x_write, dut.ip.c0.y_write, dut.ip.c0.x_read, dut.ip.c0.y_read);*//*,
    		     "xw: %x, yw: %x, w: %x\n",
    		 dut.ip.d0.xw, dut.ip.d0.yw, dut.ip.d0.w,
    		     "ax: %x, dx: %x, gx: %x, by: %x, ey: %x, hy: %x\n",
    		 dut.ip.d0.ax, dut.ip.d0.dx, dut.ip.d0.gx, dut.ip.d0.by, dut.ip.d0.ey, dut.ip.d0.hy,
    		     "x: %x, y: %x\n",
    		 dut.ip.d0.x, dut.ip.d0.y,
    		     "mult_clock: %b, mult_enable: %b, mult_A: %x, mult_B: %x, mult_P: %x\n",
    		 dut.ip.d0.m0.clock, dut.ip.d0.m0.enable, dut.ip.d0.m0.A, dut.ip.d0.m0.B, dut.ip.d0.m0.P,
    		     "x_norm: %x, y_norm: %x, x_round: %x, y_round: %x\n",
    		 dut.ip.d0.x_norm, dut.ip.d0.y_norm, dut.ip.d0.x_round, dut.ip.d0.y_round,
    		     "in_pointer: %d, out_pointer: %d\n",
    		 dut.ip.d0.dh0.in_pointer, dut.ip.d0.dh0.out_pointer,
    		     "valid: %b, valid: %b\n",
    		 dut.ip.d0.dest_pixel_from_mults.valid, dut.ip.d0.dh0.dest_pixel_in.valid,
    		     "request_calculation: %b, controller_curr_state: %s\n",
    		 dut.ip.request_calculation, dut.ip.controller_curr_state.name,
    		     "datapath_ready: %b, last_request: %b, ns: %b\n",
    		 dut.ip.datapath_ready, dut.ip.last_request, dut.ip.controller_curr_state,
    		     "fractional: %x, div_res: %x, rounded_div_res: %x, dropped: %x, upper: %x, result:%x\n",
    		 dut.ip.d0.r0.fractional_remainder, dut.ip.d0.r0.div_res, dut.ip.d0.r0.rounded_div_res, dut.ip.d0.r0.dropped, dut.ip.d0.r0.upper, dut.ip.d0.r0.result,
    		     "a_valid[10]: %x, a_ready[10]: %x, a_data[10]: %x, b_valid[10]: %x, b_ready[10]: %x, b_data[10]: %x\n",
    		 dut.ip.d0.dh0.d0.a_valid[10], dut.ip.d0.dh0.d0.a_ready[10], dut.ip.d0.dh0.d0.a_data[10], dut.ip.d0.dh0.d0.b_valid[10], dut.ip.d0.dh0.d0.b_ready[10], dut.ip.d0.dh0.d0.b_data[10],
    		     "out_valid[10]: %x, out_data[10]: %x\n",
    		 dut.ip.d0.dh0.d0.out_valid[10], dut.ip.d0.dh0.d0.out_data[10],
    		     "ready_in: %b\n",
    		 dut.ip.d0.dh0.ready_in);*/

        @(posedge aclk);
        @(posedge aclk);
        @(posedge aclk);
        aresetn <= 1'b0;
        @(posedge aclk);
        @(posedge aclk);
        @(posedge aclk);
        aresetn <= 1'b1;
        @(posedge aclk);
        @(posedge aclk);
        @(posedge aclk);
        @(posedge aclk);

        s_axis_video_tvalid_in <= 1'b1;
        s_axis_video_tuser_in  <= 1'b1;
        s_axis_video_tlast_in  <= 1'b0;
        s_axis_video_tready_in <= 1'b1;
        pixels <= pixels + 1;

        @(posedge aclk);

        s_axis_video_tuser_in <= 1'b0;
        
        for(i = 0; i < 50; i = i + 1) begin
            r <= r - 1;
            g <= g + 1;
            b <= b - 2;
            s_axis_video_tlast_in <= ( (pixels+1) % 1920 == 0);
            pixels <= pixels + 1;
            #10;
        end
        
        s_axis_video_tvalid_in <= 1'b0;
        
        for(i = 0; i < 50; i = i + 1) begin
            r <= r - 1;
            g <= g + 1;
            b <= b - 2;
            s_axis_video_tlast_in <= ( (pixels+1) % 1920 == 0);
            pixels <= pixels + 1;
            #10;
        end
        
        s_axis_video_tvalid_in <= 1'b1;
        
        for(i = 0; i < 50; i = i + 1) begin
                    r <= r - 1;
                    g <= g + 1;
                    b <= b - 2;
                    s_axis_video_tlast_in <= ( (pixels+1) % 1920 == 0);
                    pixels <= pixels + 1;
                    #10;
                end
                
        s_axis_video_tready_in <= 1'b0;
        
        for(i = 0; i < 50; i = i + 1) begin
                    r <= r - 1;
                    g <= g + 1;
                    b <= b - 2;
                    s_axis_video_tlast_in <= ( (pixels+1) % 1920 == 0);
                    pixels <= pixels + 1;
                    #10;
                end
                
        s_axis_video_tready_in <= 1'b1;
        
        for(i = 0; i < 2073700; i = i + 1) begin
            r <= r - 1;
            g <= g + 1;
            b <= b - 2;
            s_axis_video_tlast_in <= ( (pixels+1) % 1920 == 0);
            pixels <= pixels + 1;
            #10;
        end

        $finish;
    end

endmodule: top