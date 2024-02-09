;;; ----------------------------------------------------------------------------
;;; ---------------------- UART communication functions via RIA ----------------
;;; ----------------------------------------------------------------------------
	.include ria.inc

        ;; initialize UART
UAINIT: rts
                
        ;; write character to UART, wait until UART is ready to transmit
        ;; A, X and Y registers must remain unchanged
UAPUTW:
		BIT  RIA_READY  ; Bit test RIA ready flags. B7=1 indicates readiness.
		BPL  UAPUTW     ; Wait until RIA is ready to receive.
		STA  RIA_TX     ; Send A.
		RTS             ; Return.

        ;; get character from UART, return result in A,
        ;; return A=0 if no character available for reading
        ;; X and Y registers must remain unchanged
UAGET:  BIT     RIA_READY  ; Bit test RIA ready flags. B6=1 indicates readiness.
    	BVS     .yes
    	LDA     #0
    	RTS
.yes:   LDA     RIA_RX
		RTS

        ;; get character from UART, wait if none, return result in A
        ;; X and Y registers must remain unchanged
UAGETW:
        BIT     RIA_READY  ; Bit test RIA ready flags. B6=1 indicates readiness.
        BVC     UAGETW     ; Wait until character on RX.
        LDA     RIA_RX     ; Read character from RX.
        RTS

UAEXIT:
        LDA #RIA_OP_EXIT    ; A = 255, OS exit()
        STA RIA_OP          ; Halt 6502
