
AutoItSetOption ("SendKeyDelay", 50)
AutoItSetOption ("SendKeyDownDelay", 50)
GLOBAL $SLEEPTIME = 10

#include <Misc.au3>

GLOBAL $DLL = DllOpen ("user32.dll")

GLOBAL $SEEDGRIND = 0
GLOBAL $THIEVES = 1

; This line was for my local copy of statetest.au3. For github, it is the lower, uncommented path.
;~ #include "../statetest/statetest.au3"
#include "statetest.au3"

GLOBAL $BATTLE = StateTestLoad ("battle.ini")
GLOBAL $BATTLEDIALOG = StateTestLoad ("battle-dialog.ini")
GLOBAL $TATAKAU = StateTestLoad ("tatakau.ini")
GLOBAL $ALLY = StateTestLoad ("ally1.ini")
;~ GLOBAL $ALLY3 = StateTestLoad ("ally3.ini")

GLOBAL $KAI = StateTestLoad ("kai.ini")
GLOBAL $SANDWORM = StateTestLoad ("sandworm.ini")
GLOBAL $XX7 = StateTestLoad ("xx7.ini")

; This line was for my local copy of statetest.au3. For github, it is the lower, uncommented path.
;~ #include "../player.au3"
#include "player.au3"

$_PLAYER_LOOP = 2
$_PLAYER_RANDOM = 0
$_PLAYER_PAUSEBREAK = 1

local $trackarray[7] = ["MonmusuSeedGrind", "MonmusuStealGrind", "MonmusuReplaySteal", "MonmusuAssist", "Mash", "BuyCoins", "Thieves"]
$_PLAYER_TRACKS = $trackarray
$_PLAYER_TRACKNUMBER = 0

HotKeySet ("{F5}", "Player_F5")
HotKeySet ("{F7}", "Player_F7")
HotKeySet ("{F8}", "Player_F8")

HotKeySet ("{F9}", "Quit")
Func Quit ()
	Refresh ()
	Exit
EndFunc

local $err = InitFFDll ()
if $err then
	ConsoleWrite ("InitFFDll Failed: Error code " & $err  & @CRLF)
endif

while 1
	sleep (3600000)
wend

Func MonmusuSeedGrind ()
	
	ConsoleWrite ("MonmusuSeedGrind Begin" & @CRLF)
	$SEEDGRIND = 1
	Send ("9")
	
	local $savetimer = TimerInit ()
	
	while NOT $_PLAYER_STOP
		
		local $stage = StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $BATTLE, 0, 0)
		if $stage <> "" then
			
			if $stage = "ruinedlab" then
				if StateTestFFUse (0, $XX7, 0, 0) = "xx7" then
					local $flee = 1
				else
					local $flee = 0
				endif
			else
				if StateTestFFUse (0, $KAI, 0, 0) = "kai" OR StateTestFFUse (0, $SANDWORM, 0, 0) = "sandworm" then
					local $flee = 0
				else
					local $flee = 1
				endif
			endif
			
			Send ("{a down}")
			Send ("{z down}")
			
			sleep (125)
			local $timer = TimerInit ()
			while TimerDiff ($timer) < 200
				StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
				if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
					if $flee then
						Flee ()
					else
						Steal ()
					endif
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLEDIALOG, 0, 0) <> "" then
					Send ("z up")
					sleep ($SLEEPTIME * 25)
					Send ("z down")
					sleep (200)
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
					$timer = TimerInit ()
				endif
				sleep ($SLEEPTIME * 5)
			wend
			
			Send ("{z up}")
			Send ("{a up}")
			
		else
			
			if TimerDiff ($savetimer) > 4800000 then
				if Save () then
					$savetimer = TimerInit ()
				endif
			endif
			
			local $dir = Random (0, 1, 1)
			
			if ($dir) then
				local $first = "LEFT"
				local $second = "RIGHT"
			else
				local $first = "RIGHT"
				local $second = "LEFT"
			endif
			
			Send ("{SHIFTDOWN}")
			Send ("{" & $first & " DOWN}")
			sleep ($SLEEPTIME)
			Send ("{" & $first & " UP}")
			Send ("{" & $second & " DOWN}")
			sleep ($SLEEPTIME)
			Send ("{" & $second & " UP}")
			Send ("{SHIFTUP}")
;~ 			Send ("z")
		
		endif
		
	wend
	
	ConsoleWrite ("MonmusuSeedGrind End" & @CRLF)
	$SEEDGRIND = 0
	Send ("0")
	
EndFunc

