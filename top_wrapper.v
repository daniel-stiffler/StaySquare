`default_nettype none
`timescale 1 ps / 1 ps

module top
   (HDMI_RX_CLK,          // TODO : Which clock? SCLK, MCLK, LRCLK?
    FMC1_HPC_LA22_N,
    FMC1_HPC_LA23_N,
    FMC1_HPC_LA19_N,
    FMC1_HPC_LA25_N,
    HDMI_RX_P,            // TODO: Expand to 24 and connect
    FMC1_HPC_LA23_P,
    FMC1_HPC_LA22_P,
    hdmi_out_clk,
    hdmi_data_e,
    hdmi_hsync,
    HDMI_INT,
    HDMI_TX_P,            // TODO: Expand to 24 and connect
    hdmi_vsync,

    // TODO: All these below:
    ddr3_sdram_addr,         	
    ddr3_sdram_ba,         	
    ddr3_sdram_cas_n,         	
    ddr3_sdram_ck_n,         	
    ddr3_sdram_ck_p,         	
    ddr3_sdram_cke,         	
    ddr3_sdram_cs_n,         	
    ddr3_sdram_dm,         	
    ddr3_sdram_dq,         	
    ddr3_sdram_dqs_n,         	
    ddr3_sdram_dqs_p,         	
    ddr3_sdram_odt,         	
    ddr3_sdram_ras_n,         	
    ddr3_sdram_reset_n,         	
    ddr3_sdram_we_n,         	
    iic_scl_io,         	
    iic_sda_io,         	
    reset,         	
    sys_diff_clock_clk_n,         	
    sys_diff_clock_clk_p);

  input  wire HDMI_RX_CLK;
  input  wire FMC1_HPC_LA22_N;
  input  wire FMC1_HPC_LA23_N;
  input  wire FMC1_HPC_LA19_N;
  input  wire FMC1_HPC_LA25_N;
  input  wire [23:0] HDMI_RX_P;
  output wire [0:0] FMC1_HPC_LA23_P;
  input  wire FMC1_HPC_LA22_P;
  output wire hdmi_out_clk;
  output wire hdmi_data_e;
  output wire hdmi_hsync;
  input  wire HDMI_INT;
  output wire [23:0] HDMI_TX_P;
  output wire hdmi_vsync;
  output wire [13:0] ddr3_sdram_addr;
  output wire [2:0] ddr3_sdram_ba;
  output wire ddr3_sdram_cas_n;
  output wire [0:0] ddr3_sdram_ck_n;
  output wire [0:0] ddr3_sdram_ck_p;
  output wire [0:0] ddr3_sdram_cke;
  output wire [0:0] ddr3_sdram_cs_n;
  output wire [7:0] ddr3_sdram_dm;
  inout  wire [63:0] ddr3_sdram_dq;
  inout  wire [7:0] ddr3_sdram_dqs_n;
  inout  wire [7:0] ddr3_sdram_dqs_p;
  output wire [0:0] ddr3_sdram_odt;
  output wire ddr3_sdram_ras_n;
  output wire ddr3_sdram_reset_n;
  output wire ddr3_sdram_we_n;
  inout  wire iic_scl_io;
  inout  wire iic_sda_io;
  input  wire reset;
  input  wire sys_diff_clock_clk_n;
  input  wire sys_diff_clock_clk_p;

  hdmi_passthrough_wrapper design(.HDMI_RX_CLK(HDMI_RX_CLK),
                                  .HDMI_RX_DE(FMC1_HPC_LA22_N),
                                  .HDMI_RX_HP(FMC1_HPC_LA23_N),
                                  .HDMI_RX_HSYNC(FMC1_HPC_LA19_N),
                                  .HDMI_RX_INT1(FMC1_HPC_LA25_N),
                                  .HDMI_RX_P(HDMI_RX_P),
                                  .HDMI_RX_RESETN(FMC1_HPC_LA23_P),
                                  .HDMI_RX_VSYNC(FMC1_HPC_LA22_P),
                                  .HDMI_TX_CLK(hdmi_out_clk),
                                  .HDMI_TX_DE(hdmi_data_e),
                                  .HDMI_TX_HSYNC(hdmi_hsync),
                                  .HDMI_TX_INT(HDMI_INT),
                                  .HDMI_TX_P(HDMI_TX_P),
                                  .HDMI_TX_VSYNC(hdmi_vsync),
                                  .ddr3_sdram_addr(ddr3_sdram_addr),
                                  .ddr3_sdram_ba(ddr3_sdram_ba),
                                  .ddr3_sdram_cas_n(ddr3_sdram_cas_n),
                                  .ddr3_sdram_ck_n(ddr3_sdram_ck_n),
                                  .ddr3_sdram_ck_p(ddr3_sdram_ck_p),
                                  .ddr3_sdram_cke(ddr3_sdram_cke),
                                  .ddr3_sdram_cs_n(ddr3_sdram_cs_n),
                                  .ddr3_sdram_dm(ddr3_sdram_dm),
                                  .ddr3_sdram_dq(ddr3_sdram_dq),
                                  .ddr3_sdram_dqs_n(ddr3_sdram_dqs_n),
                                  .ddr3_sdram_dqs_p(ddr3_sdram_dqs_p),
                                  .ddr3_sdram_odt(ddr3_sdram_odt),
                                  .ddr3_sdram_ras_n(ddr3_sdram_ras_n),
                                  .ddr3_sdram_reset_n(ddr3_sdram_reset_n),
                                  .ddr3_sdram_we_n(ddr3_sdram_we_n),
                                  .iic_scl_io(iic_scl_io),
                                  .iic_sda_io(iic_sda_io),
                                  .reset(reset),
                                  .sys_diff_clock_clk_n(sys_diff_clock_clk_n),
                                  .sys_diff_clock_clk_p(sys_diff_clock_clk_p));

endmodule // top
