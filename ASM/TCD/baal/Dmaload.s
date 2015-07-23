;DMA fast file loader ripped from Chaos Engine by DR.D of TCD


*	ON ENTRY:
*	A0 HOLDS FILENAME TO LOAD
*	A1 HOLDS LOAD ADDRESS


;	A0=NAME
;	A1=ADDRESS
;	BSR LOAD


TEST=0

	IFEQ	TEST
SUPER	PEA	0
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	LEA	FILE1(PC),A0
	LEA	BUFFER(PC),A1
	BSR	LOAD
	CLR.W	-(A7)
	TRAP	#1
	
	ENDC
		


	

LOAD  MOVEQ     #0,D0
      LEA       OTHER(PC),A2
      MOVEM.L   A0-A6/D1-D7,-(A7) 
      MOVE.L    D0,D6 
      MOVE.L    D1,D7 
      MOVEA.L   A0,A4 
      MOVEA.L   A1,A5 
      MOVEA.L   A2,A6 
      LEA       Z0031(PC),A0
      MOVE.L    A7,(A0) 
      BSR.S     Z0002 
      BSR.S     Z0005 
      TST.B     D6
      BNE.S     Z0000 
      BSR       Z0007 
      MOVE.L    D7,(A7) 
      BRA.S     Z0001 
Z0000:CMP.B     #5,D6 
      BNE.S     Z0001 
      MOVEQ     #0,D1 
      MOVEQ     #0,D2 
      MOVE.W    #-$8000,D3
      BSR       Z0030 
Z0001:MOVEA.L   Z0031(PC),A7
      MOVEM.L   (A7)+,A0-A6/D1-D7 
      RTS 
Z0002:CMPI.B    #$3A,1(A4)
      BNE.S     Z0004 
      MOVE.B    (A4)+,D0
      SUBQ.B    #1,D0 
      ANDI.B    #$F,D0
      LEA       Z0035(PC),A0
      MOVE.B    D0,(A0) 
Z0003:ADDQ.W    #1,A4 
      CMPI.B    #$5C,(A4) 
      BEQ.S     Z0003 
Z0004:RTS 
Z0005:MOVEQ     #0,D0 
      BSR       Z002D 
      LEA       Z0032(PC),A0
      MOVE.B    17(A6),D0 
      MOVE.L    D0,(A0)+
      MOVE.B    22(A6),D0 
      MOVE.L    D0,(A0)+
      MOVE.B    24(A6),D0 
      MOVE.W    D0,(A0)+
      MOVE.W    (A0),D0 
      BCLR      #3,D0 
      CMPI.B    #1,26(A6) 
      BEQ.S     Z0006 
      BSET      #3,D0 
Z0006:MOVE.W    D0,(A0)+
      MOVEQ     #0,D1 
      MOVE.B    20(A6),D1 
      LSL.W     #8,D1 
      MOVE.B    19(A6),D1 
      MOVEQ     #0,D0 
      BSR       Z0022 
      SUB.L     D0,D1 
      LSR.L     #1,D1 
      MOVE.L    D1,(A0)+
      RTS 
Z0007:BSR.S     Z000F 
      BNE.S     Z000E 
      MOVE.L    D2,D7 
      MOVE.L    D2,D4 
      MOVE.L    D1,D3 
Z0008:MOVE.L    D3,D0 
      BSR       Z0022 
      MOVE.L    D0,D1 
      MOVE.L    D3,D0 
      MOVEQ     #0,D2 
Z0009:BSR       Z0023 
      ADDQ.L    #2,D2 
      ADDQ.L    #1,D3 
      CMP.L     D0,D3 
      BEQ.S     Z0009 
      MOVE.L    D0,D3 
      MOVE.L    D4,D0 
      LSR.L     #8,D0 
      LSR.L     #1,D0 
      BEQ.S     Z000B 
      MOVEQ     #0,D5 
      CMP.L     D2,D0 
      BGE.S     Z000A 
      MOVE.L    D0,D2 
      MOVEQ     #-1,D5
