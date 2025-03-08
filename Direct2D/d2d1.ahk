#Requires AutoHotkey v2.0
#SingleInstance Force

;==================================================================================================================
; Direct2D Wrapper Class
;==================================================================================================================
; Description:    A wrapper class for the Direct2D API that simplifies drawing operations
;                 on GUI windows. This class provides an object-oriented interface to
;                 Direct2D's hardware-accelerated graphics capabilities.
;
; Features:       - Hardware-accelerated 2D graphics rendering
;                 - Simple drawing methods for common shapes (rectangles, circles, lines, polygons)
;                 - Automatic resource management and cleanup
;                 - Color handling with alpha channel support
;                 - Proper DPI awareness
;                 - Structured COM object interface
;
; Usage:          Create a GUI window and pass its handle to the class:
;                 myGui := Gui("+AlwaysOnTop +Resize")
;                 d2d := d2d1(myGui.hwnd, x, y, width, height)
;                 
;                 Then use the drawing methods in a timer or event:
;                 d2d.BeginDraw()
;                 d2d.FillRectangle(x, y, width, height, color)
;                 d2d.EndDraw()
;
; Dependencies:   - AutoHotkey v2
;                 - Direct2D, DirectWrite, DWM API, and GDI+ libraries
;
; Author:         Based on Spawnova's Direct2D overlay class
; Source:         https://github.com/Spawnova/ShinsOverlayClass
; Version:        1.2
; Last Updated:   2025-03-08
;==================================================================================================================

; Seting up the Direct2D library


; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "Example: 1")
inst := d2d1(myGui.hwnd, x := 100, y := 100, width := 800, height := 600)
SetTimer(GuiWindow.Bind(inst), 40)



exit ;EOAES

GuiWindow(inst) {


    inst.BeginDraw()
    
    ;background
    inst.FillRectangle(0, 0, 800, 600, "0xffffff")

    ;shapes
    inst.FillRectangle(30, 30, 100, 100, "0xffff1d")
    inst.FillCircle(600, 300, 150, "0xcd1c1c")
    inst.DrawLine(150,150,600,600, "0x000000",5)
    inst.FillPolygon([[250,150], [150,350], [350,350]], "0x2516ff", 200, -150)



    inst.EndDraw()

}

; I want to understand how the Direct2D library works, so I decided to work with a class that uses it.
;
;Aims:
; i want to create a struct class that deals with the Direct2D library, remove all the numget and numputs / adding a level of abstraction to the library.
; make it behave like a COM object I am more familiur with / make it as easy to use as possible
; make it as customisable as possible, ie. avoid hardcoding values, allow for user to access the library's full functionality
; the original aim was to create a class that could be used to create a GUI with Direct2D, but i realised that this would be too complex for me to do in one go, so i decided to create a class that could be used to draw shapes on a GUI window.
; correctly manage everything, I get confused about when where to clear / de-reffrence / 


; This class is a butched version of Spawnova's Direct2D overlay class.
; Repet: This class is a butched version of Spawnova's Direct2D overlay class. 
; The Full Class can be found here: https://github.com/Spawnova/ShinsOverlayClass

class d2d1 {

