#include "QSKDefines.h"
#include "proto.h"
#include "extern.h"

/***********************************************************************/
/*                                                                     */
/*  DATE        :Thursday, Sep 9, 2011                                 */
/*																	   */
/*  DESCRIPTION :      Contains the main code to read the the 	       */
/* 	  					the thermistor A/D and display the		       */
/*						temperature	in degrees F on the LCD			   */
/*  CPU GROUP   :62P                                                   */
/*                                                                     */
/*  Copyright (c) 2009 by BNS Solutions, Inc.						   */
/*  All rights reserved.											   */
/*                                                                     */
/***********************************************************************/

int disp_count;				// LED control variable
uint A2DValue;
uint A2DValuePot;
uint A2DValueTherm;
uchar A2DProcessed;

void main(void)
//-----------------------------------------------------------------------------------------------------
//  Purpose:	The MCU will come here after reset. 
//  
//
//  Rev:    1.0     Initial Release
//  
//  Notes:          None    
//-----------------------------------------------------------------------------------------------------
{
	float temp;
	
	MCUInit();
	InitDisplay("G1-L2-P4");
	InitUART();
	//BNSPrintf(SERIAL, "\n\rLab2P4\n\r");
  	TimerInit();
	ADInit();	

	while(1) {
		if (A2DProcessed == TRUE) {         		// only update the display when a new value is available
		A2DProcessed = FALSE;						// Each time a new value is available note for next loop
		temp = -0.0927*(A2DValueTherm)+72.3930; 	//Convert A/D value to temp in degrees C
		temp = (temp*9.0)/5.0 + 32.0;				// Convert degrees C to degrees F
		BNSPrintf(LCD,"\t%0.2f%cF ",temp, 223);	// Display 'temp"degreesymbol"F' on LCD
		}
	}
}


void TimerInit(void)
//-----------------------------------------------------------------------------------------------------
//  Purpose:	This will set up the A0 timer for 1ms and the A1 as counter
//  
//
//  Rev:    1.0     Initial Release
//  
//  Notes:          None    
//-----------------------------------------------------------------------------------------------------
{
   /* Configure Timer A0 - 1ms (millisecond) counter */
   ta0mr = 0x80;	// Timer mode, f32, no pulse output
   ta0 = (unsigned int) (((f1_CLK_SPEED/32)*1e-3) - 1);	// (1ms x 12MHz/32)-1 = 374
 
   /* Configure Timer A1 - Timer A0 used as clock */
   ta1mr = 0x01;	// Event Counter mode, no pulse output
   ta1 = 0x3FF;		// initial value - max value of ADC (0x3FF)
   trgsr = 0x02;	// Timer A0 as event trigger

/* The recommended procedure for writing an Interrupt Priority Level is shown
   below (see M16C datasheets under 'Interrupts' for details). */

   DISABLE_IRQ		// disable irqs before setting irq registers - macro defined in skp_bsp.h
   ta1ic = 3;		// Set the timer A1's IPL (interrupt priority level) to 3
   ENABLE_IRQ		// enable interrupts macro defined in skp_bsp.h

   /* Start timers */
   ta1s = 1;		// Start Timer A1
   ta0s = 1;		// Start timer A0
}


void ADInit(void)
//-----------------------------------------------------------------------------------------------------
//  Purpose:	Set up the A2D for one shot mode.
//  
//
//  Rev:    1.0     Initial Release
//  
//  Notes:          None    
//-----------------------------------------------------------------------------------------------------
{
	
   /* Configure ADC - AN0 (Analog Adjust Pot) */
   adcon0 = 0x80;	// AN0, One-shot, software trigger, fAD/2
   adcon1 = 0x28;	// 10-bit mode, Vref connected.
   adcon2 = 0x01;	// Sample and hold enabled
}