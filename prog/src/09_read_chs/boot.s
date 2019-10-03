;;;
;;; マクロ
;;;
    %include "../include/define.s"
    %include "../include/macros.s"

    ORG BOOT_LOAD               ; ロードアドレスをアセンブラに指示
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

    mov [BOOT + drive.no], dl       ; ブートドライブを保存

    ;; 文字を表示
    cdecl puts, .s0             ; puts(.s0);

    ;; 残りのセクタをすべて読み込む
    mov bx, BOOT_SECT - 1           ; BX = 残りのぶーとセクタ数
    mov cx, BOOT_LOAD + SECT_SIZE   ; CX = 次のロードアドレス

    cdecl read_chs, BOOT, bx, cx    ; AX = read_chs(.chs, bx, cx);

    cmp ax, bx                      ; if (AX !=  残りのセクタ数)
                                    ; {
    .10Q:                           ;
    jz .10E                         ;
                                    ;
    .10T:                           ;
    cdecl puts, .e0                 ;     puts(.e0);
    call reboot                     ;     reboot();
                                    ;
    .10E:                           ; }

    ;; 次のステージへ移行
    jmp stage_2                 ; ブート処理の第2ステージ

    ;; データ
    .s0 db "Booting...", 0x0A, 0x0D, 0
    .e0 db "Error:sector read", 0

    ALIGN 2, db 0
BOOT:                           ; ブートドライブに関する情報
    istruc drive
        at drive.no, dw 0
        at drive.cyln, dw 0
        at drive.head, dw 0
        at drive.sect, dw 2
    iend


;;;
;;; モジュール
;;;
    %include "../modules/real/puts.s"
    %include "../modules/real/reboot.s"
    %include "../modules/real/read_chs.s"
;;;
;;; ブートフラグ(先頭 512 バイトの終了)
;;;
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA

;;;
;;; ブート処理の第2ステージ
;;;
stage_2:
    ;; 文字列を表示
    cdecl puts, .s0             ; puts(.s0);

    ;; 処理の終了
    jmp $                       ; while (1);

    ;; データ
    .s0 db "2nd stage...", 0x0A, 0x0D, 0

;;;
;;; パディング(このファイルは 8K byte とする)
;;;
    times BOOT_SIZE - ($ - $$) db 0 ; padding
