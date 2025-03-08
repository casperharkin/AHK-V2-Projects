#Requires AutoHotkey v2.0
#SingleInstance Force

;==================================================================================================================
; Side Toolbar Class
;==================================================================================================================
; Description:    Creates a customizable side toolbar that docks to the right side of the screen
;                 and adjusts the Windows work area accordingly. The toolbar provides a clean
;                 interface with menu buttons, action buttons, and a notes area.
;
; Features:       - Docks to the right side of the screen
;                 - Automatically adjusts Windows work area to prevent windows from being covered
;                 - Menu buttons with hover effects (File, Edit, Tools)
;                 - Dropdown menus for each menu button
;                 - Customizable action buttons
;                 - Notes area with multi-line edit control
;                 - Custom-styled GUI with colored borders
;
; Usage:          Simply instantiate the class to activate:
;                 SideToolbar()
;
; Dependencies:   - AutoHotkey v2
;                 - Windows API for DPI awareness and work area adjustment
;
; Author:         Original code refactored and improved
; Version:        1.0
; Last Updated:   2025-03-08
;==================================================================================================================

; Set DPI awareness for proper scaling
; DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED := -5
DllCall("SetThreadDpiAwarenessContext", "ptr", -5, "ptr")

; Initialize the toolbar
SideToolbar()

; OnExit handler to restore work area
OnExit((*) => SideToolbar.RestoreWorkArea())

class SideToolbar {
    ; Static properties
    static Instance := ""
    static Handles := Map()
    
    ; Instance properties
    Gui := ""
    FileMenu := ""
    EditMenu := ""
    ToolsMenu := ""
    GuiWidth := 0
    
    __New() {
        ; Store instance reference
        SideToolbar.Instance := this
        
        ; Create GUI
        this.Gui := Gui()
        this.Gui.Opt("+LastFound -ToolWindow +AlwaysOnTop -Caption -DPIScale") 
        this.Gui.BackColor := "FFFFFF"
        this.Gui.SetFont("s9 cFFFFFF", "Segoe UI") 
        
        ; Create GUI elements
        this.CreateHeader()
        this.CreateMenuButtons()
        this.CreateControls()
        
        ; Set up event handlers
        OnMessage(0x200, this.WM_MOUSEMOVE.Bind(this))
        OnMessage(0x202, this.WM_LBUTTONUP.Bind(this))
        
        ; Create menus
        this.SetupMenus()
        
        ; Calculate dimensions and position
        this.CalculatePosition()
        
        ; Show GUI and adjust work area
        this.Gui.Show("x" (A_ScreenWidth - this.GuiWidth) " y0 w" this.GuiWidth " h" this.WorkAreaHeight)
        this.SetWorkArea(0, 0, A_ScreenWidth - this.GuiWidth, this.WorkAreaHeight)
        
        ; Create borders
        this.CreateBorders() 
    }
    