Z000A:MOVEA.L   A5,A0 
      BSR       Z002E 
      ADD.L     D2,D1 
      MOVE.L    D2,D0 
      LSL.L     #8,D0 
      ADD.L     D0,D0 
      ADDA.L    D0,A5 
      SUB.L     D0,D4 
      BEQ.S     Z000D 
      TST.L     D5
      BEQ.S     Z0008 
Z000B:MOVE.L    D1,D0 
      BSR       Z002D 
Z000C:MOVE.B    (A6)+,(A5)+ 
      SUBQ.W    #1,D4 
      BNE.S     Z000C 
Z000D:MOVEQ     #0,D0 
Z000E:RTS 
Z000F:MOVE.L    A4,-(A7)
      MOVEQ     #0,D0 
      MOVEQ     #0,D1 
      MOVEQ     #0,D2 
      MOVEQ     #0,D3 
      MOVEQ     #0,D4 
      MOVE.L    Z0033(PC),D5
      ADD.L     D5,D5 
      ADDQ.L    #1,D5 
      MOVE.L    Z0032(PC),D6
      LSR.L     #4,D6 
      TST.B     (A4)
      BEQ       Z0018 
      BSR       Z0019 
      MOVE.L    D5,D1 
Z0010:MOVE.L    D1,D0 
      BSR       Z002D 
      BSR       Z002A 
      MOVEA.L   A6,A0 
      MOVEQ     #$F,D0
Z0011:BTST      #3,11(A0) 
      BNE.S     Z0015 
      MOVEA.L   A0,A1 
      LEA       Z0038(PC),A2
      MOVEQ     #$A,D2
Z0012:CMPM.B    (A1)+,(A2)+ 
      BNE.S     Z0013 
      DBF       D2,Z0012
      MOVE.L    D1,D3 
      MOVE.W    26(A0),D1 
      ROL.W     #8,D1 
      MOVE.L    28(A0),D2 
      ROL.W     #8,D2 
      SWAP      D2
      ROL.W     #8,D2 
      MOVEQ     #0,D4 
      MOVEQ     #0,D0 
      TST.B     (A4)
      BEQ.S     Z0018 
      BTST      #4,11(A0) 
      BEQ.S     Z0017 
      BSR.S     Z0019 
      MOVEQ     #0,D3 
      MOVE.L    D1,D4 
      MOVE.L    D1,D5 
      MOVE.L    D1,D0 
      BRA.S     Z0016 
Z0013:TST.B     (A0)
      BEQ.S     Z0014 
      CMPI.B    #-$1B,(A0)
      BNE.S     Z0015 
Z0014:TST.L     D3
      BNE.S     Z0015 
      MOVEA.L   A0,A3 
      MOVE.L    D1,D3 
Z0015:LEA       32(A0),A0 
      DBF       D0,Z0011
      ADDQ.L    #1,D1 
      SUBQ.L    #1,D6 
      BNE.S     Z0010 
      MOVE.L    D4,D0 
      BEQ.S     Z0017 
      BSR       Z0023 
Z0016:CMP.W     #$FFF,D0
      BEQ.S     Z0017 
      MOVE.L    D0,D4 
      BSR       Z0022 
      MOVE.L    D0,D1 
      MOVEQ     #2,D6 
      BRA       Z0010 
Z0017:MOVE.L    #$CC,D0 
      TST.B     (A4)
      BNE.S     Z0018 
      MOVEA.L   A3,A0 
      MOVEQ     #0,D1 
      MOVEQ     #0,D2 
      MOVE.L    #$CD,D0 
Z0018:MOVEA.L   (A7)+,A4
      RTS 
Z0019:MOVE.L    D1,-(A7)
      LEA       Z0038(PC),A0
      MOVEQ     #$A,D0
