/*
 * main.c
 *
 *  Created on: Oct 5, 2018
 *      Author: arthur
 */

#include "xparameters.h"
#include "xil_io.h"
#include "xscutimer.h"
#include <stdio.h>
#include "xadcps.h"
#include "xstatus.h"
#include "piestimator.h"

XStatus InitRand(XAdcPs *instance_ptr) {
	const u32 id = XPAR_XADCPS_0_DEVICE_ID;
	XAdcPs_Config *cfg_ptr;
	cfg_ptr = XAdcPs_LookupConfig(id);
	if (cfg_ptr == NULL) {
		return XST_FAILURE;
	}
	XAdcPs_CfgInitialize(instance_ptr, cfg_ptr, cfg_ptr->BaseAddress);

	XAdcPs_SetSequencerMode(instance_ptr, XADCPS_SEQ_MODE_SAFE);
	XAdcPs_SetSeqChEnables(instance_ptr, XADCPS_SEQ_CH_TEMP); // Enable only temperature channel
	XAdcPs_SetSequencerMode(instance_ptr, XADCPS_SEQ_MODE_CONTINPASS);
	return XST_SUCCESS;
}

u32 GetRand(XAdcPs *instance_ptr) {
	u32 rand = 0;
	for (int x=0; x<32; x++) {
		rand = (rand << 1) | ((XAdcPs_GetAdcData(instance_ptr, XADCPS_CH_TEMP) >> 1) & 0x1);
	}
	return rand;
}

void DemoInit(u32 num_insts) {
	XAdcPs xadcps_inst;
	InitRand(&xadcps_inst);
	Xil_Out32(PIESTIMATOR_CONTROL_START_REG, 0);
	for (u32 inst = 0; inst < num_insts; inst++) {
		Xil_Out32(PIESTIMATOR_SET_SEED_REG(inst), 0);
		Xil_Out32(PIESTIMATOR_SEED_REG(inst), 0);
	}
	for (u32 inst = 0; inst < num_insts; inst++) {
		u32 seed = GetRand(&xadcps_inst);
		Xil_Out32(PIESTIMATOR_SEED_REG(inst), seed);
		Xil_Out32(PIESTIMATOR_SET_SEED_REG(inst), 1);
		Xil_Out32(PIESTIMATOR_SET_SEED_REG(inst), 0);
	}
};

void DemoRun(u32 num_insts, u32 duration) {
	Xil_Out32(PIESTIMATOR_CONTROL_DURATION_REG, duration);
	Xil_Out32(PIESTIMATOR_CONTROL_START_REG, 1);
	Xil_Out32(PIESTIMATOR_CONTROL_START_REG, 0);

	printf("Estimating Pi...\r\n");

	u32 done = 0;
	while (done < num_insts) {
		done = 0;
		for (u32 inst = 0; inst < num_insts; inst++) {
			done += Xil_In32(PIESTIMATOR_DONE_REG(inst)) & 0x1;
		}
	}

	u32 numer = 0;
	u32 denom = 0;

	// Uncomment the following line to print data that can be copy-pasted into excel
	//#define OUTPUT_FOR_EXCEL

	#ifdef OUTPUT_FOR_EXCEL
		printf("Instances\tDSP Utilization\tNumerator\tDenominator\tEstimate\tAccuracy\tDuration\tElapsed Time\r\n");
	#endif

	for (u32 inst = 0; inst < num_insts; inst++) {
		numer += Xil_In32(PIESTIMATOR_RESULT_REG(inst));
		denom += duration;

		#ifdef OUTPUT_FOR_EXCEL
			double est = ((double)numer)/denom*4.0;
			double pi = 3.14159265359;
			double acc = 100.0 * (est - pi) / pi;
			printf("%ld\t", inst+1);
			printf("%ld\t", (inst+1)*2);
			printf("=HEX2DEC(\"%08lx\")\t", numer);
			printf("=HEX2DEC(\"%08lx\")\t", denom);
			printf("%lf\t", est);
			printf("%lf\t", acc);
			printf("=HEX2DEC(\"%08lx\")\t", duration);
			printf("%lf\r\n", ((double)duration)/125000000);
		#endif
	}
	#ifndef OUTPUT_FOR_EXCEL
		double est = ((double)numer)/denom*4.0;
		double pi = 3.14159265359;
		double acc = 100.0 * (est - pi) / pi;
		printf("Utilization:           %ld Estimator IPs\r\n", num_insts);
		printf("                       %ld DSP Slices\r\n", num_insts*2);
		printf("Elapsed time:          0x%08lx clock cycles\r\n", duration);
		printf("                       %lf seconds\r\n", ((double)duration)/125000000);
		printf("Samples within circle: 0x%08lx samples\r\n", numer);
		printf("Total samples:         0x%08lx samples\r\n", denom);
		printf("Estimate of pi:        %lf\r\n", est);
		printf("Accuracy:              %lf percent\r\n", acc);
	#endif
}

int main() {
	u32 num_insts = PIESTIMATOR_MAX_INSTANCES;
	u32 duration = 0xFFFFFFFF / num_insts;
	DemoInit(num_insts);
	DemoRun(num_insts, duration);
	while(1);
	return 0;
}
