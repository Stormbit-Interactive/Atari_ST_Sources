
*****************************************************************************
**************************    D S P - P A U L A    **************************
****************  coded by Chris of AURA of the INDEPENDENT  ****************
***********************   DSP-Realtime Paula V2.4   *************************
******************************** SSI-Version ********************************
***********************  AMIGA-Proplayer V3.0B-CIA  *************************
************************  first code  :  14.04.93  **************************
************************  last changes:  20.02.94  **************************
*****************************************************************************
************************** about 90-95% CPU free ****************************
************************** about 80-90% DSP free ****************************
****************  thanx to bITmASTER and Questor of Inter  ******************
************************** for the SSI-Information **************************
*****************************************************************************
;Hinweise zum DSP-Coding mit der DSP-Paula:
;------------------------------------------

;- r7/m7 werden f�r den SSI-IRQ ben�tigt, sonst sind alle Register frei
;- Host-Command 1 ist belegt
;- P-Speicher $1F94 bis $4000 ist von der DSP-Paula belegt
;- w�hrend und nach der Ausf�hrung des Hostcommands ist der SSI-IRQ aktiv
;  und mu� laufende Programme unterbrechen k�nnen. Der SSI-IRQ ben�tigt
;  aber nur 6 Tz, somit ist er keine gro�e Bremse.

;Hinweise zum MC-Coding:
;------------------------------------------
;- der Code ist nur an den zeitkritischen Stellen optimiert, also nicht
;  schimpfen.
;- programmiert mit dem EasyAss 4.0L.
;
;1. Bra.w: Initialisierung (von CODEC, Timer-A, ProPlayer und DSP-PAULA)
;          d0.w: PCM-Prescalewert von 1-5 und 7
;		   d1.w:  0: ADS nicht installieren (schon installiert)
;                -1: ADS installieren, d.h. DSP f�r Paula vorbereiten
;          a0.l: Moduladresse
;          a1.l: Adr. des Timer-A-IRQs
;2. Bra.w: Paula-Emulation + ProPlayer 3.0B-CIA-Einsprungadr.
;          (immer in den Timer A setzen)
;3. Bra.w: Deinstallation (von CODEC und Timer-A)
;+12.w   : Main-Voice: zw. $0000(leise) und $ffff(laut)
;+14.w   : Offset in Bytes zu den Paula-Registern
;Aufbau der Paularegister:
;	DFF0A0:				dc.l $00000000	;Amiga:Adressregister �� Audio-Kanal 1 ��
;	DFF0A4:				dc.w $0000		;Amiga:Sample-L�nge
;	DFF0A6:				dc.w $0000		;Amiga:Abtastfrequenz
;	DFF0A8:				dc.w $0000		;Amiga:Lautst�rke
;	DFF0AA:				ds.w 3			;Interne Informationen
; dasselbe in dieser Reihenfolge f�r DFF0B0,DFF0C0,DFF0D0. 


;
;Hinweise zur Installation:
;Die Paula l�uft nun im Timer und kann somit mit dem Blitter ins Gehege
;kommen. Der Blitter belegt je nach dem zu viel Buszyklen, soda� er den 
;Timer-A zu sp�t ausgel�st werden kann. Die Folge w�hre ein Knacksen, das
;nicht zu verhindern ist, da der DSP die neuen Sampledaten ben�tigt, aber 
;nicht rechtzeitig erh�lt.

;weitere Hinweise:
;die Proplayer und DSP-Paula-Routine rettet alle notwendigen Register!!

	org $0
	mc68030
	TEXT
BASE5:
paula_start:
 		bra.w	ap_grand_init			;Installation 
		bra.w	ap_dsp_paula_do			;Paula samt ProPlayer ausf�hren
		bra.w	ap_small_deinit			;Deinstallation		
main_voice:		dc.w	$ffff			;Hauptlautst�rke 16 Bit (0-$ffff)
paula_regs:		dc.w	DFF0A0-paula_start

	even
