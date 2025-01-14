                    #Requires AutoHotkey v2.0
                    OnExit Exiting

                    ;https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context
                    ;https://www.autohotkey.com/boards/viewtopic.php?t=90374
                    ;DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED := -5
                    DllCall("SetThreadDpiAwarenessContext", "ptr", -5, "ptr")

                    MyGuiInstance := MyGuiClass()

                    MenuHandler(Item, *) {
                        Try MsgBox("You selected " Item)
                        Try MsgBox("You selected " Item.text)
                    }

                    Exiting(*){
                        MyGuiInstance.SetWorkArea(0, 0, A_ScreenWidth, A_ScreenHeight-((40*A_ScreenDPI) / 96))
                    }

                    class MyGuiClass {
                        __New() {

                            MyGui := Gui()
                            MyGui.Opt("+LastFound -ToolWindow +AlwaysOnTop -Caption -DPIScale") 

                            MyGui.BackColor := "FFFFFF"
                            MyGui.SetFont("s9 cFFFFFF", "Segoe UI") 

                            ; Blue Menu BG
                            DllCall("SendMessage", "Ptr", hTitleHeader := MyGui.Add("Text", "x1 y0 w545 h65 +0x4E", "HELLO AHK V2").Hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))

                            ; File Menu
                            hButtonMenuFileN := MyGui.Add("Picture", "x15 y30 w60 h24 +0x4E").Hwnd
                            hButtonMenuFileH := MyGui.Add("Picture", "xp yp wp hp +0x4E Hidden1").Hwnd
                            DllCall("SendMessage", "Ptr", hButtonMenuFileN, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
                            DllCall("SendMessage", "Ptr", hButtonMenuFileH, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("2A8AD4", 1, 1))
                            hButtonMenuFileText := MyGui.Add("Text", "x15 y30 w60 h24 +BackgroundTrans +0x201", "File").Hwnd

                            ; Edit Menu
                            hButtonMenuEditN := MyGui.Add("Picture", "x+2 yp w60 h24 +0x4E").Hwnd
                            hButtonMenuEditH := MyGui.Add("Picture", "xp yp wp hp +0x4E Hidden1").Hwnd
                            DllCall("SendMessage", "Ptr", hButtonMenuEditN, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
                            DllCall("SendMessage", "Ptr", hButtonMenuEditH, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("2A8AD4", 1, 1))
                            hButtonMenuEditText := MyGui.Add("Text", "xp yp wp hp +BackgroundTrans +0x201", "Edit").Hwnd

                            ; Tools Menu
                            hButtonMenuToolsN := MyGui.Add("Picture", "x+2 yp w60 h24 +0x4E").Hwnd
                            hButtonMenuToolsH := MyGui.Add("Picture", "xp yp wp hp +0x4E Hidden1").Hwnd
                            DllCall("SendMessage", "Ptr", hButtonMenuToolsN, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0173C7", 1, 1))
                            DllCall("SendMessage", "Ptr", hButtonMenuToolsH, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("2A8AD4", 1, 1))
                            hButtonMenuToolsText := MyGui.Add("Text", "xp yp wp hp +BackgroundTrans +0x201", "Tools").Hwnd

                            ; Title 
                            MyGui.SetFont("Bold s10")
                            MyGui.Add("Text", "x0 y6 w215 h24 +BackgroundTrans +0x201", "Toolbar")
                            MyGui.SetFont()

                            ; Adding Button controls
                            XMyBtnButton := MyGui.Add("Button", "x11 y70 w310 h23", "Button 1")
                            XMyBtnButton.OnEvent("Click", MenuHandler)
                            MyGui.Add("Button", "x11 yp+29 w310 h23", "Button 2").OnEvent("Click", MenuHandler)
                            MyGui.Add("Button", "x11 yp+29 w310 h23", "Button 3").OnEvent("Click", MenuHandler)
                            MyGui.Add("Button", "x11 yp+29 w310 h23", "Button 4").OnEvent("Click", MenuHandler)
                            MyGui.Add("Button", "x11 yp+29 w310 h23", "Button 5").OnEvent("Click", MenuHandler)

                            MyGui.Add("GroupBox", "x11 yp+29 w310 h860", "Quick Notes")
                            MyGui.Add("Edit", "x15 yp+15 w304 h840 -E0x200 +Multi")

                            ; yeah, i know. 
                            Global __Handles := {} 
                            __Handles.hButtonMenuFileN := hButtonMenuFileN
                            __Handles.hButtonMenuFileH := hButtonMenuFileH
                            __Handles.hButtonMenuFileText := hButtonMenuFileText
                            __Handles.hButtonMenuEditN := hButtonMenuEditN
                            __Handles.hButtonMenuEditH := hButtonMenuEditH
                            __Handles.hButtonMenuEditText := hButtonMenuEditText
                            __Handles.hButtonMenuToolsN := hButtonMenuToolsN
                            __Handles.hButtonMenuToolsH := hButtonMenuToolsH
                            __Handles.hButtonMenuToolsText := hButtonMenuToolsText    

                            OnMessage(0x200, this.WM_MOUSEMOVE.Bind(this))
                            OnMessage(0x202, this.WM_LBUTTONUP.Bind(this))
                            this.Menus()

                            ControlGetPos(,,&ctlW,, GuiCtrlFromHwnd(XMyBtnButton.Hwnd))
                            guiWidth := ctlW+23

                            MonitorGetWorkArea(1,,,, &WABottom)
                            MonitorGet(1,,,, &Bottom)
                            TaskbarHeight := Bottom - WABottom

                            MyGui.Show("x" (A_ScreenWidth - guiWidth) " y0 w" guiWidth " h" A_ScreenHeight-TaskbarHeight)
                            This.SetWorkArea(0, 0, A_ScreenWidth - guiWidth, A_ScreenHeight-TaskbarHeight)

                            this.CreateBorders(MyGui) 
                        }

                        WM_LBUTTONUP(wParam, lParam, msg, hwnd) {
                            MouseGetPos , , &id, &control, 2
                            if (control = __Handles.hButtonMenuFileText) {
                                ControlGetPos(&ctlX, &ctlY, &ctlW, &ctlH, GuiCtrlFromHwnd(__Handles.hButtonMenuFileText))
                                This.FileMenu.Show(ctlX, ctlY + ctlH)
                            } else if (control = __Handles.hButtonMenuEditText) {
                                ControlGetPos(&ctlX, &ctlY, &ctlW, &ctlH, GuiCtrlFromHwnd(__Handles.hButtonMenuEditText))
                                This.EditMenu.Show(ctlX, ctlY + ctlH)
                            } else if (control = __Handles.hButtonMenuToolsText) {
                                ControlGetPos(&ctlX, &ctlY, &ctlW, &ctlH, GuiCtrlFromHwnd(__Handles.hButtonMenuToolsText))
                                This.ToolsMenu.Show(ctlX, ctlY + ctlH)
                            }
                        }

                        WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
                            MouseGetPos , , &id, &control,2
                            try _ := control=__Handles.hButtonMenuFileText ? ControlShow(GuiCtrlFromHwnd(__Handles.hButtonMenuFileH)) : ControlHide(GuiCtrlFromHwnd(__Handles.hButtonMenuFileH))
                            try _ := control=__Handles.hButtonMenuEditText ? ControlShow(GuiCtrlFromHwnd(__Handles.hButtonMenuEditH)) : ControlHide(GuiCtrlFromHwnd(__Handles.hButtonMenuEditH))
                            try _ := control=__Handles.hButtonMenuToolsText ? ControlShow(GuiCtrlFromHwnd(__Handles.hButtonMenuToolsH)) : ControlHide(GuiCtrlFromHwnd(__Handles.hButtonMenuToolsH))
                        }

                        CreateDIB(Input, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1) {
                            WB := Ceil((W * 3) / 2) * 2
                            BMBITS := Buffer(WB * H, 0)  
                            P := BMBITS.Ptr  

                            Parts := StrSplit(Input, "|")  
                            For Index, Value in Parts {
                                NumPut("UInt", "0x" . Value, P)   
                                P += 4 - (W & 1 && Mod(Index * 3, W * 3) = 0 ? 0 : 1)  ; Increment pointer
                            }

                            hBM := DllCall("CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
                            hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
                            DllCall("SetBitmapBits", "Ptr", hBM, "UInt", WB * H, "Ptr", BMBITS.Ptr)

                            if (Gradient != 1) {
                                hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
                            }
                            return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", 0x200C, "UPtr")
                        }

                        CreateBorders(MyGui){
                            MyGui.GetClientPos(&X, &Y, &Width, &Height)
                            DllCall("SendMessage", "Ptr", hBorderLeft := MyGui.Add("Text", "x1 y1 w1 h" Height " +0x4E").Hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0072C6", 1, 1))
                            DllCall("SendMessage", "Ptr", hBorderRight := MyGui.Add("Text", "x" Width-2 " y0 w2 h" Height " +0x4E").Hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0072C6", 1, 1))
                            DllCall("SendMessage", "Ptr", hBorderBottom := MyGui.Add("Text", "x1 y" Height-1 " w" Width-10 " h2 +0x4E").Hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB("0072C6", 1, 1))
                        }

                        Menus() {
                            This.FileMenu := Menu()
                            This.FileMenu.Add("FileMenu: Item 1", MenuHandler)
                            This.FileMenu.Add("FileMenu: Item 2", MenuHandler)
                            This.FileMenu.Add("FileMenu: Item 3", MenuHandler)

                            This.EditMenu := Menu()
                            This.EditMenu.Add("EditMenu: Item 1", MenuHandler)
                            This.EditMenu.Add("EditMenu: Item 2", MenuHandler)
                            This.EditMenu.Add("EditMenu: Item 3", MenuHandler)

                            This.ToolsMenu := Menu()
                            This.ToolsMenu.Add("ToolsMenu: Item 1", MenuHandler)
                            This.ToolsMenu.Add("ToolsMenu: Item 2", MenuHandler)
                            This.ToolsMenu.Add("ToolsMenu: Item 3", MenuHandler)
                        }

                        SetWorkArea(left, top, right, bottom) {  ; windows are not resized!
                            area := Buffer(16)  ; 16 bytes
                            NumPut("Int", left, area, 0)   
                            NumPut("Int", top, area, 4)    
                            NumPut("Int", right, area, 8)   
                            NumPut("Int", bottom, area, 12) 
                            DllCall("SystemParametersInfo", "UInt", 0x2F, "UInt", 0, "Ptr", area, "UInt", 0)  ; SPI_SETWORKAREA
                        }


                    }