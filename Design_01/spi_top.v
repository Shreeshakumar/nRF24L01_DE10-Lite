module spi_top (
    input wire clk_in,                         //internal clock
    input wire key0_rst,                       //to reset everything
    input wire sw_tx_9,                        //enable tx
    input wire sw_rx_8,                        //enable rx
    input wire [7:0]sw_data,                   //data in to transmit
    input wire miso_tx,                        //from nrf tx to de10 board
    input wire miso_rx,                        //from nrf rx to de10 board
  
    output wire csn_tx,                        //from de10 board to nrf tx 
    output wire sck_tx,                        //from de10 board to nrf tx  
    output wire ce_tx,                         //from de10 board to nrf tx
    output wire mosi_tx,                       //from de10 board to nrf tx
    output wire csn_rx,                        //from de10 board to nrf rx
    output wire sck_rx,                        //from de10 board to nrf rx
    output wire ce_rx,                         //from de10 board to nrf rx
    output wire mosi_rx,                       //from de10 board to nrf rx
  
    output reg ledr_tx,                        //indicate tx
    output reg ledr_rx,                        //indicate rx
    output reg [7:0]ledr_rx_data               // to show received data
);

    wire sclk;                                 //10Mhz from spi_clock_divider to spi_controller

    spi_clock_divider spi_clock_divider (
        .clk_50(clk_in),                       //50Mhz from top M to spi_controller
        .rst(key0_rst),                        //reset trigger from top M to spi_clock_divider

        .clk_10(sclk)                          //10Mhz to spi_controller
    );

    spi_controller spi_controller (
        .clk_10(sclk),                         //10Mhz from spi_clock_divider to spi_controller
        .rst(key0_rst),                        //reset trigger from top M to spi_controller
        .data_in(sw_data),                     //data to send from top M
        .start_tx(sw_tx_9),                    //enable tx trigger from top M
        .start_rx(sw_rx_8),                    //enable rx trigger from top M
        
        .done_tx(ledr_tx),                     //done tx trigger to top M
        .done_rx(ledr_rx),                     //done rx trigger to top M
        .data_out(ledr_rx_data),               //data receiver to top M
        
        .mosi_tx(mosi_tx),                     //out pin to nrf tx
        .miso_tx(miso_tx),                     //input
        
        .mosi_rx(mosi_rx),                     //out pin to nrf rx
        .miso_rx(miso_rx)                      //input

    );

    sck_tx <= sclk;
    ce_tx <= 0;
    csn_tx <= 0;
    sck_rx <= sclk;
    ce_rx <= 0;
    csn_rx <= 0;
    
endmodule
