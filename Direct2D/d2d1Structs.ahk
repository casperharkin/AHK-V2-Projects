;==================================================================================================================
; Direct2D Structure Definitions
;==================================================================================================================
; Description:    Collection of structure definitions for Direct2D API integration
;                 Provides buffer creation functions for various Direct2D structures
;
; Features:       - Memory buffer creation for Direct2D structures
;                 - Support for common structures like rectangles, points, and matrices
;                 - Color conversion utilities
;                 - Proper memory alignment for 32-bit and 64-bit compatibility
;                 - Helper methods for common structure operations
;
; Usage:          buffer := D2D1Structs.D2D1_RECT_F(left, top, right, bottom)
;                 colorBuffer := D2D1Structs.D2D1_COLOR_F(0xFF0000)
;                 rectFromSize := D2D1Structs.RectFromSize(x, y, width, height)
;
; Dependencies:   - AutoHotkey v2.0+
;                 - D2D1Enums.ahk
;
; Author:         CasperHarkin
; Version:        1.2.0
; Last Updated:   12/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#Include "D2D1Enums.ahk"

class D2D1Structs {
    ; ==================== Size Structures ====================
    
    /**
     * Create a D2D1_SIZE_U structure (unsigned integer size)
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @returns {Buffer} D2D1_SIZE_U structure
     */
    static D2D1_SIZE_U(width := 0, height := 0) {
        local size := Buffer(8, 0)
        NumPut("uint", width, size, 0)
        NumPut("uint", height, size, 4)
        return size
    }
    
    /**
     * Create a D2D1_SIZE_F structure (floating point size)
     * @param {Number} width - Width as float
     * @param {Number} height - Height as float
     * @returns {Buffer} D2D1_SIZE_F structure
     */
    static D2D1_SIZE_F(width := 0.0, height := 0.0) {
        local size := Buffer(8, 0)
        NumPut("float", width, size, 0)
        NumPut("float", height, size, 4)
        return size
    }
    
    ; ==================== Point Structures ====================
    
    /**
     * Create a D2D1_POINT_2F structure for a single point
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @returns {Buffer} D2D1_POINT_2F structure
     */
    static D2D1_POINT_2F_SINGLE(x, y) {
        local bf := Buffer(8)
        NumPut("float", x, bf, 0)
        NumPut("float", y, bf, 4)
        return bf
    }
    
    /**
     * Create a D2D_POINT_2F structure for two points (line)
     * @param {Number} x1 - First X coordinate
     * @param {Number} y1 - First Y coordinate
     * @param {Number} x2 - Second X coordinate
     * @param {Number} y2 - Second Y coordinate
     * @returns {Buffer} D2D_POINT_2F structure
     */
    static D2D_POINT_2F(x1, y1, x2, y2) {
        local bf := Buffer(16)  ; Reduced from 64 to 16 (only need 16 bytes for 2 points)
        NumPut("float", x1, bf, 0)
        NumPut("float", y1, bf, 4)
        NumPut("float", x2, bf, 8)
        NumPut("float", y2, bf, 12)
        return bf
    }
    
    /**
     * Create a buffer for multiple points (polygon/polyline)
     * @param {Array} points - Array of [x,y] coordinate pairs
     * @param {Number} xOffset - Optional X offset to apply to all points
     * @param {Number} yOffset - Optional Y offset to apply to all points
     * @returns {Buffer} Buffer containing all points
     */
    static D2D1_POINTS_ARRAY(points, xOffset := 0, yOffset := 0) {
        local count := points.Length
        local bf := Buffer(count * 8, 0)
        
        Loop count {
            NumPut("float", points[A_Index][1] + xOffset, bf, (A_Index - 1) * 8)
            NumPut("float", points[A_Index][2] + yOffset, bf, (A_Index - 1) * 8 + 4)
        }
        
        return bf
    }
    
    ; ==================== Rectangle Structures ====================
    
    /**
     * Create a D2D_RECT_F structure
     * @param {Number} left - Left coordinate
     * @param {Number} top - Top coordinate
     * @param {Number} right - Right coordinate
     * @param {Number} bottom - Bottom coordinate
     * @returns {Buffer} D2D_RECT_F structure
     */
    static D2D_RECT_F(left := 0, top := 0, right := 0, bottom := 0) {
        local rect := Buffer(16, 0)
        NumPut("float", left, rect, 0)
        NumPut("float", top, rect, 4)
        NumPut("float", right, rect, 8)
        NumPut("float", bottom, rect, 12)
        return rect
    }
    
    /**
     * Create a D2D_RECT_F structure from position and size
     * @param {Number} x - X position (left)
     * @param {Number} y - Y position (top)
     * @param {Number} width - Width of rectangle
     * @param {Number} height - Height of rectangle
     * @returns {Buffer} D2D_RECT_F structure
     */
    static RectFromSize(x := 0, y := 0, width := 0, height := 0) {
        return this.D2D_RECT_F(x, y, x + width, y + height)
    }
    
    /**
     * Create a D2D1_ROUNDED_RECT structure
     * @param {Number} left - Left coordinate
     * @param {Number} top - Top coordinate
     * @param {Number} right - Right coordinate
     * @param {Number} bottom - Bottom coordinate
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @returns {Buffer} D2D1_ROUNDED_RECT structure
     */
    static D2D1_ROUNDED_RECT(left := 0, top := 0, right := 0, bottom := 0, radiusX := 0, radiusY := 0) {
        local rect := Buffer(24, 0)
        NumPut("float", left, rect, 0)
        NumPut("float", top, rect, 4)
        NumPut("float", right, rect, 8)
        NumPut("float", bottom, rect, 12)
        NumPut("float", radiusX, rect, 16)
        NumPut("float", radiusY, rect, 20)
        return rect
    }
    
    /**
     * Create a D2D1_ROUNDED_RECT structure from position and size
     * @param {Number} x - X position (left)
     * @param {Number} y - Y position (top)
     * @param {Number} width - Width of rectangle
     * @param {Number} height - Height of rectangle
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @returns {Buffer} D2D1_ROUNDED_RECT structure
     */
    static RoundedRectFromSize(x := 0, y := 0, width := 0, height := 0, radiusX := 0, radiusY := 0) {
        return this.D2D1_ROUNDED_RECT(x, y, x + width, y + height, radiusX, radiusY)
    }
    
    ; ==================== Ellipse Structures ====================
    
    /**
     * Create a D2D_RECT_F structure for an ellipse
     * @param {Number} centerX - X coordinate of center
     * @param {Number} centerY - Y coordinate of center
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius (if omitted, uses radiusX for a circle)
     * @returns {Buffer} D2D_RECT_F structure
     */
    static EllipseRect(centerX, centerY, radiusX, radiusY := 0) {
        if (radiusY == 0)
            radiusY := radiusX
        return this.D2D_RECT_F(centerX, centerY, radiusX, radiusY)
    }
    
    /**
     * Create a D2D1_ELLIPSE structure
     * @param {Number} centerX - X coordinate of center
     * @param {Number} centerY - Y coordinate of center
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius (if omitted, uses radiusX for a circle)
     * @returns {Buffer} D2D1_ELLIPSE structure
     */
    static D2D1_ELLIPSE(centerX, centerY, radiusX, radiusY := 0) {
        if (radiusY == 0)
            radiusY := radiusX
            
        local ellipse := Buffer(16, 0)
        NumPut("float", centerX, ellipse, 0)
        NumPut("float", centerY, ellipse, 4)
        NumPut("float", radiusX, ellipse, 8)
        NumPut("float", radiusY, ellipse, 12)
        return ellipse
    }
    
    ; ==================== Color Structures ====================
    
    /**
     * Create a D2D1_COLOR_F structure from an ARGB color
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @returns {Buffer} D2D1_COLOR_F structure
     */
    static D2D1_COLOR_F(color) {
        local colorBuf := Buffer(16, 0)
        
        ; Ensure color has alpha channel
        if (color <= 0xFFFFFF)
            color += 0xFF000000
        
        ; Convert to 0-1 range float values
        NumPut("Float", ((color & 0xFF0000) >> 16) / 255, colorBuf, 0)  ; R
        NumPut("Float", ((color & 0xFF00) >> 8) / 255, colorBuf, 4)     ; G
        NumPut("Float", ((color & 0xFF)) / 255, colorBuf, 8)            ; B
        NumPut("Float", ((color & 0xFF000000) >> 24) / 255, colorBuf, 12) ; A
        
        return colorBuf
    }
    
    /**
     * Create a D2D1_COLOR_F structure from RGBA components
     * @param {Number} r - Red component (0-255)
     * @param {Number} g - Green component (0-255)
     * @param {Number} b - Blue component (0-255)
     * @param {Number} a - Alpha component (0-255)
     * @returns {Buffer} D2D1_COLOR_F structure
     */
    static D2D1_COLOR_F_RGBA(r, g, b, a := 255) {
        local colorBuf := Buffer(16, 0)
        
        ; Convert to 0-1 range float values
        NumPut("Float", r / 255, colorBuf, 0)  ; R
        NumPut("Float", g / 255, colorBuf, 4)  ; G
        NumPut("Float", b / 255, colorBuf, 8)  ; B
        NumPut("Float", a / 255, colorBuf, 12) ; A
        
        return colorBuf
    }
    
    ; ==================== Matrix Structures ====================
    
    /**
     * Create a D2D1_MATRIX_3X2_F structure
     * @param {Number} M11 - Scaling X
     * @param {Number} M12 - Shear Y
     * @param {Number} M21 - Shear X
     * @param {Number} M22 - Scaling Y
     * @param {Number} Dx - Translation X
     * @param {Number} Dy - Translation Y
     * @returns {Buffer} D2D1_MATRIX_3X2_F structure
     */
    static D2D1_MATRIX_3X2_F(M11 := 1, M12 := 0, M21 := 0, M22 := 1, Dx := 0, Dy := 0) {
        local mat := Buffer(24, 0)
        NumPut("float", M11, mat, 0)
        NumPut("float", M12, mat, 4)
        NumPut("float", M21, mat, 8)
        NumPut("float", M22, mat, 12)
        NumPut("float", Dx, mat, 16)
        NumPut("float", Dy, mat, 20)
        return mat
    }
    
    /**
     * Create a translation matrix
     * @param {Number} x - X translation
     * @param {Number} y - Y translation
     * @returns {Buffer} D2D1_MATRIX_3X2_F structure configured for translation
     */
    static TranslationMatrix(x, y) {
        return this.D2D1_MATRIX_3X2_F(1, 0, 0, 1, x, y)
    }
    
    /**
     * Create a scaling matrix
     * @param {Number} scaleX - X scale factor
     * @param {Number} scaleY - Y scale factor
     * @param {Number} centerX - X center of scaling (optional)
     * @param {Number} centerY - Y center of scaling (optional)
     * @returns {Buffer} D2D1_MATRIX_3X2_F structure configured for scaling
     */
    static ScalingMatrix(scaleX, scaleY, centerX := 0, centerY := 0) {
        if (centerX == 0 && centerY == 0) {
            return this.D2D1_MATRIX_3X2_F(scaleX, 0, 0, scaleY, 0, 0)
        } else {
            ; Scale around center point
            return this.D2D1_MATRIX_3X2_F(
                scaleX, 0, 
                0, scaleY, 
                centerX - scaleX * centerX, 
                centerY - scaleY * centerY
            )
        }
    }
    
    /**
     * Create a rotation matrix
     * @param {Number} angle - Rotation angle in degrees
     * @param {Number} centerX - X center of rotation (optional)
     * @param {Number} centerY - Y center of rotation (optional)
     * @returns {Buffer} D2D1_MATRIX_3X2_F structure configured for rotation
     */
    static RotationMatrix(angle, centerX := 0, centerY := 0) {
        ; Convert angle to radians
        angle := angle * 0.017453292519943295 ; PI/180
        
        ; Calculate sine and cosine
        s := Sin(angle)
        c := Cos(angle)
        
        if (centerX == 0 && centerY == 0) {
            return this.D2D1_MATRIX_3X2_F(c, s, -s, c, 0, 0)
        } else {
            ; Rotate around center point
            return this.D2D1_MATRIX_3X2_F(
                c, s, 
                -s, c, 
                centerX - c * centerX + s * centerY, 
                centerY - s * centerX - c * centerY
            )
        }
    }
    
    /**
     * Combine two transformation matrices
     * @param {Buffer} matrix1 - First transformation matrix
     * @param {Buffer} matrix2 - Second transformation matrix
     * @returns {Buffer} Combined D2D1_MATRIX_3X2_F structure
     */
    static CombineMatrices(matrix1, matrix2) {
        ; Extract values from first matrix
        m1_11 := NumGet(matrix1, 0, "float")
        m1_12 := NumGet(matrix1, 4, "float")
        m1_21 := NumGet(matrix1, 8, "float")
        m1_22 := NumGet(matrix1, 12, "float")
        m1_dx := NumGet(matrix1, 16, "float")
        m1_dy := NumGet(matrix1, 20, "float")
        
        ; Extract values from second matrix
        m2_11 := NumGet(matrix2, 0, "float")
        m2_12 := NumGet(matrix2, 4, "float")
        m2_21 := NumGet(matrix2, 8, "float")
        m2_22 := NumGet(matrix2, 12, "float")
        m2_dx := NumGet(matrix2, 16, "float")
        m2_dy := NumGet(matrix2, 20, "float")
        
        ; Matrix multiplication
        return this.D2D1_MATRIX_3X2_F(
            m1_11 * m2_11 + m1_12 * m2_21,
            m1_11 * m2_12 + m1_12 * m2_22,
            m1_21 * m2_11 + m1_22 * m2_21,
            m1_21 * m2_12 + m1_22 * m2_22,
            m1_dx * m2_11 + m1_dy * m2_21 + m2_dx,
            m1_dx * m2_12 + m1_dy * m2_22 + m2_dy
        )
    }
    
    ; ==================== Brush Structures ====================
    
    /**
     * Create a D2D1_BRUSH_PROPERTIES structure
     * @param {Number} opacity - Opacity (0.0 to 1.0)
     * @param {Buffer} transform - D2D1_MATRIX_3X2_F transform matrix
     * @returns {Buffer} D2D1_BRUSH_PROPERTIES structure
     */
    static D2D1_BRUSH_PROPERTIES(opacity := 1.0, transform := 0) {
        local props := Buffer(28, 0)
        NumPut("float", opacity, props, 0)
        
        if (transform) {
            ; Copy the transform matrix
            NumPut("float", NumGet(transform, 0, "float"), props, 4)   ; M11
            NumPut("float", NumGet(transform, 4, "float"), props, 8)   ; M12
            NumPut("float", NumGet(transform, 8, "float"), props, 12)  ; M21
            NumPut("float", NumGet(transform, 12, "float"), props, 16) ; M22
            NumPut("float", NumGet(transform, 16, "float"), props, 20) ; Dx
            NumPut("float", NumGet(transform, 20, "float"), props, 24) ; Dy
        } else {
            ; Identity matrix
            NumPut("float", 1, props, 4)   ; M11
            NumPut("float", 0, props, 8)   ; M12
            NumPut("float", 0, props, 12)  ; M21
            NumPut("float", 1, props, 16)  ; M22
            NumPut("float", 0, props, 20)  ; Dx
            NumPut("float", 0, props, 24)  ; Dy
        }
        
        return props
    }
    
    /**
     * Create a D2D1_BITMAP_BRUSH_PROPERTIES structure
     * @param {Integer} extendModeX - X extend mode (D2D1Enums.EXTEND_MODE values)
     * @param {Integer} extendModeY - Y extend mode (D2D1Enums.EXTEND_MODE values)
     * @param {Integer} interpolationMode - Interpolation mode (D2D1Enums.BITMAP_INTERPOLATION_MODE values)
     * @returns {Buffer} D2D1_BITMAP_BRUSH_PROPERTIES structure
     */
    static D2D1_BITMAP_BRUSH_PROPERTIES(
        extendModeX := D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_CLAMP, 
        extendModeY := D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_CLAMP, 
        interpolationMode := D2D1Enums.BITMAP_INTERPOLATION_MODE.D2D1_BITMAP_INTERPOLATION_MODE_LINEAR
    ) {
        local props := Buffer(12, 0)
        NumPut("uint", extendModeX, props, 0)
        NumPut("uint", extendModeY, props, 4)
        NumPut("uint", interpolationMode, props, 8)
        return props
    }
    
    /**
     * Create a D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES structure
     * @param {Number} startPointX - X coordinate of start point
     * @param {Number} startPointY - Y coordinate of start point
     * @param {Number} endPointX - X coordinate of end point
     * @param {Number} endPointY - Y coordinate of end point
     * @returns {Buffer} D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES structure
     */
    static D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES(startPointX, startPointY, endPointX, endPointY) {
        local props := Buffer(16, 0)
        NumPut("float", startPointX, props, 0)
        NumPut("float", startPointY, props, 4)
        NumPut("float", endPointX, props, 8)
        NumPut("float", endPointY, props, 12)
        return props
    }
    
