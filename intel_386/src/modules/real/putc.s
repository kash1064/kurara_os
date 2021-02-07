;************************************************************************
;	テレタイプ式1文字出力
;------------------------------------------------------------------------
;	BIOS を使用
;========================================================================
;■書式		: void putc(ch);
;
;■引数
;	ch		: 文字コード
;
;■戻り値	: 無し
;************************************************************************
putc:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;    + 4| 出力文字
												;    + 2| IP（戻り番地）
		push	bp								;  BP+ 0| BP（元の値）
		mov		bp, sp							; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ax
		push	bx

		;---------------------------------------
		; 【処理の開始】
		;---------------------------------------
		;NOTE: 引数として受け取った16bitのうち、下位1byteを出力文字の文字コードとして取得
		mov		al, [bp + 4]					; 出力文字を取得
		
		;---------------------------------------
		; 一文字表示
		;---------------------------------------
		; AH = 0x0e;
		; AL = キャラクターコード;
		; BH = 0;
		; BL = カラーコード; ※(ここでカラーコードを指定するには上のビデオモード設定で、「VGAグラフィックス」をで設定しなければならない。)
		; 戻り値：なし
		; 註：ビープ、バックスペース、CR、LFは制御コードとして認識される
		; http://oswiki.osask.jp/?(AT)BIOS
		; https://wiki.osdev.org/BIOS#BIOS_functions
		;---------------------------------------

		mov		ah, 0x0E						; テレタイプ式1文字出力
		mov		bx, 0x0000						; ページ番号と文字色を0に設定
		int		0x10							; ビデオBIOSコール

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		bx
		pop		ax

		;---------------------------------------
		; 【 スタックフレームの破棄】
		;---------------------------------------
		mov		sp, bp							; 
		pop		bp

		ret

