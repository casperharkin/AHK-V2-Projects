# Direct2D Structure Definitions (d2d1Structs.ahk)

## Introduction

The `d2d1Structs.ahk` file is a critical component of the Direct2D wrapper for AutoHotkey v2. It provides structure definitions and buffer creation functions that bridge the gap between AutoHotkey and the Windows Direct2D API. This document offers both a tutorial-based approach to understanding and using these structures, with practical examples, as well as comprehensive technical details about the underlying Direct2D concepts and implementation specifics.

## What is Direct2D?

Direct2D is a hardware-accelerated, immediate-mode 2D graphics API from Microsoft that provides high-performance and high-quality rendering for 2D geometry, bitmaps, and text. It takes advantage of modern graphics hardware through DirectX, offering better performance than GDI or GDI+.

Key benefits of Direct2D include:
- Hardware acceleration for better performance
- High-quality rendering with antialiasing
- Support for advanced graphics features
- Consistent rendering across different devices

### Technical Architecture

Direct2D is built on top of DirectX and is designed to work with other DirectX APIs like DXGI (DirectX Graphics Infrastructure) and Direct3D. The architecture consists of:

1. **Direct2D Factory**: Creates resources and render targets
2. **Render Targets**: Surfaces where drawing operations are performed
3. **Resources**: Objects like brushes, geometries, and bitmaps
4. **Device Contexts**: Manage the state of drawing operations

Direct2D uses a retained-mode model for resources (they persist between frames) but an immediate-mode model for drawing operations (they are executed immediately and not stored).

## Understanding Memory Structures in Direct2D

Direct2D, like most Windows APIs, requires specific memory structures to function. These structures need to be properly formatted and aligned in memory. The `d2d1Structs.ahk` file handles this complexity for you by providing functions that:

1. Create properly sized memory buffers
2. Fill these buffers with the correct data in the right format
3. Handle differences between 32-bit and 64-bit environments
4. Provide helper methods for common operations

### Memory Layout and Alignment

Direct2D structures must adhere to specific memory layouts and alignment requirements. For example:

- **Alignment**: Most structures are 4-byte aligned
- **Padding**: Some structures include padding to maintain alignment
- **Endianness**: Direct2D follows the little-endian byte order of Windows

The `d2d1Structs.ahk` file handles these requirements automatically, ensuring that structures are properly aligned and formatted regardless of the environment.

### Buffer Management

The `Buffer` class in AutoHotkey v2 is used to create and manage memory for Direct2D structures. Key aspects of buffer management include:

- **Buffer Creation**: Allocates memory of the appropriate size
- **Data Insertion**: Uses `NumPut` to insert data at the correct offsets
- **Type Conversion**: Converts AutoHotkey types to Direct2D types (e.g., integers to floats)
- **Memory Cleanup**: Relies on AutoHotkey's garbage collection

## Structure Categories

The structures in `d2d1Structs.ahk` are organized into logical categories based on their purpose:

### Size Structures

Size structures represent dimensions in 2D space.

#### D2D1_SIZE_U

Represents an unsigned integer size with width and height.

```autohotkey
; Create a size structure with width=800 and height=600
sizeU := D2D1Structs.D2D1_SIZE_U(800, 600)
```

**Technical Details**:
- **Memory Size**: 8 bytes
- **Layout**:
  - `width` (UINT32): Offset 0, 4 bytes
  - `height` (UINT32): Offset 4, 4 bytes
- **Direct2D Equivalent**: `D2D1_SIZE_U` structure
- **Usage Context**: Typically used for pixel-based measurements, such as window or bitmap dimensions

#### D2D1_SIZE_F

Represents a floating-point size with width and height.

```autohotkey
; Create a floating-point size structure
sizeF := D2D1Structs.D2D1_SIZE_F(800.5, 600.25)
```

**Technical Details**:
- **Memory Size**: 8 bytes
- **Layout**:
  - `width` (FLOAT): Offset 0, 4 bytes
  - `height` (FLOAT): Offset 4, 4 bytes
- **Direct2D Equivalent**: `D2D1_SIZE_F` structure
- **Usage Context**: Used for more precise measurements in the Direct2D coordinate space, which can represent fractional values
- **Precision**: Single-precision floating-point (32-bit)

### Point Structures

Point structures represent coordinates in 2D space.

#### D2D1_POINT_2F_SINGLE

Represents a single point with x and y coordinates.

```autohotkey
; Create a point at coordinates (100, 200)
point := D2D1Structs.D2D1_POINT_2F_SINGLE(100, 200)
```

**Technical Details**:
- **Memory Size**: 8 bytes
- **Layout**:
  - `x` (FLOAT): Offset 0, 4 bytes
  - `y` (FLOAT): Offset 4, 4 bytes
- **Direct2D Equivalent**: `D2D1_POINT_2F` structure
- **Precision**: Single-precision floating-point (32-bit)
- **Coordinate System**: Direct2D uses a coordinate system where (0,0) is at the top-left corner