    /**
     * Create a D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES structure
     * @param {Number} centerX - X coordinate of center
     * @param {Number} centerY - Y coordinate of center
     * @param {Number} offsetX - X offset of gradient origin
     * @param {Number} offsetY - Y offset of gradient origin
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @returns {Buffer} D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES structure
     */
    static D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES(centerX, centerY, offsetX, offsetY, radiusX, radiusY) {
        local props := Buffer(24, 0)
        NumPut("float", centerX, props, 0)
        NumPut("float", centerY, props, 4)
        NumPut("float", offsetX, props, 8)
        NumPut("float", offsetY, props, 12)
        NumPut("float", radiusX, props, 16)
        NumPut("float", radiusY, props, 20)
        return props
    }
    
    /**
     * Create a D2D1_GRADIENT_STOP structure
     * @param {Number} position - Position of the gradient stop (0.0 to 1.0)
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @returns {Buffer} D2D1_GRADIENT_STOP structure
     */
    static D2D1_GRADIENT_STOP(position, color) {
        local stop := Buffer(20, 0)
        NumPut("float", position, stop, 0)
        
        ; Ensure color has alpha channel
        if (color <= 0xFFFFFF)
            color += 0xFF000000
        
        ; Convert to 0-1 range float values
        NumPut("Float", ((color & 0xFF0000) >> 16) / 255, stop, 4)   ; R
        NumPut("Float", ((color & 0xFF00) >> 8) / 255, stop, 8)      ; G
        NumPut("Float", ((color & 0xFF)) / 255, stop, 12)            ; B
        NumPut("Float", ((color & 0xFF000000) >> 24) / 255, stop, 16) ; A
        
        return stop
    }
    
    /**
     * Create an array of gradient stops
     * @param {Array} stops - Array of [position, color] pairs
     * @returns {Buffer} Buffer containing all gradient stops
     */
    static D2D1_GRADIENT_STOPS_ARRAY(stops) {
        local count := stops.Length
        local bf := Buffer(count * 20, 0)
        
        Loop count {
            position := stops[A_Index][1]
            color := stops[A_Index][2]
            
            ; Ensure color has alpha channel
            if (color <= 0xFFFFFF)
                color += 0xFF000000
                
            offset := (A_Index - 1) * 20
            NumPut("float", position, bf, offset)
            NumPut("Float", ((color & 0xFF0000) >> 16) / 255, bf, offset + 4)   ; R
            NumPut("Float", ((color & 0xFF00) >> 8) / 255, bf, offset + 8)      ; G
            NumPut("Float", ((color & 0xFF)) / 255, bf, offset + 12)            ; B
            NumPut("Float", ((color & 0xFF000000) >> 24) / 255, bf, offset + 16) ; A
        }
        
        return bf
    }
    
    ; ==================== Path Geometry Structures ====================
    
    /**
     * Create a D2D1_BEZIER_SEGMENT structure
     * @param {Number} point1X - X coordinate of first control point
     * @param {Number} point1Y - Y coordinate of first control point
     * @param {Number} point2X - X coordinate of second control point
     * @param {Number} point2Y - Y coordinate of second control point
     * @param {Number} point3X - X coordinate of end point
     * @param {Number} point3Y - Y coordinate of end point
     * @returns {Buffer} D2D1_BEZIER_SEGMENT structure
     */
    static D2D1_BEZIER_SEGMENT(point1X, point1Y, point2X, point2Y, point3X, point3Y) {
        local segment := Buffer(24, 0)
        NumPut("float", point1X, segment, 0)
        NumPut("float", point1Y, segment, 4)
        NumPut("float", point2X, segment, 8)
        NumPut("float", point2Y, segment, 12)
        NumPut("float", point3X, segment, 16)
        NumPut("float", point3Y, segment, 20)
        return segment
    }
    
    /**
     * Create a D2D1_TRIANGLE structure
     * @param {Number} point1X - X coordinate of first point
     * @param {Number} point1Y - Y coordinate of first point
     * @param {Number} point2X - X coordinate of second point
     * @param {Number} point2Y - Y coordinate of second point
     * @param {Number} point3X - X coordinate of third point
     * @param {Number} point3Y - Y coordinate of third point
     * @returns {Buffer} D2D1_TRIANGLE structure
     */
    static D2D1_TRIANGLE(point1X, point1Y, point2X, point2Y, point3X, point3Y) {
        local triangle := Buffer(24, 0)
        NumPut("float", point1X, triangle, 0)
        NumPut("float", point1Y, triangle, 4)
        NumPut("float", point2X, triangle, 8)
        NumPut("float", point2Y, triangle, 12)
        NumPut("float", point3X, triangle, 16)
        NumPut("float", point3Y, triangle, 20)
        return triangle
    }
    
