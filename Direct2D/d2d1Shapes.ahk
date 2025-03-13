;==================================================================================================================
; Direct2D Shape Classes
;==================================================================================================================
; Description:    Object-oriented shape classes for Direct2D rendering
;                 Provides a hierarchy of shape classes for easy manipulation and rendering
;
; Features:       - Base shape class with common properties and methods
;                 - Specialized classes for rectangles, circles, lines, polygons, and text
;                 - Support for filled and outlined shapes
;                 - Text rendering with alignment and effects
;                 - Transformation support (rotation, scaling, translation)
;                 - Easy positioning and styling
;
; Usage:          rect := D2D1Rectangle(x, y, width, height, color)
;                 d2d.beginDraw()
;                 rect.draw(d2d)
;                 d2d.endDraw()
;
; Dependencies:   - AutoHotkey v2.0+
;                 - d2d1.ahk
;                 - D2D1Enums.ahk
;                 - D2D1Structs.ahk
;
; Author:         CasperHarkin
; Version:        1.1.0
; Last Updated:   12/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#Include "D2D1Enums.ahk"
#Include "D2D1Structs.ahk"

/**
 * Base shape class
 */
class d2d1Shapes {
    ; Basic properties
    _x := 0
    _y := 0
    _color := 0xFFFFFFFF
    _transform := 0
    _visible := true
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, color := 0xFFFFFFFF) {
        this._x := x
        this._y := y
        this._color := color
    }
    
    /**
     * Draw the shape
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        ; To be implemented by derived classes
    }
    
    /**
     * Move the shape
     * @param {Number} dx - X offset
     * @param {Number} dy - Y offset
     * @returns {d2d1Shapes} - This object for method chaining
     */
    move(dx, dy) {
        this._x += dx
        this._y += dy
        return this
    }
    
    /**
     * Set the shape color
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @returns {d2d1Shapes} - This object for method chaining
     */
    setColor(color) {
        this._color := color
        return this
    }
    
    /**
     * Set the shape position
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @returns {d2d1Shapes} - This object for method chaining
     */
    setPosition(x, y) {
        this._x := x
        this._y := y
        return this
    }
    
    /**
     * Set the shape visibility
     * @param {Boolean} visible - Whether the shape is visible
     * @returns {d2d1Shapes} - This object for method chaining
     */
    setVisible(visible) {
        this._visible := visible
        return this
    }
    
    /**
     * Rotate the shape
     * @param {Number} angle - Rotation angle in degrees
     * @param {Number} centerX - X center of rotation (default: shape center)
     * @param {Number} centerY - Y center of rotation (default: shape center)
     * @returns {d2d1Shapes} - This object for method chaining
     */
    rotate(angle, centerX := 0, centerY := 0) {
        ; Default to shape center if not specified
        if (centerX == 0)
            centerX := this._x
        if (centerY == 0)
            centerY := this._y
            
        this._transform := D2D1Structs.RotationMatrix(angle, centerX, centerY)
        return this
    }
    
    /**
     * Scale the shape
     * @param {Number} scaleX - X scale factor
     * @param {Number} scaleY - Y scale factor (default: same as scaleX)
     * @param {Number} centerX - X center of scaling (default: shape center)
     * @param {Number} centerY - Y center of scaling (default: shape center)
     * @returns {d2d1Shapes} - This object for method chaining
     */
    scale(scaleX, scaleY := 0, centerX := 0, centerY := 0) {
        ; Default to uniform scaling if scaleY not specified
        if (scaleY == 0)
            scaleY := scaleX
            
        ; Default to shape center if not specified
        if (centerX == 0)
            centerX := this._x
        if (centerY == 0)
            centerY := this._y
            
        this._transform := D2D1Structs.ScalingMatrix(scaleX, scaleY, centerX, centerY)
        return this
    }
    
    /**
     * Translate the shape
     * @param {Number} dx - X translation
     * @param {Number} dy - Y translation
     * @returns {d2d1Shapes} - This object for method chaining
     */
    translate(dx, dy) {
        this._transform := D2D1Structs.TranslationMatrix(dx, dy)
        return this
    }
    
    /**
     * Reset the shape transformation
     * @returns {d2d1Shapes} - This object for method chaining
     */
    resetTransform() {
        this._transform := 0
        return this
    }
    
    /**
     * Clone the shape
     * @returns {d2d1Shapes} - A new shape with the same properties
     */
    clone() {
        ; To be implemented by derived classes
        return this
    }
}