	__New(hwnd, x := 100, y := 100, width := 800, height := 600) {

        pOut := 0
		this.is64Bit := (a_ptrsize == 8)
		this.width := width
		this.height := height
        this.hwnd := hwnd 

        for each, dll in ["d2d1", "dwrite", "dwmapi", "gdiplus"]
        if !DllCall("GetModuleHandle", "str", dll, "Ptr")
            DllCall("LoadLibrary", "Str", dll) 


        ; Initialize GDI+ token
        token := 0
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", Structs.GdiplusStartupInput(), "Ptr*", 0)
        this.gdiplusToken := token

        ; Create GUIDs for Direct2D and DirectWrite factories
        this.Guid("{06152247-6f50-465a-9245-118bfd3b6007}", &clsidFactory)
        this.Guid("{b859ee5a-d838-4b5b-a2e8-1adc7d93db48}", &clsidwFactory)


        ; Show the GUI window
        DllCall("ShowWindow", "Uptr", this.hwnd, "uint", 1)


        ; Bind OnErase function to WM_ERASEBKGND message (0x14)
        this.OnEraseFunc := ObjBindMethod(this, "OnErase")
        OnMessage(0x14, this.OnEraseFunc)

        ;Allocate buffers for various graphical operations
      
        this.rect1Ptr := Buffer(64, 0)
        this.rect2Ptr := Buffer(64, 0)

        this.colPtr := Buffer(64, 0)
        this.clrPtr := Buffer(64, 0)


		;DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Uptr", hwnd, "ptr", Structs._MARGINS(), "uint")

        ; Set layered window attributes (transparency settings)
        DllCall("SetLayeredWindowAttributes", "Uptr", hwnd, "Uint", 0, "char", 255, "uint", 2)
  
        ; ; Create Direct2D factory
        if (DllCall("d2d1\D2D1CreateFactory", "uint", 1, "Ptr", clsidFactory, "uint*", 0, "Ptr*", &pOut) != 0) {
            MsgBox("Problem creating factory", "overlay will not function`n`nError: " DllCall("GetLastError", "uint"))
            return
        }

        this.factory := pOut

        this.D2D1_STROKE_STYLE_PROPERTIES := Structs.D2D1_STROKE_STYLE_PROPERTIES(StartCap := 2, EndCap := 2, DashCap := 0, LineJoin := 2, MiterLimit := 255, DashStyle := 0, DashOffset := 0)
        this._CreateStroke := this.vTable(this.factory, 11)

        ; Create stroke object
        if (DllCall(this._CreateStroke, "ptr", this.factory, "ptr", this.D2D1_STROKE_STYLE_PROPERTIES, "ptr", 0, "uint", 0, "ptr*", &pOut) != 0) {
            MsgBox("Problem creating stroke", "overlay will not function`n`nError: " DllCall("GetLastError", "uint"))
            return
        }
        this.stroke := pOut

        ; Create rounded stroke object
        if (DllCall(this._CreateStroke, "ptr", this.factory, "ptr", this.D2D1_STROKE_STYLE_PROPERTIES, "ptr", 0, "uint", 0, "ptr*", &pOut) != 0) {
            MsgBox("Problem creating rounded stroke", "overlay will not function`n`nError: " DllCall("GetLastError", "uint"))
            return
        }
        this.strokeRounded := pOut

        ; Create render target
        D2D1_RENDER_TARGET_PROPERTIES := Structs.D2D1_RENDER_TARGET_PROPERTIES(D2D1_RENDER_TARGET_TYPE := 0, DXGI_FORMAT := 0, D2D1_ALPHA_MODE := 1, dpiX := 96, dpiY := 96, D2D1_RENDER_TARGET_USAGE := 0, D2D1_FEATURE_LEVEL := 0)
        D2D1_HWND_RENDER_TARGET_PROPERTIES := Structs.D2D1_HWND_RENDER_TARGET_PROPERTIES(this.hwnd, this.width, this.height)

        if (DllCall(this.vTable(this.factory, 14), "Ptr", this.factory, "Ptr", D2D1_RENDER_TARGET_PROPERTIES, "ptr", D2D1_HWND_RENDER_TARGET_PROPERTIES, "Ptr*", &pOut) != 0) {
            MsgBox("Problem creating renderTarget", "overlay will not function`n`nError: " DllCall("GetLastError", "uint"))
            return
        }
        
        this.renderTarget := pOut

        this.matrixPtr := Structs.D2D1_MATRIX_3X2_F()

        ; Create brush object
        if (DllCall(this.vTable(this.renderTarget, 8), "Ptr", this.renderTarget, "Ptr", this.colPtr, "Ptr", this.matrixPtr, "Ptr*", &pOut) != 0) {
            MsgBox("Problem creating brush", "overlay will not function`n`nError: " DllCall("GetLastError", "uint"))
            return
        }
        this.brush := pOut

        ; Enable anti-aliasing
        DllCall(this.vTable(this.renderTarget, 32), "Ptr", this.renderTarget, "Uint", 0)

        ; Create DirectWrite factory
        if (DllCall("dwrite\DWriteCreateFactory", "uint", 0, "Ptr", clsidwFactory, "Ptr*", &pOut) != 0) {
            MsgBox("Problem creating writeFactory", "overlay will not function`n`nError: " DllCall("GetLastError", "uint"))
            return
        }
        this.wFactory := pOut

        ; Initialize functions and position overlay
        this.InitFuncs()
        this.SetPosition(x, y)
        this.Clear()

        return this
	}


    SetPosition(x,y,w:=0,h:=0) {
		this.x := x
		this.y := y
		if (!this.hwnd and w != 0 and h != 0) {
			newSize := Buffer(16,0)
			NumPut("uint",this.width := w, newSize,0)
			NumPut("uint",this.height := h, newSize,4)
			DllCall(this._NRSize,"Ptr",this.renderTarget,"ptr",newsize)
		}
		DllCall("MoveWindow","Uptr",this.hwnd,"int",x,"int",y,"int",this.width,"int",this.height,"char",1)
	}
	
    
	BeginDraw() {
		local pOut := 0, GetWindowRectResult := this.hwnd
		if (!DllCall("GetWindowRect", "Uptr", GetWindowRectResult, "ptr", this.D2D1_STROKE_STYLE_PROPERTIES)) {
			if (this.drawing) {
				this.Clear()
				this.drawing := 0
			}
			return 0
		}

		DllCall(this._BeginDraw, "Ptr", this.renderTarget)
		DllCall(this._Clear, "Ptr", this.renderTarget, "Ptr", this.clrPtr)

		return this.drawing := 1
	}
	
    FillCircle(x, y, radius, color) {
		this.SetBrushColor(color)
		DllCall(this._FillEllipse,"Ptr",this.renderTarget,"Ptr", Structs.D2D_RECT_F(x, y, radius, radius),"ptr",this.brush)
	}

	FillRectangle(x, y, w, h, color) {
		this.SetBrushColor(color)
		DllCall(this._FillRectangle,"Ptr",this.renderTarget,"Ptr", Structs.D2D_RECT_F(x, y, x+w, y+h) ,"ptr",this.brush)
	}

    
	DrawLine(x1,y1,x2,y2,color:=0xFFFFFFFF,thickness:=1, rounded:=0) {
		this.SetBrushColor(color)
        bf :=  Structs.D2D_POINT_2F(x1, y1, x2, y2)
		if (this.is64Bit) {
		    DllCall(this._DrawLine,"Ptr",this.renderTarget,"Double", NumGet(bf,0,"double"),"Double", NumGet(bf,8,"double"),"ptr",this.brush,"float",thickness,"ptr",(rounded?this.strokeRounded:this.stroke))
		} else {
			DllCall(this._DrawLine,"Ptr",this.renderTarget,"float",x1,"float",y1,"float",x2,"float",y2,"ptr",this.brush,"float",thickness,"ptr",(rounded?this.strokeRounded:this.stroke))
		}
		
	}
	
	;####################################################################################################################################################################################################################################
	;FillPolygon
	;
	;points				:				An array of 2d points, example: [[0,0],[5,0],[0,5]]
	;color				:				Color in 0xAARRGGBB or 0xRRGGBB format (if 0xRRGGBB then alpha is set to FF (255))
	;xOffset			:				X offset to draw the filled polygon array
	;yOffset			:				Y offset to draw the filled polygon array
	;
	;return				;				1 on success; 0 otherwise

	FillPolygon(points,color,xoffset:=0,yoffset:=0) {
		if (points.length < 3)
			return 0
		pGeom := sink := 0
		if (DllCall(this.vTable(this.factory,10),"Ptr",this.factory,"Ptr*",&pGeom) = 0) {
			if (DllCall(this.vTable(pGeom,17),"Ptr",pGeom,"Ptr*",&sink) = 0) {
				this.SetBrushColor(color)
				if (this.is64Bit) {
					bf := Buffer(64)
					NumPut("float", points[1][1]+xoffset, bf, 0)
					NumPut("float", points[1][2]+yoffset, bf, 4)
					DllCall(this.vTable(sink,5),"ptr",sink,"double",numget(bf,0,"double"),"uint",0)
					loop points.length-1
					{
						NumPut("float", points[a_index+1][1]+xoffset, bf, 0)
						NumPut("float", points[a_index+1][2]+yoffset, bf, 4)
						DllCall(this.vTable(sink,10),"ptr",sink,"double",numget(bf,0,"double"))
					}
					DllCall(this.vTable(sink,8),"ptr",sink,"uint",1)
					DllCall(this.vTable(sink,9),"ptr",sink)
				} else {
					DllCall(this.vTable(sink,5),"ptr",sink,"float",points[1][1]+xoffset,"float",points[1][2]+yoffset,"uint",0)
					loop points.length-1
						DllCall(this.vTable(sink,10),"ptr",sink,"float",points[a_index+1][1]+xoffset,"float",points[a_index+1][2]+yoffset)
					DllCall(this.vTable(sink,8),"ptr",sink,"uint",1)
					DllCall(this.vTable(sink,9),"ptr",sink)
				}
				
				if (DllCall(this.vTable(this.renderTarget,23),"Ptr",this.renderTarget,"Ptr",pGeom,"ptr",this.brush,"ptr",0) = 0) {
					DllCall(this.vTable(sink,2),"ptr",sink)
					DllCall(this.vTable(pGeom,2),"Ptr",pGeom)
					return 1
				}
				DllCall(this.vTable(sink,2),"ptr",sink)
				DllCall(this.vTable(pGeom,2),"Ptr",pGeom)
				
			}
		}
		
		
		return 0
	}
	
	EndDraw() {
		local pOut:=0
		if (this.drawing)
			DllCall(this._EndDraw,"Ptr",this.renderTarget,"Ptr*",&pOut,"Ptr*",&pOut)
	}

    Clear() {
		local pOut:=0
		DllCall(this._BeginDraw,"Ptr",this.renderTarget)
		DllCall(this._Clear,"Ptr",this.renderTarget,"Ptr",this.clrPtr)
		DllCall(this._EndDraw,"Ptr",this.renderTarget,"Ptr*",&pOut,"Ptr*",&pOut)
	}
	
	vTable(a,p) {
		return NumGet(NumGet(a+0,0,"ptr"),p*a_ptrsize,"Ptr")
	}

	Guid(guidStr,&clsidFactory) {
		clsidFactory := buffer(16,0)
		DllCall("ole32\CLSIDFromString", "WStr", guidStr, "Ptr", clsidFactory)
	}

	SetBrushColor(col) {
        static lastCol := 0
		if (col <= 0xFFFFFF)
			col += 0xFF000000
		if (col != lastCol) {
			NumPut("Float",((col & 0xFF0000)>>16)/255,this.colPtr,0)
			NumPut("Float",((col & 0xFF00)>>8)/255,this.colPtr,4)
			NumPut("Float",((col & 0xFF))/255,this.colPtr,8)
			NumPut("Float",(col > 0xFFFFFF ? ((col & 0xFF000000)>>24)/255 : 1),this.colPtr,12)
			DllCall(this._SetBrush,"Ptr",this.brush,"Ptr",this.colPtr)
			lastCol := col
			return 1
		}
		return 0
	}

	__Delete() {
		DllCall("gdiplus\GdiplusShutdown", "Ptr*", this.gdiplusToken)
		DllCall(this.vTable(this.factory,2),"ptr",this.factory)
		DllCall(this.vTable(this.stroke,2),"ptr",this.stroke)
		DllCall(this.vTable(this.strokeRounded,2),"ptr",this.strokeRounded)
		DllCall(this.vTable(this.renderTarget,2),"ptr",this.renderTarget)
		DllCall(this.vTable(this.brush,2),"ptr",this.brush)
		DllCall(this.vTable(this.wfactory,2),"ptr",this.wfactory)
		OnMessage(0x14,this.OnEraseFunc,0)
	}

	InitFuncs() {
		this._DrawText := this.vTable(this.renderTarget,27)
		this._BeginDraw := this.vTable(this.renderTarget,48)
		this._Clear := this.vTable(this.renderTarget,47)
		this._DrawImage := this.vTable(this.renderTarget,26)
		this._EndDraw := this.vTable(this.renderTarget,49)
		this._RMatrix := this.vTable(this.renderTarget,30)
		this._DrawEllipse := this.vTable(this.renderTarget,20)
		this._FillEllipse := this.vTable(this.renderTarget,21)
		this._DrawRectangle := this.vTable(this.renderTarget,16)
		this._FillRectangle := this.vTable(this.renderTarget,17)
		this._DrawRoundedRectangle := this.vTable(this.renderTarget,18)
		this._FillRoundedRectangle := this.vTable(this.renderTarget,19)
		this._DrawLine := this.vTable(this.renderTarget,15)
		this._NRSize := this.vTable(this.renderTarget,58)
		this._SetBrush := this.vTable(this.brush,8)
	}