#### D2D_POINT_2F

Represents two points (typically used for lines).

```autohotkey
; Create a line from (100,100) to (200,200)
line := D2D1Structs.D2D_POINT_2F(100, 100, 200, 200)
```

**Technical Details**:
- **Memory Size**: 16 bytes
- **Layout**:
  - `x1` (FLOAT): Offset 0, 4 bytes
  - `y1` (FLOAT): Offset 4, 4 bytes
  - `x2` (FLOAT): Offset 8, 4 bytes
  - `y2` (FLOAT): Offset 12, 4 bytes
- **Direct2D Usage**: Used for line drawing operations
- **Precision**: Single-precision floating-point (32-bit)

#### D2D1_POINTS_ARRAY

Creates a buffer for multiple points (used for polygons or polylines).

```autohotkey
; Create a triangle with three points
points := [[100, 100], [200, 300], [50, 300]]
pointsBuffer := D2D1Structs.D2D1_POINTS_ARRAY(points)

; You can also apply an offset to all points
pointsWithOffset := D2D1Structs.D2D1_POINTS_ARRAY(points, 50, 25)  ; Offset by (50,25)
```

**Technical Details**:
- **Memory Size**: 8 bytes per point (variable total size)
- **Layout**: Sequence of `D2D1_POINT_2F` structures
  - Each point: 8 bytes (x: 4 bytes, y: 4 bytes)
- **Direct2D Usage**: Used for polygon and polyline drawing operations
- **Performance Considerations**: 
  - Creates a contiguous buffer for efficient memory access
  - Applying offsets during creation is more efficient than creating a separate transformation

### Rectangle Structures

Rectangle structures define rectangular areas in 2D space.

#### D2D_RECT_F

Defines a rectangle using left, top, right, and bottom coordinates.

```autohotkey
; Create a rectangle from (10,10) to (110,110)
rect := D2D1Structs.D2D_RECT_F(10, 10, 110, 110)
```

**Technical Details**:
- **Memory Size**: 16 bytes
- **Layout**:
  - `left` (FLOAT): Offset 0, 4 bytes
  - `top` (FLOAT): Offset 4, 4 bytes
  - `right` (FLOAT): Offset 8, 4 bytes
  - `bottom` (FLOAT): Offset 12, 4 bytes
- **Direct2D Equivalent**: `D2D1_RECT_F` structure
- **Coordinate System**: Top-left to bottom-right
- **Precision**: Single-precision floating-point (32-bit)
- **Inclusive/Exclusive**: The right and bottom coordinates are exclusive (not part of the rectangle)

#### RectFromSize

Creates a rectangle from position and size.

```autohotkey
; Create a 100x100 rectangle at position (10,10)
rect := D2D1Structs.RectFromSize(10, 10, 100, 100)
```

**Technical Details**:
- **Memory Size**: 16 bytes (same as D2D_RECT_F)
- **Layout**: Same as D2D_RECT_F
- **Implementation Note**: This is a convenience method that calculates the right and bottom coordinates
- **Performance Considerations**: Performs simple addition operations, negligible performance impact

#### D2D1_ROUNDED_RECT

Defines a rectangle with rounded corners.

```autohotkey
; Create a rounded rectangle with 10-pixel corner radius
roundedRect := D2D1Structs.D2D1_ROUNDED_RECT(10, 10, 110, 110, 10, 10)

; Or using the helper method
roundedRect := D2D1Structs.RoundedRectFromSize(10, 10, 100, 100, 10, 10)
```

**Technical Details**:
- **Memory Size**: 24 bytes
- **Layout**:
  - `left` (FLOAT): Offset 0, 4 bytes
  - `top` (FLOAT): Offset 4, 4 bytes
  - `right` (FLOAT): Offset 8, 4 bytes
  - `bottom` (FLOAT): Offset 12, 4 bytes
  - `radiusX` (FLOAT): Offset 16, 4 bytes
  - `radiusY` (FLOAT): Offset 20, 4 bytes
- **Direct2D Equivalent**: `D2D1_ROUNDED_RECT` structure
- **Rendering Considerations**: 
  - Corner radii are applied to all four corners
  - If the corner radius is too large for the rectangle size, it will be automatically adjusted

### Ellipse Structures

Ellipse structures define circular or oval shapes.

#### EllipseRect

Creates a rectangle structure for an ellipse.

```autohotkey
; Create a circle with center at (100,100) and radius 50
ellipseRect := D2D1Structs.EllipseRect(100, 100, 50)

; Create an ellipse with different x and y radii
ellipseRect := D2D1Structs.EllipseRect(100, 100, 50, 30)
```

**Technical Details**:
- **Memory Size**: 16 bytes (same as D2D_RECT_F)
- **Layout**: Same as D2D_RECT_F, but with different semantic meaning
  - `centerX` (FLOAT): Offset 0, 4 bytes
  - `centerY` (FLOAT): Offset 4, 4 bytes
  - `radiusX` (FLOAT): Offset 8, 4 bytes
  - `radiusY` (FLOAT): Offset 12, 4 bytes