    /**
     * Create a D2D1_ARC_SEGMENT structure
     * @param {Number} pointX - X coordinate of end point
     * @param {Number} pointY - Y coordinate of end point
     * @param {Number} sizeX - X radius
     * @param {Number} sizeY - Y radius
     * @param {Number} rotationAngle - Rotation angle in degrees
     * @param {Integer} sweepDirection - Sweep direction (D2D1Enums.SWEEP_DIRECTION values)
     * @param {Integer} arcSize - Arc size (D2D1Enums.ARC_SIZE values)
     * @returns {Buffer} D2D1_ARC_SEGMENT structure
     */
    static D2D1_ARC_SEGMENT(
        pointX, 
        pointY, 
        sizeX, 
        sizeY, 
        rotationAngle, 
        sweepDirection := D2D1Enums.SWEEP_DIRECTION.D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE, 
        arcSize := D2D1Enums.ARC_SIZE.D2D1_ARC_SIZE_SMALL
    ) {
        local arc := Buffer(28, 0)  ; Corrected size from 24 to 28 bytes
        NumPut("float", pointX, arc, 0)
        NumPut("float", pointY, arc, 4)
        NumPut("float", sizeX, arc, 8)
        NumPut("float", sizeY, arc, 12)
        NumPut("float", rotationAngle, arc, 16)
        NumPut("uint", sweepDirection, arc, 20)
        NumPut("uint", arcSize, arc, 24)
        return arc
    }
    
    /**
     * Create a D2D1_QUADRATIC_BEZIER_SEGMENT structure
     * @param {Number} point1X - X coordinate of control point
     * @param {Number} point1Y - Y coordinate of control point
     * @param {Number} point2X - X coordinate of end point
     * @param {Number} point2Y - Y coordinate of end point
     * @returns {Buffer} D2D1_QUADRATIC_BEZIER_SEGMENT structure
     */
    static D2D1_QUADRATIC_BEZIER_SEGMENT(point1X, point1Y, point2X, point2Y) {
        local segment := Buffer(16, 0)
        NumPut("float", point1X, segment, 0)
        NumPut("float", point1Y, segment, 4)
        NumPut("float", point2X, segment, 8)
        NumPut("float", point2Y, segment, 12)
        return segment
    }
    
    ; ==================== Stroke Style Structures ====================
    
    /**
     * Create a D2D1_STROKE_STYLE_PROPERTIES structure
     * @param {Integer} StartCap - Start cap style (D2D1Enums.CAP_STYLE values)
     * @param {Integer} EndCap - End cap style (D2D1Enums.CAP_STYLE values)
     * @param {Integer} DashCap - Dash cap style (D2D1Enums.CAP_STYLE values)
     * @param {Integer} LineJoin - Line join style (D2D1Enums.LINE_JOIN values)
     * @param {Number} MiterLimit - Miter limit
     * @param {Integer} DashStyle - Dash style (D2D1Enums.DASH_STYLE values)
     * @param {Number} DashOffset - Dash offset
     * @returns {Buffer} D2D1_STROKE_STYLE_PROPERTIES structure
     */
    static D2D1_STROKE_STYLE_PROPERTIES(
        StartCap := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND, 
        EndCap := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND, 
        DashCap := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_FLAT, 
        LineJoin := D2D1Enums.LINE_JOIN.D2D1_LINE_JOIN_ROUND, 
        MiterLimit := 255, 
        DashStyle := D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_SOLID, 
        DashOffset := 0
    ) {
        local size := 28
        local ptr := Buffer(size, 0)
        NumPut("uint", StartCap, ptr, 0)
        NumPut("uint", EndCap, ptr, 4)
        NumPut("uint", DashCap, ptr, 8)
        NumPut("uint", LineJoin, ptr, 12)
        NumPut("float", MiterLimit, ptr, 16)
        NumPut("uint", DashStyle, ptr, 20)
        NumPut("float", DashOffset, ptr, 24)
        return ptr
    }
    