	OnErase(wParam, lParam, msg, hwnd) {
		if (hwnd = this.hwnd)
			return 0
	}

}

class Structs {

    static _MARGINS(cxLeftWidth := -1, cxRightWidth := -1, cyTopHeight := -1, cyBottomHeight := -1) {
        ; typedef struct _MARGINS {
        ;   int cxLeftWidth;     // Offset 0: Left width
        ;   int cxRightWidth;    // Offset 4: Right width
        ;   int cyTopHeight;     // Offset 8: Top height
        ;   int cyBottomHeight;  // Offset 12: Bottom height
        ; } MARGINS, *PMARGINS;
        local marg := Buffer(16, 0)  ; 4 ints (4 bytes each) = 16 bytes
        NumPut("int", cxLeftWidth, marg, 0)     ; Offset 0: LeftWidth
        NumPut("int", cxRightWidth, marg, 4)    ; Offset 4: RightWidth
        NumPut("int", cyTopHeight, marg, 8)     ; Offset 8: TopHeight
        NumPut("int", cyBottomHeight, marg, 12) ; Offset 12: BottomHeight
        return marg
    }

    static D2D_POINT_2F(x1, y1, x2, y2) {
        bf := Buffer(64)
        NumPut("float", x1, bf, 0)  ;Special thanks to teadrinker for helping me
        NumPut("float", y1, bf, 4)  ;with these params!
        NumPut("float", x2, bf, 8)
        NumPut("float", y2, bf, 12)
        return bf
       ;D2D_POINT_2F;
    }


    static GdiplusStartupInput(GdiplusVersion := 1) {
        ; struct GdiplusStartupInput {
        ;   UINT GdiplusVersion;            // Offset 0: Version (e.g. 1)
        ;   DebugEventProc DebugEventCallback;  // Offset 4 (or 4/8 depending on pointer size)
        ;   BOOL SuppressBackgroundThread;  // Next 4 bytes
        ;   BOOL SuppressExternalCodecs;    // Next 4 bytes
        ; }
        ; Buffer size: 8 + 2 * A_PtrSize ensures proper alignment.
        local inPtr := Buffer(8 + 2 * A_PtrSize, 0)
        NumPut("UInt", GdiplusVersion, inPtr, 0) ; Offset 0: GdiplusVersion
        ; Other fields left as zero (NULL/false)
        return inPtr
    }

    static D2D1_RENDER_TARGET_PROPERTIES(D2D1_RENDER_TARGET_TYPE := 0, DXGI_FORMAT := 0, D2D1_ALPHA_MODE := 1, dpiX := 96, dpiY := 96, D2D1_RENDER_TARGET_USAGE := 0, D2D1_FEATURE_LEVEL := 0) {
        ; typedef struct D2D1_RENDER_TARGET_PROPERTIES {
        ;   D2D1_RENDER_TARGET_TYPE type;    // Offset 0: 4 bytes
        ;   DXGI_FORMAT format;              // Offset 4: 4 bytes
        ;   D2D1_ALPHA_MODE alphaMode;       // Offset 8: 4 bytes
        ;   FLOAT dpiX;                      // Offset 12: 4 bytes
        ;   FLOAT dpiY;                      // Offset 16: 4 bytes
        ;   D2D1_RENDER_TARGET_USAGE usage;  // Offset 20: 4 bytes
        ;   D2D1_FEATURE_LEVEL minLevel;     // Offset 24: 4 bytes
        ; } D2D1_RENDER_TARGET_PROPERTIES;
        local rtPtr := Buffer(28, 0)  ; Total size = 7 * 4 = 28 bytes
        NumPut("uint", D2D1_RENDER_TARGET_TYPE, rtPtr, 0)   ; Offset 0: Render target type
        NumPut("uint", DXGI_FORMAT, rtPtr, 4)               ; Offset 4: DXGI_FORMAT
        NumPut("uint", D2D1_ALPHA_MODE, rtPtr, 8)           ; Offset 8: D2D1_ALPHA_MODE
        NumPut("float", dpiX, rtPtr, 12)                    ; Offset 12: Horizontal DPI
        NumPut("float", dpiY, rtPtr, 16)                    ; Offset 16: Vertical DPI
        NumPut("uint", D2D1_RENDER_TARGET_USAGE, rtPtr, 20) ; Offset 20: Render target usage
        NumPut("uint", D2D1_FEATURE_LEVEL, rtPtr, 24)       ; Offset 24: Minimum feature level
        return rtPtr
    }

