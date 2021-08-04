//TOGGLEL JOB  (001),'TOGGLE LED',                                 
//             CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),REGION=128K            
//INIT   EXEC ASMFCG                                                    
//ASM.SYSUT1 DD UNIT=SYSDA                                              
//ASM.SYSUT2 DD UNIT=SYSDA                                              
//ASM.SYSUT3 DD UNIT=SYSDA                                              
//ASM.SYSGO DD UNIT=SYSDA
//ASM.SYSIN DD *                                                        
TOGGLEL  CSECT                                                          
         STM   14,12,12(13)                                             
         BALR  12,0                                                     
         USING *,12                                                     
         ST    13,SAVE+4                                                
         LA    13,SAVE                                                  
         OPEN  (OUTFLE,OUTPUT)
* 
*        WRITE TO 1403 PRINTER 01E TO TURN LIGHT ON 
         MVC   RECORD+1(11),=CL12'TURN LED ON' 
         PUT   OUTFLE,RECORD
* 
*        WAIT 5 SECONDS
         STIMER WAIT,BINTVL=WAITTIME
* 
*        WRITE TO 1403 PRINTER 01E TO TURN LIGHT OFF 
         MVC   RECORD+1(12),=CL12'TURN LED OFF' 
         PUT   OUTFLE,RECORD                         
* 
         CLOSE (OUTFLE)                                                 
         L     13,SAVE+4                                                
         LM    14,12,12(13)                                             
         XR    15,15                                                    
         BR    14                                                       
OUTFLE   DCB   DDNAME=OUTFLE,                                          X
               DSORG=PS,                                               X
               MACRF=PM,                                               X
               BLKSIZE=133,                                            X
               LRECL=133,                                              X
               RECFM=F                                                  
RECORD   DC    CL133' '                                        
WAITTIME DC    F'500'
SAVE     DS    18F                                                      
         END                                                            
/*
//GO.OUTFLE DD UNIT=01E,UCS=AN  
//