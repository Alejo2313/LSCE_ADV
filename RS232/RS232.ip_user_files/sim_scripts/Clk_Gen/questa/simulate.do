onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib Clk_Gen_opt

do {wave.do}

view wave
view structure
view signals

do {Clk_Gen.udo}

run -all

quit -force