    static D2D1_HWND_RENDER_TARGET_PROPERTIES(hwnd := 0, width := 0, height := 0, D2D1_PRESENT_OPTIONS := 0) {
        ; typedef struct D2D1_HWND_RENDER_TARGET_PROPERTIES {
        ;   HWND hwnd;                        // Offset 0: Pointer/handle (A_PtrSize bytes)
        ;   UINT pixelSize.width;             // Offset A_PtrSize: 4 bytes
        ;   UINT pixelSize.height;            // Offset A_PtrSize+4: 4 bytes
        ;   D2D1_PRESENT_OPTIONS options;     // Offset A_PtrSize+8: 4 bytes
        ; }
        local size := A_PtrSize + 12  ; Total size = A_PtrSize + 12 bytes
        local hrtPtr := Buffer(size, 0)
        NumPut("UPtr", hwnd, hrtPtr, 0)                                 ; Offset 0: Handle to the window
        NumPut("uint", width, hrtPtr, A_PtrSize)                         ; Offset A_PtrSize: Width
        NumPut("uint", height, hrtPtr, A_PtrSize + 4)                     ; Offset A_PtrSize+4: Height
        NumPut("uint", D2D1_PRESENT_OPTIONS, hrtPtr, A_PtrSize + 8)       ; Offset A_PtrSize+8: Presentation options
        return hrtPtr
    }

    static D2D1_MATRIX_3X2_F(M11 := 1, M12 := 0, M21 := 0, M22 := 1, Dx := 0, Dy := 0) {
        ; typedef struct D2D1_MATRIX_3X2_F {
        ;   float M11;   // Offset 0: Scaling X
        ;   float M12;   // Offset 4: Shear Y
        ;   float M21;   // Offset 8: Shear X
        ;   float M22;   // Offset 12: Scaling Y
        ;   float Dx;    // Offset 16: Translation X
        ;   float Dy;    // Offset 20: Translation Y
        ; }
        local mat := Buffer(24, 0)  ; 6 floats * 4 bytes = 24 bytes
        NumPut("float", M11, mat, 0)
        NumPut("float", M12, mat, 4)
        NumPut("float", M21, mat, 8)
        NumPut("float", M22, mat, 12)
        NumPut("float", Dx,  mat, 16)
        NumPut("float", Dy,  mat, 20)
        return mat
    }

    static D2D1_STROKE_STYLE_PROPERTIES(StartCap := 2, EndCap := 2, DashCap := 0, LineJoin := 2, MiterLimit := 255, DashStyle := 0, DashOffset := 0) {
        ; typedef struct D2D1_STROKE_STYLE_PROPERTIES {
        ;   D2D1_CAP_STYLE startCap;    // Offset 0: Start cap style
        ;   D2D1_CAP_STYLE endCap;      // Offset 4: End cap style
        ;   D2D1_CAP_STYLE dashCap;     // Offset 8: Dash cap style
        ;   D2D1_LINE_JOIN lineJoin;    // Offset 12: Line join style
        ;   FLOAT miterLimit;           // Offset 16: Miter limit
        ;   D2D1_DASH_STYLE dashStyle;  // Offset 20: Dash style
        ;   FLOAT dashOffset;           // Offset 24: Dash offset
        ; }
        local size := 28  ; Total size = 7 fields * 4 bytes each = 28 bytes
        local ptr := Buffer(size, 0)
        NumPut("uint", StartCap, ptr, 0)     ; Offset 0: Start cap style
        NumPut("uint", EndCap, ptr, 4)       ; Offset 4: End cap style
        NumPut("uint", DashCap, ptr, 8)      ; Offset 8: Dash cap style
        NumPut("uint", LineJoin, ptr, 12)    ; Offset 12: Line join style
        NumPut("float", MiterLimit, ptr, 16) ; Offset 16: Miter limit
        NumPut("uint", DashStyle, ptr, 20)   ; Offset 20: Dash style
        NumPut("float", DashOffset, ptr, 24) ; Offset 24: Dash offset
        return ptr
    }

