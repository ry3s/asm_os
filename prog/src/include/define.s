;************************************************************************
;	メモリイメージ
;************************************************************************

		;---------------------------------------
		;           |            |
		;           |____________|
		; 0000_7A00 |            | ( 512) スタック
		;           |____________|
		; 0000_7C00 |            | (  8K) ブート
		;           =            =
		;           |____________|
		; 0000_9C00 |            | (  8K) カーネル（一時展開）
		;           =            =
		;           |____________|
		; 0000_BC00 |////////////|
		;           =            =
		;           |____________|
		; 0010_0000 |       (2K) | 割り込みディスクリプタテーブル
		;           |____________|
		; 0010_0800 |       (2K) | カーネルスタック
		;           |____________|
		; 0010_1000 |       (8K) | カーネルプログラム
		;           |            |
		;           =            =
		;           |____________|
		; 0010_3000 |       (8K) | タスク用スタック
		;           |            | （各タスク1K）
		;           =            =
		;           |____________|
		; 0010_5000 |            | Dir
		;      6000 |____________| Page
		; 0010_7000 |            | Dir
		;      8000 |____________| Page
		; 0010_9000 |////////////|
		;           |            |

		BOOT_SIZE			equ		(1024 * 8)		; ブートサイズ
		KERNEL_SIZE			equ		(1024 * 8)		; カーネルサイズ

		BOOT_LOAD			equ		0x7C00			; ブートプログラムのロード位置
		BOOT_END			equ		(BOOT_LOAD + BOOT_SIZE)

		KERNEL_LOAD			equ		0x0010_1000

		SECT_SIZE			equ		(512)			; セクタサイズ

		BOOT_SECT			equ		(BOOT_SIZE   / SECT_SIZE)	; ブートプログラムのセクタ数
		KERNEL_SECT			equ		(KERNEL_SIZE / SECT_SIZE)	; カーネルのセクタ数

		E820_RECORD_SIZE	equ		20

		VECT_BASE			equ		0x0010_0000		;	0010_0000:0010_07FF


		STACK_BASE			equ		0x0010_3000		; タスク用スタックエリア
		STACK_SIZE			equ		1024			; スタックサイズ

		SP_TASK_0			equ		STACK_BASE + (STACK_SIZE * 1)
		SP_TASK_1			equ		STACK_BASE + (STACK_SIZE * 2)
		SP_TASK_2			equ		STACK_BASE + (STACK_SIZE * 3)
		SP_TASK_3			equ		STACK_BASE + (STACK_SIZE * 4)
		SP_TASK_4			equ		STACK_BASE + (STACK_SIZE * 5)
		SP_TASK_5			equ		STACK_BASE + (STACK_SIZE * 6)
		SP_TASK_6			equ		STACK_BASE + (STACK_SIZE * 7)

		CR3_BASE			equ		0x0010_5000		; ページ変換テーブル：タスク3用

		PARAM_TASK_4		equ		0x0010_8000		; 描画パラメータ：タスク4用
		PARAM_TASK_5		equ		0x0010_9000		; 描画パラメータ：タスク5用
		PARAM_TASK_6		equ		0x0010_A000		; 描画パラメータ：タスク6用

		CR3_TASK_4			equ		0x0020_0000		; ページ変換テーブル：タスク4用
		CR3_TASK_5			equ		0x0020_2000		; ページ変換テーブル：タスク5用
		CR3_TASK_6			equ		0x0020_4000		; ページ変換テーブル：タスク6用


;************************************************************************
;	ディスクイメージ
;************************************************************************
		;(SECT/SUM)  file img
		;                       ____________
		;( 16/  0)   0000_0000 |       (8K) | ブート
		;                      =            =
		;                      |____________|
		;( 16/ 16)   0000_2000 |       (8K) | カーネル
		;                      =            =
		;                      |____________|
		;(256/ 32)   0000_4000 |     (128K) | FAT-1
		;                      |            |
		;                      |            |
		;                      =            =
		;                      |____________|
		;(256/288)   0002_4000 |     (128K) | FAT-2
		;                      |            |
		;                      |            |
		;                      =            =
		;                      |____________|
		;( 32/544)   0004_4000 |      (16K) | ルートディレクトリ領域
		;                      |            | (32セクタ/512エントリ)
		;                      =            =
		;                      |____________|
		;(   /576)   0004_8000 |            | データ領域
		;                      |            |
		;                      =            =
		;                      |            |
		;                      |____________|
		;(   /640)   0005_0000 |////////////|
		;                      |            |

		FAT_SIZE			equ		(1024 * 128)	; FAT-1/2
		ROOT_SIZE			equ		(1024 *  16)	; ルートディレクトリ領域

		ENTRY_SIZE			equ		32				; エントリサイズ

		; BOOT イメージは異なるファイルなので、FAT アドレスの定義には加算しない
		FAT_OFFSET			equ		(BOOT_SIZE + KERNEL_SIZE)
		FAT1_START			equ		(KERNEL_SIZE)
		FAT2_START			equ		(FAT1_START + FAT_SIZE)
		ROOT_START			equ		(FAT2_START + FAT_SIZE)
		FILE_START			equ		(ROOT_START + ROOT_SIZE)

		; ファイル属性
		ATTR_READ_ONLY		equ		0x01
		ATTR_HIDDEN			equ		0x02
		ATTR_SYSTEM			equ		0x04
		ATTR_VOLUME_ID		equ		0x08
		ATTR_DIRECTORY		equ		0x10
		ATTR_ARCHIVE		equ		0x20
