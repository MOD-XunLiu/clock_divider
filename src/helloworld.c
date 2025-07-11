/******************************************************************************
* Copyright (C) 2005 - 2021 Xilinx, Inc.  All rights reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/

/*****************************************************************************/
/**
* @file xgpio_tapp_example.c
*
* This file contains a example for using AXI GPIO hardware and driver.
* This example assumes that there is a UART Device or STDIO Device in the
* hardware system.
*
* @note
*
* None
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver	Who  Date	  Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a sv   04/15/05 Initial release for TestApp integration.
* 3.00a sv   11/21/09 Updated to use HAL Processor APIs.
* 3.01a bss  04/18/13 Removed incorrect Documentation lines.(CR #701641)
* 4.1   lks  11/18/15 Updated to use canonical xparameters and
*		      clean up of the comments and code for CR 900381
* 4.3   ms   01/23/17 Added xil_printf statement in main function to
*                     ensure that "Successfully ran" and "Failed" strings
*                     are available in all examples. This is a fix for
*                     CR-965028.
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xparameters.h"
#include "xgpiops.h"
#include "stdio.h"
#include "xstatus.h"
#include "sleep.h"
#include "xil_printf.h"

/************************** Constant Definitions ****************************/

#define printf xil_printf	/* A smaller footprint printf */

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define GPIO_ID XPAR_PS7_GPIO_0_DEVICE_ID
#define GPIO_BANK XGPIOPS_BANK2

/************************** Variable Definitions **************************/

/*
 * The following are declared globally so they are zeroed and so they are
 * easily accessible from a debugger
 */
XGpioPs GpioOutput; /* The driver instance for GPIO Device configured as O/P */
XGpioPs_Config *ConfigPtr;

int main(void)
{

	int Status;
	u32 input_value;
	u32 OUTPUT = 0x11111111;
	u32 ENABLE = 0x11111111;

	/*
	 * Initialize the GPIO driver so that it's ready to use,
	 * specify the device ID that is generated in xparameters.h
	 */
	ConfigPtr = XGpioPs_LookupConfig(GPIO_ID);
    if (ConfigPtr == NULL) {
        xil_printf("GPIO LookupConfig failed\r\n");
        return XST_FAILURE;
    }
	Status = XGpioPs_CfgInitialize(&GpioOutput, ConfigPtr,
						ConfigPtr->BaseAddr);
	 if (Status != XST_SUCCESS)  {
		  printf("Failed to initialize GPIO Driver\r\n");
		  return XST_FAILURE;
	 }

	 /* Set the direction for all signals to be outputs */
	 XGpioPs_SetDirection(&GpioOutput, GPIO_BANK, OUTPUT);
	 XGpioPs_SetOutputEnable(&GpioOutput, GPIO_BANK, ENABLE);

	 while (1) {

		 sleep(1);
		 printf("Enter an unsigned integer as scale: \r\n");
		 scanf("%lu", &input_value);
		 /* Set the GPIO outputs to low */
		 XGpioPs_Write(&GpioOutput, GPIO_BANK, input_value);
		 printf("Wrote %u\r\n", input_value);
		 
	 }

	 return XST_SUCCESS;
}