    ; ==================== Render Target Structures ====================
    
    /**
     * Create a D2D1_RENDER_TARGET_PROPERTIES structure
     * @param {Integer} D2D1_RENDER_TARGET_TYPE - Render target type (D2D1Enums.RENDER_TARGET_TYPE values)
     * @param {Integer} DXGI_FORMAT - DXGI format
     * @param {Integer} D2D1_ALPHA_MODE - Alpha mode
     * @param {Number} dpiX - Horizontal DPI
     * @param {Number} dpiY - Vertical DPI
     * @param {Integer} D2D1_RENDER_TARGET_USAGE - Render target usage (D2D1Enums.RENDER_TARGET_USAGE values)
     * @param {Integer} D2D1_FEATURE_LEVEL - Feature level (D2D1Enums.FEATURE_LEVEL values)
     * @returns {Buffer} D2D1_RENDER_TARGET_PROPERTIES structure
     */
    static D2D1_RENDER_TARGET_PROPERTIES(
        D2D1_RENDER_TARGET_TYPE := D2D1Enums.RENDER_TARGET_TYPE.D2D1_RENDER_TARGET_TYPE_DEFAULT, 
        DXGI_FORMAT := 0, 
        D2D1_ALPHA_MODE := 1, 
        dpiX := 96, 
        dpiY := 96, 
        D2D1_RENDER_TARGET_USAGE := D2D1Enums.RENDER_TARGET_USAGE.D2D1_RENDER_TARGET_USAGE_NONE, 
        D2D1_FEATURE_LEVEL := D2D1Enums.FEATURE_LEVEL.D2D1_FEATURE_LEVEL_DEFAULT
    ) {
        local rtPtr := Buffer(28, 0)
        NumPut("uint", D2D1_RENDER_TARGET_TYPE, rtPtr, 0)
        NumPut("uint", DXGI_FORMAT, rtPtr, 4)
        NumPut("uint", D2D1_ALPHA_MODE, rtPtr, 8)
        NumPut("float", dpiX, rtPtr, 12)
        NumPut("float", dpiY, rtPtr, 16)
        NumPut("uint", D2D1_RENDER_TARGET_USAGE, rtPtr, 20)
        NumPut("uint", D2D1_FEATURE_LEVEL, rtPtr, 24)
        return rtPtr
    }
    
    /**
     * Create a D2D1_HWND_RENDER_TARGET_PROPERTIES structure
     * @param {Integer} hwnd - Window handle
     * @param {Integer} width - Width
     * @param {Integer} height - Height
     * @param {Integer} D2D1_PRESENT_OPTIONS - Present options (D2D1Enums.PRESENT_OPTIONS values):
     *                                        D2D1_PRESENT_OPTIONS_NONE = VSync enabled
     *                                        D2D1_PRESENT_OPTIONS_IMMEDIATELY = VSync disabled
     * @returns {Buffer} D2D1_HWND_RENDER_TARGET_PROPERTIES structure
     */
    static D2D1_HWND_RENDER_TARGET_PROPERTIES(
        hwnd := 0, 
        width := 0, 
        height := 0, 
        D2D1_PRESENT_OPTIONS := D2D1Enums.PRESENT_OPTIONS.D2D1_PRESENT_OPTIONS_NONE
    ) {
        local size := A_PtrSize + 12
        local hrtPtr := Buffer(size, 0)
        NumPut("UPtr", hwnd, hrtPtr, 0)
        NumPut("uint", width, hrtPtr, A_PtrSize)
        NumPut("uint", height, hrtPtr, A_PtrSize + 4)
        NumPut("uint", D2D1_PRESENT_OPTIONS, hrtPtr, A_PtrSize + 8)
        return hrtPtr
    }
    
    /**
     * Create a D2D1_BITMAP_PROPERTIES structure
     * @param {Integer} pixelFormat - Pixel format
     * @param {Number} dpiX - Horizontal DPI
     * @param {Number} dpiY - Vertical DPI
     * @returns {Buffer} D2D1_BITMAP_PROPERTIES structure
     */
    static D2D1_BITMAP_PROPERTIES(pixelFormat := 0, dpiX := 96, dpiY := 96) {
        local props := Buffer(16, 0)
        NumPut("uint", pixelFormat, props, 0)  ; pixelFormat
        NumPut("uint", 0, props, 4)            ; alphaMode
        NumPut("float", dpiX, props, 8)        ; dpiX
        NumPut("float", dpiY, props, 12)       ; dpiY
        return props
    }
    
