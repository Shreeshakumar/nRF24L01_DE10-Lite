`timescale 1ns / 1ps

module spi_clock_divider_tb;

    // Testbench signals
    reg clk_50;
    reg rst;
    wire clk_10;
    wire [2:0] counter_p;
    wire [2:0] counter_n;

    // Instantiate the module under test (MUT)
    spi_clock_divider #(.DIVIDER(5)) uut (
        .clk_50(clk_50),
        .rst(rst),
        .clk_10(clk_10),
        .counter_p(counter_p),
        .counter_n(counter_n)
      //  .p(p),
        //.n(n)
    );

    // Generate 50 MHz clock (period = 20 ns)
    initial begin
        clk_50 = 0;
        forever #10 clk_50 = ~clk_50; // Toggle every 10 ns
    end

    // Stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        #50;       // Hold reset for a few cycles
        rst = 0;

        // Run simulation for some time
        #500;      // Enough to observe a few clk_10 cycles
        $stop;
    end

endmodule