- **Usage Note**: This is a convenience method that reuses the rectangle structure for ellipses
- **Compatibility**: This structure is specific to this implementation and not a standard Direct2D structure

#### D2D1_ELLIPSE

Creates a Direct2D ellipse structure.

```autohotkey
; Create a circle with center at (100,100) and radius 50
ellipse := D2D1Structs.D2D1_ELLIPSE(100, 100, 50)

; Create an ellipse with different x and y radii
ellipse := D2D1Structs.D2D1_ELLIPSE(100, 100, 50, 30)
```

**Technical Details**:
- **Memory Size**: 16 bytes
- **Layout**:
  - `x` (FLOAT): Offset 0, 4 bytes - Center X coordinate
  - `y` (FLOAT): Offset 4, 4 bytes - Center Y coordinate
  - `radiusX` (FLOAT): Offset 8, 4 bytes
  - `radiusY` (FLOAT): Offset 12, 4 bytes
- **Direct2D Equivalent**: `D2D1_ELLIPSE` structure
- **Mathematical Representation**: Follows the standard ellipse equation: (x-h)²/a² + (y-k)²/b² = 1, where (h,k) is the center and a,b are the radii

### Color Structures

Color structures define colors for rendering operations.

#### D2D1_COLOR_F

Creates a color structure from an ARGB color value.

```autohotkey
; Create a fully opaque red color
redColor := D2D1Structs.D2D1_COLOR_F(0xFF0000)

; Create a semi-transparent blue color
blueColor := D2D1Structs.D2D1_COLOR_F(0x8000FF)  ; Alpha=80, Blue=FF
```

**Technical Details**:
- **Memory Size**: 16 bytes
- **Layout**:
  - `r` (FLOAT): Offset 0, 4 bytes - Red component (0.0-1.0)
  - `g` (FLOAT): Offset 4, 4 bytes - Green component (0.0-1.0)
  - `b` (FLOAT): Offset 8, 4 bytes - Blue component (0.0-1.0)
  - `a` (FLOAT): Offset 12, 4 bytes - Alpha component (0.0-1.0)
- **Direct2D Equivalent**: `D2D1_COLOR_F` structure
- **Color Space**: Direct2D uses the sRGB color space
- **Alpha Handling**: 
  - If alpha is not specified (0xRRGGBB format), it defaults to fully opaque (1.0)
  - Alpha is premultiplied in Direct2D rendering operations

#### D2D1_COLOR_F_RGBA

Creates a color structure from individual RGBA components.

```autohotkey
; Create a fully opaque red color
redColor := D2D1Structs.D2D1_COLOR_F_RGBA(255, 0, 0, 255)

; Create a semi-transparent green color
greenColor := D2D1Structs.D2D1_COLOR_F_RGBA(0, 255, 0, 128)
```

**Technical Details**:
- **Memory Size**: 16 bytes (same as D2D1_COLOR_F)
- **Layout**: Same as D2D1_COLOR_F
- **Input Range**: 0-255 for each component (standard RGB range)
- **Conversion**: Automatically converts from 0-255 range to 0.0-1.0 range
- **Usage Context**: More intuitive for developers familiar with standard RGB color values

### Matrix Structures

Matrix structures define transformations in 2D space.

#### D2D1_MATRIX_3X2_F

Creates a 3x2 transformation matrix.

```autohotkey
; Create an identity matrix (no transformation)
matrix := D2D1Structs.D2D1_MATRIX_3X2_F()

; Create a custom transformation matrix
matrix := D2D1Structs.D2D1_MATRIX_3X2_F(M11, M12, M21, M22, Dx, Dy)
```

**Technical Details**:
- **Memory Size**: 24 bytes
- **Layout**:
  - `M11` (FLOAT): Offset 0, 4 bytes - Scaling X
  - `M12` (FLOAT): Offset 4, 4 bytes - Shear Y
  - `M21` (FLOAT): Offset 8, 4 bytes - Shear X
  - `M22` (FLOAT): Offset 12, 4 bytes - Scaling Y
  - `Dx` (FLOAT): Offset 16, 4 bytes - Translation X
  - `Dy` (FLOAT): Offset 20, 4 bytes - Translation Y
- **Direct2D Equivalent**: `D2D1_MATRIX_3X2_F` structure
- **Mathematical Representation**: 
  ```
  [ M11  M12 ]
  [ M21  M22 ]
  [ Dx   Dy  ]
  ```
- **Default Values**: Identity matrix (M11=1, M22=1, others=0)
- **Transformation Order**: In Direct2D, transformations are applied in the order: scale, rotate, translate

#### TranslationMatrix

Creates a translation matrix.

```autohotkey
; Create a matrix that translates by (100,50)
matrix := D2D1Structs.TranslationMatrix(100, 50)
```