    /**
     * Create a D2D1_DRAWING_STATE_DESCRIPTION structure
     * @param {Integer} antialiasMode - Antialias mode (D2D1Enums.ANTIALIAS_MODE values)
     * @param {Integer} textAntialiasMode - Text antialias mode (D2D1Enums.TEXT_ANTIALIAS_MODE values)
     * @param {Integer} tag1 - Tag 1
     * @param {Integer} tag2 - Tag 2
     * @param {Buffer} transform - D2D1_MATRIX_3X2_F transform matrix
     * @returns {Buffer} D2D1_DRAWING_STATE_DESCRIPTION structure
     */
    static D2D1_DRAWING_STATE_DESCRIPTION(
        antialiasMode := D2D1Enums.ANTIALIAS_MODE.D2D1_ANTIALIAS_MODE_PER_PRIMITIVE, 
        textAntialiasMode := D2D1Enums.TEXT_ANTIALIAS_MODE.D2D1_TEXT_ANTIALIAS_MODE_DEFAULT, 
        tag1 := 0, 
        tag2 := 0, 
        transform := 0
    ) {
        local desc := Buffer(48, 0)  ; Corrected size from 40 to 48 bytes
        NumPut("uint", antialiasMode, desc, 0)
        NumPut("uint", textAntialiasMode, desc, 4)
        NumPut("uint64", tag1, desc, 8)
        NumPut("uint64", tag2, desc, 16)
        
        if (transform) {
            ; Copy the transform matrix
            NumPut("float", NumGet(transform, 0, "float"), desc, 24)  ; M11
            NumPut("float", NumGet(transform, 4, "float"), desc, 28)  ; M12
            NumPut("float", NumGet(transform, 8, "float"), desc, 32)  ; M21
            NumPut("float", NumGet(transform, 12, "float"), desc, 36) ; M22
            NumPut("float", NumGet(transform, 16, "float"), desc, 40) ; Dx
            NumPut("float", NumGet(transform, 20, "float"), desc, 44) ; Dy
        } else {
            ; Identity matrix
            NumPut("float", 1, desc, 24)  ; M11
            NumPut("float", 0, desc, 28)  ; M12
            NumPut("float", 0, desc, 32)  ; M21
            NumPut("float", 1, desc, 36)  ; M22
            NumPut("float", 0, desc, 40)  ; Dx
            NumPut("float", 0, desc, 44)  ; Dy
        }
        
        return desc
    }
    
    ; ==================== Miscellaneous Structures ====================
    
    /**
     * Create a MARGINS structure
     * @param {Integer} cxLeftWidth - Left width
     * @param {Integer} cxRightWidth - Right width
     * @param {Integer} cyTopHeight - Top height
     * @param {Integer} cyBottomHeight - Bottom height
     * @returns {Buffer} MARGINS structure
     */
    static _MARGINS(cxLeftWidth := -1, cxRightWidth := -1, cyTopHeight := -1, cyBottomHeight := -1) {
        local marg := Buffer(16, 0)
        NumPut("int", cxLeftWidth, marg, 0)
        NumPut("int", cxRightWidth, marg, 4)
        NumPut("int", cyTopHeight, marg, 8)
        NumPut("int", cyBottomHeight, marg, 12)
        return marg
    }
    
    /**
     * Create a GdiplusStartupInput structure
     * @param {Integer} GdiplusVersion - GDI+ version
     * @returns {Buffer} GdiplusStartupInput structure
     */
    static gdiplusStartupInput(GdiplusVersion := 1) {
        local inPtr := Buffer(8 + 2 * A_PtrSize, 0)
        NumPut("UInt", GdiplusVersion, inPtr, 0)
        return inPtr
    }
    
    /**
     * Create a D2D1_FACTORY_OPTIONS structure
     * @param {Integer} debugLevel - Debug level (D2D1Enums.DEBUG_LEVEL values)
     * @returns {Buffer} D2D1_FACTORY_OPTIONS structure
     */
    static D2D1_FACTORY_OPTIONS(debugLevel := D2D1Enums.DEBUG_LEVEL.D2D1_DEBUG_LEVEL_NONE) {
        local options := Buffer(4, 0)
        NumPut("uint", debugLevel, options, 0)
        return options
    }
}