/**
 * Rectangle shape
 */
class D2D1Rectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, width, height, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
    }
    
    /**
     * Draw the rectangle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.RectFromSize for consistent structure handling
        rect := D2D1Structs.RectFromSize(this._x, this._y, this._width, this._height)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the rectangle
        d2d.fillRectangle(this._x, this._y, this._width, this._height, this._color)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the rectangle size
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @returns {D2D1Rectangle} - This object for method chaining
     */
    setSize(width, height) {
        this._width := width
        this._height := height
        return this
    }
    
    /**
     * Clone the rectangle
     * @returns {D2D1Rectangle} - A new rectangle with the same properties
     */
    clone() {
        rect := D2D1Rectangle(this._x, this._y, this._width, this._height, this._color)
        rect._transform := this._transform
        rect._visible := this._visible
        return rect
    }
}

/**
 * Outline Rectangle shape
 */
class D2D1OutlineRectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, width, height, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the rectangle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.RectFromSize for consistent structure handling
        rect := D2D1Structs.RectFromSize(this._x, this._y, this._width, this._height)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the rectangle outline
        d2d.drawRectangle(this._x, this._y, this._width, this._height, this._color, this._thickness, this._rounded)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the rectangle size
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @returns {D2D1OutlineRectangle} - This object for method chaining
     */
    setSize(width, height) {
        this._width := width
        this._height := height
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1OutlineRectangle} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded caps
     * @param {Boolean} rounded - Whether to use rounded caps
     * @returns {D2D1OutlineRectangle} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Clone the rectangle outline
     * @returns {D2D1OutlineRectangle} - A new rectangle outline with the same properties
     */
    clone() {
        rect := D2D1OutlineRectangle(this._x, this._y, this._width, this._height, this._color, this._thickness, this._rounded)
        rect._transform := this._transform
        rect._visible := this._visible
        return rect
    }
}

/**
 * Rounded Rectangle shape
 */
class D2D1RoundedRectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    _radiusX := 0
    _radiusY := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
        this._radiusX := radiusX
        this._radiusY := radiusY
    }
    
    /**
     * Draw the rounded rectangle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.RoundedRectFromSize for consistent structure handling
        rect := D2D1Structs.RoundedRectFromSize(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the rounded rectangle
        d2d.fillRoundedRectangle(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY, this._color)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the rectangle size
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @returns {D2D1RoundedRectangle} - This object for method chaining
     */
    setSize(width, height) {
        this._width := width
        this._height := height
        return this
    }
    
    /**
     * Set the corner radius
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @returns {D2D1RoundedRectangle} - This object for method chaining
     */
    setRadius(radiusX, radiusY) {
        this._radiusX := radiusX
        this._radiusY := radiusY
        return this
    }
    
    /**
     * Clone the rounded rectangle
     * @returns {D2D1RoundedRectangle} - A new rounded rectangle with the same properties
     */
    clone() {
        rect := D2D1RoundedRectangle(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY, this._color)
        rect._transform := this._transform
        rect._visible := this._visible
        return rect
    }
}

/**
 * Outline Rounded Rectangle shape
 */
class D2D1OutlineRoundedRectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    _radiusX := 0
    _radiusY := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
        this._radiusX := radiusX
        this._radiusY := radiusY
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the rounded rectangle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.RoundedRectFromSize for consistent structure handling
        rect := D2D1Structs.RoundedRectFromSize(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the rounded rectangle outline
        d2d.drawRoundedRectangle(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY, this._color, this._thickness, this._rounded)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the rectangle size
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @returns {D2D1OutlineRoundedRectangle} - This object for method chaining
     */
    setSize(width, height) {
        this._width := width
        this._height := height
        return this
    }
    
    /**
     * Set the corner radius
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @returns {D2D1OutlineRoundedRectangle} - This object for method chaining
     */
    setRadius(radiusX, radiusY) {
        this._radiusX := radiusX
        this._radiusY := radiusY
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1OutlineRoundedRectangle} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded caps
     * @param {Boolean} rounded - Whether to use rounded caps
     * @returns {D2D1OutlineRoundedRectangle} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Clone the rounded rectangle outline
     * @returns {D2D1OutlineRoundedRectangle} - A new rounded rectangle outline with the same properties
     */
    clone() {
        rect := D2D1OutlineRoundedRectangle(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY, this._color, this._thickness, this._rounded)
        rect._transform := this._transform
        rect._visible := this._visible
        return rect
    }
}

/**
 * Circle shape
 */
class D2D1Circle extends d2d1Shapes {
    _radius := 0
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radius - Radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, radius, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._radius := radius
    }
    
    /**
     * Draw the circle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_ELLIPSE for consistent structure handling
        ellipse := D2D1Structs.D2D1_ELLIPSE(this._x, this._y, this._radius, this._radius)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the circle
        d2d.fillCircle(this._x, this._y, this._radius, this._color)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the radius
     * @param {Number} radius - Radius
     * @returns {D2D1Circle} - This object for method chaining
     */
    setRadius(radius) {
        this._radius := radius
        return this
    }
    
    /**
     * Clone the circle
     * @returns {D2D1Circle} - A new circle with the same properties
     */
    clone() {
        circle := D2D1Circle(this._x, this._y, this._radius, this._color)
        circle._transform := this._transform
        circle._visible := this._visible
        return circle
    }
}

/**
 * Outline Circle shape
 */
class D2D1OutlineCircle extends d2d1Shapes {
    _radius := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radius - Radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, radius, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._radius := radius
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the circle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_ELLIPSE for consistent structure handling
        ellipse := D2D1Structs.D2D1_ELLIPSE(this._x, this._y, this._radius, this._radius)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the circle outline
        d2d.drawCircle(this._x, this._y, this._radius, this._color, this._thickness, this._rounded)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the radius
     * @param {Number} radius - Radius
     * @returns {D2D1OutlineCircle} - This object for method chaining
     */
    setRadius(radius) {
        this._radius := radius
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1OutlineCircle} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded caps
     * @param {Boolean} rounded - Whether to use rounded caps
     * @returns {D2D1OutlineCircle} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Clone the circle outline
     * @returns {D2D1OutlineCircle} - A new circle outline with the same properties
     */
    clone() {
        circle := D2D1OutlineCircle(this._x, this._y, this._radius, this._color, this._thickness, this._rounded)
        circle._transform := this._transform
        circle._visible := this._visible
        return circle
    }
}

/**
 * Line shape
 */
class D2D1Line extends d2d1Shapes {
    _x2 := 0
    _y2 := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x1 - Start X coordinate
     * @param {Number} y1 - Start Y coordinate
     * @param {Number} x2 - End X coordinate
     * @param {Number} y2 - End Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x1, y1, color)
        this._x2 := x2
        this._y2 := y2
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the line
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D_POINT_2F for consistent structure handling
        points := D2D1Structs.D2D_POINT_2F(this._x, this._y, this._x2, this._y2)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the line
        d2d.drawLine(this._x, this._y, this._x2, this._y2, this._color, this._thickness, this._rounded)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the end point
     * @param {Number} x2 - End X coordinate
     * @param {Number} y2 - End Y coordinate
     * @returns {D2D1Line} - This object for method chaining
     */
    setEndPoint(x2, y2) {
        this._x2 := x2
        this._y2 := y2
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1Line} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded caps
     * @param {Boolean} rounded - Whether to use rounded caps
     * @returns {D2D1Line} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Clone the line
     * @returns {D2D1Line} - A new line with the same properties
     */
    clone() {
        line := D2D1Line(this._x, this._y, this._x2, this._y2, this._color, this._thickness, this._rounded)
        line._transform := this._transform
        line._visible := this._visible
        return line
    }
}

