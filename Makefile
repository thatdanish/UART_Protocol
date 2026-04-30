# SV files 

BAUD_GEN_SV = $(shell pwd)/src/uart_baud_gen.sv
BAUD_GEN_TB = $(shell pwd)/tb/uart_baud_gen_tb.sv
VVP_BAUD =  $(shell pwd)/temp/uart_baud_gen.vvp
VCD_BAUD =  $(shell pwd)/temp/uart_baud_gen.vcd

TX_SV = $(shell pwd)/src/uart_tx.sv
TX_TB = $(shell pwd)/tb/uart_tx_tb.sv
VVP_TX =  $(shell pwd)/temp/uart_tx.vvp
VCD_TX =  $(shell pwd)/temp/uart_tx.vcd

RX_SV = $(shell pwd)/src/uart_rx.sv
RX_TB = $(shell pwd)/tb/uart_rx_tb.sv
VVP_RX =  $(shell pwd)/temp/uart_rx.vvp
VCD_RX =  $(shell pwd)/temp/uart_rx.vcd

TOP_SV = $(shell pwd)/src/uart_top.sv
TOP_TB = $(shell pwd)/tb/uart_top_tb.sv
VVP_TOP =  $(shell pwd)/temp/uart_top.vvp
VCD_TOP =  $(shell pwd)/temp/uart_top.vcd

# Compilation

COMPILER = iverilog
COMPILER_FLAG1 = -o
COMPILER_FLAG2 = -g2012

# Simulation 

SIMULATION = vvp

# Wave

WAVE = gtkwave

# Target : Baud Rate generator

baud_rate: compile_baud_rate
	$(SIMULATION) $(VVP_BAUD)

compile_baud_rate:
	mkdir -p temp
	$(COMPILER) $(COMPILER_FLAG2) $(COMPILER_FLAG1) $(VVP_BAUD) $(BAUD_GEN_TB) $(BAUD_GEN_SV)

wave_baud_rate:
	$(WAVE) $(VCD_BAUD)

clean_baud_rate:
	rm -rf $(VVP_BAUD)
	rm -rf $(VCD_BAUD)

# Target : Tx

tx: compile_tx
	$(SIMULATION) $(VVP_TX)

compile_tx:
	mkdir -p temp
	$(COMPILER) $(COMPILER_FLAG2) $(COMPILER_FLAG1) $(VVP_TX) $(TX_TB) $(TX_SV)

wave_tx:
	$(WAVE) $(VCD_TX)

clean_tx:
	rm -rf $(VVP_TX)
	rm -rf $(VCD_TX)

# Target : Rx

rx: compile_rx
	$(SIMULATION) $(VVP_RX)

compile_rx:
	mkdir -p temp
	$(COMPILER) $(COMPILER_FLAG2) $(COMPILER_FLAG1) $(VVP_RX) $(RX_TB) $(RX_SV)

wave_rx:
	$(WAVE) $(VCD_RX)

clean_rx:
	rm -rf $(VVP_RX)
	rm -rf $(VCD_RX)