Z001A:MOVE.B    #$20,(A0)+
      DBF       D0,Z001A
      LEA       Z0038(PC),A0
      MOVEQ     #7,D1 
      BSR.S     Z001C 
      TST.B     D0
      BEQ.S     Z001B 
      CMP.B     #$2E,D0 
      BNE.S     Z001B 
      LEA       Z0039(PC),A0
      MOVEQ     #2,D1 
      BSR.S     Z001C 
Z001B:MOVE.L    (A7)+,D1
      RTS 
Z001C:MOVE.B    (A4),D0 
      BEQ.S     Z001D 
      ADDQ.W    #1,A4 
      BSR.S     Z001E 
      BEQ.S     Z001D 
      BSR.S     Z0020 
      MOVE.B    D0,(A0)+
      DBF       D1,Z001C
      MOVE.B    (A4),D0 
      BEQ.S     Z001D 
      BSR.S     Z001E 
      BNE.S     Z001D 
      ADDQ.W    #1,A4 
Z001D:RTS 
Z001E:TST.B     D0
      BEQ.S     Z001F 
      CMP.B     #$2E,D0 
      BEQ.S     Z001F 
      CMP.B     #$5C,D0 
Z001F:RTS 
Z0020:CMP.B     #$41,D0 
      BLT.S     Z0021 
      CMP.B     #$7A,D0 
      BGT.S     Z0021 
      ANDI.B    #-$21,D0
Z0021:RTS 
Z0022:MOVE.L    D1,-(A7)
      MOVE.L    Z0032(PC),D1
      LSR.L     #4,D1 
      ADD.L     Z0033(PC),D1
      ADD.L     Z0033(PC),D1
      SUBQ.L    #3,D1 
      ADD.L     D0,D0 
      ADD.L     D1,D0 
      MOVE.L    (A7)+,D1
      RTS 
Z0023:MOVEM.L   D1-D3,-(A7) 
      MOVE.L    D0,D3 
      BSR.S     Z0026 
      BSR       Z002B 
      MOVE.L    D1,D0 
      MOVE.B    0(A6,D0.W),D1 
      BSR.S     Z0028 
      MOVE.B    0(A6,D0.W),D2 
      BTST      #0,D3 
      BNE.S     Z0024 
      ANDI.W    #$FF,D1 
      ANDI.W    #$F,D2
      LSL.W     #8,D2 
      BRA.S     Z0025 
Z0024:ANDI.W    #$F0,D1 
      ANDI.W    #$FF,D2 
      LSL.W     #4,D2 
      LSR.W     #4,D1 
Z0025:OR.W      D2,D1 
      MOVEQ     #0,D0 
      MOVE.W    D1,D0 
      MOVEM.L   (A7)+,D1-D3 
      RTS 
Z0026:MOVE.L    D2,-(A7)
      MOVE.L    D0,D1 
      LSR.L     #1,D0 
      ADD.L     D1,D0 
      MOVE.L    D0,D1 
      ANDI.L    #$1FF,D1
      LSR.L     #8,D0 
      LSR.L     #1,D0 
      MOVE.L    Z0033(PC),D2
      CMP.B     #9,D2 
      BNE.S     Z0027 
      ADD.W     D2,D0 
Z0027:ADDQ.W    #1,D0 
      MOVE.L    (A7)+,D2
      RTS 
      LEA       Z0037(PC),A0
      MOVE.W    #-1,(A0)
Z0028:ADDQ.W    #1,D0 
      CMP.W     #$200,D0
      BLT.S     Z0029 
      MOVE.L    Z0036(PC),D0
      ADDQ.L    #1,D0 
      BSR.S     Z002B 
      MOVEQ     #0,D0 
Z0029:RTS 
Z002A:LEA       Z0036(PC),A0
      CLR.L     (A0)+ 
      CLR.W     (A0)
      RTS 