**Technical Details**:
- **Memory Size**: 24 bytes (same as D2D1_MATRIX_3X2_F)
- **Matrix Values**: 
  - M11 = 1, M12 = 0
  - M21 = 0, M22 = 1
  - Dx = x, Dy = y
- **Mathematical Effect**: Moves points by (x,y)
- **Performance Considerations**: Translation is the most efficient transformation

#### ScalingMatrix

Creates a scaling matrix.

```autohotkey
; Create a matrix that scales by 2x horizontally and 1.5x vertically
matrix := D2D1Structs.ScalingMatrix(2, 1.5)

; Scale around a specific point (100,100)
matrix := D2D1Structs.ScalingMatrix(2, 1.5, 100, 100)
```

**Technical Details**:
- **Memory Size**: 24 bytes (same as D2D1_MATRIX_3X2_F)
- **Matrix Values** (scaling from origin): 
  - M11 = scaleX, M12 = 0
  - M21 = 0, M22 = scaleY
  - Dx = 0, Dy = 0
- **Matrix Values** (scaling around center point):
  - M11 = scaleX, M12 = 0
  - M21 = 0, M22 = scaleY
  - Dx = centerX - scaleX * centerX
  - Dy = centerY - scaleY * centerY
- **Mathematical Effect**: Scales points by (scaleX, scaleY) from the origin or a specified center point

#### RotationMatrix

Creates a rotation matrix.

```autohotkey
; Create a matrix that rotates by 45 degrees
matrix := D2D1Structs.RotationMatrix(45)

; Rotate around a specific point (100,100)
matrix := D2D1Structs.RotationMatrix(45, 100, 100)
```

**Technical Details**:
- **Memory Size**: 24 bytes (same as D2D1_MATRIX_3X2_F)
- **Angle Unit**: Degrees (converted to radians internally)
- **Matrix Values** (rotation around origin):
  - M11 = cos(angle), M12 = sin(angle)
  - M21 = -sin(angle), M22 = cos(angle)
  - Dx = 0, Dy = 0
- **Matrix Values** (rotation around center point):
  - M11 = cos(angle), M12 = sin(angle)
  - M21 = -sin(angle), M22 = cos(angle)
  - Dx = centerX - cos(angle) * centerX + sin(angle) * centerY
  - Dy = centerY - sin(angle) * centerX - cos(angle) * centerY
- **Mathematical Effect**: Rotates points by the specified angle around the origin or a specified center point
- **Rotation Direction**: Positive angles rotate clockwise

#### CombineMatrices

Combines two transformation matrices.

```autohotkey
; Create a rotation followed by a translation
rotMatrix := D2D1Structs.RotationMatrix(45)
transMatrix := D2D1Structs.TranslationMatrix(100, 50)
combinedMatrix := D2D1Structs.CombineMatrices(rotMatrix, transMatrix)
```

**Technical Details**:
- **Memory Size**: 24 bytes (same as D2D1_MATRIX_3X2_F)
- **Matrix Multiplication**: Implements standard 3x2 matrix multiplication
- **Transformation Order**: The first matrix (matrix1) is applied first, then the second matrix (matrix2)
- **Mathematical Operation**: Standard matrix multiplication formula for 3x2 matrices

### Brush Structures

Brush structures define how shapes are filled or outlined.

#### D2D1_BRUSH_PROPERTIES

Defines properties for a brush.

```autohotkey
; Create brush properties with 50% opacity
brushProps := D2D1Structs.D2D1_BRUSH_PROPERTIES(0.5)

; Create brush properties with opacity and transformation
matrix := D2D1Structs.RotationMatrix(45)
brushProps := D2D1Structs.D2D1_BRUSH_PROPERTIES(0.8, matrix)
```

**Technical Details**:
- **Memory Size**: 28 bytes
- **Layout**:
  - `opacity` (FLOAT): Offset 0, 4 bytes - Opacity value (0.0-1.0)
  - `transform` (D2D1_MATRIX_3X2_F): Offset 4, 24 bytes - Transformation matrix
- **Direct2D Equivalent**: `D2D1_BRUSH_PROPERTIES` structure
- **Default Values**: 
  - Opacity: 1.0 (fully opaque)
  - Transform: Identity matrix (no transformation)
- **Usage Context**: Used when creating brushes to specify their opacity and transformation

#### D2D1_BITMAP_BRUSH_PROPERTIES

Defines properties for a bitmap brush.

```autohotkey
; Create bitmap brush properties with clamp extend mode
bitmapBrushProps := D2D1Structs.D2D1_BITMAP_BRUSH_PROPERTIES()

; Create bitmap brush properties with wrap extend mode
bitmapBrushProps := D2D1Structs.D2D1_BITMAP_BRUSH_PROPERTIES(
    D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_WRAP,
    D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_WRAP
)
```

