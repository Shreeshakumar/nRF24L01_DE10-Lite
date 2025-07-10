module spi_clock_divider (
    input wire clk_50,
    input wire rst,
    output reg [2:0] counter_p,
    output reg [2:0] counter_n,
    output clk_10
    //output reg p,
    //output reg n
);
   // reg [31:0] counter_p;
    //reg [31:0] counter_n;

    //rst <= 1;
    always @(posedge clk_50) begin
        if (rst) begin
            counter_p <= -1;
            //clk_10 <= 0;
          //  p <= 0;
        end else begin
            if (counter_p == (4)) begin
                //clk_10 <= ~clk_10;
                counter_p <= 0;
            end else begin
                counter_p <= counter_p + 1;
            end
        end
    end

    always @(negedge clk_50) begin
        if (rst) begin
            counter_n <= 0;
           // n <= 0;
        end else begin
            if (counter_n == (4)) begin
               // clk_10 <= ~clk_10;
                counter_n <= 0;
            end else begin
                if (counter_p == 0) begin 
                    counter_n <= 0; end
                else begin
                counter_n <= counter_n + 1;
            end end
        end
    end

    assign clk_10 = ((counter_p == (4)) |(counter_p == (3)) | (counter_n == (2)));
endmodule
