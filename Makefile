# Simulation target
sim: compile
	vvp top_tb

# Compile all Verilog files
compile:
	iverilog -g2012 -o top_tb top_tb.sv top.sv memory.sv alu.sv register_file.sv imm_gen.sv multiplier.sv

# Clean build artifacts (Windows compatible)
clean:
#	@rm -f top_tb.exe top_tb *.vcd *.fst
	del /Q top_tb.exe top_tb *.vcd *.fst 2>nul

# Run simulation and display results
run: sim
	@echo === Simulation Complete ===

wave: sim
	gtkwave top_tb.vcd top_tb.gtkw &

# Run simulation and display with custom visual style
wave-styled: sim
	gtkwave top_tb.vcd visual_style.gtkw &

.PHONY: sim compile clean run wave wave-styled