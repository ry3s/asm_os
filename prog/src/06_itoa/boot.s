    BOOT_LOAD equ 0x7C00        ; ブートプログラムのロード位置
    ORG BOOT_LOAD               ; ロードアドレスをアセンブラに指示
;;;
;;; マクロ
;;;
    %include "../include/macros.s"

;;;
;;; エントリポイント
;;;
entry:
    jmp ipl                       ; IPLへジャンプ

    ;; BPB(BIOS Prameter Block)
    times 90 - ($ - $$) db 0x90

    ;; IPL (Initial Program Loader)
ipl:
    cli                        ; 割り込み禁止

    mov ax, 0x0000              ; AX = 0x0000;
    mov ds, ax                  ; DS = 0x0000;
    mov es, ax                  ; ES = 0x0000;
    mov ss, ax                  ; SS = 0x0000;
    mov sp, BOOT_LOAD           ; SP = 0x7C00;

    sti                        ; 割り込み許可

    mov [BOOT.DRIVE], dl       ; ブートドライブを保存

    ;; 文字を表示
    cdecl puts, .s0             ; puts(.s0);

    cdecl	itoa,  8086, .s1, 8, 10, 0b0001	; "    8086"
	cdecl	puts, .s1

	cdecl	itoa,  8086, .s1, 8, 10, 0b0011	; "+   8086"
	cdecl	puts, .s1

	cdecl	itoa, -8086, .s1, 8, 10, 0b0001	; "-   8086"
	cdecl	puts, .s1

	cdecl	itoa,    -1, .s1, 8, 10, 0b0001	; "-      1"
	cdecl	puts, .s1

	cdecl	itoa,    -1, .s1, 8, 10, 0b0000	; "   65535"
	cdecl	puts, .s1

	cdecl	itoa,    -1, .s1, 8, 16, 0b0000	; "    FFFF"
	cdecl	puts, .s1

	cdecl	itoa,    12, .s1, 8,  2, 0b0100	; "00001100"
	cdecl	puts, .s1

    jmp $                       ; while(1)

    .s0: db "Booting...", 0x0A, 0x0D, 0
    .s1: db "--------", 0x0A, 0x0D, 0
    ALIGN 2, db 0
BOOT:                           ; ブートドライブに関する情報
    .DRIVE: dw 0                ; ドライブ番号


;;;
;;; モジュール
;;;
    %include "../modules/real/puts.s"
    %include "../modules/itoa.s"
;;;
;;; ブートフラグ(先頭 512 バイトの終了)
;;;
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA
