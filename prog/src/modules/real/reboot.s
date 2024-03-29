;;; メッセージを表示して再起動を行う
;;; void reboot(void);
;;;
reboot:
    ;; メッセージを表示
    cdecl puts, .s0

    ;; キー入力待ち
    .10L:
    mov ah, 0x10
    int 0x16

    cmp al, ' '
    jne .10L

    ;; 改行を出力
    cdecl puts, .s1

    ;; 再起動
    int 0x19                    ; BIOS(0x19) reboot();

    ;; 文字列データ
    .s0 db 0x0A, 0x0D, "Push SPACE key to reboot...", 0
    .s1 db 0x0A, 0x0D, 0x0A, 0x0D, 0
