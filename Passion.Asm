;��������watermelon���б�д��Ŀ��������GUID
		.386
		.model flat, stdcall
		option casemap :none
		
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		gdi32.inc
includelib	gdi32.lib
include		advapi32.inc
includelib	advapi32.lib
include		comctl32.inc
includelib 	comctl32.lib
include 	shell32.inc
includelib	shell32.lib
include 	ws2_32.inc
includelib	ws2_32.lib
include 	ole32.inc
includelib	ole32.lib


;��ֵ����
ICO_MAIN	equ		1000h	;ͼ��
DLG_MAIN	equ		1
IDC_GUIDTEXT	equ		101


		.data
hInstance	dd		?


		.code
;�Ի������
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@szBuffer[128]:byte	;���ڴ�����ɵ�GUID
		LOCAL	@guid:GUID		;����һ��GUID�ṹ��
		LOCAL	@result[128]:byte	;���ڴ�����յĽ��

		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	GetDlgItem,hWnd,IDC_GUIDTEXT		;��ʼʱ���Ȼһ�
			invoke	EnableWindow,eax,FALSE
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax == IDOK
				;TODO :���￪ʼд����GUID�ĳ�������CoCreateGuid
				invoke	GetDlgItem,hWnd,IDC_GUIDTEXT
				invoke	EnableWindow,eax,TRUE		;��EDITTEXT����
				
				;���濪ʼ��ȡGUID�����յĽ��
				invoke	CoCreateGuid,addr @guid
				;��GUIDת��Ϊ�ַ���
				invoke	StringFromGUID2,addr @guid,addr @szBuffer,sizeof @szBuffer
				;�ַ���֮���ת��������������ʾ��ȫ������������
				.if	eax
					invoke	WideCharToMultiByte,CP_UTF8,0,\
						addr @szBuffer,-1,addr @result,\
						sizeof @result,NULL,NULL
					invoke	SetDlgItemText,hWnd,IDC_GUIDTEXT,addr @result
				.else
					invoke	SetDlgItemText,hWnd,IDC_GUIDTEXT,addr @szBuffer
				.endif
			.endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgMain	endp

start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL	;ģ̬�Ի���
		invoke	ExitProcess,NULL
end	start