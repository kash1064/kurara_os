;************************************************************************
;
;	カーネル部
;
;************************************************************************

%define	USE_SYSTEM_CALL
%define	USE_TEST_AND_SET

;************************************************************************
;	マクロ
;************************************************************************
%include	"/kurara_os/src/include/define.s"
%include	"/kurara_os/src/include/macro.s"

		ORG		KERNEL_LOAD						; カーネルのロードアドレス

[BITS 32]
;************************************************************************
;	エントリポイント
;************************************************************************
kernel:
		;---------------------------------------
		; フォントアドレスを取得
		;---------------------------------------
		mov		esi, BOOT_LOAD + SECT_SIZE		; ESI   = 0x7C00 + 512
		movzx	eax, word [esi + 0]				; EAX   = [ESI + 0] // セグメント
		movzx	ebx, word [esi + 2]				; EBX   = [ESI + 2] // オフセット
		shl		eax, 4							; EAX <<= 4;
		add		eax, ebx						; EAX  += EBX;
		mov		[FONT_ADR], eax					; FONT_ADR[0] = EAX;

		;---------------------------------------
		; TSSディスクリプタの設定
		;---------------------------------------
		set_desc	GDT.tss_0, TSS_0			; // タスク0用TSSの設定
		set_desc	GDT.tss_1, TSS_1			; // タスク1用TSSの設定
		set_desc	GDT.tss_2, TSS_2			; // タスク2用TSSの設定
		set_desc	GDT.tss_3, TSS_3			; // タスク3用TSSの設定
		set_desc	GDT.tss_4, TSS_4			; // タスク4用TSSの設定
		set_desc	GDT.tss_5, TSS_5			; // タスク5用TSSの設定
		set_desc	GDT.tss_6, TSS_6			; // タスク6用TSSの設定

		;---------------------------------------
		; コールゲートの設定
		;---------------------------------------
		set_gate	GDT.call_gate, call_gate	; // コールゲートの設定

		;---------------------------------------
		; LDTの設定
		;---------------------------------------
		set_desc	GDT.ldt, LDT, word LDT_LIMIT

		;---------------------------------------
		; GDTをロード（再設定）
		;---------------------------------------
		lgdt	[GDTR]							; // グローバルディスクリプタテーブルをロード

		;---------------------------------------
		; スタックの設定
		;---------------------------------------
		mov		esp, SP_TASK_0					; // タスク0用のスタックを設定

		;---------------------------------------
		; タスクレジスタの初期化
		;---------------------------------------
		mov		ax, SS_TASK_0
		ltr		ax								; // タスクレジスタの設定

		;---------------------------------------
		; 初期化
		;---------------------------------------
		cdecl	init_int						; // 割り込みベクタの初期化
		cdecl	init_pic						; // 割り込みコントローラの初期化
		cdecl	init_page						; // ページングの初期化

		set_vect	0x00, int_zero_div			; // 割り込み処理の登録：0除算
		set_vect	0x07, int_nm				; // 割り込み処理の登録：デバイス使用不可
		set_vect	0x0E, int_pf				; // 割り込み処理の登録：ページフォルト
		set_vect	0x20, int_timer				; // 割り込み処理の登録：タイマー
		set_vect	0x21, int_keyboard			; // 割り込み処理の登録：KBC
		set_vect	0x28, int_rtc				; // 割り込み処理の登録：RTC
		set_vect	0x81, trap_gate_81, word 0xEF00	; // トラップゲートの登録：1文字出力
		set_vect	0x82, trap_gate_82, word 0xEF00	; // トラップゲートの登録：点の描画

		;---------------------------------------
		; デバイスの割り込み許可
		;---------------------------------------
		cdecl	rtc_int_en, 0x10				; rtc_int_en(UIE); // 更新サイクル終了割り込み許可
		cdecl	int_en_timer0					; // タイマー（カウンタ0）割り込み許可

		;---------------------------------------
		; IMR(割り込みマスクレジスタ)の設定
		;---------------------------------------
		outp	0x21, 0b_1111_1000				; // 割り込み有効：スレーブPIC/KBC/タイマー
		outp	0xA1, 0b_1111_1110				; // 割り込み有効：RTC

		;---------------------------------------
		; ページングを有効化
		;---------------------------------------
		mov		eax, CR3_BASE					;
		mov		cr3, eax						; // ページテーブルの登録

		mov		eax, cr0						; // PGビットをセット
		or		eax, (1 << 31)					; CR0 |= PG;
		mov		cr0, eax						; 
		jmp		$ + 2							; FLUSH();

		;---------------------------------------
		; CPUの割り込み許可
		;---------------------------------------
		sti										; // 割り込み許可

		;---------------------------------------
		; フォントの一覧表示
		;---------------------------------------
		cdecl	draw_font, 63, 13				; // フォントの一覧表示
		cdecl	draw_color_bar, 63, 4			; // カラーバーの表示

		;---------------------------------------
		; 文字列の表示
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x010F, .s0	; draw_str();