/**
 * Polygon shape
 */
class D2D1Polygon extends d2d1Shapes {
    _points := []
    _xOffset := 0
    _yOffset := 0
    
    /**
     * Constructor
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     */
    __New(points, color := 0xFFFFFFFF, xOffset := 0, yOffset := 0) {
        super.__New(0, 0, color)
        this._points := points
        this._xOffset := xOffset
        this._yOffset := yOffset
    }
    
    /**
     * Draw the polygon
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_POINTS_ARRAY for consistent structure handling
        pointsBuffer := D2D1Structs.D2D1_POINTS_ARRAY(this._points, this._xOffset, this._yOffset)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the polygon
        d2d.fillPolygon(this._points, this._color, this._xOffset, this._yOffset)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the points
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @returns {D2D1Polygon} - This object for method chaining
     */
    setPoints(points) {
        this._points := points
        return this
    }
    
    /**
     * Set the offset
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     * @returns {D2D1Polygon} - This object for method chaining
     */
    setOffset(xOffset, yOffset) {
        this._xOffset := xOffset
        this._yOffset := yOffset
        return this
    }
    
    /**
     * Add a point to the polygon
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @returns {D2D1Polygon} - This object for method chaining
     */
    addPoint(x, y) {
        this._points.Push([x, y])
        return this
    }
    
    /**
     * Clone the polygon
     * @returns {D2D1Polygon} - A new polygon with the same properties
     */
    clone() {
        ; Clone the points array
        pointsCopy := []
        for point in this._points {
            pointsCopy.Push([point[1], point[2]])
        }
        
        polygon := D2D1Polygon(pointsCopy, this._color, this._xOffset, this._yOffset)
        polygon._transform := this._transform
        polygon._visible := this._visible
        return polygon
    }
}

/**
 * Outline Polygon shape
 */
class D2D1OutlinePolygon extends d2d1Shapes {
    _points := []
    _thickness := 1
    _rounded := 0
    _xOffset := 0
    _yOffset := 0
    
    /**
     * Constructor
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded corners
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     */
    __New(points, color := 0xFFFFFFFF, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0) {
        super.__New(0, 0, color)
        this._points := points
        this._thickness := thickness
        this._rounded := rounded
        this._xOffset := xOffset
        this._yOffset := yOffset
    }
    
    /**
     * Draw the polygon outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_POINTS_ARRAY for consistent structure handling
        pointsBuffer := D2D1Structs.D2D1_POINTS_ARRAY(this._points, this._xOffset, this._yOffset)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the polygon outline
        d2d.drawPolygon(this._points, this._color, this._thickness, this._rounded, this._xOffset, this._yOffset)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the points
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @returns {D2D1OutlinePolygon} - This object for method chaining
     */
    setPoints(points) {
        this._points := points
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1OutlinePolygon} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded corners
     * @param {Boolean} rounded - Whether to use rounded corners
     * @returns {D2D1OutlinePolygon} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Set the offset
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     * @returns {D2D1OutlinePolygon} - This object for method chaining
     */
    setOffset(xOffset, yOffset) {
        this._xOffset := xOffset
        this._yOffset := yOffset
        return this
    }
    
    /**
     * Add a point to the polygon
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @returns {D2D1OutlinePolygon} - This object for method chaining
     */
    addPoint(x, y) {
        this._points.Push([x, y])
        return this
    }
    
