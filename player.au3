#include-once
#cs -----------------------------------------------------------------------------------------------------------------------------

AutoIt Version: 3.3.8.1
Author:			B.J. Black

Script Function:
	Generic script player library.

#ce -----------------------------------------------------------------------------------------------------------------------------

#cs

#include <player.au3>
; Func Player_Init ($trackarray, $pausebreak = 1, $loopmode = 0, $random = 0)
; Func Player_Play ()
; Func Player_Set_PauseBreak ()
; Func Player_PauseBreak ()
; Func Player_NextTrack ()

#ce

; ===============================================================================================================================
#Region Trainer Version

GLOBAL CONST $_PLAYER_VERSION_STRING = "Script Player v0.1"

#EndRegion
; ===============================================================================================================================
#Region Include Files

#include <Array.au3>

#EndRegion
; ===============================================================================================================================
#Region Global Variables

GLOBAL $_PLAYER_PLAY
GLOBAL $_PLAYER_PAUSE
GLOBAL $_PLAYER_STOP

#EndRegion
; ===============================================================================================================================
#Region Global Settings

GLOBAL $_PLAYER_LOOP ; Play one and stop (0), play to end of playlist(1), loop one (2), loop all (3).
GLOBAL $_PLAYER_RANDOM

GLOBAL $_PLAYER_PAUSEBREAK ; 1 if a pause command immediately breaks, or 0 if the user has defined breaking points in his script.

; This is a list of functions callable by the player- note that they should take no arguments.
GLOBAL $_PLAYER_TRACKS

; This is an index into $_PLAYER_TRACKS, indicating the current track number.
GLOBAL $_PLAYER_TRACKNUMBER

#EndRegion
; ===============================================================================================================================
#Region HotKey Functions

Func Player_F5 ()
	if $_PLAYER_PLAY then
		if $_PLAYER_PAUSE then
			$_PLAYER_PAUSE = FALSE
		else
			$_PLAYER_PAUSE = TRUE
			if $_PLAYER_PAUSEBREAK then
				Player_PauseBreak ()
			endif
		endif
	else
		$_PLAYER_PLAY = TRUE
		Player_Play ()
		$_PLAYER_PLAY = FALSE
		$_PLAYER_STOP = FALSE
	endif
EndFunc

Func Player_F7 ()
	if NOT $_PLAYER_PLAY then
		Player_NextTrack ()
	endif
EndFunc

Func Player_F8 ()
	if $_PLAYER_PLAY then
		$_PLAYER_STOP = TRUE
		$_PLAYER_PAUSE = FALSE
	endif
EndFunc

Func Player_F9 ()
	Exit
EndFunc

#EndRegion
; ===============================================================================================================================
#Region User Functions

Func Player_Init ($trackarray, $pausebreak = 1, $loopmode = 0, $random = 0)
	
	$_PLAYER_LOOP = $loopmode
	$_PLAYER_RANDOM = $random
	$_PLAYER_PAUSEBREAK = $pausebreak
	$_PLAYER_TRACKS = $trackarray
	$_PLAYER_TRACKNUMBER = 0
	
EndFunc

Func Player_Play ()
	
	while NOT $_PLAYER_STOP
		
		local $track = $_PLAYER_TRACKNUMBER
		local $pool[UBound ($_PLAYER_TRACKS)]
		for $i = 0 to UBound ($pool) - 1
			$pool[$i] = $i
		next
		
		Call ($_PLAYER_TRACKS[$_PLAYER_TRACKNUMBER])
		
		while $_PLAYER_RANDOM AND ($_PLAYER_LOOP = 1 OR $_PLAYER_LOOP = 3)
			
			_ArrayDelete ($pool, $track)
			if NOT IsArray ($pool) then
				ExitLoop
			endif
			
			$track = Random (0, UBound ($pool) - 1, 1)
			$_PLAYER_TRACKNUMBER = $pool[$track]
			
			Call ($_PLAYER_TRACKS[$_PLAYER_TRACKNUMBER])
			
		wend
		
		if $_PLAYER_LOOP <> 2 then
			Player_NextTrack ()
		endif
		
		if $_PLAYER_LOOP <> 1 AND $_PLAYER_LOOP <> 3 then
			$_PLAYER_STOP = 1
		endif
		
	wend
	
EndFunc

Func Player_Set_PauseBreak ($bool)
	if $bool then
		$_PLAYER_PAUSEBREAK = TRUE
	else
		$_PLAYER_PAUSEBREAK = FALSE
	endif
EndFunc

Func Player_PauseBreak ()
	while $_PLAYER_PAUSE
		sleep (10)
	wend
EndFunc

Func Player_NextTrack ()
	if $_PLAYER_RANDOM then
		$_PLAYER_TRACKNUMBER = Random (0, UBound ($_PLAYER_TRACKS) - 1, 1)
	else
		$_PLAYER_TRACKNUMBER += 1
		if $_PLAYER_TRACKNUMBER >= UBound ($_PLAYER_TRACKS) then
			$_PLAYER_TRACKNUMBER = 0
		endif
	endif
	TrayTip ("Player Track", $_PLAYER_TRACKS[$_PLAYER_TRACKNUMBER], 3600)
EndFunc

#EndRegion
