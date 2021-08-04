//INIT1403 JOB  (001),'INIT 1403',                                 
//             CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),REGION=128K            
//INIT   EXEC ASMFCG                                                    
//ASM.SYSUT1 DD UNIT=SYSDA                                              
//ASM.SYSUT2 DD UNIT=SYSDA                                              
//ASM.SYSUT3 DD UNIT=SYSDA                                              
//ASM.SYSGO DD UNIT=SYSDA
//ASM.SYSIN DD *                                                        
INIT1403 CSECT                                                          
         STM   14,12,12(13)                                             
         BALR  12,0                                                     
         USING *,12                                                     
         ST    13,SAVE+4                                                
         LA    13,SAVE                                                  
         OPEN  (OUTFLE,OUTPUT)                                          
         PUT   OUTFLE,RECORD                                            
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
RECORD   DC    CL133' INIT 1403'                                        
SAVE     DS    18F                                                      
         END                                                            
/*
//GO.OUTFLE DD UNIT=01E,UCS=AN  
//