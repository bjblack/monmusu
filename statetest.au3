#include-once
AutoItSetOption("MustDeclareVars", 1)
#cs -----------------------------------------------------------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         B.J. Black

Statetest Description:
	State Tests are data structures that can be used to test the state of the active window. They contain pixel coordinates and
colors that correspond to states of the program.
	Statetests are an array of the following elements:
-	$statetest[0]:	$statecount
-	$statetest[1]:	$pixelcount
-	$statetest[2]:	$statenames[$statecount]
-	$statetest[3]:	$x[$pixelcount]
-	$statetest[4]:	$y[$pixelcount]
-	$statetest[5]:	$statecolors[$pixelcount][$statecount]
-	$statetest[6]:	$defaultreturn (a string (usually ""), or another statetest)
-	$statetest[7]: $bounds[4] = [$xmin, $ymin, $xmax, $ymax]

	Given any two indices $stateindex and $pixelindex in 0 to $statecount - 1 and 0 to $pixelcount - 1, respectively, the
values contained in $x, $y, and $statecolors will be the x-coordinate, y-coordinate, and color of a pixel which is always that
color whenever the program is in that state (colors are in hexadecimal format, prefixed with "0x").
	The states should be in alphabetical order, the pixels in (x, y) order (x being the more significant), if there is any intention of using the editing functions in my statetestedit.au3. The functions in this file are neutral to sorting.
	A complex statetest will have statetests loaded into the $statenames array and/or $defaultreturn.
	(Note when accessing indices 2 through 5 that you need to dereference the array to a variable, and dereference the variable
to get at the values- in AutoIt, you can't dereference an array inside an array.)

Statetest Storage:
	Statetests can be stored in standard INI files.
	In the "General" section are the $statecount, $pixelcount, and $defaultreturn values, under the keys "Statecount", "Pixelcount", and "DefaultReturn", respectively. (The value for $defaultreturn follows the rules for the statenames, below.)
	In the "Statenames" section are the $statenames values, under keys equal to their indices in $statenames. A statename starting with a backslash is taken as a subtest; the remainder of the string will be the subtest's filename- the statetest will be loaded from that file into the $statename array at that index. A regular statename starting with a backslash is legal; in the ini, it will be prefixed with two backslashes (one will be removed during loading).
	The other sections are named after indices to $x, $y, and $statecolors (first dimension), and contain values for the same
arrays, under keys "X", "Y", and indices to $statecolors (second dimension).

#include "statetest.au3"
; statetest	StateTestLoad ($inifilename)
; null StateTestFFSnapshot ($ffslot, $hwnd, $bounds = 0)
; null StateTestFFSnapshotCopy ($ffslotsrc, $ffslotdest)
; string StateTestFFUse ($ffslot, $statetest, $xoff, $yoff)
; string	StateTestWindowUse ($hwnd, $statetest, $xoff, $yoff)
; string	StateTestBitmapUse ($bitmap, $statetest, $xoff, $yoff)

#ce -----------------------------------------------------------------------------------------------------------------------------

#include <GDIP.au3>
; _GDIPlus_Startup ()
; _GDIPlus_BitmapGetPixel ($bitmap, $x, $y)
; _GDIPlus_Shutdown ()

; A useful utility by FastFrench, from the autoitscript.com forums.
;~ #include <FastFind.au3> ; My path- B.J. Black.
#include "FastFind.au3" ; Path for GitHub.
;~ FFSnapShot($left=0, $top=0, $right=0, $bottom=0, $NoSnapShot=$FFDefaultSnapShot, $WindowHandle=-1)
;~ FFGetPixel($x, $y, $NoSnapShot=$FFLastSnap)

Func StateTestLoad ($inifilename)
#cs -----------------------------------------------------------------------------------------------------------------------------
	StateTestLoad loads a statetest from an INI file.
	If the file is missing, returns a statetest containing 0 in both $statecount and $pixelcount and undefined values afterward. Also prints a line to the console.
	If the file exists but does not describe a statetest (or is improperly formatted), the function may return the same as with
a missing file, or may instead return a defective statetest or even crash the script (by dereferencing an array with an
out-of-bounds subscript).
#ce -----------------------------------------------------------------------------------------------------------------------------
	
	local $statecount = Int (IniRead ($inifilename, "General", "Statecount", 0))
	local $pixelcount = Int (IniRead ($inifilename, "General", "Pixelcount", 0))
	local $defaultreturn = IniRead ($inifilename, "General", "DefaultReturn", "")
	
	if $statecount <> 0 then
		local $statenames[$statecount]
	else
		local $statenames
	endif
	
	if $pixelcount <> 0 then
		local $x[$pixelcount]
		local $y[$pixelcount]
		if $statecount <> 0 then
			local $statecolors[$pixelcount][$statecount]
		else
			local $statecolors
		endif
	else
		local $x, $y, $statecolors
	endif
	
	local $bounds[4] = [100000, 100000, -100000, -100000]
	
	if StringLeft ($defaultreturn, 1) = "\" then
		; Escape character- Remove it and check for a second one.
		$defaultreturn = StringRight ($defaultreturn, StringLen ($defaultreturn) - 1)
		
		if StringLeft ($defaultreturn, 1) <> "\" then
			; No repeat of the escape character- This should be a subtest's filename.
			$defaultreturn = StateTestLoad ($defaultreturn)
		endif
	endif
	
	local $ini = FileOpen ($inifilename)
	if $ini = -1 then
		ConsoleWrite ("Missing ini file: " & $inifilename & @CRLF)
	endif
	local $str = FileReadLine ($ini)
	
	while NOT @error
		; Run this until FileReadLine sets @error (EOF).
		
		if StringLeft ($str, 1) = "[" AND StringRight ($str, 1) = "]" then
			; This is standard format for an INI section header.
			
			local $section = StringLeft (StringRight ($str, StringLen ($str) - 1), StringLen ($str) - 2)
			if $section = "Statenames" then
				; This is the section containing the state names.
				
				$str = FileReadLine ($ini)
				while NOT @error AND NOT (StringLeft ($str, 1) = "[" AND StringRight ($str, 1) = "]")
					; Run this until we find a new section header or EOF.
					
					local $strtokens = StringSplit ($str, "=")
					if $strtokens[0] = 2 then
						; The line is properly formatted.
						
						if StringIsDigit ($strtokens[1]) then
							; The key is our index number.
							$statenames[$strtokens[1]] = $strtokens[2]
							
							; Checking if it's a subtest...
							if StringLeft ($statenames[$strtokens[1]], 1) = "\" then
								; Escape character- Remove it and check for a second one.
								$statenames[$strtokens[1]] = StringRight ($statenames[$strtokens[1]], StringLen ($statenames[$strtokens[1]]) - 1)
								
								if StringLeft ($statenames[$strtokens[1]], 1) <> "\" then
									; No repeat of the escape character- This should be a subtest's filename.
									$statenames[$strtokens[1]] = StateTestLoad ($statenames[$strtokens[1]])
								endif
							endif
							
						endif
						
					endif
					
					$str = FileReadLine ($ini)
				wend
				
				
			elseif StringIsDigit ($section) then
				; The section name is a number- an index to my arrays.
				
				$str = FileReadLine ($ini)
				while NOT @error AND NOT (StringLeft ($str, 1) = "[" AND StringRight ($str, 1) = "]")
					; Run this until we find a new section header or EOF.
					
					local $strtokens = StringSplit ($str, "=")
					if $strtokens[0] = 2 then
						; The line is properly formatted.
						
						if $strtokens[1] = "X" then
							
							; This is our x-coordinate.
							local $xvalue = Number ($strtokens[2])
							
							$x[$section] = $xvalue
							
							if $xvalue < $bounds[0] then
								$bounds[0] = $xvalue
							endif
							if $xvalue > $bounds[2] then
								$bounds[2] = $xvalue
							endif
							
						elseif $strtokens[1] = "Y" then
							
							; This is our y-coordinate.
							local $yvalue = Number ($strtokens[2])
							
							$y[$section] = $yvalue
							
							if $yvalue < $bounds[1] then
								$bounds[1] = $yvalue
							endif
							if $yvalue > $bounds[3] then
								$bounds[3] = $yvalue
							endif
							
						elseif StringIsDigit ($strtokens[1]) then
							; This is the index and value for $statecolors.
							$statecolors[$section][$strtokens[1]] = Number ($strtokens[2])
						endif
						
					endif
					
					$str = FileReadLine ($ini)
				wend
				
			else
				; We need a new line from the file.
				$str = FileReadLine ($ini)
			endif
			
		else
			; We need a new line from the file.
			$str = FileReadLine ($ini)
		endif
		
	wend
	SetError (0)
	
	FileClose ($ini)
	
	local $statetest[8] = [$statecount, $pixelcount, $statenames, $x, $y, $statecolors, $defaultreturn, $bounds]
	return $statetest
	
EndFunc

Func StateTestFFSnapshot ($ffslot, $hwnd, $bounds = 0)
	
	; Get the client's origin on screen.
	local $tpoint = DllStructCreate("int X;int Y")
	DllStructSetData($tpoint, "X", 0)
	DllStructSetData($tpoint, "Y", 0)
	_WinAPI_ClientToScreen ($hwnd, $tpoint)
	
	; Get the origin.
	$FFSnapOrigin[$ffslot][0] = DllStructGetData ($tpoint, "X")
	$FFSnapOrigin[$ffslot][1] = DllStructGetData ($tpoint, "Y")
	
	; Check the passed rectangle (Format: [$left, $top, $right, $bottom]).
	if IsArray ($bounds) then
		
		; Adjust the origin.
		local $left = $bounds[0]
		local $top = $bounds[1]
		
		; Take the dimensions.
		local $right = $bounds[2]
		local $bottom = $bounds[3]
		
	else
		
		; Get the client's size.
		local $dims = WinGetClientSize ($hwnd)
		
		; Make the dimensions.
		local $left = $FFSnapOrigin[$ffslot][0]
		local $top = $FFSnapOrigin[$ffslot][1]
		local $right = $FFSnapOrigin[$ffslot][0] + $dims[0] - 1
		local $bottom = $FFSnapOrigin[$ffslot][1] + $dims[1] - 1
		
		; Check the $left and $top for negatives (damn FastFind again!)
		if $left < 0 then
			$left = 0
		endif
		if $top < 0 then
			$top = 0
		endif
		
	endif
	
	; Take snapshot.
;~ 	ConsoleWrite ("$bounds = [" & $left & ", " & $top & ", " & $right & ", " & $bottom & ")" & @CRLF)
;~ 	ConsoleWrite ("FFSnapShot (" & $left & ", " & $top & ", " & $right & ", " & $bottom & ", " & $ffslot & ", 0)" & @CRLF)
	local $msg = FFSnapShot ($left, $top, $right, $bottom, $ffslot, 0)
	if @Error then
		ConsoleWrite ("FFSnapShot error = " & @Error & " with return message = " & $msg)
		SetError (0)
	endif
;~ 	FFSaveBMP ("tmp")
	
	#cs
	; Check the passed rectangle (Format: [$left, $top, $right, $bottom]).
	if IsArray ($bounds) then
		
		; Adjust the origin.
		local $left = $bounds[0]
		local $top = $bounds[1]
		
		; Take the dimensions.
		local $right = $bounds[2]
		local $bottom = $bounds[3]
		
	else
		
		; Get the client's size.
		local $dims = WinGetClientSize ($hwnd)
		
		; Make the dimensions.
		local $left = $FFSnapOrigin[$ffslot][0]
		local $top = $FFSnapOrigin[$ffslot][1]
		local $right = $FFSnapOrigin[$ffslot][0] + $dims[0] - 1
		local $bottom = $FFSnapOrigin[$ffslot][1] + $dims[1] - 1
		
		; Check the $left and $top for negatives (damn new version of Firefox!)
		if $left < 0 then
			$left = 0
		endif
		if $top < 0 then
			$top = 0
		endif
		
	endif
	
	; Get the client's origin on screen.
	local $tpoint = DllStructCreate("int X;int Y")
	DllStructSetData($tpoint, "X", 0)
	DllStructSetData($tpoint, "Y", 0)
	_WinAPI_ClientToScreen ($hwnd, $tpoint)
	
	; Get the origin.
	$FFSnapOrigin[$ffslot][0] = DllStructGetData ($tpoint, "X")
	$FFSnapOrigin[$ffslot][1] = DllStructGetData ($tpoint, "Y")
	
	; Take snapshot.
	ConsoleWrite ("$bounds = [" & $left & ", " & $top & ", " & $right & ", " & $bottom & ")" & @CRLF)
	FFSnapShot ($left, $top, $right, $bottom, $ffslot, 0)
;~ 	FFSaveBMP ("tmp")
	#ce
	
EndFunc

Func StateTestFFSnapshotCopy ($ffslotsrc, $ffslotdest)
	
	; Copies a snapshot into another slot.
	FFDuplicateSnapShot($ffslotsrc, $ffslotdest)
	$FFSnapOrigin[$ffslotdest][0] = $FFSnapOrigin[$ffslotsrc][0]
	$FFSnapOrigin[$ffslotdest][1] = $FFSnapOrigin[$ffslotsrc][1]
	
EndFunc

Func StateTestFFUse ($ffslot, $statetest, $xoff = 0, $yoff = 0)
#cs -----------------------------------------------------------------------------------------------------------------------------
	StateTestUse uses a statetest on a FastFind snapshot (User responsible for snapshot using StateTestFFSnapshot.)
	Returns the name of the state that matches, "" when no state matches.
#ce -----------------------------------------------------------------------------------------------------------------------------
	
	if NOT IsArray ($statetest) then
		return ""
	endif
	
	local $statecount = $statetest[0]
	local $pixelcount = $statetest[1]
	local $statenames = $statetest[2]
	local $x = $statetest[3]
	local $y = $statetest[4]
	local $statecolors = $statetest[5]
	local $defaultreturn = $statetest[6]
	local $bounds = $statetest[7]
	
	if $pixelcount = 0 then
		; Special case, no pixels to test.
		return ""
	endif
	
	for $stateindex = 0 to $statecount - 1
		; Testing every state in the test.
		
		for $pixelindex = 0 to $pixelcount - 1
			; Testing every pixel for the test.
			
			if $statecolors[$pixelindex][$stateindex] <> FFGetPixel ($x[$pixelindex] + $xoff, $y[$pixelindex] + $yoff, $ffslot) then
				; It's not this state.
				ContinueLoop 2
			endif
			
		next
		; Every pixel checks.
		
		if IsString ($statenames[$stateindex]) then
			return $statenames[$stateindex]
		else
			local $ret = StateTestFFUse ($ffslot, $statenames[$stateindex], $xoff, $yoff)
			if StringCompare ($ret, "") <> 0 then
				return $ret
			else
				exitloop
			endif
		endif
		
	next
	; No state matches.
	
	if IsString ($defaultreturn) then
		return $defaultreturn
	else
		return StateTestFFUse ($ffslot, $defaultreturn, $xoff, $yoff)
	endif
	
EndFunc

Func StateTestWindowUse ($hwnd, $statetest, $xoff, $yoff)
#cs -----------------------------------------------------------------------------------------------------------------------------
	StateTestUse uses a statetest on an active window.
	Returns the name of the state that matches, "" when no state matches.
#ce -----------------------------------------------------------------------------------------------------------------------------
	
	StateTestFFSnapshot (0, $hwnd) ; Shooting the full window.
;~ 	StateTestFFSnapshot (0, $hwnd, $statetest[7]) ; Shooting just the area of the statetest.
	
	return StateTestFFUse (0, $statetest, $xoff, $yoff)
	
EndFunc

Func StateTestBitmapUse ($bitmap, $statetest, $xoff, $yoff)
#cs -----------------------------------------------------------------------------------------------------------------------------
	StateTestUse uses a statetest on a bitmap.
	Calls _GDIPlus_BitmapGetPixel, so the calling script needs to call
_GDIPlus_Startup before calling this.
	Returns the name of the state that matches, "" when no state matches.
#ce -----------------------------------------------------------------------------------------------------------------------------
	local $statecount = $statetest[0]
	local $pixelcount = $statetest[1]
	local $statenames = $statetest[2]
	local $x = $statetest[3]
	local $y = $statetest[4]
	local $statecolors = $statetest[5]
	local $defaultreturn = $statetest[6]
	
	if $pixelcount = 0 then
		; Special case, no pixels to test.
		return ""
	endif
	
	for $stateindex = 0 to $statecount - 1
		; Testing every state in the test.
		
		for $pixelindex = 0 to $pixelcount - 1
			; Testing every pixel for the test.
			
			; _GDIPlus_BitmapGetPixel returns a color with a byte of alpha, so we mask that out.
			if $statecolors[$pixelindex][$stateindex] <> BitAND (_GDIPlus_BitmapGetPixel ($bitmap, $x[$pixelindex] + $xoff, $y[$pixelindex] + $yoff), 0x00FFFFFF) then
				; It's not this state.
				ContinueLoop 2
			endif
			
		next
		; Every pixel checks.
		
		if IsString ($statenames[$stateindex]) then
			return $statenames[$stateindex]
		else
			local $ret = StateTestBitmapUse ($bitmap, $statenames[$stateindex], $xoff, $yoff)
			if StringCompare ($ret, "") <> 0 then
				return $ret
			else
				ExitLoop
			endif
		endif
		
	next
	; No state matches.
	
	if IsString ($defaultreturn) then
		return $defaultreturn
	else
		return StateTestBitmapUse ($bitmap, $defaultreturn, $xoff, $yoff)
	endif
	
EndFunc
