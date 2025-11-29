# Simulation target
sim: compile
	vvp top_tb

# Compile all Verilog files
compile:
	iverilog -g2012 -o top_tb top_tb.sv top.sv memory.sv alu.sv register_file.sv imm_gen.sv

# Clean build artifacts (Windows compatible)
clean:
	-del top_tb.exe 2>nul
	-del *.vcd 2>nul
	-del *.fst 2>nul

# Run simulation and display results
run: sim
	@echo === Simulation Complete ===

.PHONY: sim compile clean run