**Technical Details**:
- **Memory Size**: 12 bytes
- **Layout**:
  - `extendModeX` (D2D1_EXTEND_MODE): Offset 0, 4 bytes - Horizontal extend mode
  - `extendModeY` (D2D1_EXTEND_MODE): Offset 4, 4 bytes - Vertical extend mode
  - `interpolationMode` (D2D1_BITMAP_INTERPOLATION_MODE): Offset 8, 4 bytes - Interpolation mode
- **Direct2D Equivalent**: `D2D1_BITMAP_BRUSH_PROPERTIES` structure
- **Default Values**:
  - extendModeX: D2D1_EXTEND_MODE_CLAMP (clamp to edge)
  - extendModeY: D2D1_EXTEND_MODE_CLAMP (clamp to edge)
  - interpolationMode: D2D1_BITMAP_INTERPOLATION_MODE_LINEAR (linear interpolation)
- **Extend Modes**:
  - CLAMP: Repeats the edge pixels
  - WRAP: Tiles the bitmap
  - MIRROR: Tiles the bitmap with alternating reflections

#### D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES

Defines properties for a linear gradient brush.

```autohotkey
; Create a linear gradient from (0,0) to (100,100)
linearGradientProps := D2D1Structs.D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES(0, 0, 100, 100)
```

**Technical Details**:
- **Memory Size**: 16 bytes
- **Layout**:
  - `startPointX` (FLOAT): Offset 0, 4 bytes - X coordinate of start point
  - `startPointY` (FLOAT): Offset 4, 4 bytes - Y coordinate of start point
  - `endPointX` (FLOAT): Offset 8, 4 bytes - X coordinate of end point
  - `endPointY` (FLOAT): Offset 12, 4 bytes - Y coordinate of end point
- **Direct2D Equivalent**: `D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES` structure
- **Gradient Direction**: The gradient runs from the start point to the end point
- **Color Interpolation**: Colors are interpolated linearly along the gradient line

#### D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES

Defines properties for a radial gradient brush.

```autohotkey
; Create a radial gradient centered at (100,100) with radius 50
radialGradientProps := D2D1Structs.D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES(100, 100, 0, 0, 50, 50)
```

**Technical Details**:
- **Memory Size**: 24 bytes
- **Layout**:
  - `centerX` (FLOAT): Offset 0, 4 bytes - X coordinate of center
  - `centerY` (FLOAT): Offset 4, 4 bytes - Y coordinate of center
  - `offsetX` (FLOAT): Offset 8, 4 bytes - X offset of gradient origin
  - `offsetY` (FLOAT): Offset 12, 4 bytes - Y offset of gradient origin
  - `radiusX` (FLOAT): Offset 16, 4 bytes - X radius
  - `radiusY` (FLOAT): Offset 20, 4 bytes - Y radius
- **Direct2D Equivalent**: `D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES` structure
- **Gradient Pattern**: 
  - The gradient radiates from the center point
  - The offset parameters allow the gradient origin to be different from the center
  - Different X and Y radii allow for elliptical gradients

#### D2D1_GRADIENT_STOP

Defines a color stop for a gradient.

```autohotkey
; Create a gradient stop at position 0.0 with red color
gradientStop := D2D1Structs.D2D1_GRADIENT_STOP(0.0, 0xFF0000)
```

**Technical Details**:
- **Memory Size**: 20 bytes
- **Layout**:
  - `position` (FLOAT): Offset 0, 4 bytes - Position along the gradient (0.0-1.0)
  - `r` (FLOAT): Offset 4, 4 bytes - Red component (0.0-1.0)
  - `g` (FLOAT): Offset 8, 4 bytes - Green component (0.0-1.0)
  - `b` (FLOAT): Offset 12, 4 bytes - Blue component (0.0-1.0)
  - `a` (FLOAT): Offset 16, 4 bytes - Alpha component (0.0-1.0)
- **Direct2D Equivalent**: `D2D1_GRADIENT_STOP` structure
- **Position Range**: 0.0 (start of gradient) to 1.0 (end of gradient)
- **Color Format**: Same as D2D1_COLOR_F (RGBA floats)

#### D2D1_GRADIENT_STOPS_ARRAY

Creates an array of gradient stops.

```autohotkey
; Create a gradient with three stops (red to green to blue)
stops := [
    [0.0, 0xFF0000],  ; Red at position 0.0
    [0.5, 0x00FF00],  ; Green at position 0.5
    [1.0, 0x0000FF]   ; Blue at position 1.0
]
gradientStops := D2D1Structs.D2D1_GRADIENT_STOPS_ARRAY(stops)
```

**Technical Details**:
- **Memory Size**: 20 bytes per stop (variable total size)
- **Layout**: Sequence of `D2D1_GRADIENT_STOP` structures
- **Usage Context**: Used when creating gradient brushes
- **Performance Considerations**: 
  - Creates a contiguous buffer for efficient memory access
  - Stops should be ordered by position (0.0 to 1.0)

### Path Geometry Structures

Path geometry structures define complex shapes using lines, curves, and arcs.

#### D2D1_BEZIER_SEGMENT

Defines a cubic Bezier curve segment.