    /**
     * Clone the polygon outline
     * @returns {D2D1OutlinePolygon} - A new polygon outline with the same properties
     */
    clone() {
        ; Clone the points array
        pointsCopy := []
        for point in this._points {
            pointsCopy.Push([point[1], point[2]])
        }
        
        polygon := D2D1OutlinePolygon(pointsCopy, this._color, this._thickness, this._rounded, this._xOffset, this._yOffset)
        polygon._transform := this._transform
        polygon._visible := this._visible
        return polygon
    }
}

/**
 * Text shape
 */
class D2D1Text extends d2d1Shapes {
    _text := ""
    _width := 0
    _height := 0
    _fontSize := 18
    _fontName := "Arial"
    _extraOptions := ""
    
    /**
     * Constructor
     * @param {String} text - Text content
     * @param {Number} x - X position
     * @param {Number} y - Y position
     * @param {Number} width - Width of text block
     * @param {Number} height - Height of text block
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {String} fontName - Font name
     * @param {String} alignment - Text alignment ("left", "center", "right")
     * @param {String} extraOptions - Additional options for text rendering
     */
    __New(text, x, y, width, height, color := 0xFF000000, fontName := "Arial",
          alignment := "left", extraOptions := "") {
        super.__New(x, y, color)
        this._text := text
        this._width := width
        this._height := height
        this._fontName := fontName
        
        ; Build extra options string
        this._extraOptions := "w" width " h" height
        
        ; Add alignment
        if (alignment = "center")
            this._extraOptions .= " aCenter"
        else if (alignment = "right")
            this._extraOptions .= " aRight"
            
        ; Add any additional options
        if (extraOptions)
            this._extraOptions .= " " extraOptions
    }
    
    /**
     * Draw the text
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D_RECT_F for consistent structure handling
        rect := D2D1Structs.D2D_RECT_F(this._x, this._y, this._x + this._width, this._y + this._height)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the text
        d2d.drawText(this._text, this._x, this._y, this._fontSize, this._color,
                    this._fontName, this._extraOptions)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the text content
     * @param {String} text - New text content
     * @returns {D2D1Text} - This object for method chaining
     */
    setText(text) {
        this._text := text
        return this
    }
    
    /**
     * Set the font size
     * @param {Number} size - Font size
     * @returns {D2D1Text} - This object for method chaining
     */
    setFontSize(size) {
        this._fontSize := size
        return this
    }
    
    /**
     * Set the font name
     * @param {String} fontName - Font name
     * @returns {D2D1Text} - This object for method chaining
     */
    setFontName(fontName) {
        this._fontName := fontName
        return this
    }
    
    /**
     * Set the text alignment
     * @param {String} alignment - Text alignment ("left", "center", "right")
     * @returns {D2D1Text} - This object for method chaining
     */
    setAlignment(alignment) {
        ; Remove existing alignment options
        this._extraOptions := RegExReplace(this._extraOptions, "a(Left|Right|Center)", "")
        
        ; Add new alignment
        if (alignment = "center")
            this._extraOptions .= " aCenter"
        else if (alignment = "right")
            this._extraOptions .= " aRight"
            
        return this
    }
    
    /**
     * Add drop shadow effect
     * @param {Integer} color - Shadow color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     * @returns {D2D1Text} - This object for method chaining
     */
    addDropShadow(color, xOffset := 1, yOffset := 1) {
        ; Remove existing shadow options
        this._extraOptions := RegExReplace(this._extraOptions, "ds[a-fA-F\d]+ dsx[\d\.]+ dsy[\d\.]+", "")
        
        ; Add new shadow options
        colorHex := Format("{:X}", color)
        this._extraOptions .= " ds" colorHex " dsx" xOffset " dsy" yOffset
        
        return this
    }
    
