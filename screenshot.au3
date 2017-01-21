
#include <WinAPI.au3>
#include <FastFind.au3>

HotKeySet ("{F5}", "Screenshot")
Func Screenshot ()
	StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
	FFSaveJPG("screenshot", 85, 0)
	ConsoleWrite ("Screenshot taken.")
EndFunc

HotKeySet ("{F8}", "Quit")
Func Quit ()
	Exit
EndFunc

Func StateTestFFSnapshot ($ffslot, $hwnd)
	
	; Get the client's origin on screen.
	local $tpoint = DllStructCreate("int X;int Y")
	DllStructSetData($tpoint, "X", 0)
	DllStructSetData($tpoint, "Y", 0)
	_WinAPI_ClientToScreen ($hwnd, $tpoint)
	
	; Get the client's size.
	local $dims = WinGetClientSize ($hwnd)
	
	; Get the origin.
	$FFSnapOrigin[$ffslot][0] = DllStructGetData ($tpoint, "X")
	$FFSnapOrigin[$ffslot][1] = DllStructGetData ($tpoint, "Y")
	
	; Take snapshot.
	FFSnapShot($FFSnapOrigin[$ffslot][0], $FFSnapOrigin[$ffslot][1], $FFSnapOrigin[$ffslot][0] + $dims[0] - 1, $FFSnapOrigin[$ffslot][1] + $dims[1] - 1, $ffslot, 0)
	
EndFunc

while 1
	sleep (3600000)
wend
