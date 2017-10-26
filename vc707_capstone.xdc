############################################
## Constraints for VC707 Capstone Project ##
############################################

############
## Clocks ##
############

# Uh, do we need clocks constraints?

################
## Clock Pins ##
################

set_property -dict {PACKAGE_PIN AU34 IOSTANDARD LVCMOS18} [get_ports SI5324_INT_ALM_LS]

set_property -dict {PACKAGE_PIN AT36 IOSTANDARD LVCMOS18} [get_ports SI5324_RST_LS]

set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVDS} [get_ports SYSCLK_P]

set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVDS} [get_ports SYSCLK_N]

set_property -dict {PACKAGE_PIN AW32 IOSTANDARD LVCMOS18} [get_ports REC_CLOCK_C_P]

set_property -dict {PACKAGE_PIN AW33 IOSTANDARD LVCMOS18} [get_ports REC_CLOCK_C_N]

set_property PACKAGE_PIN AD8 [get_ports SI5324_OUT_C_P]
set_property PACKAGE_PIN AD7 [get_ports SI5324_OUT_C_N]

###############
## HDMI Pins ##
###############

# HDMI_INT
set_property -dict  {PACKAGE_PIN  AM24  IOSTANDARD  LVCMOS18} [get_ports HDMI_INT]

# HDMI_R_CLK
set_property -dict  {PACKAGE_PIN  AU23  IOSTANDARD  LVCMOS18} [get_ports hdmi_out_clk]

# HDMI_R_HSYNC
set_property -dict  {PACKAGE_PIN  AU22  IOSTANDARD  LVCMOS18} [get_ports hdmi_hsync]

# HDMI_R_VSYNC
set_property -dict  {PACKAGE_PIN  AT22  IOSTANDARD  LVCMOS18} [get_ports hdmi_vsync]

# HDMI_R_DE
set_property -dict  {PACKAGE_PIN  AP21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data_e]

# HDMI_R_SPDIF
set_property -dict  {PACKAGE_PIN  AR23  IOSTANDARD  LVCMOS18} [get_ports spdif]

# HDMI_SPDIF_OUT_LS
set_property -dict  {PACKAGE_PIN  AR22  IOSTANDARD  LVCMOS18} [get_ports HDMI_SPDIF_OUT_LS]

# HDMI_R_D<31:0>
set_property -dict  {PACKAGE_PIN  AM22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[0]]
set_property -dict  {PACKAGE_PIN  AL22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[1]]
set_property -dict  {PACKAGE_PIN  AJ20  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[2]]
set_property -dict  {PACKAGE_PIN  AJ21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[3]]
set_property -dict  {PACKAGE_PIN  AM21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[4]]
set_property -dict  {PACKAGE_PIN  AL21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[5]]
set_property -dict  {PACKAGE_PIN  AK22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[6]]
set_property -dict  {PACKAGE_PIN  AJ22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[7]]
set_property -dict  {PACKAGE_PIN  AL20  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[8]]
set_property -dict  {PACKAGE_PIN  AK20  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[9]]
set_property -dict  {PACKAGE_PIN  AK23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[10]]
set_property -dict  {PACKAGE_PIN  AJ23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[11]]
set_property -dict  {PACKAGE_PIN  AN21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[12]]
set_property -dict  {PACKAGE_PIN  AP22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[13]]
set_property -dict  {PACKAGE_PIN  AP23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[14]]
set_property -dict  {PACKAGE_PIN  AN23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[15]]
set_property -dict  {PACKAGE_PIN  AM23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[16]]
set_property -dict  {PACKAGE_PIN  AN24  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[17]]
set_property -dict  {PACKAGE_PIN  AY24  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[18]]
set_property -dict  {PACKAGE_PIN  BB22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[19]]
set_property -dict  {PACKAGE_PIN  BA22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[20]]
set_property -dict  {PACKAGE_PIN  BA25  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[21]]
set_property -dict  {PACKAGE_PIN  AY25  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[22]]
set_property -dict  {PACKAGE_PIN  AY22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[23]]
set_property -dict  {PACKAGE_PIN  AY23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[24]]
set_property -dict  {PACKAGE_PIN  AV24  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[25]]
set_property -dict  {PACKAGE_PIN  AU24  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[26]]
set_property -dict  {PACKAGE_PIN  AW21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[27]]
set_property -dict  {PACKAGE_PIN  AV21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[28]]
set_property -dict  {PACKAGE_PIN  AT24  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[29]]
set_property -dict  {PACKAGE_PIN  AR24  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[30]]
set_property -dict  {PACKAGE_PIN  AU21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[31]]
set_property -dict  {PACKAGE_PIN  AT21  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[32]]
set_property -dict  {PACKAGE_PIN  AW22  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[33]]
set_property -dict  {PACKAGE_PIN  AW23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[34]]
set_property -dict  {PACKAGE_PIN  AV23  IOSTANDARD  LVCMOS18} [get_ports hdmi_data[35]]