Func MonmusuStealGrind ()
	
	ConsoleWrite ("MonmusuStealGrind Begin" & @CRLF)
	Send ("9")
	
	local $savetimer = TimerInit ()
	
	while NOT $_PLAYER_STOP
		
		if StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $BATTLE, 0, 0) <> "" then
			
			Send ("{a down}")
			Send ("{z down}")
			
			sleep (125)
			local $timer = TimerInit ()
			while TimerDiff ($timer) < 200
				StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
				if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
					MassSteal ()
					exitloop
				elseif StateTestFFUse (0, $BATTLEDIALOG, 0, 0) <> "" then
					Send ("{z up}")
					sleep ($SLEEPTIME * 5)
					Send ("{z down}")
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
					Send ("x")
					sleep ($SLEEPTIME * 5)
					$timer = TimerInit ()
				endif
			wend
			
			$timer = TimerInit ()
			while TimerDiff ($timer) < 200
				StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
				if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
					Fight ()
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLEDIALOG, 0, 0) <> "" then
					Send ("{z up}")
					sleep ($SLEEPTIME * 5)
					Send ("{z down}")
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
					Send ("x")
					sleep ($SLEEPTIME * 5)
					$timer = TimerInit ()
				endif
				sleep ($SLEEPTIME * 5)
			wend
			
			Send ("{z up}")
			Send ("{a up}")
			
		else
			
			if TimerDiff ($savetimer) > 4800000 then
				if Save () then
					$savetimer = TimerInit ()
				endif
			endif
			
			local $dir = Random (0, 1, 1)
			
			if ($dir) then
				local $first = "LEFT"
				local $second = "RIGHT"
			else
				local $first = "RIGHT"
				local $second = "LEFT"
			endif
			
			Send ("{SHIFTDOWN}")
			Send ("{" & $first & " DOWN}")
			sleep ($SLEEPTIME)
			Send ("{" & $first & " UP}")
			Send ("{" & $second & " DOWN}")
			sleep ($SLEEPTIME)
			Send ("{" & $second & " UP}")
			Send ("{SHIFTUP}")
;~ 			Send ("z")
		
		endif
		
	wend
	
	ConsoleWrite ("MonmusuStealGrind End" & @CRLF)
	Send ("0")
	
EndFunc

Func MonmusuReplaySteal ()
	
	ConsoleWrite ("MonmusuReplaySteal...")
	Send ("9")
	
	while NOT $_PLAYER_STOP
		
		sleep (100)
		Send ("z")
		sleep (100)
		Send ("z")
		
		while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $BATTLE, 0, 0) = ""
			sleep (5)
		wend
		
		Send ("{a down}")
		Send ("{z down}")
		
		sleep (125)
		local $timer = TimerInit ()
		while TimerDiff ($timer) < 200
			StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
			if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
				MassSteal ()
				exitloop
			elseif StateTestFFUse (0, $BATTLEDIALOG, 0, 0) <> "" then
				Send ("{z up}")
				sleep ($SLEEPTIME * 5)
				Send ("{z down}")
				$timer = TimerInit ()
			elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
				Send ("x")
				sleep ($SLEEPTIME * 5)
				$timer = TimerInit ()
			endif
		wend
		
		$timer = TimerInit ()
		while TimerDiff ($timer) < 200
			StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
			if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
				Fight ()
				sleep (50)
				$timer = TimerInit ()
			elseif StateTestFFUse (0, $BATTLEDIALOG, 0, 0) <> "" then
				Send ("{z up}")
				sleep ($SLEEPTIME * 5)
				Send ("{z down}")
				$timer = TimerInit ()
			elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
				Send ("x")
				sleep ($SLEEPTIME * 5)
				$timer = TimerInit ()
			endif
			sleep ($SLEEPTIME * 5)
		wend
		
		Send ("{z up}")
		Send ("{a up}")
		
	wend
	
	ConsoleWrite ("End" & @CRLF)
	Send ("0")
	
EndFunc

Func MonmusuAssist ()
	
	ConsoleWrite ("MonmusuAssist Begin" & @CRLF)
	
	while NOT $_PLAYER_STOP
		
		if StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $BATTLE, 0, 0) <> "" then
			
			Send ("9")
			
			Send ("{a down}")
			Send ("{z down}")
			
			sleep (100)
			local $timer = TimerInit ()
			while TimerDiff ($timer) < 250
				StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
				if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
					Steal ()
					exitloop
				elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
					$timer = TimerInit ()
				endif
				sleep ($SLEEPTIME * 5)
			wend
			
			$timer = TimerInit ()
			while TimerDiff ($timer) < 250
				StateTestFFSnapshot (0, WinGetHandle ("[ACTIVE]"))
				if StateTestFFUse (0, $TATAKAU, 0, 0) = "tatakau" then
					Fight ()
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLEDIALOG, 0, 0) <> "" then
					Send ("{z up}")
					sleep ($SLEEPTIME * 5)
					Send ("{z down}")
					$timer = TimerInit ()
				elseif StateTestFFUse (0, $BATTLE, 0, 0) <> "" then
					$timer = TimerInit ()
				endif
				sleep ($SLEEPTIME * 5)
			wend
			
			Send ("{z up}")
			Send ("{a up}")
			
			Send ("0")
			
		else
			
			sleep (100)
			
		endif
		
	wend
	
	ConsoleWrite ("MonmusuAssist End" & @CRLF)
	
EndFunc

