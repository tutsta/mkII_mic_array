//Standalone SPI test routines for MiniZed based on Xilinx example code for SpiPolledExample
//Avnet Inc Copyright 2019

/***************************** Include Files *********************************/

#include "stdio.h"
#include <stdlib.h>
#include "xparameters.h"	/* XPAR parameters */
#include "xspips.h"		/* SPI device driver */
#include "xil_io.h"
//#include "xspi_l.h"
#include "xil_printf.h"

#define false 0
#define true 1

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define SPI_DEVICE_ID		XPAR_PS7_SPI_0_DEVICE_ID

#define SPI_BASEADDR		XPAR_PS7_SPI_0_BASEADDR

#define SPI_CTRL_BASEADDR   0x43C00000

// This is the size of the buffer to be transmitted/received in this example.
#define BUFFER_SIZE      12
#define MAX_LINE_LENGTH  80

#define NUM_DEVICES 1 // number of MAX11040K devices in the SPI cascade

#define CMD_NULL         0x00 // null command
#define CMD_WRITE_SICR   0x40 // write sampling instant control register
#define CMD_READ_SICR    0xC0 // read sampling instant control register
#define CMD_WRITE_DRCR   0x50 // write data rate control register
#define CMD_READ_DRCR    0xD0 // read data rate control register
#define CMD_WRITE_CFR    0x60 // write configuration register
#define CMD_READ_CFR     0xE0 // read configuration register
#define CMD_READ_DATA    0xF0 // read data register

/**************************** Type Definitions *******************************/

// The following data type is used to send and receive data on the SPI interface.
typedef u8 DataBuffer[256];


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

int SpiStart(u16 SpiDeviceId);
int SpiReadSICReg(u16 SpiDeviceId);
int SpiWriteSICReg(u16 SpiDeviceId);
int SpiClearSICReg(u16 SpiDeviceId);
int SpiReadDRCReg(u16 SpiDeviceId);
int SpiWriteDRCReg(u16 SpiDeviceId);
void display_menu(void);

/************************** Variable Definitions *****************************/

// The instances to support the device drivers are global such that the are initialized to zero each time the program runs.
XSpiPs SpiInstance;			/* The instance of the SPI device */

// The following variables are used to read and write to the  Spi device, they are global to avoid having large buffers on the stack.
u8 ReadBuffer[BUFFER_SIZE];
u8 WriteBuffer[BUFFER_SIZE];
u8 data_tx_array[BUFFER_SIZE];
u8 data_rx_array[BUFFER_SIZE];

// ADC reference input clock
float fXinClock = 24.576e6;


//Main function
int main(void)
{
	//u32 axiBaseAddr = SPI_CTRL_BASEADDR;
	u32 Control;
    char chkey;
	int bLooping = true;

/*    int size_val;

    size_val = sizeof(int);
    printf("Size of int is: %d bytes\n",size_val);
    size_val = sizeof(unsigned short int);
    printf("Size of unsigned short int is: %d bytes\n",size_val);
    size_val = sizeof(unsigned int);
    printf("Size of unsigned int is: %d bytes\n",size_val);
	size_val = sizeof(unsigned long int);
	printf("Size of unsigned long int is: %d bytes\n", size_val);
	size_val = sizeof(unsigned long long int);
	printf("Size of unsigned long long int is: %d bytes\n", size_val);
	size_val = sizeof(float);
    printf("Size of float is: %d bytes\n",size_val);
    size_val = sizeof(double);
    printf("Size of double is: %d bytes\n",size_val);
    size_val = sizeof(char);
    printf("Size of char is: %d bytes\n",size_val);*/


//	Control = XSpi_ReadReg(SPI_BASEADDR, XSP_CR_OFFSET);
//	printf("SPI control register: 0x%lX\n", Control);
//	Control |= XSP_CR_XIP_CLK_POLARITY_MASK;
//	printf("SPI control register: 0x%lX\n", Control);
//	XSpi_WriteReg(SPI_BASEADDR, XSP_CR_OFFSET, Control);
    
	printf("################################################################################\r\n");
	printf("MiniZed SPI interface to MAX11040K ADC\n");
	printf("################################################################################\n");
	fflush(stdout); // Prints to screen or whatever your standard out is

	//Read the value of the first AXI-Lite peripheral register
	Control = Xil_In32(SPI_CTRL_BASEADDR);
	printf("SPI control peripheral register 0 addr: 0x%08lX\n", Control);
	Xil_Out32(SPI_CTRL_BASEADDR, 0x1);
	Control = Xil_In32(SPI_CTRL_BASEADDR);
	printf("SPI control peripheral register 0 value: 0x%08lX\n", Control);


    SpiStart(SPI_DEVICE_ID);

    display_menu();
	while (bLooping)
	{
		chkey = getchar();
		//printf("\nChar received:%c\n", chkey);
		int intkey = (int)chkey;
		// Read sampling instant control register
		if (chkey == '0')
		{
			chkey = getchar(); // clear the CR from the input buffer
			SpiReadSICReg(SPI_DEVICE_ID);
            display_menu();
		}
		// Write sampling instant control register
        else if (chkey == '1')
        {
        	chkey = getchar(); // clear the CR from the input buffer
            SpiWriteSICReg(SPI_DEVICE_ID);
            // read back the register values
            SpiReadSICReg(SPI_DEVICE_ID);
            display_menu();
		}
		// Clear the sampling instant control register
        else if (chkey == '2')
        {
        	chkey = getchar(); // clear the CR from the input buffer
            SpiClearSICReg(SPI_DEVICE_ID);
            // read back the register values
            SpiReadSICReg(SPI_DEVICE_ID);
            display_menu();
		}
		// Read data rate control register
        else if (chkey == '3')
        {
        	chkey = getchar(); // clear the CR from the input buffer
            SpiReadDRCReg(SPI_DEVICE_ID);
            display_menu();
		}
		// Write data rate control register
        else if (chkey == '4')
        {
        	chkey = getchar(); // clear the CR from the input buffer
            SpiWriteDRCReg(SPI_DEVICE_ID);
            // read back the register values
            SpiReadDRCReg(SPI_DEVICE_ID);
            display_menu();
		}
		// Exit
		else if ((intkey >= 0x21) && (intkey <= 0x7E))
		{
			printf("You pressed the '%c' key.  Program exit.\n", chkey);
			fflush(stdout); // Prints to screen or whatever your standard out is
			bLooping = false;
		}
	} //while (bLooping)

	return 0;
} //main()