Z002B:MOVE.L    D1,-(A7)
      MOVE.L    Z0036(PC),D1
      CMP.L     D0,D1 
      BEQ.S     Z002C 
      BSR.S     Z002D 
      BSR.S     Z002D 
      LEA       Z0036(PC),A0
      MOVE.L    D0,(A0) 
Z002C:MOVE.L    (A7)+,D1
      RTS 
Z002D:MOVEM.L   A0/D0-D3,-(A7)
      MOVEQ     #0,D3 
      MOVE.L    D0,D1 
      BSR.S     Z002F 
      MOVEM.L   (A7)+,A0/D0-D3
      RTS 
Z002E:MOVE.L    D3,-(A7)
      MOVEQ     #0,D3 
      BSR.S     Z0030 
      MOVE.L    (A7)+,D3
      RTS 
Z002F:MOVEQ     #1,D2 
      MOVEA.L   A6,A0 
Z0030:MOVE.L    Z0034(PC),D0
      BSR.S     Z003A 
      BNE       Z0001 
      RTS 
Z0031:DS.W      2 
Z0032:DS.W      2 
Z0033:DS.W      2 
Z0034:DC.B      $00,$00,$00 
Z0035:DC.B      $00,$00,$00,$00,$00 
Z0036:DS.W      2 
Z0037:DC.B      $00,$00 
Z0038:DS.W      4 
Z0039:DS.W      2 
Z003A:MOVEM.L   A0-A1/D1-D4,-(A7) 
      LINK      A6,#-$1E
      MOVE.L    D0,D4 
      ANDI.W    #1,D0 
      MOVE.W    D0,-28(A6)
      SWAP      D0
      CMP.W     #9,D0 
      BLT.S     Z003B 
      CMP.W     #$B,D0
      BLE.S     Z003C 
Z003B:MOVE.W    #$A,D0
Z003C:MOVE.W    D0,-30(A6)
      MOVE.W    D1,-22(A6)
      MOVE.W    D2,-18(A6)
      MOVE.W    D3,-8(A6) 
      MOVE.L    A0,-12(A6)
      ROR.L     #3,D4 
      ANDI.W    #1,D4 
      EORI.B    #1,D4 
      ADDQ.B    #1,D4 
      MOVE.W    D4,-16(A6)
      CLR.W     D4
      ROL.L     #1,D4 
      MOVE.W    D4,-14(A6)
      MOVEQ     #$15,D0 
      ADD.W     D1,D2 
      MOVE.W    -30(A6),D3
      MULU      #$A0,D3 
      CMP.W     D3,D2 
      BGT       Z0041 
      EXT.L     D1
      DIVU      -30(A6),D1
      CMPI.W    #1,-16(A6)
      BEQ.S     Z003D 
      ADD.W     D1,D1 
Z003D:MOVE.W    D1,-26(A6)
      SWAP      D1
      ADDQ.W    #1,D1 
      MOVE.W    D1,-24(A6)
      BSR       Z0051 
Z003E:MOVE.W    -24(A6),D0
      MOVE.W    -30(A6),D1
      ADDQ.W    #1,D1 
      SUB.W     D0,D1 
      CMP.W     -18(A6),D1
      BLE.S     Z003F 
      MOVE.W    -18(A6),D1
Z003F:MOVE.W    D1,-20(A6)
      BSR.S     Z0042 
      BNE.S     Z0040 
      MOVE.W    -18(A6),D0
      SUB.W     -20(A6),D0
      BEQ.S     Z0040 
      MOVE.W    D0,-18(A6)
      MOVE.W    #1,-24(A6)
      MOVE.W    -16(A6),D0
      ADD.W     D0,-26(A6)
      MOVE.W    -20(A6),D0
      LSL.L     #8,D0 
      ADD.L     D0,D0 
      ADD.L     D0,-12(A6)
      BRA.S     Z003E 
