;本程序由watermelon进行编写，目的是生成GUID
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


;等值定义
ICO_MAIN	equ		1000h	;图标
DLG_MAIN	equ		1
IDC_GUIDTEXT	equ		101


		.data
hInstance	dd		?


		.code
;对话框过程
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@szBuffer[128]:byte	;用于存放生成的GUID
		LOCAL	@guid:GUID		;定义一个GUID结构体
		LOCAL	@result[128]:byte	;用于存放最终的结果

		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	GetDlgItem,hWnd,IDC_GUIDTEXT		;初始时候先灰化
			invoke	EnableWindow,eax,FALSE
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax == IDOK
				;TODO :这里开始写生成GUID的程序，运用CoCreateGuid
				invoke	GetDlgItem,hWnd,IDC_GUIDTEXT
				invoke	EnableWindow,eax,TRUE		;将EDITTEXT激活
				
				;下面开始获取GUID和最终的结果
				invoke	CoCreateGuid,addr @guid
				;将GUID转化为字符串
				invoke	StringFromGUID2,addr @guid,addr @szBuffer,sizeof @szBuffer
				;字符集之间的转化，否则会出现显示不全或者乱码的情况
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
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL	;模态对话框
		invoke	ExitProcess,NULL
end	start
