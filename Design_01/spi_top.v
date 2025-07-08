module spi_top (
    input wire clk_in,             // System clock
    input wire key0_rst,
    input wire sw_tx_9,
    input wire sw_rx_8,
    input wire [7:0]sw_data,
  
    output wire csn_tx,
    output wire scl_tx,
    output wire ce_tx,
    output wire mosi_tx,
    output wire miso_tx,    
    output wire csn_tx,
    output wire scl_tx,
    output wire ce_tx,
    output wire mosi_tx,
    output wire miso_tx,
  
    output reg ledr_tx,
    output reg ledr_rx,
    output reg [7:0]ledr_rx_data
);

    reg start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire spi_done;

    spi_clock_divider spi_clock_divider (
        .clk_50(clk_50),
        .rst(rst),

        .clk_10(clk_10)
    );

    spi_controller spi_controller (
        .clk_10(clk_10),
        .rst(rst),
        .done_tx(done_tx),
        .done_rx(done_rx),
        .data_out(data_out),

        .start_tx(start_tx),
        .start_rx(start_rx),
        .data_in(data_in),
        .csn_tx(csn_tx),
        .csn_rx(csn_rx)
    );

    reg [1:0] state;
    localparam IDLE = 2'b00,
               START = 2'b01,
               WAIT = 2'b10,
               DONE = 2'b11;

    reg [7:0] rx_buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            start <= 0;
            tx_data <= 8'h00;
            rx_buffer <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    if (trigger) begin
                        tx_data <= 8'hFF;  // NOP command to read STATUS
                        start <= 1;
                        state <= START;
                    end
                end

                START: begin
                    start <= 0;
                    state <= WAIT;
                end

                WAIT: begin
                    if (spi_done) begin
                        rx_buffer <= rx_data;
                        state <= DONE;
                    end
                end

                DONE: begin
                    // Optional: Do something with rx_buffer
                    state <= IDLE;
                end
            endcase
        end
    end

    assign received_data = rx_buffer;
    assign done = (state == DONE);

endmodule