.10L:											; while (;;)
												; {
		;---------------------------------------
		; 回転する棒を表示
		;---------------------------------------
		cdecl	draw_rotation_bar				;   // 回転する棒を表示

		;---------------------------------------
		; キーコードの取得
		;---------------------------------------
		cdecl	ring_rd, _KEY_BUFF, .int_key	;   EAX = ring_rd(buff, &int_key);
		cmp		eax, 0							;   if (EAX == 0)
		je		.10E							;   {
												;   
		;---------------------------------------
		; キーコードの表示
		;---------------------------------------
		cdecl	draw_key, 2, 29, _KEY_BUFF		;     ring_show(key_buff); // 全要素を表示
.10E:											;   }
		jmp		.10L							; }

.s0:	db	" Hello, kernel! ", 0

ALIGN 4, db 0
.int_key:	dd	0

ALIGN 4, db 0
FONT_ADR:	dd	0
RTC_TIME:	dd	0

;************************************************************************
;	タスク
;************************************************************************
; NOTE: 80386の機能を利用してマルチタスクを動作させるためには、カーネルが管理するTSSに加え、タスク自身がアクセスするコードとデータ用のセグメントも必要
%include	"/kurara_os/src/boot/descriptor.s"
%include	"/kurara_os/src/modules/protect/int_timer.s"
%include	"/kurara_os/src/modules/protect/int_pf.s"
%include	"/kurara_os/src/modules/protect/paging.s"
%include	"/kurara_os/src/tasks/task_1.s"
%include	"/kurara_os/src/tasks/task_2.s"
%include	"/kurara_os/src/tasks/task_3.s"

;************************************************************************
;	モジュール
;************************************************************************
%include	"/kurara_os/src/modules/protect/vga.s"
%include	"/kurara_os/src/modules/protect/draw_char.s"
%include	"/kurara_os/src/modules/protect/draw_font.s"
%include	"/kurara_os/src/modules/protect/draw_str.s"
%include	"/kurara_os/src/modules/protect/draw_color_bar.s"
%include	"/kurara_os/src/modules/protect/draw_pixel.s"
%include	"/kurara_os/src/modules/protect/draw_line.s"
%include	"/kurara_os/src/modules/protect/draw_rect.s"
%include	"/kurara_os/src/modules/protect/itoa.s"
%include	"/kurara_os/src/modules/protect/rtc.s"
%include	"/kurara_os/src/modules/protect/draw_time.s"

; NOTE: 割り込み処理がアクセスするメモリ空間は、カーネルがアクセスするメモリ空間と同様、セグメントディスクリプタで定義します
; NOTE: 割り込み処理用のセグメントディスクリプタを新たに定義し、セグメントディスクリプタテーブルに追加後、セグメントディスクリプタのインデックスをセグメントレジスタに設定する
; NOTE: 80386は、最大256の割り込み要因を区別することが可能であり、ベクタ番号で区別される
; NOTE: ベクタ番号0から31までの割り込み要因はCPUによって用途が決められているので、決められた目的以外の割り込みを使用したいのであれば、32番以降のベクタ番号を使用する
%include	"/kurara_os/src/modules/protect/interrupt.s"
%include	"/kurara_os/src/modules/protect/pic.s"
%include	"/kurara_os/src/modules/protect/int_rtc.s"
%include	"/kurara_os/src/modules/protect/int_keyboard.s"
%include	"/kurara_os/src/modules/protect/ring_buff.s"
%include	"/kurara_os/src/modules/protect/timer.s"
%include	"/kurara_os/src/modules/protect/draw_rotation_bar.s"
%include	"/kurara_os/src/modules/protect/call_gate.s"
%include	"/kurara_os/src/modules/protect/trap_gate.s"
%include	"/kurara_os/src/modules/protect/test_and_set.s"
%include	"/kurara_os/src/modules/protect/int_nm.s"
%include	"/kurara_os/src/modules/protect/wait_tick.s"
%include	"/kurara_os/src/modules/protect/memcpy.s"

;************************************************************************
;	パディング
;************************************************************************
		times KERNEL_SIZE - ($ - $$) db 0x00	; パディング

;************************************************************************
;	FAT
;************************************************************************
%include	"/kurara_os/src/boot/fat.s"