    /**
     * Add outline effect
     * @param {Integer} color - Outline color in 0xAARRGGBB or 0xRRGGBB format
     * @returns {D2D1Text} - This object for method chaining
     */
    addOutline(color) {
        ; Remove existing outline options
        this._extraOptions := RegExReplace(this._extraOptions, "ol[a-fA-F\d]+", "")
        
        ; Add new outline options
        colorHex := Format("{:X}", color)
        this._extraOptions .= " ol" colorHex
        
        return this
    }
    
    /**
     * Set the text size
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @returns {D2D1Text} - This object for method chaining
     */
    setSize(width, height) {
        this._width := width
        this._height := height
        
        ; Update width and height in extra options
        this._extraOptions := RegExReplace(this._extraOptions, "w[\d\.]+ h[\d\.]+", "w" width " h" height)
        
        return this
    }
    
    /**
     * Clone the text
     * @returns {D2D1Text} - A new text with the same properties
     */
    clone() {
        text := D2D1Text(this._text, this._x, this._y, this._width, this._height, this._color, this._fontName)
        text._fontSize := this._fontSize
        text._extraOptions := this._extraOptions
        text._transform := this._transform
        text._visible := this._visible
        return text
    }
}

/**
 * Triangle shape
 */
class D2D1Triangle extends d2d1Shapes {
    _x2 := 0
    _y2 := 0
    _x3 := 0
    _y3 := 0
    
    /**
     * Constructor
     * @param {Number} x1 - First point X coordinate
     * @param {Number} y1 - First point Y coordinate
     * @param {Number} x2 - Second point X coordinate
     * @param {Number} y2 - Second point Y coordinate
     * @param {Number} x3 - Third point X coordinate
     * @param {Number} y3 - Third point Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x1, y1, x2, y2, x3, y3, color := 0xFFFFFFFF) {
        super.__New(x1, y1, color)
        this._x2 := x2
        this._y2 := y2
        this._x3 := x3
        this._y3 := y3
    }
    
    /**
     * Draw the triangle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_TRIANGLE for consistent structure handling
        triangle := D2D1Structs.D2D1_TRIANGLE(this._x, this._y, this._x2, this._y2, this._x3, this._y3)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Create points array for polygon
        points := [[this._x, this._y], [this._x2, this._y2], [this._x3, this._y3]]
        
        ; Draw the triangle as a polygon
        d2d.fillPolygon(points, this._color)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the points
     * @param {Number} x1 - First point X coordinate
     * @param {Number} y1 - First point Y coordinate
     * @param {Number} x2 - Second point X coordinate
     * @param {Number} y2 - Second point Y coordinate
     * @param {Number} x3 - Third point X coordinate
     * @param {Number} y3 - Third point Y coordinate
     * @returns {D2D1Triangle} - This object for method chaining
     */
    setPoints(x1, y1, x2, y2, x3, y3) {
        this._x := x1
        this._y := y1
        this._x2 := x2
        this._y2 := y2
        this._x3 := x3
        this._y3 := y3
        return this
    }
    
    /**
     * Clone the triangle
     * @returns {D2D1Triangle} - A new triangle with the same properties
     */
    clone() {
        triangle := D2D1Triangle(this._x, this._y, this._x2, this._y2, this._x3, this._y3, this._color)
        triangle._transform := this._transform
        triangle._visible := this._visible
        return triangle
    }
}

/**
 * Outline Triangle shape
 */
class D2D1OutlineTriangle extends d2d1Shapes {
    _x2 := 0
    _y2 := 0
    _x3 := 0
    _y3 := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x1 - First point X coordinate
     * @param {Number} y1 - First point Y coordinate
     * @param {Number} x2 - Second point X coordinate
     * @param {Number} y2 - Second point Y coordinate
     * @param {Number} x3 - Third point X coordinate
     * @param {Number} y3 - Third point Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded corners
     */
    __New(x1, y1, x2, y2, x3, y3, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x1, y1, color)
        this._x2 := x2
        this._y2 := y2
        this._x3 := x3
        this._y3 := y3
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the triangle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_TRIANGLE for consistent structure handling
        triangle := D2D1Structs.D2D1_TRIANGLE(this._x, this._y, this._x2, this._y2, this._x3, this._y3)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Create points array for polygon
        points := [[this._x, this._y], [this._x2, this._y2], [this._x3, this._y3]]
        
