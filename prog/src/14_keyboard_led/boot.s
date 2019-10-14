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
;;; リアルモード時に取得した情報
;;;
FONT:
    .seg: dw 0
    .off: dw 0
ACPI_DATA:                      ; acpi data
    .adr dd 0                   ; acpi data address
    .len dd 0                   ; acpi data length
;;;
;;; モジュール(先頭 512 byte 以降に配置)
;;;
;;;
    %include "../modules/real/itoa.s"
    %include "../modules/real/get_drive_param.s"
    %include "../modules/real/get_font_adr.s"
    %include "../modules/real/get_mem_info.s"
    %include "../modules/real/kbc.s"
;;;
;;; ブート処理の第2ステージ
;;;
stage_2:
    ;; 文字列を表示
    cdecl puts, .s0             ; puts(.s0);

    ;; ドライブ情報を取得
    cdecl get_drive_param, BOOT ; get_drive_param(DX, BOOT.CYLN);
    cmp ax, 0                   ; if (0 == AX)
                                ; {
    .10Q:                       ;
    jne .10E                    ;
                                ;
    .10T:                       ;
    cdecl puts, .e0             ;   puts(.e0);
    call reboot                 ;   reboot();
                                ; }
    .10E:                       ;

    ;; ドライブ情報を表示
    mov ax, [BOOT + drive.no]
    cdecl itoa, ax, .p1, 2, 16, 0b0100
    mov ax, [BOOT + drive.cyln]
    cdecl itoa, ax, .p2, 4, 16, 0b0100
    mov ax, [BOOT + drive.head]
    cdecl itoa, ax, .p3, 2, 16, 0b0100
    mov ax, [BOOT + drive.sect]
    cdecl itoa, ax, .p4, 2, 16, 0b0100
    cdecl puts, .s1

    ;; 処理の終了
    jmp stage_3rd                       ; while (1);

    ;; データ
    .s0 db "2nd stage...", 0x0A, 0x0D, 0

    .s1 db " Drive:0x"
    .p1 db "  , C:0x"
    .p2 db "    , H:0x"
    .p3 db "  , S:0x"
    .p4 db "  ", 0x0A, 0x0D, 0

    .e0 db "Can't get drive number.", 0

;;;
;;; ブート処理の第3ステージ
;;;
stage_3rd:
    ;; 文字列を表示
    cdecl puts, .s0

    ;; プロテクトモードで使用するフォントは，BIOSに内蔵されたものを流用する
    cdecl get_font_adr, FONT    ; BIOSのフォントを取得

    ;; フォントアドレスの表示
    cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1

    ;; メモリ情報の取得と表示
    cdecl get_mem_info          ; get_mem_inf();

    mov eax, [ACPI_DATA.adr]    ; EAX = ACPI.adr;
    cmp eax, 0                  ; if (EAX) {
    je .10E

    cdecl itoa, ax, .p4, 4, 16, 0b0100 ; itoa(AX); 下位アドレスを変換
    shr eax, 16                        ; EAX >>= 16;
    cdecl itoa, ax, .p3, 4, 16, 0b0100 ; itoa(AX); 上位アドレスを変換

    cdecl puts, .s2
    .10E:
    ;; 処理の終了
    jmp stage_4                ; goto stage_4

    ;; data
    .s0: db "3rd stage...", 0x0A, 0x0D, 0

    .s1: db " Font Address="
    .p1: db "ZZZZ:"
    .p2: db "ZZZZ", 0x0A, 0x0D, 0
    db 0x0A, 0x0D, 0

    .s2:	db	" ACPI data="
    .p3:	db	"ZZZZ"
    .p4:	db	"ZZZZ", 0x0A, 0x0D, 0

;;;
;;; ブート処理の第4ステージ
;;;
stage_4:
    ;; 文字列を表示
    cdecl puts, .s0

    ;; A20ゲートの有効化
    cli                            ; // 割り込み禁止

    cdecl KBC_Cmd_Write, 0xAD       ; // キーボード無効化

    cdecl KBC_Cmd_Write, 0xD0   ; // 出力ポート読み出しコマンド
    cdecl KBC_Data_Read, .key   ; // 出力ポートデータ

    mov bl, [.key]              ; BL = key;
    or bl, 0x02                 ; BL |= 0x02;

    cdecl KBC_Cmd_Write, 0xD1   ; // 出力ポート書き込みコマンド
    cdecl KBC_Data_Write, bx    ;// 出力ポートデータ

    cdecl KBC_Cmd_Write, 0xAE   ; // キーボード有効化

    sti                         ; 割り込み許可

    ;; 文字列を表示
    cdecl puts, .s1

    ;; キーボードのLEDテスト
    cdecl puts, .s2

    mov bx, 0                   ; CX = LEDの初期値;

    .10L:                       ; do {
    mov ah, 0x00                ;
    int 0x16                    ;   AL = BIOS(0x16, 0x00);

    cmp al, '1'                 ;   if (AL < '1')
    jb  .10E                    ;       break;

    cmp al, '3'                 ;   if ('3' < AL)
    ja  .10E                    ;       break;

    mov cl, al                  ;   CL = input from keyboard;
    dec cl                      ;   CL -= 1;
    and cl, 0x03                 ;   CL &= 0x03; // 0-2に制限
    mov ax, 0x0001              ;   AX = 0x0001;
    shl ax, cl                  ;   AX <<= CL; // 0-2ビット左シフト

    xor bx, ax                  ;   BX ^= AX; ビット反転

    ;; LEDコマンドの送信
    cli                         ;   // 割り込み禁止

    cdecl KBC_Cmd_Write, 0xAD   ;   // キーボード無効化

    cdecl KBC_Data_Write, 0xED  ;   // LED cmd
    cdecl KBC_Data_Read, .key   ;   // 受信応答

    cmp [.key], byte 0xFA       ;   if (0xFA == key) {
    jne .11F                    ;

    cdecl KBC_Data_Write, bx    ;       // LEDデータ出力

    jmp .11E                    ;   } else {

    .11F:                       ;       // 受信コードを表示
    cdecl itoa, word [.key], .e1, 2, 16, 0b1000
    cdecl puts, .e0             ; }

    .11E:                       ;
    cdecl KBC_Cmd_Write, 0xAE   ;   // キーボード有効化

    sti                         ;   // 割り込み許可

    jmp .10L                    ; } while (1);

    .10E:
    ;; 文字列の表示
    cdecl puts, .s3
    ;; 処理の終了
    jmp $                       ; while (1);

    ;; // data
    .s0:	db	"4th stage...", 0x0A, 0x0D, 0
    .s1:	db	" A20 Gate Enabled.", 0x0A, 0x0D, 0
    .s2:	db	" Keyboard LED Test...", 0
    .s3:	db	" (done)", 0x0A, 0x0D, 0
    .e0:	db	"["
    .e1:	db	"ZZ]", 0

    .key:	dw	0
;;;
;;; パディング(このファイルは 8K byte とする)
;;;
    times BOOT_SIZE - ($ - $$) db 0 ; padding