    CreateHeader() {
        ; Blue header background
        hTitleHeader := this.Gui.Add("Text", "x1 y0 w545 h65 +0x4E", "HELLO AHK V2").Hwnd
        DllCall("SendMessage", "Ptr", hTitleHeader, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
        
        ; Title text
        this.Gui.SetFont("Bold s10")
        this.Gui.Add("Text", "x0 y6 w215 h24 +BackgroundTrans +0x201", "Toolbar")
        this.Gui.SetFont()
    }
    
    CreateMenuButtons() {
        ; File Menu
        hButtonMenuFileN := this.Gui.Add("Picture", "x15 y30 w60 h24 +0x4E").Hwnd
        hButtonMenuFileH := this.Gui.Add("Picture", "xp yp wp hp +0x4E Hidden1").Hwnd
        DllCall("SendMessage", "Ptr", hButtonMenuFileN, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
        DllCall("SendMessage", "Ptr", hButtonMenuFileH, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("2A8AD4", 1, 1))
        hButtonMenuFileText := this.Gui.Add("Text", "x15 y30 w60 h24 +BackgroundTrans +0x201", "File").Hwnd
        
        ; Edit Menu
        hButtonMenuEditN := this.Gui.Add("Picture", "x+2 yp w60 h24 +0x4E").Hwnd
        hButtonMenuEditH := this.Gui.Add("Picture", "xp yp wp hp +0x4E Hidden1").Hwnd
        DllCall("SendMessage", "Ptr", hButtonMenuEditN, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
        DllCall("SendMessage", "Ptr", hButtonMenuEditH, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("2A8AD4", 1, 1))
        hButtonMenuEditText := this.Gui.Add("Text", "xp yp wp hp +BackgroundTrans +0x201", "Edit").Hwnd
        
        ; Tools Menu
        hButtonMenuToolsN := this.Gui.Add("Picture", "x+2 yp w60 h24 +0x4E").Hwnd
        hButtonMenuToolsH := this.Gui.Add("Picture", "xp yp wp hp +0x4E Hidden1").Hwnd
        DllCall("SendMessage", "Ptr", hButtonMenuToolsN, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
        DllCall("SendMessage", "Ptr", hButtonMenuToolsH, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("2A8AD4", 1, 1))
        hButtonMenuToolsText := this.Gui.Add("Text", "xp yp wp hp +BackgroundTrans +0x201", "Tools").Hwnd
        
        ; Store handles in the static Handles map
        SideToolbar.Handles := Map(
            "hButtonMenuFileN", hButtonMenuFileN,
            "hButtonMenuFileH", hButtonMenuFileH,
            "hButtonMenuFileText", hButtonMenuFileText,
            "hButtonMenuEditN", hButtonMenuEditN,
            "hButtonMenuEditH", hButtonMenuEditH,
            "hButtonMenuEditText", hButtonMenuEditText,
            "hButtonMenuToolsN", hButtonMenuToolsN,
            "hButtonMenuToolsH", hButtonMenuToolsH,
            "hButtonMenuToolsText", hButtonMenuToolsText
        )
    }
    
    CreateControls() {
        ; Adding Button controls
        this.Button1 := this.Gui.Add("Button", "x11 y70 w310 h23", "Button 1")
        this.Button1.OnEvent("Click", this.MenuHandler.Bind(this))
        
        this.Gui.Add("Button", "x11 yp+29 w310 h23", "Button 2").OnEvent("Click", this.MenuHandler.Bind(this))
        this.Gui.Add("Button", "x11 yp+29 w310 h23", "Button 3").OnEvent("Click", this.MenuHandler.Bind(this))
        this.Gui.Add("Button", "x11 yp+29 w310 h23", "Button 4").OnEvent("Click", this.MenuHandler.Bind(this))
        this.Gui.Add("Button", "x11 yp+29 w310 h23", "Button 5").OnEvent("Click", this.MenuHandler.Bind(this))
        
        ; Notes area
        this.Gui.Add("GroupBox", "x11 yp+29 w310 h860", "Quick Notes")
        this.Gui.Add("Edit", "x15 yp+15 w304 h840 -E0x200 +Multi")
    }
    
    CalculatePosition() {
        ; Get button width for calculating GUI width
        ControlGetPos(,,&ctlW,, GuiCtrlFromHwnd(this.Button1.Hwnd))
        this.GuiWidth := ctlW + 23
        
        ; Calculate taskbar height
        MonitorGetWorkArea(1,,,, &waBottom)
        MonitorGet(1,,,, &bottom)
        taskbarHeight := bottom - waBottom
        
        ; Set work area height
        this.WorkAreaHeight := A_ScreenHeight - taskbarHeight
    }
    
    SetupMenus() {
        ; File Menu
        this.FileMenu := Menu()
        this.FileMenu.Add("FileMenu: Item 1", this.MenuHandler.Bind(this))
        this.FileMenu.Add("FileMenu: Item 2", this.MenuHandler.Bind(this))
        this.FileMenu.Add("FileMenu: Item 3", this.MenuHandler.Bind(this))
        
        ; Edit Menu
        this.EditMenu := Menu()
        this.EditMenu.Add("EditMenu: Item 1", this.MenuHandler.Bind(this))
        this.EditMenu.Add("EditMenu: Item 2", this.MenuHandler.Bind(this))
        this.EditMenu.Add("EditMenu: Item 3", this.MenuHandler.Bind(this))
        
        ; Tools Menu
        this.ToolsMenu := Menu()
        this.ToolsMenu.Add("ToolsMenu: Item 1", this.MenuHandler.Bind(this))
        this.ToolsMenu.Add("ToolsMenu: Item 2", this.MenuHandler.Bind(this))
        this.ToolsMenu.Add("ToolsMenu: Item 3", this.MenuHandler.Bind(this))
    }
    
    CreateBorders() {
        this.Gui.GetClientPos(&x, &y, &width, &height)
        
        hBorderLeft := this.Gui.Add("Text", "x1 y1 w1 h" height " +0x4E").Hwnd
        DllCall("SendMessage", "Ptr", hBorderLeft, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0072C6", 1, 1))
        
        hBorderRight := this.Gui.Add("Text", "x" width-2 " y0 w2 h" height " +0x4E").Hwnd
        DllCall("SendMessage", "Ptr", hBorderRight, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0072C6", 1, 1))
        
        hBorderBottom := this.Gui.Add("Text", "x1 y" height-1 " w" width-10 " h2 +0x4E").Hwnd
        DllCall("SendMessage", "Ptr", hBorderBottom, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0072C6", 1, 1))
    }
    
    WM_LBUTTONUP(wParam, lParam, msg, hwnd) {
        MouseGetPos , , &id, &control, 2
        
        if (control = SideToolbar.Handles["hButtonMenuFileText"]) {
            ControlGetPos(&ctlX, &ctlY, &ctlW, &ctlH, GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuFileText"]))
            this.FileMenu.Show(ctlX, ctlY + ctlH)
        } else if (control = SideToolbar.Handles["hButtonMenuEditText"]) {
            ControlGetPos(&ctlX, &ctlY, &ctlW, &ctlH, GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuEditText"]))
            this.EditMenu.Show(ctlX, ctlY + ctlH)
        } else if (control = SideToolbar.Handles["hButtonMenuToolsText"]) {
            ControlGetPos(&ctlX, &ctlY, &ctlW, &ctlH, GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuToolsText"]))
            this.ToolsMenu.Show(ctlX, ctlY + ctlH)
        }
    }
    
    WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
        MouseGetPos , , &id, &control, 2
        
        ; Handle hover effects for menu buttons
        try _ := control=SideToolbar.Handles["hButtonMenuFileText"] ? 
            ControlShow(GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuFileH"])) : 
            ControlHide(GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuFileH"]))
            
        try _ := control=SideToolbar.Handles["hButtonMenuEditText"] ? 
            ControlShow(GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuEditH"])) : 
            ControlHide(GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuEditH"]))
            
        try _ := control=SideToolbar.Handles["hButtonMenuToolsText"] ? 
            ControlShow(GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuToolsH"])) : 
            ControlHide(GuiCtrlFromHwnd(SideToolbar.Handles["hButtonMenuToolsH"]))
    }
    
    CreateDIB(input, w, h, resizeW := 0, resizeH := 0, gradient := 1) {
        wb := Ceil((w * 3) / 2) * 2
        bmbits := Buffer(wb * h, 0)  
        p := bmbits.Ptr  
        
        parts := StrSplit(input, "|")  
        for index, value in parts {
            NumPut("UInt", "0x" . value, p)   
            p += 4 - (w & 1 && Mod(index * 3, w * 3) = 0 ? 0 : 1)  ; Increment pointer
        }
        
        hBM := DllCall("CreateBitmap", "Int", w, "Int", h, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
        hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
        DllCall("SetBitmapBits", "Ptr", hBM, "UInt", wb * h, "Ptr", bmbits.Ptr)
        
        if (gradient != 1) {
            hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
        }
        
        return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", resizeW, "Int", resizeH, "Int", 0x200C, "UPtr")
    }
    
    SetWorkArea(left, top, right, bottom) {
        area := Buffer(16)  ; 16 bytes
        NumPut("Int", left, area, 0)   
        NumPut("Int", top, area, 4)    
        NumPut("Int", right, area, 8)   
        NumPut("Int", bottom, area, 12) 
        DllCall("SystemParametersInfo", "UInt", 0x2F, "UInt", 0, "Ptr", area, "UInt", 0)  ; SPI_SETWORKAREA
    }
    
    MenuHandler(item, *) {
        try MsgBox("You selected " item)
        try MsgBox("You selected " item.text)
    }
    
    static RestoreWorkArea() {
        if SideToolbar.Instance {
            SideToolbar.Instance.SetWorkArea(0, 0, A_ScreenWidth, A_ScreenHeight-((40*A_ScreenDPI) / 96))
        }
    }
}