        ; Draw the triangle outline as a polygon outline
        d2d.drawPolygon(points, this._color, this._thickness, this._rounded)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the points
     * @param {Number} x1 - First point X coordinate
     * @param {Number} y1 - First point Y coordinate
     * @param {Number} x2 - Second point X coordinate
     * @param {Number} y2 - Second point Y coordinate
     * @param {Number} x3 - Third point X coordinate
     * @param {Number} y3 - Third point Y coordinate
     * @returns {D2D1OutlineTriangle} - This object for method chaining
     */
    setPoints(x1, y1, x2, y2, x3, y3) {
        this._x := x1
        this._y := y1
        this._x2 := x2
        this._y2 := y2
        this._x3 := x3
        this._y3 := y3
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1OutlineTriangle} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded corners
     * @param {Boolean} rounded - Whether to use rounded corners
     * @returns {D2D1OutlineTriangle} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Clone the triangle outline
     * @returns {D2D1OutlineTriangle} - A new triangle outline with the same properties
     */
    clone() {
        triangle := D2D1OutlineTriangle(this._x, this._y, this._x2, this._y2, this._x3, this._y3, this._color, this._thickness, this._rounded)
        triangle._transform := this._transform
        triangle._visible := this._visible
        return triangle
    }
}

/**
 * Ellipse shape
 */
class D2D1Ellipse extends d2d1Shapes {
    _radiusX := 0
    _radiusY := 0
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, radiusX, radiusY, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._radiusX := radiusX
        this._radiusY := radiusY
    }
    
    /**
     * Draw the ellipse
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_ELLIPSE for consistent structure handling
        ellipse := D2D1Structs.D2D1_ELLIPSE(this._x, this._y, this._radiusX, this._radiusY)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the ellipse
        d2d.fillEllipse(this._x, this._y, this._radiusX, this._radiusY, this._color)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the radii
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @returns {D2D1Ellipse} - This object for method chaining
     */
    setRadii(radiusX, radiusY) {
        this._radiusX := radiusX
        this._radiusY := radiusY
        return this
    }
    
    /**
     * Clone the ellipse
     * @returns {D2D1Ellipse} - A new ellipse with the same properties
     */
    clone() {
        ellipse := D2D1Ellipse(this._x, this._y, this._radiusX, this._radiusY, this._color)
        ellipse._transform := this._transform
        ellipse._visible := this._visible
        return ellipse
    }
}

/**
 * Outline Ellipse shape
 */
class D2D1OutlineEllipse extends d2d1Shapes {
    _radiusX := 0
    _radiusY := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, radiusX, radiusY, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._radiusX := radiusX
        this._radiusY := radiusY
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the ellipse outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Use D2D1Structs.D2D1_ELLIPSE for consistent structure handling
        ellipse := D2D1Structs.D2D1_ELLIPSE(this._x, this._y, this._radiusX, this._radiusY)
        
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the ellipse outline
        d2d.drawEllipse(this._x, this._y, this._radiusX, this._radiusY, this._color, this._thickness, this._rounded)
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the radii
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @returns {D2D1OutlineEllipse} - This object for method chaining
     */
    setRadii(radiusX, radiusY) {
        this._radiusX := radiusX
        this._radiusY := radiusY
        return this
    }
    
    /**
     * Set the line thickness
     * @param {Number} thickness - Line thickness
     * @returns {D2D1OutlineEllipse} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded caps
     * @param {Boolean} rounded - Whether to use rounded caps
     * @returns {D2D1OutlineEllipse} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Clone the ellipse outline
     * @returns {D2D1OutlineEllipse} - A new ellipse outline with the same properties
     */
    clone() {
        ellipse := D2D1OutlineEllipse(this._x, this._y, this._radiusX, this._radiusY, this._color, this._thickness, this._rounded)
        ellipse._transform := this._transform
        ellipse._visible := this._visible
        return ellipse
    }
}

