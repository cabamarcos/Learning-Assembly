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
        RE1=reg(26,21),#MBR
        RE2=reg(15,11)#MAR
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
