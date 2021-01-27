# LCSE PROJECT
This project is an extended work for Laboratorio de Circuitos y Sistemas Electrónicos (**LCSE**), a subject of Máster Universitario en Ingeniería de Sistemas Electrónicos ([MUISE](http://www.die.upm.es/MISE/)) and Doble Máster en Ingeniería de Telecomunicaciones e Ingeniería de Sistemas Electrónicos  ([MUIT-MUISE](http://www.etsit.upm.es/estudios/dobles-titulos-de-master-etsit/muit-muise.html)).

The aim of this project is implement a specific use microcontroller with reduced functionalities using **VHDL**.
The architecture employed is similar to the Harvard's one, and it is shown in the next Figure:
![ARCHITECTURE](https://user-images.githubusercontent.com/36552876/106066892-df0b8a80-60fd-11eb-9c18-462a54db8f4b.png)

The system is formed by:
- CPU: it is going to be used the PicoBlaze.
- DMA: hardware mechanism that allows data transferring between peripheral and memory in background.
- RS232: serial communication interface.
- Arbitrium signal: allows or denies the access to the master communication bus.
- 7 segment display: shows addresses and its content.
- GPIO: pins for general purpose.
## Memory map
![mem_map](https://user-images.githubusercontent.com/36552876/106067824-c2705200-60ff-11eb-9b2b-30dac94b0790.png)

All addresses have been chosen in order to ease the range checking. Thinking in future improvements, some blocks has been left empty.
## DMA
![DMA_MM](https://user-images.githubusercontent.com/36552876/98708943-074adf00-2382-11eb-8f98-49e6dedfd0a5.PNG)

The **DMA** uses 16 bytes of memory space and its range  goes from 0xC0 to 0xD0. Each channel has 4 configuration registers.
 - **DMA_CONFIG_CH**: Most Significant Bit to enable/disable the channel. Next 2 bits to configue the transmission mode:
	 - 00: Memory to Memory
	 - 01: Memory to Peripheral
	 - 10: Peripheral to Memory
	 - 11: Disabled
 - **DMA_SRC_CH**: source address from 0x00 to 0xFF.
 - **DMA_DEST_CH**: destination address from 0x00 to 0xFF.
 - **DMA_CNT_CH**: The 4 left bits for the transmission counter with values from 0x0 to 0xF. The other 4 bits in the same range for the number of transmissions realizated.
 Its memory map is shown below:
 ![DMA_MEM_MAP](https://user-images.githubusercontent.com/36552876/106068667-32cba300-6101-11eb-8bf0-5ddb020d91a0.png)
## RS232
Telecommunication standard designed for serial transmission data. This implementation uses two wires for transmission and reception without flow contro.
Its memory map is shown below:

![RS232_MEM_MAP](https://user-images.githubusercontent.com/36552876/106068813-7f16e300-6101-11eb-9eac-3fc106e7045e.png)
## GPIO
![GPIO_MEM_MAP](https://user-images.githubusercontent.com/36552876/98708945-074adf00-2382-11eb-9120-2d85de1661b6.png)

The **GPIO** uses 10 bytes of memory space and its range  goes from 0xE0 to 0xEF.
 - **IRQ_MASKA/B:** Port A/B interruption mask with values from 0X00 to 0XFF.
 - **IRQ_MODEA/B:** Interrupt mode for GPIO 'N'. '1' for falling and '0' for rising.
 - **MODEA1/2 and MODEB1/2:** Funcition mode for GPIO 'N':
	 - 00: High Z
	 - 01: Output
	 - 10: Input
	 - 11: ALT function
 - **GPIOA/B REGISTERS:** GPIO 'N' value. '1' for High and '0' for Low.
 ## Segment display
 ![DISP_MEM_MAP](https://user-images.githubusercontent.com/36552876/98708942-06b24880-2382-11eb-9d11-7bbf5e99a17a.png)
 
 The **Segment display** uses 6 bytes of memory space and its range  goes from 0xD8 to 0xDF.
  - **EN:** MSB for enable or disable the module. '1' for enable and '0' for disable.
 - **ENX:** Enable display X where the MSB is for display 0 and LSB for display 7. '1' for disable and '0' for enable.
 - **DIGITX_REGISTERS:** value of each display. The 4 left bits for pair displays and the other 4 for odd ones.
