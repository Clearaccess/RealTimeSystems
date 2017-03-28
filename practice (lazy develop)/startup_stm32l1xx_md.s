Stack_Size      EQU     0x00000400

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp
Varlr			DCD 0
				ALIGN

                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset
                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
					SPACE 0xA8
					DCD TIM2_Handler
__Vectors_End

__Vectors_Size  EQU  __Vectors_End - __Vectors

                AREA    |.text|, CODE, READONLY



; Reset handler routine
Reset_Handler    PROC
                 EXPORT  Reset_Handler             [WEAK]
			     IMPORT OSinit
					;ldiscovery
					
					
					
					
					;Init usart
					;RCC A-port
					 LDR R0,=0x40023800
					 LDR R1,[R0,#0x1c]
					 LDR R2,=0x00000001
					 ORR R1,R2
					 STR R1,[R0,#0x1c]
					
					; GPIO _moder A-port
					 LDR R0,=0x40020000
					 LDR R1,[R0,#0x00]
					 LDR R2,=0x00280000
					 ORR R1,R2
					 STR R1,[R0,#0x00]
					 
					 	; GPIOx_AFRH
					 LDR R0,=0x40020000
					LDR R1,[R0,#0x24]
					LDR R2,=0x00000770
					ORR R1,R2
					STR R1,[R0,#0x24]
					
					
					 LDR R3,=250000
					 LDR R0,=0x40023800
					 LDR R1,[R0,#0x1c]
					 LDR R2,=0x00000002
					 ORR R1,R2
					 STR R1,[R0,#0x1c]
						
					 ;RCC_ ...EN...
					 LDR R0,=0x40023800
					 LDR R1,[R0,#0x24]
					 LDR R2,=0x00000001
					 ORR R1,R2
					 STR R1,[R0,#0x24]
					 ;TIMx_CNT
					 LDR R0,=0x40000000
					 LDR R1,[R0,#0x24]
					 LDR R2,=0
					 ORR R1,R2
					 STR R1,[R0,#0x24]
					 ;TIMx_ARR
					 LDR R0,=0x40000000
					 LDR R1,[R0,#0x2C]
					 LDR R2,=1000
					 ORR R1,R2
					 STR R1,[R0,#0x2C]
					 ;TIMx_CR1
					 ;LDR R0,=0x40000000
					 ;LDR R1,[R0,#0x00]
					 ;LDR R2,=0x00000001
					 ;ORR R1,R2
					 ;STR R1,[R0,#0x00]
					 ;TIMx_PSC
					 LDR R0,=0x40000000
					 LDR R1,[R0,#0x28]
					 LDR R2,=50
					 ORR R1,R2
					 STR R1,[R0,#0x28]
					 ;TIMx_DIER
					 LDR R0,=0x40000000
					 LDR R1,[R0,#0x0C]
					 LDR R2,=0x00000001
					 ORR R1,R2
					 STR R1,[R0,#0x0C]
					 ;NVIC_ISER
					 LDR R0,=0xE000E100
					 LDR R1,[R0,#0x00]
					 LDR R2,=0x10000000
					 ORR R1,R2
					 STR R1,[R0,#0x00]
					 
					 ;#1 GPIO _moder
					 LDR R0,=0x40020400
					 LDR R1,[R0,#0x00]
					 LDR R2,=0x00004000
					 ORR R1,R2
					 STR R1,[R0,#0x00]
					 
					 ;#2 GPIO _moder
					 LDR R0,=0x40020400
					 LDR R1,[R0,#0x00]
					 LDR R2,=0x00001000
					 ORR R1,R2
					 STR R1,[R0,#0x00]
					 
					 LDR R0,=OSinit
					 BLX R0
					
enable	
					 ;#1 GPIO _odr
					 ;LDR R0,=0x40020400
					 ;LDR R1,[R0,#0x14]
					 ;LDR R2,=0x00000080
					 ;ORR R1,R2
					 ;STR R1,[R0,#0x14]
					 
					 ;#1 delete GPIO _odr
					 ;LDR R0,=0x40020400
					 ;LDR R1,[R0,#0x14]
					 ;LDR R2,=~0x00000080
					 ;AND R1,R2
					 ;STR R1,[R0,#0x14]
					 
					 ;#1 GPIO _odr part 1
					 LDR R0,=0x40020400
					 cpsid i
					 LDR R1,[R0,#0x14]
					 LDR R2,=0x00000080
cmp1				 ADD R4,#0x00000001
					 CMP R4,R3
					 BNE cmp1
					 LDR R4,=0x00000000	
					 
					 ;#1 GPIO _odr part 2
					 EOR R1,R2
					 STR R1,[R0,#0x14]
					 cpsie i
					 
cmp2				 ADD R4,#0x00000001
					 CMP R4,R3
					 BNE cmp2
					 LDR R4,=0x00000000
					 B enable
                 ENDP
TIM2_Handler    PROC		
					 IMPORT OSkernel
					 ;сохраняем LR которое меняется в OSkernel
					 MOV R0, LR
					 LDR R1, =Varlr 
					 STR R0, [r1]
				     BL OSkernel
					 ;TIMx_SR
					 LDR R0,=0x40000000
					 LDR R1,[R0,#0x10]
					 LDR R2,=~0x00000001
					 AND R1,R2
					 STR R1,[R0,#0x10]
					 ;востанавливаем значение LR
					 LDR R1, =Varlr 
					 LDR R0, [r1]
					 MOV LR, R0
	BX LR
	ENDP
		
SaveContext PROC
			EXPORT SaveContext
			;Save PSW from task[i] stack to context[i] 
			LDR R1,[SP,#0x24]
			STR R1,[R0,#0x40]
			;Save PC from task[i] stack to context[i] 
			LDR R1,[SP,#0x20]
			STR R1,[R0,#0x34]
			;Save LR from task[i] stack to context[i]
			LDR R1,[SP,#0x1C]
			STR R1,[R0,#0x38]
			;Save R12 from task[i] stack to context[i]
			LDR R1,[SP,#0x18]
			STR R1,[R0,#0x30]
			;Save R3 from task[i] stack to context[i]
			LDR R1,[SP,#0x14]
			STR R1,[R0,#0x0C]
			;Save R2 from task[i] stack to context[i]
			LDR R1,[SP,#0x10]
			STR R1,[R0,#0x08]
			;Save R1 from task[i] stack to context[i]
			LDR R1,[SP,#0x0c]
			STR R1,[R0,#0x04]
			;Save R0 from task[i] stack to context[i]
			LDR R1,[SP,#0x08]
			STR R1,[R0,#0x00]
			;Save R4 from current context to context[i]
			STR R4,[R0,#0x10]
			;Save R5 from current context to context[i]
			STR R5,[R0,#0x14]
			;Save R6 from current context to context[i]
			STR R6,[R0,#0x18]
			;Save R7 from current context to context[i]
			STR R7,[R0,#0x1C]
			;Save R8 from current context to context[i]
			STR R8,[R0,#0x20]
			;Save R9 from current context to context[i]
			STR R9,[R0,#0x24]
			;Save R10 from current context to context[i]
			STR R10,[R0,#0x28]
			;Save R11 from current context to context[i]
			STR R11,[R0,#0x2C]
			;Save SP from current context to context[i]
			STR SP,[R0,#0x3C]
	BX LR
	ENDP
			
RestoreContext PROC
			EXPORT RestoreContext
			;First stack item
			LDR R7,[SP,#0x00]
			;Second stack item
			LDR R8,[SP,#0x04]
			
			;Restore SP
			LDR SP,[R0,#0x3C]
			
			;Load first value in new stack
			STR R7,[SP,#0x00]
			;Load second value in new stack
			STR R8,[SP,#0x04]
			
			;Restore R11
			LDR R11,[R0,#0x2C]
			
			;Restore R10
			LDR R10,[R0,#0x28]
			
			;Restore R9
			LDR R9,[R0,#0x24]
			
			;Restore R8
			LDR R8,[R0,#0x20]
			
			;Restore R7
			LDR R7,[R0,#0x1C]
			
			;Restore R6
			LDR R6,[R0,#0x18]
			
			;Restore R5
			LDR R5,[R0,#0x14]
			
			;Restore R4
			LDR R4,[R0,#0x10]
			
			;Restore R0
			LDR R1,[R0,#0x00]
			STR R1,[SP,#0x08]
			
			;Restore R1
			LDR R1,[R0,#0x04]
			STR R1,[SP,#0x0c]
			
			;Restore R2
			LDR R1,[R0,#0x08]
			STR R1,[SP,#0x10]
			
			;Restore R3
			LDR R1,[R0,#0x0C]
			STR R1,[SP,#0x14]
			
			;Restore R12
			LDR R1,[R0,#0x30]
			STR R1,[SP,#0x18]
			
			;Restore LR
			LDR R1,[R0,#0x38]
			STR R1,[SP,#0x1C]
			
			;Restore PC
			LDR R1,[R0,#0x34]
			STR R1,[SP,#0x20]
			
			;Restore PSW
			LDR R1,[R0,#0x40]
			STR R1,[SP,#0x24]
			
			BX LR
			ENDP

            ALIGN
            END

;************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE*****
