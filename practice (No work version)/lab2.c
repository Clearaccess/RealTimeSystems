#include "stm32l1xx.h"

#define sysclk 2097000
#define uartbrd 57600

extern struct 
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
extern volatile unsigned int chunk;
extern volatile unsigned char tcur;

void Input()
{
	NVIC_DisableIRQ(TIM2_IRQn);
	volatile int i=0;
	volatile char num=tcur;
	NVIC_EnableIRQ(TIM2_IRQn);
	while(1){
			NVIC_DisableIRQ(TIM2_IRQn);
			if(i>=chunk){
				contexts[num].tA+=contexts[num].T;
				contexts[num].active=0;
				break;
			}
			i++;
			NVIC_EnableIRQ(TIM2_IRQn);
	}
}

void Output()
{	
	NVIC_DisableIRQ(TIM2_IRQn);
	volatile int i=0;
	volatile char num=tcur;
	NVIC_EnableIRQ(TIM2_IRQn);
	while(1){
			NVIC_DisableIRQ(TIM2_IRQn);
			if(i>=chunk){
				contexts[num].tA+=contexts[num].T;
				contexts[num].active=0;
				break;
			}
			i++;
			NVIC_EnableIRQ(TIM2_IRQn);
	}
}

void GreatWork()
{
	NVIC_DisableIRQ(TIM2_IRQn);
	volatile int i=0;
	volatile char num=tcur;
	NVIC_EnableIRQ(TIM2_IRQn);
	while(1){
			NVIC_DisableIRQ(TIM2_IRQn);
			if(i>=chunk){
				contexts[num].tA+=contexts[num].T;
				contexts[num].active=0;
				break;
			}
			i++;
			NVIC_EnableIRQ(TIM2_IRQn);
	}
}

void * const Tasks[] __attribute__((at(0x08001000))) = {
	Input,
	Output,
	GreatWork,
	0
	};


int main() {
	
	
	RCC->APB2ENR = 0x00004000;
	USART1->BRR = (((sysclk/16) / uartbrd)<<4) | (((sysclk/16)%uartbrd)/(uartbrd/16));
	USART1->CR1 = 0x0000200c;
}