Z0040:MOVE.L    D0,D1 
      BEQ.S     Z0041 
      ANDI.B    #$58,D0 
      MOVEQ     #$1C,D1 
      CMP.B     #$40,D0 
      BEQ.S     Z0041 
      MOVEQ     #$19,D1 
      CMP.B     #8,D0 
      BEQ.S     Z0041 
      MOVEQ     #$18,D1 
      CMP.B     #$18,D0 
      BEQ.S     Z0041 
      MOVEQ     #$15,D1 
      CMP.B     #$10,D0 
      BEQ.S     Z0041 
      MOVEQ     #-1,D1
Z0041:BSR       Z0053 
      UNLK      A6
      MOVE.L    D1,D0 
      MOVEM.L   (A7)+,A0-A1/D1-D4 
      RTS 
Z0042:BSR       Z0055 
      MOVE.W    #2,D3 
      BRA.S     Z0044 
Z0043:CMP.B     #$10,D0 
      BNE.S     Z0045 
      BSR       Z004F 
Z0044:MOVE.W    -26(A6),D0
      LSR.W     #1,D0 
      BSR       Z004D 
Z0045:MOVEA.L   -12(A6),A0
      MOVE.W    -24(A6),D1
      MOVE.W    -20(A6),D2
      BSR.S     Z0047 
      TST.W     D0
      BEQ.S     Z0046 
      CMP.B     #$40,D0 
      DBEQ      D3,Z0043
      TST.W     D0
Z0046:RTS 
Z0047:BSR       Z004C 
      MOVE.W    #$90,-$79FA.W
      MOVE.W    #$190,-$79FA.W
      MOVE.W    #$90,-$79FA.W 
      MOVEQ     #0,D0 
      MOVE.W    D2,D0 
      BSR       Z0060 
      LSL.L     #8,D0 
      ADD.L     D0,D0 
      MOVEA.L   A0,A1 
      ADDA.L    D0,A1 
      MOVE.W    #$80,-$79FA.W 
      MOVE.W    #$90,D0 
      BSR       Z0060 
      MOVE.L    #$40000,D0
      CLR.L     -4(A6)
Z0048:BTST      #5,-$5FF.W
      BEQ.S     Z0049 
      SUBQ.L    #1,D0 
      BEQ.S     Z004A 
      MOVE.B    -$79F7.W,-3(A6) 
      MOVE.B    -$79F5.W,-2(A6) 
      MOVE.B    -$79F3.W,-1(A6) 
      CMPA.L    -4(A6),A1 
      BGT.S     Z0048 
      BSR       Z005D 
Z0049:MOVE.W    #$90,-$79FA.W 
      MOVE.W    -$79FA.W,D0 
      BTST      #0,D0 
      BEQ.S     Z004B 
      BSR       Z005E 
      ANDI.B    #$18,D0 
      RTS 
Z004A:BSR       Z005D 
Z004B:MOVEQ     #-1,D0
      RTS 
Z004C:MOVE.L    A0,D0 
      MOVE.B    D0,-$79F3.W 
      LSR.L     #8,D0 
      MOVE.B    D0,-$79F5.W 
      LSR.L     #8,D0 
      MOVE.B    D0,-$79F7.W 
      MOVE.W    #$84,-$79FA.W 
      MOVE.W    D1,D0 
      BRA       Z0060 
Z004D:TST.W     D0
      BEQ.S     Z004F 
      MOVE.W    #$86,-$79FA.W 
      BSR       Z0060 
      MOVE.W    #$10,D0 
      BSR       Z005A 
      BMI.S     Z004E 
      MOVEQ     #0,D0 
Z004E:RTS 
Z004F:MOVEQ     #0,D0 
      BSR       Z005A 
      BMI.S     Z0050 
      EORI.B    #4,D0 
      BTST      #2,D0 
      BNE.S     Z0050 
      MOVEQ     #0,D0 
