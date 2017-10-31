`default_nettype none
`timescale 1 ps / 1 ps

module top
   (FMC1_HPC_LA00_CC_P,
    FMC1_HPC_LA22_N,
    FMC1_HPC_LA23_N,
    FMC1_HPC_LA19_N,
    FMC1_HPC_LA25_N,
    FMC1_HPC_LA00_CC_N,
    FMC1_HPC_LA02_P,
    FMC1_HPC_LA02_N,
    FMC1_HPC_LA03_P,
    FMC1_HPC_LA03_N,
    FMC1_HPC_LA04_P,
    FMC1_HPC_LA04_N,
    FMC1_HPC_LA08_P,
    FMC1_HPC_LA07_P,
    FMC1_HPC_LA08_N,
    FMC1_HPC_LA07_N,
    FMC1_HPC_LA12_P,
    FMC1_HPC_LA12_N,
    FMC1_HPC_LA11_P,
    FMC1_HPC_LA14_P,
    FMC1_HPC_LA11_N,
    FMC1_HPC_LA16_P,
    FMC1_HPC_LA16_N,
    FMC1_HPC_LA15_P,
    FMC1_HPC_LA14_N,
    FMC1_HPC_LA15_N,
    FMC1_HPC_LA20_P,
    FMC1_HPC_LA20_N,
    FMC1_HPC_LA19_P,
    FMC1_HPC_LA23_P,
    FMC1_HPC_LA22_P,
    hdmi_out_clk,
    hdmi_data_e,
    hdmi_hsync,
    HDMI_INT,
    hdmi_data,
    hdmi_vsync,
    ddr3_addr,
    ddr3_ba,
    ddr3_cas_n,
    ddr3_ck_n,
    ddr3_ck_p,
    ddr3_cke,
    ddr3_cs_n,
    ddr3_dm,
    ddr3_dq,
    ddr3_dqs_n,
    ddr3_dqs_p,
    ddr3_odt,
    ddr3_ras_n,
    ddr3_reset_n,
    ddr3_we_n,

    iic_scl_io,               // TODO: FIX THESE    
    iic_sda_io,               // TODO: FIX THESE

    CPU_RESET,

    sys_clk_n,
    sys_clk_p);

  input  wire FMC1_HPC_LA00_CC_P;
  input  wire FMC1_HPC_LA22_N;
  input  wire FMC1_HPC_LA23_N;
  input  wire FMC1_HPC_LA19_N;
  input  wire FMC1_HPC_LA25_N;

  input  wire [23:0] HDMI_RX_P;

  input  wire FMC1_HPC_LA00_CC_N;
  input  wire FMC1_HPC_LA02_P;
  input  wire FMC1_HPC_LA02_N;
  input  wire FMC1_HPC_LA03_P;
  input  wire FMC1_HPC_LA03_N;
  input  wire FMC1_HPC_LA04_P;
  input  wire FMC1_HPC_LA04_N;
  input  wire FMC1_HPC_LA08_P;
  input  wire FMC1_HPC_LA07_P;
  input  wire FMC1_HPC_LA08_N;
  input  wire FMC1_HPC_LA07_N;
  input  wire FMC1_HPC_LA12_P;
  input  wire FMC1_HPC_LA12_N;
  input  wire FMC1_HPC_LA11_P;
  input  wire FMC1_HPC_LA14_P;
  input  wire FMC1_HPC_LA11_N;
  input  wire FMC1_HPC_LA16_P;
  input  wire FMC1_HPC_LA16_N;
  input  wire FMC1_HPC_LA15_P;
  input  wire FMC1_HPC_LA14_N;
  input  wire FMC1_HPC_LA15_N;
  input  wire FMC1_HPC_LA20_P;
  input  wire FMC1_HPC_LA20_N;
  input  wire FMC1_HPC_LA19_P;

  output wire [0:0] FMC1_HPC_LA23_P;
  input  wire FMC1_HPC_LA22_P;
  output wire hdmi_out_clk;
  output wire hdmi_data_e;
  output wire hdmi_hsync;
  input  wire HDMI_INT;
  output wire [35:0] hdmi_data;
  output wire hdmi_vsync;

  output wire [13:0] ddr3_addr;
  output wire [2:0] ddr3_ba;
  output wire ddr3_cas_n;
  output wire [0:0] ddr3_ck_n;
  output wire [0:0] ddr3_ck_p;
  output wire [0:0] ddr3_cke;
  output wire [0:0] ddr3_cs_n;
  output wire [7:0] ddr3_dm;
  inout  wire [63:0] ddr3_dq;
  inout  wire [7:0] ddr3_dqs_n;
  inout  wire [7:0] ddr3_dqs_p;
  output wire [0:0] ddr3_odt;
  output wire ddr3_ras_n;
  output wire ddr3_reset_n;
  output wire ddr3_we_n;

  inout  wire iic_scl_io;
  inout  wire iic_sda_io;

  input  wire CPU_RESET;

  input  wire sys_clk_n;
  input  wire sys_clk_p;

  assign HDMI_RX_P = {FMC1_HPC_LA00_CC_N,
                      FMC1_HPC_LA02_P,
                      FMC1_HPC_LA02_N,
                      FMC1_HPC_LA03_P,
                      FMC1_HPC_LA03_N,
                      FMC1_HPC_LA04_P,
                      FMC1_HPC_LA04_N,
                      FMC1_HPC_LA08_P,
                      FMC1_HPC_LA07_P,
                      FMC1_HPC_LA08_N,
                      FMC1_HPC_LA07_N,
                      FMC1_HPC_LA12_P,
                      FMC1_HPC_LA12_N,
                      FMC1_HPC_LA11_P,
                      FMC1_HPC_LA14_P,
                      FMC1_HPC_LA11_N,
                      FMC1_HPC_LA16_P,
                      FMC1_HPC_LA16_N,
                      FMC1_HPC_LA15_P,
                      FMC1_HPC_LA14_N,
                      FMC1_HPC_LA15_N,
                      FMC1_HPC_LA20_P,
                      FMC1_HPC_LA20_N,
                      FMC1_HPC_LA19_P}

  hdmi_tx_rx_wrapper design(.HDMI_CLK(FMC1_HPC_LA00_CC_P),
                            .HDMI_RESET(FMC1_HPC_LA23_P), // RESETN?
                            .HDMI_RX_DE(FMC1_HPC_LA22_N),
                            .HDMI_RX_HPA(FMC1_HPC_LA23_N),
                            .HDMI_RX_HSYNC(FMC1_HPC_LA19_N),
                            .HDMI_RX_P(HDMI_RX_P),
                            .HDMI_RX_VSYNC(FMC1_HPC_LA22_P),
                            .HDMI_TX_CLK(hdmi_out_clk),
                            .HDMI_TX_DE(hdmi_data_e),
                            .HDMI_TX_HSYNC(hdmi_hsync),
                            .HDMI_TX_P(hdmi_data[23:0]),
                            .HDMI_TX_VSYNC(hdmi_vsync),
                            .ddr3_sdram_addr(ddr3_addr),
                            .ddr3_sdram_ba(ddr3_ba),
                            .ddr3_sdram_cas_n(ddr3_cas_n),
                            .ddr3_sdram_ck_n(ddr3_ck_n),
                            .ddr3_sdram_ck_p(ddr3_ck_p),
                            .ddr3_sdram_cke(ddr3_cke),
                            .ddr3_sdram_cs_n(ddr3_sdram_cs_n),
                            .ddr3_sdram_dm(ddr3_dm),
                            .ddr3_sdram_dq(ddr3_dq),
                            .ddr3_sdram_dqs_n(ddr3_dqs_n),
                            .ddr3_sdram_dqs_p(ddr3_dqs_p),
                            .ddr3_sdram_odt(ddr3_odt),
                            .ddr3_sdram_ras_n(ddr3_ras_n),
                            .ddr3_sdram_reset_n(ddr3_reset_n),
                            .ddr3_sdram_we_n(ddr3_we_n),
                            .iic_scl_io(iic_scl_io),
                            .iic_sda_io(iic_sda_io),
                            .reset(CPU_RESET),
                            .sys_diff_clock_clk_n(sys_clk_n),
                            .sys_diff_clock_clk_p(sys_clk_p));

endmodule // top
