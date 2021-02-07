;************************************************************************
;	���荞�݃R���g���[���̏�����
;========================================================================
;������		: void init_pic(void);
;
;������		: ����
;
;���߂�l	: ����
;************************************************************************
init_pic:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	eax

		;---------------------------------------
		; �}�X�^PIC�̐ݒ�
		;---------------------------------------
		outp	0x20, 0x11						; // MASTER.ICW1 = 0x11;
		outp	0x21, 0x20						; // MASTER.ICW2 = 0x20;
		outp	0x21, 0x04						; // MASTER.ICW3 = 0x04;
		outp	0x21, 0x01						; // MASTER.ICW4 = 0x01;
		outp	0x21, 0xFF						; // �}�X�^���荞�݃}�X�N

		;---------------------------------------
		; �X���[�uPIC�̐ݒ�
		;---------------------------------------
		outp	0xA0, 0x11						; // SLAVE.ICW1  = 0x11;
		outp	0xA1, 0x28						; // SLAVE.ICW2  = 0x28;
		outp	0xA1, 0x02						; // SLAVE.ICW3  = 0x02;
		outp	0xA1, 0x01						; // SLAVE.ICW4  = 0x01;
		outp	0xA1, 0xFF						; // �X���[�u���荞�݃}�X�N

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		eax

		ret