    static D2D_RECT_F(left := 0, top := 0, right := 0, bottom := 0) {
        ; typedef struct D2D_RECT_F {
        ;   float left;    // Offset 0
        ;   float top;     // Offset 4
        ;   float right;   // Offset 8
        ;   float bottom;  // Offset 12
        ; }
        local rect := Buffer(16, 0)  ; 4 floats * 4 bytes = 16 bytes
        NumPut("float", left, rect, 0)
        NumPut("float", top, rect, 4)
        NumPut("float", right, rect, 8)
        NumPut("float", bottom, rect, 12)
        return rect
    }
}

; class Structs {
    
;     static _MARGINS(cxLeftWidth := -1, cxRightWidth := -1, cyTopHeight := -1, cyBottomHeight := -1) {
;         ; typedef struct _MARGINS {
;             _MARGINS := Buffer(16, 0)
;             NumPut("int", cxLeftWidth, _MARGINS, 0)     ;// Offset 0: LeftWidth
;             NumPut("int", cxRightWidth, _MARGINS, 4)    ;// Offset 4: RightWidth
;             NumPut("int", cyTopHeight, _MARGINS, 8)     ;// Offset 8: TopHeight
;             NumPut("int", cyBottomHeight, _MARGINS, 12) ;// Offset 12: BottomHeight
;             return _MARGINS
;         ;   } MARGINS, *PMARGINS;
;     }

;     static GdiplusStartupInput(GdiplusVersion := 1){
;         ; struct GdiplusStartupInput {
;             GdiplusStartupInput := Buffer(8 + 2 * A_PtrSize, 0)
;             NumPut("Uint", GdiplusVersion, GdiplusStartupInput, 0) ;// Offset 0: GdiplusVersion
;             ;     DebugEventProc DebugEventCallback;
;             ;     BOOL           SuppressBackgroundThread;
;             ;     BOOL           SuppressExternalCodecs;
;             ;     void           GdiplusStartupInput(
;             ;       DebugEventProc debugEventCallback,
;             ;       BOOL           suppressBackgroundThread,
;             ;       BOOL           suppressExternalCodecs);
;             return GdiplusStartupInput
;         ;   };
;     }

;     static D2D1_RENDER_TARGET_PROPERTIES(D2D1_RENDER_TARGET_TYPE := 0, DXGI_FORMAT := 0, D2D1_ALPHA_MODE := 1, dpiX := 96, dpiY := 96, D2D1_RENDER_TARGET_USAGE := 0, D2D1_FEATURE_LEVEL := 0) {
;         ; typedef struct D2D1_RENDER_TARGET_PROPERTIES {
;             rtPtr := Buffer(64, 0)
;             NumPut("uint", D2D1_RENDER_TARGET_TYPE, rtPtr, 0)   ;// Offset 0: Default render target type (0) 
;             NumPut("uint", DXGI_FORMAT, rtPtr, 4)               ;// Offset 4: DXGI_FORMAT (0 = unknown)
;             NumPut("uint", D2D1_ALPHA_MODE, rtPtr, 8)           ;// Offset 8: D2D1_ALPHA_MODE (1 = premultiplied)
;             NumPut("float", dpiX, rtPtr, 12)                    ;// Offset 12: Horizontal DPI (96)
;             NumPut("float", dpiY, rtPtr, 16)                    ;// Offset 16: Vertical DPI (96)
;             NumPut("uint", D2D1_RENDER_TARGET_USAGE, rtPtr, 20) ;// Offset 20: Render target usage (0 = none)
;             NumPut("uint", D2D1_FEATURE_LEVEL, rtPtr, 24)       ;// Offset 24: Minimum feature level (0 = default)
;         ; }
;             return rtPtr
;         }


;     static D2D1_HWND_RENDER_TARGET_PROPERTIES(hwnd := 0, width := 0, height := 0, D2D1_PRESENT_OPTIONS := 0){
;         ; typedef struct D2D1_HWND_RENDER_TARGET_PROPERTIES {
;             hrtPtr := Buffer(64, 0)                                          
;             NumPut("Uptr", hwnd,  hrtPtr, 0)                                 ; // Offset 0: Handle to the window     
;             NumPut("uint", width, hrtPtr, A_PtrSize)                         ; // Offset A_PtrSize:  UINT width;
;             NumPut("uint", height,hrtPtr, A_PtrSize + 4)                     ; // Offset A_PtrSize+4: UINT height;
;             NumPut("uint", D2D1_PRESENT_OPTIONS := 0, hrtPtr, A_PtrSize + 8) ;// Offset A_PtrSize+8: Presentation options (0) 
;             return hrtPtr
;             ; } D2D1_HWND_RENDER_TARGET_PROPERTIES;
;          }


;     static D2D1_MATRIX_3X2_F(M11 := 1, M12 := 0, M21 := 0, M22 := 1, Dx := 0, Dy := 0) {

;         ; typedef struct D2D1_MATRIX_3X2_F {
;             D2D1_MATRIX_3X2_F := Buffer(24, 0)
;             NumPut("float", 1, D2D1_MATRIX_3X2_F, 0)  ;// Offset 0:  M11 (Scaling X)
;             NumPut("float", 0, D2D1_MATRIX_3X2_F, 4)  ;// Offset 4:  M12 (Shear Y)
;             NumPut("float", 0, D2D1_MATRIX_3X2_F, 8)  ;// Offset 8:  M21 (Shear X)
;             NumPut("float", 1, D2D1_MATRIX_3X2_F, 12) ;// Offset 12: M22 (Scaling Y)
;             NumPut("float", 0, D2D1_MATRIX_3X2_F, 16) ;// Offset 16: Dx (Translation X)
;             NumPut("float", 0, D2D1_MATRIX_3X2_F, 20) ;// Offset 20: Dy (Translation Y)
;             return D2D1_MATRIX_3X2_F
;         ;   } D2D1_MATRIX_3X2_F;
;     }

;     static D2D1_STROKE_STYLE_PROPERTIES(StartCap := 2, EndCap := 2, DashCap := 0, LineJoin := 2, MiterLimit := 255, DashStyle := 0, DashOffset := 0) {
;             ; typedef struct D2D1_STROKE_STYLE_PROPERTIES {
;                 this.tBufferPtr := Buffer(4096, 0)
;                 NumPut("uint", 2, this.tBufferPtr, 0)       ; // Offset 0: Start cap style (e.g. 2 for rounded/square caps)
;                 NumPut("uint", 2, this.tBufferPtr, 4)       ; // Offset 4: End cap style (e.g. 2)
;             ;   D2D1_CAP_STYLE   dashCap;                     // Offset 8: Dash cap style (defaults to 0)
;                 NumPut("uint", 2, this.tBufferPtr, 12)      ; // Offset 12: Line join style (e.g. 2 for rounded join)
;                 NumPut("float", 255, this.tBufferPtr, 16)   ; // Offset 16: Miter limit (set to 255)
;             ;   D2D1_DASH_STYLE  dashStyle;                   // Offset 20: Dash style (not set; defaults to 0 for a solid line)
;             ;   FLOAT            dashOffset;                  // Offset 24: Dash offset (not set; defaults to 0)
;                 return this.tBufferPtr
;             ; } D2D1_STROKE_STYLE_PROPERTIES;
;     }

;     static D2D_RECT_F(left := 0, top := 0, right := 0, bottom := 0) {
;         ; typedef struct D2D_RECT_F {
;             bf := Buffer(64)
;             NumPut("float", left, bf, 0)
;             NumPut("float", top, bf, 4)
;             NumPut("float", right, bf, 8)
;             NumPut("float", bottom, bf, 12)
;         ;   } D2D_RECT_F;
;         return bf
;     }


; }


f9::Reload()
esc::ExitApp()