***************************************************************************
;Schnittstelle zwischen Player und DSP-Paula
;vor jedem Player-Aufruf anspringen
***************************************************************************
	TEXT
ap_dsp_paula_do:
		movem.l	d0-a6,-(sp)
		lea		BASE5(pc),a5			;Basisadr. in a5 setzen

		movec	cacr,d0					;CACR holen
		move.w	d0,cacr_rett(a5)		;retten
		lea		$ffffa200.w,a1			;DSP-Basisadr.
		lea		6(a1),a3

		moveq	#0,d0
		move.w	ap_mfp_timerwert(a5),d0	;neuer MFP-Timerwert holen
;		move.b	d0,$fffffa1f.w			;und gleich setzen
;										;ist ab n�chten IRQ aktiv (WICHTIG!!)
		move.w	(ap_mfp_bytes.w,pc,d0*2),d0	;Anzahl Bytes zur Berechnung holen

ap_wait_to_command:
;		btst	#3,2(a1)				;HF2-Bit zum Testen ob DSP-Paula 
;		beq.s	ap_wait_to_command		;bereit ist
;		move.l	d0,4(a1) 				;zu berechnende Bytes �bergeben

		lea		DFF0A0(a5),a0			;Stimme 1 Basisadr.
		moveq	#0,d1					;DMA-Bit 0
		bsr.s	ap_compute_voice
		lea		DFF0B0(a5),a0			;Stimme 2 Basisadr.
		moveq	#1,d1					;DMA-Bit 1
		bsr.s	ap_compute_voice
		lea		DFF0C0(a5),a0			;Stimme 3 Basisadr.
		moveq	#2,d1					;DMA-Bit 2
		bsr.s	ap_compute_voice
		lea		DFF0D0(a5),a0			;Stimme 4 Basisadr.
		moveq	#3,d1					;DMA-Bit 3
		bsr.s	ap_compute_voice

		bsr		ap_playmusic			;Proplayer anspringen
;!! a5 zerst�rt !!
		move.w	cacr_rett(pc),d0
		movec	d0,cacr					;CACR zur�cksetzen
		movem.l	(sp)+,d0-a6
		rts



		
ap_compute_voice:
		btst	d1,DFF096+1(a5)			;DMA-Bit an?
		beq.s	ap_compute_dum_sample	;an >> Sample abarbeiten
ap_no_new_sample:
		move.l	(a0),a2					;akt. Sampleadr. holen
		moveq	#0,d0
		move.w	4(a0),d0				;akt. Samplel�nge holen
		move.w	6(a0),d1				;Periode holen
		move.w	8(a0),d2				;Lautst�rke holen
		cmp.w	#1,d0					;Samplel�nge<=1
		bhi.s	ap_go_samplecopy
		move.l	10(a0),a2				;Loopadresse holen holen
		move.w	14(a0),d0				;Loopl�nge holen
		cmp.w	#1,d0					;Loopsamplel�nge <=1
		bhi.s	ap_go_samplecopy
ap_compute_dum_sample:
;Leersample einrichten um �bertragungszeit zu sparen
		lea		ap_dum_sample(a5),a2	;Leersampleadr.
		moveq	#1,d0					;Samplel�nge = 1 Wort
		move.w	#79,d1					;Sonderperiode
		moveq	#0,d2					;Lautst�rke 0
		move.w	d1,6(a0)				;Periode speichern
		move.w	d2,8(a0)				;Lautst�rke speichern
		move.l	a2,10(a0)				;Loopsampleadr. setzen
		move.w	d0,14(a0)				;Loopsamplel�nge auch = 1
