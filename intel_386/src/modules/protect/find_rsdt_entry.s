;************************************************************************
;	RSDTテーブルに登録されているテーブルを検索
;------------------------------------------------------------------------
;	RSDTテーブルからFACPテーブルのアドレスを取得する
;========================================================================
;■書式		: DWORD find_rsdt_entry(facp, word);
;
;■引数
;	facp	: RSDTテーブルのアドレス
;	word	: テーブル識別子
;
;■戻り値	: 見つかったアドレス、見つからなかった場合は0
;************************************************************************
find_rsdt_entry:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;    +12| テーブル名
												;    + 8| アドレス
												; ------|--------
												;    + 4| EIP（戻り番地）
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ebx
		push	ecx
		push	esi
		push	edi

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		esi, [ebp + 8]					; EDI  = RSDT;
		mov		ecx, [ebp +12]					; ECX  = 名前;

		mov		ebx, 0							; adr = 0;

		;---------------------------------------
		; ACPIテーブル検索処理
		;---------------------------------------
		mov		edi, esi						; 
		add		edi, [esi + 4]					; EDI = &ENTRY[MAX];
		add		esi, 36							; ESI = &ENTRY[0];
.10L:											; 
		cmp		esi, edi						; while (ESI < EDI)
		jge		.10E							; {
												;   
		lodsd									;   EAX = [ESI++];   // エントリ
												;   
		cmp		[eax], ecx						;   if (ECX == *EAX) // テーブル名と比較
		jne		.12E							;   {
		mov		ebx, eax						;     adr = EAX;     // FACPのアドレス
		jmp		.10E							;     break;
.12E:	jmp		.10L							;   }
.10E:											; }

		mov		eax, ebx						; return adr;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		edi
		pop		esi
		pop		ecx
		pop		ebx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