Z0050:RTS 
Z0051:MOVE.W    $43E.W,-6(A6) 
      ST        $43E.W
      BSR.S     Z0055 
      MOVE.W    -28(A6),D0
      ADD.W     D0,D0 
      MOVE.W    #$82,-$79FA.W 
      LEA       ZUEND+0(PC),A0
      MOVE.W    0(A0,D0.W),D0 
      LSR.W     #1,D0 
      BSR       Z0060 
      CMP.W     #$A0,D0 
      BLT.S     Z0052 
      BSR.S     Z004F 
Z0052:RTS 
Z0053:MOVEM.L   D0-D1,-(A7) 
      MOVE.W    -28(A6),D0
      ADD.W     D0,D0 
      LEA       ZUEND+0(PC),A0
      MOVE.W    -26(A6),D1
      MOVE.W    D1,0(A0,D0.W) 
      TST.W     -8(A6)
      BPL.S     Z0054 
      MOVE.L    #$C3500,D0
      BSR       Z0062 
Z0054:MOVEQ     #7,D0 
      BSR.S     Z0059 
      MOVE.W    -6(A6),$43E.W 
      MOVEM.L   (A7)+,D0-D1 
      RTS 
Z0055:MOVE.W    D0,-(A7)
      MOVE.W    -28(A6),D0
      ANDI.W    #1,D0 
      ADDQ.B    #1,D0 
      ADD.B     D0,D0 
      MOVE.W    D0,-(A7)
      BSR.S     Z0056 
      OR.W      (A7)+,D0
      EORI.B    #7,D0 
      ANDI.B    #7,D0 
      BSR.S     Z0059 
      MOVE.W    (A7)+,D0
      RTS 
Z0056:MOVE.W    -16(A6),D0
      CMP.W     #1,D0 
      BEQ.S     Z0057 
      MOVE.W    -14(A6),D0
      BRA.S     Z0058 
Z0057:MOVE.W    -26(A6),D0
      ANDI.W    #1,D0 
Z0058:RTS 
Z0059:MOVE      SR,-(A7)
      ORI.W     #$700,SR
      MOVE.B    #$E,-$7800.W
      MOVE.B    -$7800.W,D1 
      ANDI.B    #-8,D1
      OR.B      D0,D1 
      MOVE.B    D1,-$77FE.W 
      MOVE      (A7)+,SR
      RTS 
Z005A:CMP.B     #-$80,D0
      BCC.S     Z005B 
      ORI.B     #3,D0 
Z005B:MOVE.W    #$80,-$79FA.W 
      BSR.S     Z0060 
      MOVE.L    #$60000,D0
Z005C:BTST      #5,-$5FF.W
      BEQ.S     Z005E 
      SUBQ.L    #1,D0 
      BNE.S     Z005C 
      BSR.S     Z005D 
      MOVEQ     #-1,D0
      RTS 
Z005D:MOVE.W    #$80,-$79FA.W 
      MOVE.W    #$D0,D0 
      BSR.S     Z0060 
      MOVEQ     #$F,D0
      BSR.S     Z0062 
      BRA.S     Z005E 
      MOVE.W    #$180,-$79FA.W
      BRA.S     Z005F 
Z005E:MOVE.W    #$80,-$79FA.W 
Z005F:BSR.S     Z0061 
      MOVE.W    -$79FC.W,D0 
      ANDI.L    #$FF,D0 
      BRA.S     Z0061 
Z0060:BSR.S     Z0061 
      MOVE.W    D0,-$79FC.W 
Z0061:MOVE      SR,-(A7)
      MOVE.W    D0,-(A7)
      MOVEQ     #$18,D0 
      BSR.S     Z0062 
      MOVE.W    (A7)+,D0
      MOVE      (A7)+,SR
      RTS 
Z0062:	SUBQ.L	#1,D0
	BNE	Z0062
	RTS




ERROR	MOVE.L	#-1,D0
	RTS

	EVEN

	DATA

	IFEQ	TEST
FILE1	DC.B	"DMALOAD.S",0
	EVEN
	ENDC	

	
	BSS

OTHER	DS.B	2000

BUFFER

ZUEND