/**
 * Arc shape
 */
class D2D1Arc extends d2d1Shapes {
    _radiusX := 0
    _radiusY := 0
    _startAngle := 0
    _sweepAngle := 90
    _thickness := 1
    _rounded := 0
    _filled := false
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @param {Number} startAngle - Start angle in degrees
     * @param {Number} sweepAngle - Sweep angle in degrees
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness (for outlined arc)
     * @param {Boolean} rounded - Whether to use rounded caps (for outlined arc)
     * @param {Boolean} filled - Whether to fill the arc
     */
    __New(x, y, radiusX, radiusY, startAngle, sweepAngle, color := 0xFFFFFFFF, thickness := 1, rounded := 0, filled := false) {
        super.__New(x, y, color)
        this._radiusX := radiusX
        this._radiusY := radiusY
        this._startAngle := startAngle
        this._sweepAngle := sweepAngle
        this._thickness := thickness
        this._rounded := rounded
        this._filled := filled
    }
    
    /**
     * Draw the arc
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        if (!this._visible)
            return
            
        ; Apply transformation if set
        if (this._transform) {
            ; Save current transform
            oldTransform := Buffer(24, 0)
            DllCall(d2d._vTable(d2d._renderTarget, 31), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
            
            ; Set new transform
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", this._transform)
        }
        
        ; Draw the arc
        if (this._filled) {
            d2d.fillArc(this._x, this._y, this._radiusX, this._radiusY, this._startAngle, this._sweepAngle, this._color)
        } else {
            d2d.drawArc(this._x, this._y, this._radiusX, this._radiusY, this._startAngle, this._sweepAngle, this._color, this._thickness, this._rounded)
        }
        
        ; Restore original transform if needed
        if (this._transform) {
            DllCall(d2d._vTable(d2d._renderTarget, 30), "Ptr", d2d._renderTarget, "Ptr", oldTransform)
        }
    }
    
    /**
     * Set the radii
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @returns {D2D1Arc} - This object for method chaining
     */
    setRadii(radiusX, radiusY) {
        this._radiusX := radiusX
        this._radiusY := radiusY
        return this
    }
    
    /**
     * Set the angles
     * @param {Number} startAngle - Start angle in degrees
     * @param {Number} sweepAngle - Sweep angle in degrees
     * @returns {D2D1Arc} - This object for method chaining
     */
    setAngles(startAngle, sweepAngle) {
        this._startAngle := startAngle
        this._sweepAngle := sweepAngle
        return this
    }
    
    /**
     * Set the line thickness (for outlined arc)
     * @param {Number} thickness - Line thickness
     * @returns {D2D1Arc} - This object for method chaining
     */
    setThickness(thickness) {
        this._thickness := thickness
        return this
    }
    
    /**
     * Set whether to use rounded caps (for outlined arc)
     * @param {Boolean} rounded - Whether to use rounded caps
     * @returns {D2D1Arc} - This object for method chaining
     */
    setRounded(rounded) {
        this._rounded := rounded
        return this
    }
    
    /**
     * Set whether to fill the arc
     * @param {Boolean} filled - Whether to fill the arc
     * @returns {D2D1Arc} - This object for method chaining
     */
    setFilled(filled) {
        this._filled := filled
        return this
    }
    
    /**
     * Clone the arc
     * @returns {D2D1Arc} - A new arc with the same properties
     */
    clone() {
        arc := D2D1Arc(this._x, this._y, this._radiusX, this._radiusY, this._startAngle, this._sweepAngle, this._color, this._thickness, this._rounded, this._filled)
        arc._transform := this._transform
        arc._visible := this._visible
        return arc
    }
}