ap_go_samplecopy:
		mulu.w	main_voice(a5),d2		;*frakt. Hauptlautst�rke
		swap	d2						;ganzzahliger Wert holen 

		move.l	(ap_vol_tab.w,PC,d2.w*4),4(a1) ;Lautst�rkewert in den DSP
		move.l	(ap_freq_tab-79*8.w,PC,d1.w*8),4(a1) ;ganzzahliger Offset an den DSP
		move.l	(ap_freq_tab+4-79*8.w,PC,d1.w*8),4(a1) ;fraktionaler Offset an den DSP
		moveq	#0,d7
ap_wait_for_dspwords:
		btst	#0,2(a1)				;Auf Antwort warten
		beq.s	ap_wait_for_dspwords
		move.w	(a3),d7					;Anzahl zu �bertr. Worte holen
		clr.b	5(a1)					;oberstes Byte reinigen
;ECHTZEIT-PAULA-Emulation
;d7.l: Anzahl der zu kopierenden Worte
;a2.l: akt. Sampleadresse
;d0.l: akt. Samplel�nge
ap_ploop_realtimepaula:
		tst.w	d7						;Anzahl = 0?
		beq		ap_pcopied_all_sample
		cmp.w	#1,d0					;Samplel�nge<=1?
		bhi.s	ap_pcopy_no_leersample

;** Samplel�nge <=1 >> Loopregister �berpr�fen **
		move.l	10(a0),a2				;neue Sampleadr. holen
		move.w	14(a0),d0				;neue Samplel�nge holen
		cmp.w	#1,d0					;auch Samplel�nge<=1?
		bhi.s	ap_pcopy_no_leersample
;** kein Loop >> restliche Leersampleworte �bertragen **
		moveq	#1,d0					;1 Samplewort �bertragen
		move.w	(a2),d1					;Samplewort holen
ap_pcopy_rest_leersample:
		nop								;Wartezyklen
		nop
		move.w	d1,(a3)					;Leersample kopieren
		subq.w	#1,d7
		bne.s	ap_pcopy_rest_leersample
		bra		ap_pcopied_all_sample	;Raussprung

;** Sampleworte �bertragen **
ap_pcopy_no_leersample:
		move.l	d7,d6
		cmp.l	d0,d6					;zu �bertr. Worte > Sampleworte?
		blt.s	ap_pcopy_all_sample
		move.l	d0,d6					;nur Sampleanzahl kopieren
ap_pcopy_all_sample:
		sub.l	d6,d0					;neue Samplel�nge
		sub.l	d6,d7					;neue Kopieranzahl

		move.w	d6,d1
		and.w	#$1f,d1
		asr.w	#5,d6					;/32
		lea		(ap_pcopy_samplerest.w,PC,d1.w*2),a4	;RTS-Adr. bestimmen
		move.w	#$4e75,(a4)				;RTS setzen
		move.w	#$3919,d2				;Instruktionscache
		movec	d2,cacr             	;l�schen
		bsr.s	ap_pcopy_sample
		move.w	#$369a,(a4)				;move.w (a2)+,(a3) setzen
		
		bra		ap_ploop_realtimepaula
ap_pcopied_all_sample:
;ECHTZEIT-Paula-Emulation *ENDE*
		move.l	a2,(a0)					;neue Sampleadr. speichern
		move.w	d0,4(a0)				;neue Samplel�nge speichern		
		rts

;Sample wird kopiert
ap_pcopy_sample:
		tst.w	d6
		beq		ap_pcopy_samplerest		;=0 >> keine 32er-Bl�cke kopieren
		REPEAT
		move.w	(a2)+,(a3)
		UNTIL #31
		subq.w	#1,d6					;32 Worte auf einmal kopieren
		bne		ap_pcopy_sample
ap_pcopy_samplerest
		REPEAT 
		move.w	(a2)+,(a3)				;Restsample kopieren
		UNTIL #31
		rts

*****************************************************************************
;Hauptinstallation des Players
*****************************************************************************
;a0.l: Moduladr.
;a1.l: Timer-A-IRQ-Adr. bei d2=-1
;d0.w: Prescalewert (1-5/7)
;d1.w: =0 keine DSP-Installierung