Func Thieves ()
	
	$THIEVES += 1
	if $THIEVES > 4 then
		$THIEVES = 1
	endif
	
	TrayTip ("Thief count", $THIEVES, 3600)
	
EndFunc

Func Mash ()
	
	ConsoleWrite ("Mash...")
	
	while NOT $_PLAYER_STOP
		Send ("z")
	wend
	
	ConsoleWrite ("End" & @CRLF)
	
EndFunc

Func BuyCoins ()
	
	ConsoleWrite ("BuyCoins...")
	Send ("9")
	Send ("{a down}")
	
	local $sleeptime = 300
	
	while NOT $_PLAYER_STOP
		sleep ($sleeptime)
		Send ("z")
		sleep ($sleeptime)
		Send ("z")
		sleep ($sleeptime / 2)
		Send ("{DOWN}")
		sleep ($sleeptime / 2)
		Send ("{DOWN}")
		sleep ($sleeptime / 3)
		Send ("z")
	wend
	
	ConsoleWrite ("End" & @CRLF)
	Send ("0")
	Send ("{a up}")
	
EndFunc

Func Refresh ()
	Send ("{SHIFTUP}")
	Send ("{z up}")
	Send ("{a up}")
EndFunc

Func Save ()
	
	sleep (5000)
	if StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $BATTLE, 0, 0) <> "" then
		return 0
	endif
	
	ConsoleWrite (".")
	
	Send ("x")
	sleep (1000)
	
	if $SEEDGRIND then
		
		for $count = 0 to 102
			Send ("z")
			sleep (25)
		next
		for $count = 0 to 2
			Send ("x")
			sleep (500)
		next
		
	endif
	
	Send ("{UP}")
	sleep (1000)
	Send ("{UP}")
	sleep (1000)
	Send ("z")
	sleep (1000)
	Send ("z")
	sleep (1000)
	Send ("x")
	sleep (1000)
	
	return 1
	
EndFunc

Func Flee ()
	
	sleep ($SLEEPTIME * 10)
	Send ("{RIGHT}")
	sleep ($SLEEPTIME * 10)
	Send ("{DOWN}")
	sleep ($SLEEPTIME * 10)
	
	Send ("z up")
	
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $TATAKAU, 0, 0) = "tatakau"
		Send ("z")
		sleep ($SLEEPTIME * 10)
	wend
	
	Send ("z down")
	
EndFunc

Func Steal ()
	
	sleep (50)
	Send ("z up")
	
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $TATAKAU, 0, 0) = "tatakau"
		Send ("z")
		sleep ($SLEEPTIME * 50)
	wend
	
	local $timeout = TimerInit ()
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $ALLY, 0, 0) <> "1"
		sleep ($SLEEPTIME * 5)
		if TimerDiff ($timeout) > 1000 then
			return
		endif
	wend
	
	sleep ($SLEEPTIME * 10)
	Send ("{RIGHT}")
	sleep ($SLEEPTIME * 10)
	
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $ALLY, 0, 0) = "1"
		Send ("z")
		sleep ($SLEEPTIME * 10)
	wend
	
	Send ("z down")
	
EndFunc

Func MassSteal ()
	
	sleep ($SLEEPTIME * 60)
	Send ("{z up}")
	
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $TATAKAU, 0, 0) = "tatakau"
		Send ("z")
		sleep ($SLEEPTIME * 50)
	wend
	
	local $timeout = TimerInit ()
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $ALLY, 0, 0) <> "1"
		sleep ($SLEEPTIME * 5)
		if TimerDiff ($timeout) > 1000 then
			return
		endif
	wend
	
	sleep ($SLEEPTIME * 10)
	Send ("{RIGHT}")
	sleep ($SLEEPTIME * 10)
	Send ("z")
	sleep ($SLEEPTIME * 40)
	Send ("z")
	
	for $count = 2 to $THIEVES
		sleep ($SLEEPTIME * 10)
		Send ("{RIGHT}")
		sleep ($SLEEPTIME * 10)
		Send ("z")
		sleep ($SLEEPTIME * 40)
		Send ("z")
		
		local $rand = Random (0, 2, 1)
		switch $rand
			case 0
				sleep ($SLEEPTIME * 10)
				Send ("{RIGHT}")
			case 1
				sleep ($SLEEPTIME * 10)
				Send ("{DOWN}")
		endswitch
		
		sleep ($SLEEPTIME * 10)
		Send ("z")
	next
	
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $ALLY, 0, 0) = "1"
		Send ("z")
	wend
	
	Send ("{z down}")
	
	
EndFunc

Func Fight ()
	
	sleep ($SLEEPTIME * 10)
	Send ("{DOWN}")
	sleep ($SLEEPTIME * 10)
	
	Send ("{z up}")
	
	while StateTestWindowUse (WinGetHandle ("[ACTIVE]"), $TATAKAU, 0, 0) = "tatakau"
		Send ("z")
		sleep ($SLEEPTIME * 10)
	wend
	
	Send ("{z down}")
	
EndFunc
	