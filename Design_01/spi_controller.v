module spi_controller (
    input wire clk_10,                   //10Mhz from spi_clock_divider to spi_controller
    input wire rst,                      //reset trigger from top M to spi_controller
    input wire [7:0]data_in,             //data to send from top M
    input wire start_tx,                 //enable tx trigger from top M
    input wire start_rx,                 //enable rx trigger from top M

    input wire miso_tx,                   //in pins to nrf tx
    input wire miso_rx,                   //in pins to nrf rx

    output wire csn_tx,                   //out pins to nrf tx
    output wire mosi_tx,                  //out pins to nrf tx
    output wire csn_rx,                   //out pins to nrf rx
    output wire mosi_rx,                  //out pins to nrf rx

    output reg done_tx,                   //done tx trigger to top M
    output reg done_rx,                   //done tx trigger to top M
    output reg [7:0]data_out,             //data receiver to top M
);

    spi_tx spi_tx (
      .clk_10(clk_10),
      .rst(rst),
      .start_tx(start_tx),
      .data_in(data_in),
      .miso_tx(miso_tx),

      .mosi_tx(mosi_tx),
      .csn_tx(csn_tx),
      .done_tx(done_tx)
    );

    spi_rx spi_rx (
      .clk_10(clk_10),
      .rst(rst),
      .start_rx(start_rx),
      .miso_rx(miso_rx),
        
      .mosi_rx(mosi_rx),
      .csn_rx(csn_rx),
      .data_out(data_out),
      .done_rx(done_rx)
    );

endmodule