ap_grand_init:
		movem.l	d0-a6,-(sp)
		lea		BASE5(pc),a5			;Basisadr. in a5
		move.l	a0,a6

		moveq	#0,d1
		move.w	(ap_sampling_tab-2.w,PC,d0.w*2),d1	;Abspielfrequenz holen
		move.l	d1,ap_play_rate(a5)		;und speichern
*****************************************************************************
;Berechnung	der	Frequenztabelle
ap_calc_freq:
		lea		ap_freq_tab(a5),a2		;Frequenztabelle
		clr.l	(a2)+					;Periode 79 >> Leersample
		clr.l	(a2)+                   ;Offset auf 0

		moveq	#80,d7					;mit Periode 80 beginnen
ap_calc_freq_do:
		move.l	#3579546,d2				;Halbe Taktfrequenz	des	Amigas
		divu.l	d7,d2					;/Paula-Timerwert>>	Spielfrequenz
		move.l	d2,d3
		lsr		#8,d2					;oberes	Byte ins untere
		swap	d3						;mittleres Byte
		lsl.l	#8,d3					;ins oberste >>	d2:	Highbyte
										;				d3:	Lowbyte
		divu.l	ap_play_rate(a5),d2:d3	;64-Bit/32-Bit
		move.l	d3,d2
		rol.l	#8,d2					;Highbyte holen	>> Vorkommawert
		and.l	#$ff,d2
		move.l	d2,(a2)+				;Vorkommawert speichern
		and.l	#$00ffffff,d3			;Nachkommawert in 24-Bit holen
		move.l	d3,(a2)+				;und speichern
		rol.l	#8,d3
		addq.w	#1,d7					;Periode erh�hen
		cmp.w	#907+1,d7
		bne.s	ap_calc_freq_do
*****************************************************************************
;Volumeberechnung
ap_calc_vol:
		lea		ap_vol_tab(a5),a2		;Volumetabelle
		moveq	#65-1,d7				;noch 64 Volume-Abstufungen
		moveq	#64,d5					;mit Lautst�rkewert 1 beginnen
		move.l	#$8000/2,d6				;0.99999/2 auf 16 Bit
ap_calc_vol_host:
		divu.l	d5,d6                   ;/Lautst�rkeskala (64 Stufen)
		moveq	#0,d5
ap_calc_vol_do:
       	move.l  d5,(a2)+				;Lautst�rkewert als Kommawert
       	add.l	d6,d5
       	dbra	d7,ap_calc_vol_do
*****************************************************************************
		lea		ap_mfp_bytes(a5),a2		;Pufferadresse
		move.w	#1,d0					;mit MFP-Z�hler=1 beginnen

ap_calc_mfp_bytes:		
		move.l	#12288*100,d1			;2457600/200 Tz des MFP
		divu	d0,d1					;/MFP-Z�hlerwert
		move.l	ap_play_rate(a5),d2		;Abspielrate holen
		mulu	#100,d2					;*100		
		divu	d1,d2					;Abspielrate/Timerzeit
;		addq.w	#3,d2					;+4 bytes
		move.w	d2,(a2)+				;Byteanzahl zw. Timeraufruf speichern
		addq.w	#1,d0
		cmp.w	#256+1,d0				;256 erreicht?
		bne		ap_calc_mfp_bytes

*****************************************************************************
		pea		(a1)
		bsr		ap_mod_init				;Modul installieren
		move.l	(sp)+,a1
*****************************************************************************
ap_handle_irq:
;		move.w	#245,ap_mfp_timerwert(a5)
;		clr.b	$fffffa19.w
;		move.l	a1,$134.w				;Timer-A-Vektor
;		bset	#5,$fffffa07.w			;IER
;		bset	#5,$fffffa13.w			;IMR
;		bclr	#3,$fffffa17.w			;EOI
;		move.b	#245,$fffffa1f.w		;Timer-Wert	 246 >> 50.15Hz
;		move.b	#$7,$fffffa19.w			;Vorteiler 1:200
										;>> Timer-A wird alle 1/50s aufgerufen
