;************************************************************************
;	���荞�ݏ����F�L�[�{�[�h
;------------------------------------------------------------------------
;	KBC�i�L�[�{�[�h�R���g���[���j����L�[�R�[�h���擾���āA
;	��p�̃����O�o�b�t�@�ɕۑ�����B
;************************************************************************
int_keyboard:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		pusha
		push	ds
		push	es

		;---------------------------------------
		; �f�[�^�p�Z�O�����g�̐ݒ�
		;---------------------------------------
		mov		ax, 0x0010						; 
		mov		ds, ax							; 
		mov		es, ax							; 

		;---------------------------------------
		; KBC�̃o�b�t�@�ǂݎ��
		;---------------------------------------
		in		al, 0x60						; AL = �L�[�R�[�h�̎擾

		;---------------------------------------
		; �L�[�R�[�h�̕ۑ�
		;---------------------------------------
		cdecl	ring_wr, _KEY_BUFF, eax			; ring_wr(_KEY_BUFF, EAX); // �L�[�R�[�h�̕ۑ�

		;---------------------------------------
		; ���荞�ݏI���R�}���h���M
		;---------------------------------------
		outp	0x20, 0x20						; outp(); // �}�X�^PIC:EOI�R�}���h

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		es								; 
		pop		ds								; 
		popa

		iret									; ���荞�݂���̕��A

ALIGN 4, db 0
_KEY_BUFF:	times ring_buff_size db 0
