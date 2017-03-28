#include "stm32l1xx.h"
#pragma O0

unsigned char Stacks[8][0x200];

struct 
{
	unsigned int GPR[13];
	void * PC;
	void * LR;
	void * SP;
	unsigned int PSW;
	unsigned int priority;
	unsigned int tA;
	unsigned int T;
	unsigned int active;
} contexts[8];

extern void * Tasks[];
unsigned char tnum;
volatile unsigned char tcur;
volatile unsigned int chunk;
volatile unsigned int globalTime;
typedef void (*func)(void);

void OSinit()
{
	int i;
	RCC->APB1ENR |= 0x0000001;
	
//	TIM2->CNT=0;
//	TIM2->PSC=0x80;
//	TIM2->ARR=0x8000;
//	TIM2->DIER|=0x0000001;
//	TIM2->CR1|=0x0000001;
//	
	i = 0;
	while (Tasks[i] != 0)
	{
		contexts[i+1].PC = (void *)(((int)(Tasks[i])) | (1));
		contexts[i+1].SP = &Stacks[i][0x200-4];
		contexts[i+1].PSW = 0x01000000;
		contexts[i+1].priority=10-i;
		contexts[i+1].tA=0;
		contexts[i+1].T=10-i;
		contexts[i+1].active = 1;
		i++;	
	}
	tnum = i;
	tcur = 0;
	chunk=1000;
	globalTime=0;
	NVIC->ISER[0] |= 0x00008000;
	
	TIM2->CR1|=0x0000001;
	
	while(1); 
}

void Init(int number){
		contexts[number].PC = (void *)((int)(Tasks[number-1]));
		contexts[number].SP = &Stacks[number-1][0x200-4];
		contexts[number].PSW = 0x01000000;
	  contexts[number].active = 1;
}

char Scheduled(){
	volatile int i;
	int pMax=0;
	char iMax=0; 
	for(i=1;i<=tnum;i++){
			if(contexts[i].active==0 && contexts[i].tA<=globalTime){
				Init(i);
			}
			
			if(contexts[i].active==1 && contexts[i].priority>=pMax){
				pMax=contexts[i].priority;
				iMax=i;
			}
	}
	
	return iMax;
}

void SaveContext (void * conptr);
void RestoreContext (void * conptr);

#pragma O0
void OSkernel()
{
	SaveContext(&(contexts[tcur]));
	tcur=Scheduled();
	RestoreContext(&(contexts[tcur]));
	globalTime++;
	return;
}

