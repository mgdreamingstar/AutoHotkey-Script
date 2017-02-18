;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ARP缓存清理
; Bela Vista宾馆的无线网络设置可能有问题，100s左右自动掉线
; 通过该脚本每分钟清理一次ARP缓存，能够解决这个问题
;
; gaochao.morgen@gmail.com
; 2014/2/15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

SetTimer, ArpDelete, 60000

ArpDelete:
	Run, cmd /c arp -d,, Hide				; 清除ARP缓存
Return

