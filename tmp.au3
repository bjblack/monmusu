
#include <Misc.au3>

GLOBAL $DLL = DllOpen ("user32.dll")

Send ("{CTRLDOWN}")

sleep (1000)

	for $key = 0 to 255
		
		if _IsPressed (Hex ($key), $DLL) then
			ConsoleWrite ("Key " & Hex ($key) & " is pressed." & @CRLF)
			Send ("{" & Chr ($key) & " UP}")
		endif
		
	next
	
	for $key = 0 to 255
		
		if _IsPressed (Hex ($key), $DLL) then
			ConsoleWrite ("Key " & Hex ($key) & " is pressed." & @CRLF)
			Send ("{" & Chr ($key) & " UP}")
		endif
		
	next
	
Send ("{CTRLUP}")

if _IsPressed (11) then
	ConsoleWrite ("TRUE" & @CRLF)
else
	ConsoleWrite ("FALSE" & @CRLF)
endif