##############
## FMC Pins ##
##############

# HDMI1_LLC
set_property -dict {PACKAGE_PIN K39 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA00_CC_P]

# HDMI1_P23
set_property -dict {PACKAGE_PIN K40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA00_CC_N]

# HDMI1_P22
set_property -dict {PACKAGE_PIN P41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA02_P]

# HDMI1_P21
set_property -dict {PACKAGE_PIN N41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA02_N]

# HDMI1_P20
set_property -dict {PACKAGE_PIN M42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA03_P]

# HDMI1_P19
set_property -dict {PACKAGE_PIN L42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA03_N]

# HDMI1_P18
set_property -dict {PACKAGE_PIN H40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA04_P]

# HDMI1_P17
set_property -dict {PACKAGE_PIN H41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA04_N]

# HDMI1_P15
set_property -dict {PACKAGE_PIN G41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA07_P]

# HDMI1_P13
set_property -dict {PACKAGE_PIN G42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA07_N]

# HDMI1_P16
set_property -dict {PACKAGE_PIN M37 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA08_P]

# HDMI1_P14
set_property -dict {PACKAGE_PIN M38 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA08_N]

# HDMI1_P10
set_property -dict {PACKAGE_PIN F40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA11_P]

# HDMI1_P8
set_property -dict {PACKAGE_PIN F41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA11_N]

# HDMI1_P12
set_property -dict {PACKAGE_PIN R40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA12_P]

# HDMI1_P11
set_property -dict {PACKAGE_PIN P40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA12_N]

# HDMI1_P9
set_property -dict {PACKAGE_PIN N39 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA14_P]

# HDMI1_P4
set_property -dict {PACKAGE_PIN N40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA14_N]

# HDMI1_P5
set_property -dict {PACKAGE_PIN M36 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA15_P]

# HDMI1_P3
set_property -dict {PACKAGE_PIN L37 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA15_N]

# HDMI1_P7
set_property -dict {PACKAGE_PIN K37 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA16_P]

# HDMI1_P6
set_property -dict {PACKAGE_PIN K38 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA16_N]

# HDMI1_MCLK
set_property -dict {PACKAGE_PIN L31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA17_CC_P]

# HDMI1_SCLK
set_property -dict {PACKAGE_PIN M32 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA18_CC_P]

# HDMI1_P0
set_property -dict {PACKAGE_PIN W30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA19_P]

# HDMI1_HS
set_property -dict {PACKAGE_PIN W31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA19_N]

# HDMI1_P2
set_property -dict {PACKAGE_PIN Y29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA20_P]

# HDMI1_P1
set_property -dict {PACKAGE_PIN Y30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA20_N]

# HDMI1_LRCLK
set_property -dict {PACKAGE_PIN N28 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA21_P]

# HDMI1_SCL
set_property -dict {PACKAGE_PIN N29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA21_N]

# HDMI1_VS
set_property -dict {PACKAGE_PIN R28 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA22_P]

# HDMI1_DE
set_property -dict {PACKAGE_PIN P28 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA22_N]

# HDMI1_RESETN
set_property -dict {PACKAGE_PIN P30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA23_P]

# HDMI1_AP
set_property -dict {PACKAGE_PIN N31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA23_N]

# HDMI1_SDA
set_property -dict {PACKAGE_PIN K29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA25_P]

# HDMI1_INT1
set_property -dict {PACKAGE_PIN K30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA25_N]

#####################
## UNUSED FMC PINS ##
#####################

