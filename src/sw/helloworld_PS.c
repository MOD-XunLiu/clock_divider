/******************************************************************************
*
* File: helloworld.c
*
* Description:
* This program demonstrates how to configure and use all 32 pins of an EMIO
* GPIO bank on a Zynq-7000 board to write a 32-bit number from the Processing
* System (PS) to the Programmable Logic (PL).
*
* The program configures all 32 pins of GPIO Bank 3 (EMIO signals 86-117) as
* outputs and writes a 32-bit value to them. It also includes a function to
* verify if the written data is correct.
*
* Author: GPT + example
* Date: 2024-07-10
* Version: This is used to test if the data I wrote is correctly written
*
******************************************************************************/

#include "xgpiops.h"
#include "xparameters.h"
#include "xil_printf.h"
#include <unistd.h> // for sleep

#define GPIO_DEVICE_ID		XPAR_XGPIOPS_0_DEVICE_ID
#define GPIO_BANK	XGPIOPS_BANK3  /* Bank 3 of the GPIO Device */
#define printf			xil_printf	/* Smaller foot-print printf */

static XGpioPs Gpio;  // Define an instance of the XGpioPs driver

static int WriteAndVerifyGPIO(const XGpioPs *InstancePtr, u8 Bank, u32 Value);


int main() {
    XGpioPs_Config *ConfigPtr;
    int Status;

    // Initialize the GPIO driver
	ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);
    if (ConfigPtr == NULL) {
        xil_printf("GPIO LookupConfig failed\r\n");
        return XST_FAILURE;
    }

    Status = XGpioPs_CfgInitialize(&Gpio, ConfigPtr, ConfigPtr->BaseAddr);
//    xil_printf("BaseAddr: %x: \r\n", ConfigPtr->BaseAddr); // last checked, this is correct
    if (Status != XST_SUCCESS) {
        xil_printf("GPIO CfgInitialize failed\r\n");
        return XST_FAILURE;
    }

    // Configure all 32 pins of GPIO Bank 3 for output
    u32 direction_mask = 0xFFFFFFFF;  // Set all 32 bits as output
    u32 enable_mask = 0xFFFFFFFF;  // Enable output for all 32 bits

    XGpioPs_SetDirection(&Gpio, GPIO_BANK, direction_mask);
    XGpioPs_SetOutputEnable(&Gpio, GPIO_BANK, enable_mask);

    while(1) {
		// Write a 32-bit value to GPIO Bank 3 and verify
		sleep(1);
		u32 value = 0x00000001;  // The 32-bit value you want to write
		XGpioPs_Write(&Gpio, GPIO_BANK, value);
		xil_printf("Wrote 1\r\n");
		sleep(1);
		u32 read_value = XGpioPs_Read(&Gpio, GPIO_BANK);
		xil_printf("Read %d\r\n", read_value);
		sleep(1);
		value = 0x00000000;
		XGpioPs_Write(&Gpio, GPIO_BANK, value);
		xil_printf("Wrote 0\r\n");
		sleep(1);
		read_value = XGpioPs_Read(&Gpio, GPIO_BANK);
		xil_printf("Read %d\r\n", read_value);
    }
//    Status = WriteAndVerifyGPIO(&Gpio, GPIO_BANK, value);
//
//    if (Status == XST_SUCCESS) {
//        xil_printf("GPIO Write and Verify successful\r\n");
//    } else {
//        xil_printf("GPIO Write and Verify failed\r\n");
//    }

    return 0;
}

int WriteAndVerifyGPIO(const XGpioPs *InstancePtr, u8 Bank, u32 Value) {

//	// Write the value to the GPIO bank
//    XGpioPs_Write(InstancePtr, Bank, Value);
//
//
//    // Read back the value from the GPIO bank
//    u32 read_value = XGpioPs_Read(InstancePtr, Bank);
//
//    // Verify if the written value matches the read value
//    if (read_value == Value) {
//    	xil_printf("GPIO write value successful\r\n");
//        return XST_SUCCESS;
//    } else {
//    	xil_printf("GPIO write value failed\r\n");
//        return XST_FAILURE;
//    }
	return -1;
}