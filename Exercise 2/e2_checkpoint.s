.data
 vector: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
.text
sumav:#push $R1 and $R2
 			adds $SP $SP -4
 			str $R1 ($SP)
      adds $SP $SP -4
 			str $R2 ($SP)
      #push $R7
      adds $SP $SP -4
      str $R7 ($SP)
		  #$R5 = sum of the vector elements
		  mov $R5 0
      
  b1: cmp $R0 $R1
  		beq f1
			ldr $R7 ($R2)
 			adds $R5 $R5 $R7
 			adds $R2 $R2 4
 			adds $R1 $R1 -1
      cmp $R9 $R9 #as we don't have b instruction, we compare two equal registers so we can now return to b1 using beq
 			beq b1
      
  f1: #pop SR7
 	    ldr $R2 ($SP)
  		adds $SP $SP 4
      #pop $R2 and $R1
      ldr $R2 ($SP)
      adds $SP $SP 4
      ldr $R1 ($SP)
      adds $SP $SP 4
 			#return
 			bx $LR
      
main: # call sumav function
 			mov $R1 10
 			mov $R2 vector
 			bl sumav
 			# halt execution
 			halt
begin
{
    fetch:          (T2, C0),
                    (TA, R, BW=11, M1=1, C1=1),
                    (M2, C2, T1, C3),
                    (A0, B=0, C=0)
}

mov RE1, U32 {
        co= 010010,
  			nwords=2,
				RE1=reg(20,16),
				U32=inm(63,32),        
        {
                #MAR<-PC
                (T2,C0),
                #MBR<-MM[MAR]
                (Ta, R, BW=11,M1,C1),
                #PC<-PC+4
                (M2,C2),
                #BR[R1]<-MBR
                (T1, SELC=10000, MR=0,LC=1),
          			#JUMP TO FETCH
                (A0=1, B=1, C=0)
        }
}
str RE1, (RE2) {
        co=010000,
        nwords=1,
        RE1=reg(26,21),
        RE2=reg(15,11)
        {				#MAR<-(RE2) 
        				(SELA=1011,MR=0,T9,C0),
                #MBR<-RE1
                (MR=0, SELA=10101,T9,C1),
                #Mem[MAR]<-MBR
                (Ta,Td,BW=11,W),
                #Jump to fetch                
                (A0=1, B=1, C=0)
        }
}
ldr RE1, (RE2) {
        co=010011,
        nwords=1,
        RE1=reg(25,21),
        RE2=reg(15,11)
        {				
            		#MAR<-R2
								(SelA=1011,MR=0,T9,C0),
								#MBR<-MM[MAR]
								(Ta,R,BW=11,M1,C1),
								#R1<-MBR
								(T1,Lc,SelC=10101),
								#Jump to fetch
          			(A0=1, B=1, C=0)
        }
}
adds RE1, RE2, RE3 {
        co=011000,
        nwords=1,
        RE1=reg(25,21),
  			RE2=reg(20,16),
        RE3=reg(15,11)
  			{				#R1<-R2+R3, update SR
        				(MR=0,SELA=10000,SELB=1011, MC, SelCop=1010, T6, SelC=10101, LC=1,SelP=11,M7,C7),
                #Jump to fetch
                (A0=1, B=1, C=0)
        }
}   
adds RE1, RE2, S16 {
        co=011010,
        nwords=1,
        RE1=reg(25,21),
  			RE2=reg(20,16),
        S16=inm(15,0)
  			{				#RT2<-IR[S16]
        				(OFFSET=0, Size=10000, SE, T3, C5),
          			#R1<-R2+RT2, update SR
        				(MR=0,SELA=10000, MB=01, MC, SelCop=1010, T6, SelC=10101, LC=1,SelP=11, M7, C7),
                #Jump to fetch
                (A0=1, B=1, C=0)
        }
}   
mvns RE1, RE2 {
        co=011011,
        nwords=1,
        RE1=reg(25,21),
        RE2=reg(15,11)  
        {
          			#BR[RE1] ← NOTbitwise BR[RE2]
                (SelA=1011,MR=0,MA=0,SelCop=0011,MC,T6,LC,SelC=10101,SelP=11,M7,C7)
                #Jump to fetch
                (A0=1, B=1, C=0)
        }
}   
cmp RE1, RE2 {
        co=010110,
        nwords=1,
        RE1=reg(25,21),
        RE2=reg(15,11)
        {				
          			#BR[RRE1] - BR[RRE2]
        				(SelA=10101,MR=0,SelB=01011,SelCop=1011,MC,SelP=11,M7,C7),
                #Jump to fetch
                (A0=1, B=1, C=0)
        }
}   
beq S16 {
        co=110100,
        nwords=1,
        S16=address(15,0)rel
        {				#IF (bit Z of APRSR==0,go to fetch):
        				(C=110,B=1,A0=0,MADDR=gotofetch),
 								#else:
                #RT1<- IR[S16]
                (OFFSET=0,Size=10000,SE,C4,T3),
                #RT2<-PC
                (T2,C5),
                #PC<-RT1+RT2
                (SelCop=1010,MC,MA=1,MB=01,T6,C2),
                #Jump to fetch
                (A0=1, B=1, C=0)
         				gotofetch: (A0=1,B=1,C=0)
        }
}  
bl U16 {#jal
        co=100001,
        nwords=1,
        U16=inm(15,0)
        {				#BR[LR] ← PC
        				(T2,LC,SelC=1110,MR=1),
								#PC ← U16
                (OFFSET=0,Size=10000,T3,C2),
                #Jump to fetch
                (A0=1, B=1, C=0)
        }
} 
bx RE {#jr $ra
        co=100010,
        nwords=1,
        RE=reg(20,16)
        {				#PC ← BR[RE]
        				(SelA=10101,MR=0,T9,C2),
        				#Jump to fetch
                (A0=1, B=1, C=0)
        }
} 
halt {
        co=100011,
        nwords=1,
        {				#PC<-0
         				(MR=1, SELA=00000, T9, M2=0, C2),
                #SR<-0
                (MR=1, SELB=00000, T10, M7=0, C7),
  							#Jump to fetch
  							(A0=1, B=1, C=0)        			
        }
}
nop {
        co=000001,
        nwords=1,
        {
                (A0=1, B=1, C=0)
        }
}   
registers
{				 0=($R0),
  			 1=($R1), #$a0
  			 2=($R2), #$a1
  			 3=($R3), #$a2
  			 4=($R4), #$a3
  			 5=($R5), #$v0
  			 6=($R6), #$v1
  			 7=($R7),
  			 8=($R8),
  			 9=($R9),
  			10=($R10),
  			11=($R11),
  			12=($R12),
  			13=($R13,$SP) (stack_pointer),
  			14=($R14,$LR)
}