set_property -dict {PACKAGE_PIN J40 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA01_CC_P]
set_property -dict {PACKAGE_PIN J41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA01_CC_N]
set_property -dict {PACKAGE_PIN M41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA05_P]
set_property -dict {PACKAGE_PIN L41 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA05_N]
set_property -dict {PACKAGE_PIN K42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA06_P]
set_property -dict {PACKAGE_PIN J42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA06_N]
set_property -dict {PACKAGE_PIN R42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA09_P]
set_property -dict {PACKAGE_PIN P42 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA09_N]
set_property -dict {PACKAGE_PIN N38 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA10_P]
set_property -dict {PACKAGE_PIN M39 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA10_N]
set_property -dict {PACKAGE_PIN H39 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA13_P]
set_property -dict {PACKAGE_PIN G39 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA13_N]
set_property -dict {PACKAGE_PIN K32 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA17_CC_N]
set_property -dict {PACKAGE_PIN L32 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA18_CC_N]
set_property -dict {PACKAGE_PIN R30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA24_P]
set_property -dict {PACKAGE_PIN P31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA24_N]
set_property -dict {PACKAGE_PIN J30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA26_P]
set_property -dict {PACKAGE_PIN H30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA26_N]
set_property -dict {PACKAGE_PIN J31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA27_P]
set_property -dict {PACKAGE_PIN H31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA27_N]
set_property -dict {PACKAGE_PIN L29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA28_P]
set_property -dict {PACKAGE_PIN L30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA28_N]
set_property -dict {PACKAGE_PIN T29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA29_P]
set_property -dict {PACKAGE_PIN T30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA29_N]
set_property -dict {PACKAGE_PIN V30 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA30_P]
set_property -dict {PACKAGE_PIN V31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA30_N]
set_property -dict {PACKAGE_PIN M28 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA31_P]
set_property -dict {PACKAGE_PIN M29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA31_N]
set_property -dict {PACKAGE_PIN V29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA32_P]
set_property -dict {PACKAGE_PIN U29 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA32_N]
set_property -dict {PACKAGE_PIN U31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA33_P]
set_property -dict {PACKAGE_PIN T31 IOSTANDARD LVCMOS18} [get_ports FMC1_HPC_LA33_N]

##############
## USB Pins ##
##############

#set_property -dict {PACKAGE_PIN BA35 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_NXT]
#set_property -dict {PACKAGE_PIN BB36 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_RESET_B]
#set_property -dict {PACKAGE_PIN BB32 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_STP]
#set_property -dict {PACKAGE_PIN BB33 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DIR]
#set_property -dict {PACKAGE_PIN AV34 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_REFCLK_OPTION]
#set_property -dict {PACKAGE_PIN AY32 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_CLKOUT]
#set_property -dict {PACKAGE_PIN AV36 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA0]
#set_property -dict {PACKAGE_PIN AW36 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA1]
#set_property -dict {PACKAGE_PIN BA34 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA2]
#set_property -dict {PACKAGE_PIN BB34 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA3]
#set_property -dict {PACKAGE_PIN BA36 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA4]
#set_property -dict {PACKAGE_PIN AT34 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA5]
#set_property -dict {PACKAGE_PIN AY35 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA6]
#set_property -dict {PACKAGE_PIN AW35 IOSTANDARD LVCMOS18} [get_ports USB_SMSC_DATA7]

###############
## DDR3 Pins ##
###############

