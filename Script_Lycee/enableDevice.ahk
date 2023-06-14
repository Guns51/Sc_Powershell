SendMode Input

Run control mmsys.cpl

WinWait, Son

SendInput, {Down}{Down}{Down}{Down}{Down}
SendInput, +{F10}{Down}{Down}{Enter}
Sleep, 25
WinClose, Son