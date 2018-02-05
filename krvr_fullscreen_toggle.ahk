;
; Toggle between: 
;  A) Expand the focused window to fill all screens.
;  B) Maximize the screen to fit its primary screen.
;

c_MAXMAX_TRACKER_INDEX_NOT_FOUND = 0

c_MAXMAX_UNKNOWN = -42
c_MAXMAX_FULL = 9001
c_MAXMAX_MAX = 1 
c_MAXMAX_MIN = -1
c_MAXMAX_USER = 0

c_MinMax_MAX = 1
c_MinMax_MIN = -1
c_MinMax_USER = 0

v_MaxMaxTracker := []
v_WindowMaxMaxIndex = -99
v_MaxMaxState := c_MAXMAX_UNKNOWN

ToggleMaximizeOverAllScreens() 
{
    global
    ; =========================================================================
    ;
    ; MAIN EXECUTION
    ;
    ;

    ;
    ; Variables
    ;
    

    ; Get Active Window ID
    WinGet, v_Id, ID, A
    WinGet, v_MinMax, MinMax, A

    Gosub, TMOAS_GetMaxMaxStateForWindowId

    if ( v_MaxMaxState = c_MAXMAX_USER or v_MaxMaxState = c_MAXMAX_MIN or v_MaxMaxState = c_MAXMAX_MAX ) 
    { 
        if ( v_MinMax == 1 ) {
            WinRestore, ahk_id %v_Id%
        }

        v_Left := 0
        v_Top := 0
        v_Right := 0
        v_Bottom := 0

        SysGet, v_MonitorCount, MonitorCount
        Loop, %v_MonitorCount%
        {
            SysGet, v_Monitor, Monitor, %A_Index%

            if ( v_Top > v_MonitorTop ) {
                v_Top := v_MonitorTop
            }

            if ( v_Left > v_MonitorLeft ) {
                v_Left := v_MonitorLeft
            }

            if ( v_Right < v_MonitorRight ) {
                v_Right := v_MonitorRight
            }

            if ( v_Bottom < v_MonitorBottom ) {
                v_Bottom := v_MonitorBottom
            }

        }

        ; v_Width := Abs(v_Left - v_Right)
        ; v_Height := Abs(v_Top - v_Bottom)

        SysGet, v_VirtualWidth, 78
        SysGet, v_VirtualHeight, 79

        ; Move and resize the window so that it spans the entire view over all displays.
        WinMove, ahk_id %v_Id%, , %v_Left%, %v_Top%, %v_VirtualWidth%, %v_VirtualHeight%

        v_MaxMaxTracker.Push(v_Id)
    }
    else if ( v_MaxMaxState == c_MAXMAX_FULL ) 
    {
        Gosub, TMOAS_FindIndexForWindowId
        if ( v_WindowMaxMaxIndex != c_MAXMAX_TRACKER_INDEX_NOT_FOUND ) {
            WinMaximize, ahk_id %v_Id%
            v_MaxMaxTracker.RemoveAt(v_WindowMaxMaxIndex)
        }
        else {
            MsgBox % "Window ID not found in tracker."
        }
    }
    else if ( v_MaxMaxState == c_MAXMAX_UNKNOWN ) {
        MsgBox % "Unable to determine window starting state. Cannot manipulate window."
    }    


    ; =========================================================================
    ; 
    ; SUBROUTINES
    ;
    ;

    ; ----------
    ; Count the number of elements in the maxed windows array.
    ;
    TMOAS_CountMaxedWindows:
    v_ElementCount = 0;
    for key, value in v_MaxMaxTracker
    {
        v_ElementCount++
    }
    return

    ; ----------
    ; Get the index position for the stored id
    ;
    TMOAS_FindIndexForWindowId:
    v_WindowMaxMaxIndex := c_MAXMAX_TRACKER_INDEX_NOT_FOUND
    for key, value in v_MaxMaxTracker 
    {
        if ( value == v_Id ) {
            v_WindowMaxMaxIndex := key
            return
        }
    }
    return

    ;
    ;
    ;
    TMOAS_GetMaxMaxStateForWindowId:
    if ( v_MinMax == c_MinMax_USER )
    {
        Gosub, TMOAS_FindIndexForWindowId
        if ( v_WindowMaxMaxIndex < 1 )
        {
            ; Window is neither minimized nor maximized
            v_MaxMaxState := c_MAXMAX_USER
        }
        else {
            ; Window is maxmax'ed
            v_MaxMaxState := c_MAXMAX_FULL
        }
    }
    else if ( v_MinMax == c_MinMax_MAX )
    {
        v_MaxMaxState := c_MAXMAX_MAX
    }
    else if ( v_MinMax == c_MinMax_MIN )
    {
        v_MaxMaxState := c_MAXMAX_MIN
    }
    else 
    {
        v_MaxMaxState := c_MAXMAX_UNKNOWN
    }
    return 

}

; =============================================================================
;
; HOTKEYS
;
;
#Numpad0::
ToggleMaximizeOverAllScreens()
return