set_property -dict {PACKAGE_PIN C29 IOSTANDARD LVCMOS15} [get_ports DDR3_RESET_B]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_CLK1_P]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_CLK1_N]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_CLK0_P]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_CLK0_N]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD SSTL15} [get_ports DDR3_CKE0]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD SSTL15} [get_ports DDR3_CKE1]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD SSTL15} [get_ports DDR3_WE_B]
set_property -dict {PACKAGE_PIN E20 IOSTANDARD SSTL15} [get_ports DDR3_RAS_B]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD SSTL15} [get_ports DDR3_CAS_B]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD SSTL15} [get_ports DDR3_ODT0]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD SSTL15} [get_ports DDR3_ODT1]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD SSTL15} [get_ports DDR3_TEMP_EVENT]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD SSTL15} [get_ports DDR3_D0]
set_property -dict {PACKAGE_PIN N13 IOSTANDARD SSTL15} [get_ports DDR3_D1]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD SSTL15} [get_ports DDR3_D2]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD SSTL15} [get_ports DDR3_D3]
set_property -dict {PACKAGE_PIN M12 IOSTANDARD SSTL15} [get_ports DDR3_D4]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD SSTL15} [get_ports DDR3_D5]
set_property -dict {PACKAGE_PIN M11 IOSTANDARD SSTL15} [get_ports DDR3_D6]
set_property -dict {PACKAGE_PIN L12 IOSTANDARD SSTL15} [get_ports DDR3_D7]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD SSTL15} [get_ports DDR3_D8]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD SSTL15} [get_ports DDR3_D9]
set_property -dict {PACKAGE_PIN H13 IOSTANDARD SSTL15} [get_ports DDR3_D10]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD SSTL15} [get_ports DDR3_D11]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD SSTL15} [get_ports DDR3_D12]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD SSTL15} [get_ports DDR3_D13]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD SSTL15} [get_ports DDR3_D14]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD SSTL15} [get_ports DDR3_D15]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD SSTL15} [get_ports DDR3_D16]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD SSTL15} [get_ports DDR3_D17]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD SSTL15} [get_ports DDR3_D18]
set_property -dict {PACKAGE_PIN E14 IOSTANDARD SSTL15} [get_ports DDR3_D19]
set_property -dict {PACKAGE_PIN G13 IOSTANDARD SSTL15} [get_ports DDR3_D20]
set_property -dict {PACKAGE_PIN G12 IOSTANDARD SSTL15} [get_ports DDR3_D21]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD SSTL15} [get_ports DDR3_D22]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD SSTL15} [get_ports DDR3_D23]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD SSTL15} [get_ports DDR3_D24]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD SSTL15} [get_ports DDR3_D25]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD SSTL15} [get_ports DDR3_D26]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD SSTL15} [get_ports DDR3_D27]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD SSTL15} [get_ports DDR3_D28]
set_property -dict {PACKAGE_PIN E12 IOSTANDARD SSTL15} [get_ports DDR3_D29]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD SSTL15} [get_ports DDR3_D30]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD SSTL15} [get_ports DDR3_D31]
set_property -dict {PACKAGE_PIN A24 IOSTANDARD SSTL15} [get_ports DDR3_D32]
set_property -dict {PACKAGE_PIN B23 IOSTANDARD SSTL15} [get_ports DDR3_D33]
set_property -dict {PACKAGE_PIN B27 IOSTANDARD SSTL15} [get_ports DDR3_D34]
set_property -dict {PACKAGE_PIN B26 IOSTANDARD SSTL15} [get_ports DDR3_D35]
set_property -dict {PACKAGE_PIN A22 IOSTANDARD SSTL15} [get_ports DDR3_D36]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD SSTL15} [get_ports DDR3_D37]
set_property -dict {PACKAGE_PIN A25 IOSTANDARD SSTL15} [get_ports DDR3_D38]
set_property -dict {PACKAGE_PIN C24 IOSTANDARD SSTL15} [get_ports DDR3_D39]
set_property -dict {PACKAGE_PIN E24 IOSTANDARD SSTL15} [get_ports DDR3_D40]
set_property -dict {PACKAGE_PIN D23 IOSTANDARD SSTL15} [get_ports DDR3_D41]
set_property -dict {PACKAGE_PIN D26 IOSTANDARD SSTL15} [get_ports DDR3_D42]
set_property -dict {PACKAGE_PIN C25 IOSTANDARD SSTL15} [get_ports DDR3_D43]
set_property -dict {PACKAGE_PIN E23 IOSTANDARD SSTL15} [get_ports DDR3_D44]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD SSTL15} [get_ports DDR3_D45]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD SSTL15} [get_ports DDR3_D46]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD SSTL15} [get_ports DDR3_D47]
set_property -dict {PACKAGE_PIN A30 IOSTANDARD SSTL15} [get_ports DDR3_D48]
set_property -dict {PACKAGE_PIN D27 IOSTANDARD SSTL15} [get_ports DDR3_D49]
set_property -dict {PACKAGE_PIN A29 IOSTANDARD SSTL15} [get_ports DDR3_D50]
set_property -dict {PACKAGE_PIN C28 IOSTANDARD SSTL15} [get_ports DDR3_D51]
set_property -dict {PACKAGE_PIN D28 IOSTANDARD SSTL15} [get_ports DDR3_D52]
set_property -dict {PACKAGE_PIN B31 IOSTANDARD SSTL15} [get_ports DDR3_D53]
set_property -dict {PACKAGE_PIN A31 IOSTANDARD SSTL15} [get_ports DDR3_D54]
set_property -dict {PACKAGE_PIN A32 IOSTANDARD SSTL15} [get_ports DDR3_D55]
set_property -dict {PACKAGE_PIN E30 IOSTANDARD SSTL15} [get_ports DDR3_D56]
set_property -dict {PACKAGE_PIN F29 IOSTANDARD SSTL15} [get_ports DDR3_D57]
set_property -dict {PACKAGE_PIN F30 IOSTANDARD SSTL15} [get_ports DDR3_D58]
set_property -dict {PACKAGE_PIN F27 IOSTANDARD SSTL15} [get_ports DDR3_D59]
set_property -dict {PACKAGE_PIN C30 IOSTANDARD SSTL15} [get_ports DDR3_D60]
set_property -dict {PACKAGE_PIN E29 IOSTANDARD SSTL15} [get_ports DDR3_D61]
set_property -dict {PACKAGE_PIN F26 IOSTANDARD SSTL15} [get_ports DDR3_D62]
set_property -dict {PACKAGE_PIN D30 IOSTANDARD SSTL15} [get_ports DDR3_D63]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD SSTL15} [get_ports DDR3_DQS0_P]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD SSTL15} [get_ports DDR3_DQS0_N]
set_property -dict {PACKAGE_PIN K12 IOSTANDARD SSTL15} [get_ports DDR3_DQS1_P]
set_property -dict {PACKAGE_PIN J12 IOSTANDARD SSTL15} [get_ports DDR3_DQS1_N]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD SSTL15} [get_ports DDR3_DQS2_P]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD SSTL15} [get_ports DDR3_DQS2_N]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD SSTL15} [get_ports DDR3_DQS3_P]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD SSTL15} [get_ports DDR3_DQS3_N]
set_property -dict {PACKAGE_PIN A26 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS4_P]
set_property -dict {PACKAGE_PIN A27 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS4_N]
set_property -dict {PACKAGE_PIN F25 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS5_P]
set_property -dict {PACKAGE_PIN E25 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS5_N]
set_property -dict {PACKAGE_PIN B28 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS6_P]
set_property -dict {PACKAGE_PIN B29 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS6_N]
set_property -dict {PACKAGE_PIN E27 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS7_P]
set_property -dict {PACKAGE_PIN E28 IOSTANDARD DIFF_SSTL15} [get_ports DDR3_DQS7_N]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD SSTL15} [get_ports DDR3_DM0]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD SSTL15} [get_ports DDR3_DM1]
set_property -dict {PACKAGE_PIN F12 IOSTANDARD SSTL15} [get_ports DDR3_DM2]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD SSTL15} [get_ports DDR3_DM3]
set_property -dict {PACKAGE_PIN C23 IOSTANDARD SSTL15} [get_ports DDR3_DM4]
set_property -dict {PACKAGE_PIN D25 IOSTANDARD SSTL15} [get_ports DDR3_DM5]
set_property -dict {PACKAGE_PIN C31 IOSTANDARD SSTL15} [get_ports DDR3_DM6]
set_property -dict {PACKAGE_PIN F31 IOSTANDARD SSTL15} [get_ports DDR3_DM7]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD SSTL15} [get_ports DDR3_A0]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD SSTL15} [get_ports DDR3_A1]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD SSTL15} [get_ports DDR3_A2]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD SSTL15} [get_ports DDR3_A3]
set_property -dict {PACKAGE_PIN A17 IOSTANDARD SSTL15} [get_ports DDR3_A4]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD SSTL15} [get_ports DDR3_A5]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD SSTL15} [get_ports DDR3_A6]
set_property -dict {PACKAGE_PIN C18 IOSTANDARD SSTL15} [get_ports DDR3_A7]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD SSTL15} [get_ports DDR3_A8]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD SSTL15} [get_ports DDR3_A9]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD SSTL15} [get_ports DDR3_A10]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD SSTL15} [get_ports DDR3_A11]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD SSTL15} [get_ports DDR3_A12]
set_property -dict {PACKAGE_PIN A21 IOSTANDARD SSTL15} [get_ports DDR3_A13]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD SSTL15} [get_ports DDR3_A14]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD SSTL15} [get_ports DDR3_A15]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD SSTL15} [get_ports DDR3_BA0]
set_property -dict {PACKAGE_PIN C21 IOSTANDARD SSTL15} [get_ports DDR3_BA1]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD SSTL15} [get_ports DDR3_BA2]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD SSTL15} [get_ports DDR3_S0_B]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD SSTL15} [get_ports DDR3_S1_B]

###############
## XADC Pins ##
###############

#set_property -dict {PACKAGE_PIN AN38 IOSTANDARD LVCMOS18} [get_ports XADC_VAUX0P_R]
#set_property -dict {PACKAGE_PIN AP38 IOSTANDARD LVCMOS18} [get_ports XADC_VAUX0N_R]
#set_property -dict {PACKAGE_PIN AM41 IOSTANDARD LVCMOS18} [get_ports XADC_VAUX8P_R]
#set_property -dict {PACKAGE_PIN AM42 IOSTANDARD LVCMOS18} [get_ports XADC_VAUX8N_R]
#set_property -dict {PACKAGE_PIN BA21 IOSTANDARD LVCMOS18} [get_ports XADC_GPIO_0]
#set_property -dict {PACKAGE_PIN BB21 IOSTANDARD LVCMOS18} [get_ports XADC_GPIO_1]
#set_property -dict {PACKAGE_PIN BB24 IOSTANDARD LVCMOS18} [get_ports XADC_GPIO_2]
#set_property -dict {PACKAGE_PIN BB23 IOSTANDARD LVCMOS18} [get_ports XADC_GPIO_3]