void display_menu(void)
{
	printf("--------------------------------------------------------------------------------\n");
	printf("Interactive register operations:\n");
    printf("0 => Read sampling instant control register\n");
    printf("1 => Write sampling instant control register\n");
    printf("2 => Clear the sampling instant control register\n");
    printf("3 => Read data rate control register\n");
    printf("4 => Write data rate control register\n");
    printf("5 => Read configuration register\n");
    printf("6 => Write configuration register\n");
    printf("7 => Read data register\n");
	printf("x => Exit\n");
	fflush(stdout);
}


int Spi_Init(u16 SpiDeviceId)
{
	int Status;
	u8 DelayInit;
	XSpiPs_Config *SpiConfig; /* Pointer to Configuration data */

	/*
	 * Initialize the SPI device.
	 */
	SpiConfig = XSpiPs_LookupConfig(SpiDeviceId);
	if (NULL == SpiConfig) {
		return XST_FAILURE;
	}

	Status = XSpiPs_CfgInitialize(&SpiInstance, SpiConfig, SpiConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to check hardware build
	 */
	Status = XSpiPs_SelfTest(&SpiInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Write the delay register to ensure the correct delay between the CS and the first SCLK transition.
	 */
	DelayInit = 0x0U;
	Status = XSpiPs_SetDelays(&SpiInstance, 0, 0, 0, DelayInit);
	if (Status != (s32)XST_SUCCESS) {
		return Status;
	}

	/*
	 * Set the SPI device hardware interface options
	 */
	XSpiPs_SetOptions(&SpiInstance, XSPIPS_MASTER_OPTION | XSPIPS_CLK_ACTIVE_LOW_OPTION | XSPIPS_FORCE_SSELECT_OPTION);
	XSpiPs_SetClkPrescaler(&SpiInstance, XSPIPS_CLK_PRESCALE_64);

	return XST_SUCCESS;
} //Spi_Init()

void write_array_multiple(u8 cmd, u8 num_bytes)
{
    int index = 0;
    int data_byte_number;
   	WriteBuffer[index++] = cmd;
   for (data_byte_number = 0; data_byte_number < (num_bytes); data_byte_number++)
    {
    	WriteBuffer[index++] = data_tx_array[data_byte_number];
    }

	//Transmit the data.
	XSpiPs_PolledTransfer(&SpiInstance, WriteBuffer, ReadBuffer, index);
} //write_array_multiple()

int SpiStart(u16 SpiDeviceId)
{
	int Status;
	Status = Spi_Init(SpiDeviceId);
	if (Status)
	{
		printf("ERROR: SPI component failed to initialise\r\n");
		return XST_FAILURE;
	}

    printf("SPI component initialised OK\r\n");

	return XST_SUCCESS;
} //SpiStart()

int SpiReadSICReg(u16 SpiDeviceId)
{
    int lp;
    int numBytes = 5;

    for(lp = 0; lp < numBytes; lp++) {
    	data_tx_array[lp] = 0;
        ReadBuffer[lp] = 0;
    }

	write_array_multiple(CMD_READ_SICR, numBytes);

    printf("Sampling Instant Control Register:\r\n");
    for(lp = 0; lp < numBytes-1; lp++) {
        printf("PHI%d : %d\r\n", lp, ReadBuffer[lp+1]);
    }
    fflush(stdout);
    
	return XST_SUCCESS;
} //SpiReadSICReg()

int SpiWriteSICReg(u16 SpiDeviceId)
{
    int lp;
    int numBytes = 4;
    char buffer[MAX_LINE_LENGTH];
    char tmp;
    int data;
    int i = 0;

    for(lp = 0; lp < numBytes; lp++) {
    	data_tx_array[lp] = 0;
        ReadBuffer[lp] = 0;
    }
    
    for (lp=0;lp<4;lp++) {
        printf("\nPHI%d value 0-255 [0]: ", lp);
        i = 0;
        memset(buffer, 0, sizeof buffer);
        while (1) {
        	 tmp = getchar();
        	 if ((int)tmp == 13) break;
        	 buffer[i] = tmp;
        	 i++;
        }
        data = atoi(buffer);
        data_tx_array[lp] = (u8)(data);
        printf("\nDelay value is: %d(0x%2X) (%d clock cycles)\n", data, data_tx_array[lp], data*32);
    }

    printf("Sending: 0x%X, 0x%X, 0x%X, 0x%X\r\n", data_tx_array[0], data_tx_array[1], data_tx_array[2], data_tx_array[3]);

	write_array_multiple(CMD_WRITE_SICR, numBytes);

    fflush(stdout);
    
	return XST_SUCCESS;
} //SpiWriteSICReg()

int SpiClearSICReg(u16 SpiDeviceId)
{
    int lp;
    int numBytes = 4;

    for(lp = 0; lp < numBytes; lp++) {
    	data_tx_array[lp] = 0;
        ReadBuffer[lp] = 0;
    }

	write_array_multiple(CMD_WRITE_SICR, numBytes);

	return XST_SUCCESS;
} //SpiClearSICReg()


int SpiReadDRCReg(u16 SpiDeviceId)
{
    int lp;
    int numBytes = 3;
    int fSampCRaw;
    int fSampFRaw;
    float fSampC;
    float fineCycleFactor;
    float fSampF;
    float outputRate;

    for(lp = 0; lp < numBytes; lp++) {
    	data_tx_array[lp] = 0;
        ReadBuffer[lp] = 0;
    }

	write_array_multiple(CMD_READ_DRCR, numBytes);

	fSampFRaw = (int)ReadBuffer[1] + (((int)ReadBuffer[2] & 0x7)<<8);
	fSampCRaw = ((int)ReadBuffer[2] & 0xE0)>>5;
    printf("Data Rate Control Register:\r\n");
    printf("Data rate coarse adjust code : 0x%X\r\n", fSampCRaw);
    printf("Data rate fine adjust code : 0x%X\r\n", fSampFRaw);

    switch (fSampCRaw) {
    case 0:
    	fSampC = 4.0;
    	fineCycleFactor = 1.0;
    	break;
    case 1:
    	fSampC = 128.0;
    	fineCycleFactor = 32.0;
    	break;
    case 2:
    	fSampC = 64.0;
    	fineCycleFactor = 16.0;
    	break;
    case 3:
    	fSampC = 32.0;
    	fineCycleFactor = 8.0;
    	break;
    case 4:
    	fSampC = 16.0;
    	fineCycleFactor = 4.0;
    	break;
    case 5:
    	fSampC = 8.0;
    	fineCycleFactor = 2.0;
    	break;
    case 6:
    	fSampC = 2.0;
    	fineCycleFactor = 1.0;
    	break;
    case 7:
    	fSampC = 1.0;
    	fineCycleFactor = 1.0;
    	break;
    }

    fSampF = (float)fSampFRaw;
    outputRate = fXinClock/(fSampC*384.0 + fSampF*fineCycleFactor);

    printf("Output data rate = %.5f ksps\r\n", outputRate/1000.0);

    fflush(stdout);

	return XST_SUCCESS;
} //SpiReadDRCReg()


int SpiWriteDRCReg(u16 SpiDeviceId)
{
    int lp;
    int numBytes = 2;
    char buffer[MAX_LINE_LENGTH];
    char tmp;
    int data;
    int i = 0;

    for(lp = 0; lp < numBytes; lp++) {
    	data_tx_array[lp] = 0;
        ReadBuffer[lp] = 0;
    }

    printf("\nFine data rate adjust code 0-1535 [0]: ");
    i = 0;
    memset(buffer, 0, sizeof buffer);
   while (1) {
    	tmp = getchar();
    	if ((int)tmp == 13) break;
    	buffer[i] = tmp;
    	i++;
    }
    data = atoi(buffer);
    data_tx_array[0] = (u8)(data & 0xFF);
    data_tx_array[1] = (u8)((data & 0x700)>>8);

    printf("\nCoarse data rate adjust code 0-7 [0]: ");
    i = 0;
    memset(buffer, 0, sizeof buffer);
    while (1) {
    	tmp = getchar();
    	if ((int)tmp == 13) break;
    	buffer[i] = tmp;
    	i++;
    }
    data = atoi(buffer);
    data_tx_array[1] |= (u8)((data & 0x7)<<5);

    printf("\nSending: 0x%04X to DRC reg.\r\n", (((int)data_tx_array[1]<<8) | (int)data_tx_array[0]));

	write_array_multiple(CMD_WRITE_DRCR, numBytes);

    fflush(stdout);

	return XST_SUCCESS;
} //SpiWriteDRCReg()