ap_vbl_handle:
		movem.l	(sp)+,d0-a6
		rts

*****************************************************************************
	TEXT
ap_small_deinit:
;		lea		BASE5(pc),a5
		clr.w	main_voice(a5)			;Hauptlautst�rke auf 0
;		bclr	#5,$fffffa07.w			;IER
;		bclr	#5,$fffffa13.w			;IMR
;		clr.b	$fffffa19.w				;Timer-Stop
;		bclr	#7,$ffff8931.w			;DSP-XMIT auf Tristate
		clr.w	DFF096(a5)				;DSP-Paula ausschalten
		rts
*****************************************************************************
;Paula-Pseudoregister
DFF096:				dc.w $0000		;Amiga:DMA-Controlregister
DFF0A0:				dc.l $00000000	;Amiga:Adressregister �� Audio-Kanal 1 ��
DFF0A4:				dc.w $0000		;Amiga:Sample-L�nge
DFF0A6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0A8:				dc.w $0000		;Amiga:Lautst�rke
DFF0AA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0AE:				dc.w $0000		;XXXXX:Pseudo-Loop-L�nge

DFF0B0:				dc.l $00000000	;Amiga:Adressregister �� Audio-Kanal 2 ��
DFF0B4:				dc.w $0000		;Amiga:Sample-L�nge
DFF0B6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0B8:				dc.w $0000		;Amiga:Lautst�rke
DFF0BA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0BE:				dc.w $0000		;XXXXX:Pseudo-Loop-L�nge

DFF0C0:				dc.l $00000000	;Amiga:Adressregister �� Audio-Kanal 3 ��
DFF0C4:				dc.w $0000		;Amiga:Sample-L�nge
DFF0C6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0C8:				dc.w $0000		;Amiga:Lautst�rke
DFF0CA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0CE:				dc.w $0000		;XXXXX:Pseudo-Loop-L�nge

DFF0D0:				dc.l $00000000	;Amiga:Adressregister �� Audio-Kanal 4 ��
DFF0D4:				dc.w $0000		;Amiga:Sample-L�nge
DFF0D6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0D8:				dc.w $0000		;Amiga:Lautst�rke
DFF0DA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0DE:				dc.w $0000		;XXXXX:Pseudo-Loop-L�nge


*****************************************************************************
dsp_system:	path "d:\source\dsppaula\"
;			inline	"dsp_sy11.inl"
;ap_dsp_paula_ssi:
;			inline "dsppau21.ads"		;DSP-Paula im SSI-Betrieb
*****************************************************************************
			include	"pro__30d.q"		;Proplayer
*****************************************************************************
ap_play_rate:	dc.l	0				;Abspielfrequenz des Players
ap_mfp_timerwert:	dc.w	245			;aktueller Timer-Wert

ap_sampling_tab:
		dc.w	49150				;50 Khz
		dc.w	32750				;33 KHz
		dc.w	24600				;25 KHz
		dc.w	19650				;20 KHz
		dc.w	16400				;16 KHz
		dc.w	12300				;unzul�ssig
		dc.w	12300				;12 KHz
ap_freq_tab:	ds.l	2*(907-79+1)
ap_mfp_bytes:	ds.w	256				;zu berechn. Bytes pro MFP-Z�hlerwert
ap_vol_tab:	ds.l	65					;65 Volume-Abstufungen


cacr_rett:	dc.w	0
ap_dum_sample:	dc.l	$80808080		;Dummysample f�r Kanalabschaltung
*****************************************************************************
;	IFNE	make_bin=0
;			path "e:\mods\new_soun.d"
;module:		inline "mechiner.mod"
;	ENDIF
;	ENDIF
*****************************************************************************
	
		end