```autohotkey
; Create a Bezier curve with control points
bezier := D2D1Structs.D2D1_BEZIER_SEGMENT(
    100, 50,   ; First control point
    150, 150,  ; Second control point
    200, 100   ; End point
)
```

**Technical Details**:
- **Memory Size**: 24 bytes
- **Layout**:
  - `point1X` (FLOAT): Offset 0, 4 bytes - X coordinate of first control point
  - `point1Y` (FLOAT): Offset 4, 4 bytes - Y coordinate of first control point
  - `point2X` (FLOAT): Offset 8, 4 bytes - X coordinate of second control point
  - `point2Y` (FLOAT): Offset 12, 4 bytes - Y coordinate of second control point
  - `point3X` (FLOAT): Offset 16, 4 bytes - X coordinate of end point
  - `point3Y` (FLOAT): Offset 20, 4 bytes - Y coordinate of end point
- **Direct2D Equivalent**: `D2D1_BEZIER_SEGMENT` structure
- **Mathematical Representation**: Cubic Bezier curve with four points (start point from previous segment, two control points, and end point)
- **Parametric Equation**: B(t) = (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃, where t ∈ [0,1]

#### D2D1_TRIANGLE

Defines a triangle.

```autohotkey
; Create a triangle
triangle := D2D1Structs.D2D1_TRIANGLE(
    100, 100,  ; First point
    200, 100,  ; Second point
    150, 200   ; Third point
)
```

**Technical Details**:
- **Memory Size**: 24 bytes
- **Layout**:
  - `point1X` (FLOAT): Offset 0, 4 bytes - X coordinate of first point
  - `point1Y` (FLOAT): Offset 4, 4 bytes - Y coordinate of first point
  - `point2X` (FLOAT): Offset 8, 4 bytes - X coordinate of second point
  - `point2Y` (FLOAT): Offset 12, 4 bytes - Y coordinate of second point
  - `point3X` (FLOAT): Offset 16, 4 bytes - X coordinate of third point
  - `point3Y` (FLOAT): Offset 20, 4 bytes - Y coordinate of third point
- **Direct2D Usage**: Used for triangle drawing operations
- **Winding Order**: Points are typically specified in clockwise order for front-facing triangles

#### D2D1_ARC_SEGMENT

Defines an arc segment.

```autohotkey
; Create an arc
arc := D2D1Structs.D2D1_ARC_SEGMENT(
    200, 200,  ; End point
    50, 50,    ; X and Y radius
    45,        ; Rotation angle
    D2D1Enums.SWEEP_DIRECTION.D2D1_SWEEP_DIRECTION_CLOCKWISE,
    D2D1Enums.ARC_SIZE.D2D1_ARC_SIZE_SMALL
)
```

**Technical Details**:
- **Memory Size**: 28 bytes
- **Layout**:
  - `pointX` (FLOAT): Offset 0, 4 bytes - X coordinate of end point
  - `pointY` (FLOAT): Offset 4, 4 bytes - Y coordinate of end point
  - `sizeX` (FLOAT): Offset 8, 4 bytes - X radius
  - `sizeY` (FLOAT): Offset 12, 4 bytes - Y radius
  - `rotationAngle` (FLOAT): Offset 16, 4 bytes - Rotation angle in degrees
  - `sweepDirection` (D2D1_SWEEP_DIRECTION): Offset 20, 4 bytes - Sweep direction
  - `arcSize` (D2D1_ARC_SIZE): Offset 24, 4 bytes - Arc size
- **Direct2D Equivalent**: `D2D1_ARC_SEGMENT` structure
- **Start Point**: Assumed to be the current point in the path
- **Sweep Direction**: 
  - CLOCKWISE: Arc is drawn in clockwise direction
  - COUNTER_CLOCKWISE: Arc is drawn in counter-clockwise direction
- **Arc Size**:
  - SMALL: Smaller of the two possible arcs
  - LARGE: Larger of the two possible arcs

#### D2D1_QUADRATIC_BEZIER_SEGMENT

Defines a quadratic Bezier curve segment.

```autohotkey
; Create a quadratic Bezier curve
quadBezier := D2D1Structs.D2D1_QUADRATIC_BEZIER_SEGMENT(
    150, 50,   ; Control point
    200, 100   ; End point
)
```

**Technical Details**:
- **Memory Size**: 16 bytes
- **Layout**:
  - `point1X` (FLOAT): Offset 0, 4 bytes - X coordinate of control point
  - `point1Y` (FLOAT): Offset 4, 4 bytes - Y coordinate of control point
  - `point2X` (FLOAT): Offset 8, 4 bytes - X coordinate of end point
  - `point2Y` (FLOAT): Offset 12, 4 bytes - Y coordinate of end point
- **Direct2D Equivalent**: `D2D1_QUADRATIC_BEZIER_SEGMENT` structure
- **Start Point**: Assumed to be the current point in the path
- **Mathematical Representation**: Quadratic Bezier curve with three points (start point from previous segment, control point, and end point)
- **Parametric Equation**: B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂, where t ∈ [0,1]

### Stroke Style Structures

Stroke style structures define how lines and outlines are drawn.

#### D2D1_STROKE_STYLE_PROPERTIES

Defines properties for a stroke style.

```autohotkey
; Create a basic stroke style with round caps and joins
strokeStyle := D2D1Structs.D2D1_STROKE_STYLE_PROPERTIES(
    D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND,  ; Start cap
    D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND,  ; End cap
    D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_FLAT,   ; Dash cap
    D2D1Enums.LINE_JOIN.D2D1_LINE_JOIN_ROUND,  ; Line join
    10,                                         ; Miter limit
    D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_SOLID, ; Dash style
    0                                           ; Dash offset
)
```

**Technical Details**:
- **Memory Size**: 28 bytes
- **Layout**:
  - `startCap` (D2D1_CAP_STYLE): Offset 0, 4 bytes - Start cap style
  - `endCap` (D2D1_CAP_STYLE): Offset 4, 4 bytes - End cap style
  - `dashCap` (D2D1_CAP_STYLE): Offset 8, 4 bytes - Dash cap style
  - `lineJoin` (D2D1_LINE_JOIN): Offset 12, 4 bytes - Line join style
  - `miterLimit` (FLOAT): Offset 16, 4 bytes - Miter limit
  - `dashStyle` (D2D1_DASH_STYLE): Offset 20, 4 bytes - Dash style
  - `dashOffset` (FLOAT): Offset 24, 4 bytes - Dash offset
- **Direct2D Equivalent**: `D2D1_STROKE_STYLE_PROPERTIES` structure
- **Cap Styles**:
  - FLAT: Flat cap (ends at the exact endpoint)
  - SQUARE: Square cap (extends half the line width beyond the endpoint)
  - ROUND: Round cap (semicircle with diameter equal to line width)
  - TRIANGLE: Triangle cap (triangle with height equal to line width)
- **Line Join Styles**:
  - MITER: Sharp corner (limited by miter limit)
  - BEVEL: Beveled corner (flat)
  - ROUND: Rounded corner
  - MITER_OR_BEVEL: Miter for small angles, bevel for large angles

### Render Target Structures

Render target structures define where and how drawing operations are performed.

#### D2D1_RENDER_TARGET_PROPERTIES

Defines properties for a render target.

```autohotkey
; Create default render target properties
rtProps := D2D1Structs.D2D1_RENDER_TARGET_PROPERTIES()

; Create hardware render target properties with custom DPI
hwRtProps := D2D1Structs.D2D1_RENDER_TARGET_PROPERTIES(
    D2D1Enums.RENDER_TARGET_TYPE.D2D1_RENDER_TARGET_TYPE_HARDWARE,
    0,  ; Default DXGI format
    1,  ; Default alpha mode
    120, 120  ; 120 DPI
)
```

**Technical Details**:
- **Memory Size**: 28 bytes
- **Layout**:
  - `type` (D2D1_RENDER_TARGET_TYPE): Offset 0, 4 bytes - Render target type
  - `pixelFormat` (DXGI_FORMAT): Offset 4, 4 bytes - Pixel format
  - `alphaMode` (D2D1_ALPHA_MODE): Offset 8, 4 bytes - Alpha mode
  - `dpiX` (FLOAT): Offset 12, 4 bytes - Horizontal DPI
  - `dpiY` (FLOAT): Offset 16, 4 bytes - Vertical DPI
  - `usage` (D2D1_RENDER_TARGET_USAGE): Offset 20, 4 bytes - Render target usage
  - `minLevel` (D2D1_FEATURE_LEVEL): Offset 24, 4 bytes - Minimum feature level
- **Direct2D Equivalent**: `D2D1_RENDER_TARGET_PROPERTIES` structure
- **Render Target Types**:
  - DEFAULT: Direct2D chooses the type
  - SOFTWARE: CPU-based rendering
  - HARDWARE: GPU-based rendering

#### D2D1_HWND_RENDER_TARGET_PROPERTIES

Defines properties for a window render target.

```autohotkey
; Create render target properties for a window
hwndRtProps := D2D1Structs.D2D1_HWND_RENDER_TARGET_PROPERTIES(
    myGui.hwnd,  ; Window handle
    800, 600     ; Size
)

; Create render target properties with VSync disabled
hwndRtProps := D2D1Structs.D2D1_HWND_RENDER_TARGET_PROPERTIES(
    myGui.hwnd,
    800, 600,
    D2D1Enums.PRESENT_OPTIONS.D2D1_PRESENT_OPTIONS_IMMEDIATELY  ; Disable VSync
)
```

**Technical Details**:
- **Memory Size**: 16 bytes (32-bit) or 24 bytes (64-bit)
- **Layout**:
  - `hwnd` (HWND): Offset 0, 4/8 bytes - Window handle
  - `width` (UINT32): Offset 4/8, 4 bytes - Width
  - `height` (UINT32): Offset 8/12, 4 bytes - Height
  - `presentOptions` (D2D1_PRESENT_OPTIONS): Offset 12/16, 4 bytes - Present options
- **Direct2D Equivalent**: `D2D1_HWND_RENDER_TARGET_PROPERTIES` structure
- **Present Options**:
  - NONE: VSync enabled
  - IMMEDIATELY: VSync disabled
  - RETAIN_CONTENTS: Keep the target contents intact through present

## Practical Examples

### Example 1: Creating and Drawing a Rectangle

```autohotkey
; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Rectangle Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a rectangle structure
rect := D2D1Structs.D2D_RECT_F(50, 50, 250, 150)

; Begin drawing
d2d.beginDraw()

; Fill the rectangle with red color
d2d.fillRectangle(rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, 0xFF0000)

; End drawing
d2d.endDraw()
```

### Example 2: Creating and Drawing a Gradient

```autohotkey
; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Gradient Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create gradient stops
stops := [
    [0.0, 0xFF0000],  ; Red at position 0.0
    [0.5, 0x00FF00],  ; Green at position 0.5
    [1.0, 0x0000FF]   ; Blue at position 1.0
]
gradientStops := D2D1Structs.D2D1_GRADIENT_STOPS_ARRAY(stops)

; Create linear gradient properties
linearGradientProps := D2D1Structs.D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES(0, 0, 800, 600)

; Begin drawing
d2d.beginDraw()

; Draw a rectangle filled with the gradient
d2d.fillRectangle(0, 0, 800, 600, gradientStops)

; End drawing
d2d.endDraw()
```

### Example 3: Creating and Applying Transformations

```autohotkey
; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Transformation Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a rotation matrix (45 degrees around point 400,300)
rotMatrix := D2D1Structs.RotationMatrix(45, 400, 300)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Apply the transformation
d2d.setTransform(rotMatrix)

; Draw a rectangle (will be rotated)
d2d.fillRectangle(350, 250, 100, 100, 0xFF0000)

; Reset transformation
d2d.setTransform(D2D1Structs.D2D1_MATRIX_3X2_F())

; End drawing
d2d.endDraw()
```

## Performance Optimization

### Memory Management

Direct2D structures are created as memory buffers. In AutoHotkey, these buffers are automatically managed by the garbage collector, but it's still good practice to:

1. **Reuse structures**: Create structures outside of animation loops when possible
2. **Minimize allocations**: Avoid creating new structures in tight loops
3. **Release references**: Set variables to empty (`""`) when you're done with them to help the garbage collector

### Efficient Structure Creation

1. **Use helper methods**: Methods like `RectFromSize` and `TranslationMatrix` are more efficient than creating structures manually
2. **Batch operations**: Create multiple structures at once when possible
3. **Use appropriate types**: Use integer structures (e.g., `D2D1_SIZE_U`) for pixel-based measurements and floating-point structures (e.g., `D2D1_SIZE_F`) for more precise measurements

### Rendering Optimization

1. **Minimize state changes**: Group similar drawing operations together
2. **Use appropriate structures**: Choose the right structure for the job (e.g., use `D2D1_POINTS_ARRAY` for polygons instead of individual points)
3. **Optimize transformations**: Combine transformations when possible using `CombineMatrices`

## Technical Reference

### Memory Layout

Direct2D structures follow specific memory layouts that must be adhered to for proper operation. The `d2d1Structs.ahk` file handles this automatically, but it's important to understand the underlying structure.

For example, the `D2D1_MATRIX_3X2_F` structure has the following memory layout:

```
Offset  Size    Type    Name    Description
0       4       float   M11     Scaling X
4       4       float   M12     Shear Y
8       4       float   M21     Shear X
12      4       float   M22     Scaling Y
16      4       float   Dx      Translation X
20      4       float   Dy      Translation Y
```

### 32-bit vs. 64-bit Considerations

Some structures have different memory layouts in 32-bit and 64-bit environments, particularly those that include pointers or handles. The `d2d1Structs.ahk` file handles these differences automatically.

For example, the `D2D1_HWND_RENDER_TARGET_PROPERTIES` structure has a different size in 32-bit (16 bytes) and 64-bit (24 bytes) environments due to the size of the `HWND` handle.

### Direct2D API Integration

The structures in `d2d1Structs.ahk` are designed to be compatible with the Direct2D API. They follow the same memory layout and naming conventions as the original C++ structures, making it easier to understand the Direct2D documentation and apply it to AutoHotkey.

## Conclusion

The `d2d1Structs.ahk` file provides a powerful bridge between AutoHotkey and the Direct2D API. By understanding how to create and use these structures, you can take full advantage of Direct2D's hardware-accelerated rendering capabilities in your AutoHotkey applications.

The examples in this document demonstrate common usage patterns, but there are many more possibilities. Experiment with different combinations of structures and methods to create rich, interactive graphics in your applications.
