# Direct2D Wrapper for AutoHotkey v2 - Documentation

## 1. Introduction

### Purpose and Scope
The `D2D1` class is a comprehensive wrapper for the Windows Direct2D API, designed to simplify the creation of hardware-accelerated 2D graphics in AutoHotkey v2 applications. It provides an object-oriented interface to Direct2D's capabilities, abstracting away much of the complexity of working directly with the COM-based API.

### Origin and Attribution
This class is based on Spawnova's Direct2D overlay class, which can be found at: https://github.com/Spawnova/ShinsOverlayClass. The implementation has been significantly enhanced and adapted for AutoHotkey v2, with additional features and improvements.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     AutoHotkey Script                    │
│                                                          │
│  ┌─────────────────────────┐  ┌─────────────────────┐   │
│  │        D2D1 Class       │  │  D2D1Structs Class  │   │
│  │ (Main wrapper interface)│  │ (Structure creation)│   │
│  └───────────┬─────────────┘  └─────────┬───────────┘   │
│              │                          │               │
│  ┌───────────┴──────────────┐ ┌─────────┴─────────────┐ │
│  │   D2D1ResourceManager    │ │     Shape Classes     │ │
│  │  (Resource management)   │ │ (Object-oriented API) │ │
│  └──────────────────────────┘ └───────────────────────┘ │
│                                                          │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
               ▼                          ▼
┌─────────────────────────────────────────────────────────┐
│                 Windows COM Interface                    │
│                                                          │
│  ┌─────────────────┐  ┌───────────────┐  ┌───────────┐  │
│  │    Direct2D     │  │  DirectWrite  │  │   GDI+    │  │
│  └─────────────────┘  └───────────────┘  └───────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

The architecture consists of several main components:

1. **D2D1 Class**: The main wrapper that provides methods for drawing operations and manages Direct2D resources
2. **D2D1Structs Class**: A utility class that creates various structure definitions required by Direct2D
3. **D2D1ResourceManager Class**: Manages COM objects and ensures proper resource cleanup
4. **Shape Classes**: A hierarchy of classes for object-oriented drawing operations
5. **Scene Graph**: The D2D1Scene class for managing collections of shapes

These components interact with the Windows COM interface to access Direct2D, DirectWrite, and GDI+ functionality.

### Key Features

- Hardware-accelerated 2D graphics rendering
- Object-oriented API with shape classes
- Scene graph for managing multiple shapes
- Text rendering with formatting options and effects
- Resource management with automatic cleanup
- VSync control for smooth animations
- Antialiasing settings for quality control
- Support for transparency and blending
- Comprehensive error handling
- Font caching for improved performance

## 2. Getting Started

### Installation and Requirements

To use the Direct2D wrapper, you need:

1. AutoHotkey v2.0 or later
2. Windows 7 or later (Windows 10/11 recommended)
3. A graphics card with Direct2D support

To include the library in your project:

```ahk
#Include "path\to\d2d1.ahk"
```

### Basic Setup

Creating a basic Direct2D application involves these steps:

1. Create a GUI window
2. Initialize the D2D1 instance
3. Set up a drawing function
4. Create a timer to refresh the display

Here's a minimal example:

```ahk
; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Set up drawing timer
SetTimer(DrawExample.Bind(d2d), 40)  ; ~25 FPS

; Drawing function
DrawExample(d2d) {
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw a shape
    d2d.fillRectangle(30, 30, 100, 100, 0xFFFF1D)
    
    ; End drawing
    d2d.endDraw()
}

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()
```

### Constructor Parameters

When creating a D2D1 instance, you can specify these parameters:

```ahk
d2d := D2D1(hwnd, x, y, width, height, vsync)
```

- `hwnd`: Window handle for the GUI
- `x`: X position of the window (default: 100)
- `y`: Y position of the window (default: 100)
- `width`: Width of the rendering area (default: 800)
- `height`: Height of the rendering area (default: 600)
- `vsync`: Whether to enable vertical synchronization (default: true)

### Drawing Cycle

Every Direct2D application follows this drawing cycle:

1. Call `beginDraw()` to start drawing operations
2. Perform drawing operations (rectangles, circles, text, etc.)
3. Call `endDraw()` to finish drawing and update the display

It's important to always call `endDraw()` after `beginDraw()` to prevent resource leaks.

## 3. Core Concepts

### Direct2D API Overview

Direct2D is a hardware-accelerated, immediate-mode 2D graphics API that provides high-performance and high-quality rendering for 2D geometry, bitmaps, and text. It's designed to interoperate well with GDI, GDI+, and Direct3D.

Key components of Direct2D used in this wrapper:

- **Factories**: Create resources and devices
- **Render Targets**: Surfaces that can be drawn on
- **Brushes**: Define how shapes are filled
- **Geometries**: Define complex shapes
- **Stroke Styles**: Define how lines are drawn
- **Text Formats**: Define text appearance

### COM Object Model Abstraction

The Direct2D API is based on the Component Object Model (COM), which is a binary interface standard. Working with COM objects directly requires:

1. Creating and managing COM objects
2. Accessing methods through virtual function tables (vTables)
3. Properly releasing objects to prevent memory leaks

This wrapper abstracts these complexities by:

1. Handling COM object creation and management internally
2. Providing simple methods that map to Direct2D functionality
3. Using a resource manager to automatically release COM objects

### Memory Management

The wrapper uses several memory management patterns:

1. **Buffer Allocation**: Creates memory buffers for structures using the `Buffer()` function
2. **Reference Counting**: Properly releases COM objects by calling their Release methods
3. **Resource Manager**: The `D2D1ResourceManager` class tracks and releases resources
4. **Cleanup in Destructor**: The `__Delete()` method ensures all resources are properly released

### Virtual Table (vTable) Pattern

COM objects expose their methods through virtual function tables (vTables). The wrapper accesses these methods using the `_vTable()` helper method:

```ahk
_vTable(object, methodIndex) {
    return NumGet(NumGet(object + 0, 0, "ptr"), methodIndex * A_PtrSize, "Ptr")
}
```

This method:
1. Gets the pointer to the vTable from the COM object (`NumGet(object + 0, 0, "ptr")`)
2. Calculates the offset to the desired method (`methodIndex * A_PtrSize`)
3. Returns a pointer to that method

The wrapper then stores these function pointers and calls them using `DllCall()` when needed.

### Coordinate System

Direct2D uses a coordinate system where:

- The origin (0,0) is at the top-left corner of the window
- X coordinates increase to the right
- Y coordinates increase downward
- All coordinates are in device-independent pixels (DIPs)

### Color Handling

Colors in Direct2D are represented in the ARGB format (Alpha, Red, Green, Blue), typically as a 32-bit hexadecimal value:

```
0xAARRGGBB
```

Where:
- `AA`: Alpha channel (00-FF, where FF is fully opaque)
- `RR`: Red component (00-FF)
- `GG`: Green component (00-FF)
- `BB`: Blue component (00-FF)

If you provide a color without an alpha component (0xRRGGBB), the wrapper automatically adds full opacity (0xFF000000).

## 4. Basic Drawing Operations

### Drawing Primitives

The D2D1 class provides methods for drawing basic shapes:

#### Rectangles

```ahk
; Fill a rectangle
d2d.fillRectangle(x, y, width, height, color)

; Draw a rectangle outline
d2d.drawRectangle(x, y, width, height, color, thickness, rounded)

; Fill a rounded rectangle
d2d.fillRoundedRectangle(x, y, width, height, radiusX, radiusY, color)

; Draw a rounded rectangle outline
d2d.drawRoundedRectangle(x, y, width, height, radiusX, radiusY, color, thickness, rounded)
```

#### Circles and Ellipses

```ahk
; Fill a circle
d2d.fillCircle(x, y, radius, color)

; Draw a circle outline
d2d.drawCircle(x, y, radius, color, thickness, rounded)

; Fill an ellipse
d2d.fillEllipse(x, y, radiusX, radiusY, color)

; Draw an ellipse outline
d2d.drawEllipse(x, y, radiusX, radiusY, color, thickness, rounded)
```

#### Lines

```ahk
; Draw a line
d2d.drawLine(x1, y1, x2, y2, color, thickness, rounded)
```

#### Polygons

```ahk
; Fill a polygon
d2d.fillPolygon(points, color, xOffset, yOffset)

; Draw a polygon outline
d2d.drawPolygon(points, color, thickness, rounded, xOffset, yOffset)
```

Where `points` is an array of 2D points, e.g., `[[0,0], [5,0], [0,5]]`.

### Fill vs. Outline Operations

The D2D1 class provides two types of drawing operations:

1. **Fill operations** (`fillRectangle`, `fillCircle`, etc.): Fill the entire shape with a solid color
2. **Outline operations** (`drawRectangle`, `drawCircle`, etc.): Draw only the outline of the shape

Outline operations take additional parameters:
- `thickness`: The width of the outline (default: 1)
- `rounded`: Whether to use rounded caps/joins (default: 0)

### Brush and Stroke Styles

The D2D1 class internally manages brushes and stroke styles:

- **Brushes** define how shapes are filled (color, opacity)
- **Stroke styles** define how lines are drawn (caps, joins, dash patterns)

The wrapper provides two stroke styles:
- Regular stroke style (square caps, miter joins)
- Rounded stroke style (round caps, round joins)

### Transparency and Blending

You can control transparency by setting the alpha component of colors:

```ahk
; Fully opaque red
d2d.fillRectangle(10, 10, 100, 100, 0xFFFF0000)

; Semi-transparent blue (50% opacity)
d2d.fillRectangle(60, 60, 100, 100, 0x800000FF)
```

Direct2D automatically handles blending when shapes overlap.

## 5. Shape Classes

### Shape Class Hierarchy

The D2D1 wrapper includes a hierarchy of shape classes for object-oriented drawing:

```
D2D1Shape (Base Class)
├── D2D1Rectangle
├── D2D1OutlineRectangle
├── D2D1RoundedRectangle
├── D2D1OutlineRoundedRectangle
├── D2D1Circle
├── D2D1OutlineCircle
├── D2D1Line
├── D2D1Polygon
├── D2D1OutlinePolygon
└── D2D1Text
```

Each shape class inherits from the base `D2D1Shape` class, which provides common properties and methods.

### Available Shape Types

#### Rectangles

```ahk
; Filled rectangle
rect := D2D1Rectangle(x, y, width, height, color)

; Outlined rectangle
outlineRect := D2D1OutlineRectangle(x, y, width, height, color, thickness, rounded)

; Filled rounded rectangle
roundedRect := D2D1RoundedRectangle(x, y, width, height, radiusX, radiusY, color)

; Outlined rounded rectangle
outlineRoundedRect := D2D1OutlineRoundedRectangle(x, y, width, height, radiusX, radiusY, color, thickness, rounded)
```

#### Circles

```ahk
; Filled circle
circle := D2D1Circle(x, y, radius, color)

; Outlined circle
outlineCircle := D2D1OutlineCircle(x, y, radius, color, thickness, rounded)
```

#### Lines

```ahk
; Line
line := D2D1Line(x1, y1, x2, y2, color, thickness, rounded)
```

#### Polygons

```ahk
; Filled polygon
polygon := D2D1Polygon(points, color, xOffset, yOffset)

; Outlined polygon
outlinePolygon := D2D1OutlinePolygon(points, color, thickness, rounded, xOffset, yOffset)
```

#### Text

```ahk
; Text
text := D2D1Text(text, x, y, width, height, color, fontName, alignment, extraOptions)
```

### Creating and Manipulating Shapes

To create a shape, instantiate the appropriate class:

```ahk
; Create a red rectangle
rect := D2D1Rectangle(50, 50, 100, 100, 0xFF0000)
```

You can manipulate shapes using their methods:

```ahk
; Move the rectangle
rect.move(10, 20)

; Change the color
rect.setColor(0x00FF00)
```

To draw a shape, call its `draw` method with a D2D1 instance:

```ahk
rect.draw(d2d)
```

### Scene Graph Functionality

The `D2D1Scene` class provides a scene graph for managing multiple shapes:

```ahk
; Create a scene
scene := D2D1Scene()

; Add shapes to the scene
scene.addShape(D2D1Rectangle(50, 50, 100, 100, 0xFF0000))
scene.addShape(D2D1Circle(200, 200, 50, 0x00FF00))

; Draw all shapes in the scene
scene.draw(d2d)
```

The scene graph automatically handles the drawing cycle (beginDraw/endDraw) and draws all shapes in the order they were added.

### Composite Shapes

You can create composite shapes by combining multiple shapes in a scene:

```ahk
; Create a scene for a composite shape
face := D2D1Scene()

; Add shapes to create a face
face.addShape(D2D1Circle(100, 100, 50, 0xFFFF00))  ; Head
face.addShape(D2D1Circle(85, 85, 10, 0x000000))    ; Left eye
face.addShape(D2D1Circle(115, 85, 10, 0x000000))   ; Right eye
face.addShape(D2D1Circle(100, 110, 20, 0xFF0000))  ; Mouth

; Draw the composite shape
face.draw(d2d)
```

## 6. Text Rendering

### Basic Text Drawing

The D2D1 class provides a `drawText` method for rendering text:

```ahk
d2d.drawText(text, x, y, fontSize, color, fontName, extraOptions)
```

Parameters:
- `text`: The text to draw
- `x`, `y`: Position of the text
- `fontSize`: Font size in points
- `color`: Text color in 0xAARRGGBB format
- `fontName`: Font family name (default: "Arial")
- `extraOptions`: Additional formatting options (see below)

### Font Handling and Caching

The D2D1 class includes a font caching system to improve performance. When you specify a font name and size, the wrapper:

1. Checks if the font is already in the cache
2. If found, uses the cached font
3. If not found, creates a new font and adds it to the cache

The cache has a maximum size (default: 50 fonts) to prevent memory issues. This caching mechanism significantly improves performance when rendering text repeatedly with the same fonts.

```ahk
; Font caching is handled automatically
d2d.drawText("This text uses a cached font", 50, 50, 18, 0x000000, "Arial")
d2d.drawText("This text also uses the cached font", 50, 80, 18, 0x000000, "Arial")
```

### Text Formatting Options

The `extraOptions` parameter accepts a string with these options:

- `w[number]`: Width of the text block
- `h[number]`: Height of the text block
- `aLeft`, `aCenter`, `aRight`: Text alignment
- `ds[hex color]`: Drop shadow color
- `dsx[number]`: Drop shadow X offset
- `dsy[number]`: Drop shadow Y offset
- `ol[hex color]`: Outline color

Example:

```ahk
; Center-aligned text with drop shadow
d2d.drawText("Hello, World!", 50, 50, 24, 0x000000, "Arial", "w400 h50 aCenter ds808080 dsx2 dsy2")
```

### Text Effects

#### Drop Shadow

To add a drop shadow to text:

```ahk
; Using drawText directly
d2d.drawText("Text with shadow", 50, 50, 18, 0x000000, "Arial", "ds808080 dsx2 dsy2")

; Using D2D1Text class
text := D2D1Text("Text with shadow", 50, 50, 400, 30, 0x000000, "Arial")
text.addDropShadow(0x80808080, 2, 2)
text.draw(d2d)
```

#### Outline

To add an outline to text:

```ahk
; Using drawText directly
d2d.drawText("Text with outline", 50, 100, 18, 0xFF0000, "Arial", "olFF0000")

; Using D2D1Text class
text := D2D1Text("Text with outline", 50, 100, 400, 30, 0xFF0000, "Arial")
text.addOutline(0xFF000000)
text.draw(d2d)
```

### Text Alignment and Layout

You can control text alignment using the alignment options:

```ahk
; Left-aligned text (default)
d2d.drawText("Left aligned", 50, 50, 18, 0x000000, "Arial", "aLeft")

; Center-aligned text
d2d.drawText("Center aligned", 50, 100, 18, 0x000000, "Arial", "aCenter")

; Right-aligned text
d2d.drawText("Right aligned", 50, 150, 18, 0x000000, "Arial", "aRight")
```

When using the D2D1Text class, you can specify the alignment in the constructor:

```ahk
; Center-aligned text
text := D2D1Text("Center aligned", 50, 50, 400, 30, 0x000000, "Arial", "center")
```

## 7. Animation Techniques

### Animation Fundamentals

Animation in Direct2D involves:

1. Updating object properties (position, size, color, etc.)
2. Redrawing the scene at regular intervals
3. Using timers to control the frame rate

The basic pattern is:

```ahk
; Set up animation variables
angle := 0

; Create a timer for animation
SetTimer(AnimationFrame.Bind(d2d), 16)  ; ~60 FPS

; Animation function
AnimationFrame(d2d) {
    ; Update animation variables
    global angle
    angle += 2
    if (angle >= 360)
        angle := 0
    
    ; Calculate new positions or properties
    x := 400 + 150 * Cos(angle * 0.0174533)
    y := 300 + 150 * Sin(angle * 0.0174533)
    
    ; Draw the frame
    d2d.beginDraw()
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    d2d.fillCircle(x, y, 50, 0x0000FF)
    d2d.endDraw()
}
```

### Frame-Based Animation

Frame-based animation uses a timer to update the display at regular intervals:

```ahk
; 60 FPS (16.67ms per frame)
SetTimer(AnimationFrame.Bind(d2d), 16)

; 30 FPS (33.33ms per frame)
SetTimer(AnimationFrame.Bind(d2d), 33)
```

The timer interval controls the frame rate:
- Smaller interval = higher frame rate = smoother animation but higher CPU usage
- Larger interval = lower frame rate = choppier animation but lower CPU usage

### Smooth Movement and Transitions

To create smooth movement, use small increments and trigonometric functions:

```ahk
; Linear movement
x += speed

; Acceleration/deceleration
speed += acceleration
x += speed

; Circular movement
x := centerX + radius * Cos(angle * 0.0174533)
y := centerY + radius * Sin(angle * 0.0174533)

; Oscillation
x := centerX + amplitude * Sin(angle * 0.0174533)
```

### Color Animations

You can animate colors by changing their components:

```ahk
; Pulsing opacity
alpha := 127.5 + 127.5 * Sin(angle * 0.0174533)
color := (Round(alpha) << 24) | 0x0000FF  ; Blue with changing alpha

; Color cycling (hue rotation)
r := Round(127.5 + 127.5 * Cos(angle * 0.0174533))
g := Round(127.5 + 127.5 * Cos((angle + 120) * 0.0174533))
b := Round(127.5 + 127.5 * Cos((angle + 240) * 0.0174533))
color := (r << 16) | (g << 8) | b
```

### Shape Transformations

When using shape classes, you can animate them by changing their properties:

```ahk
; Move a shape
shape.move(dx, dy)

; Change a shape's color
shape.setColor(newColor)

; Resize a circle
circle._radius += 1

; Rotate polygon points
for i, point in polygon._points {
    ; Rotation logic here
}
```

## 8. Advanced Features

### VSync Control

Vertical Synchronization (VSync) synchronizes the frame rate with the monitor's refresh rate to prevent screen tearing.

You can control VSync in several ways:

```ahk
; Enable VSync during initialization (default)
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600, true)

; Disable VSync during initialization
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600, false)

; Toggle VSync at runtime
d2d.setVSync(true)   ; Enable VSync
d2d.setVSync(false)  ; Disable VSync
```

When to use VSync:
- **Enable VSync** for most applications, especially those with animations
- **Disable VSync** when you need the lowest input latency or for benchmarking

The `setVSync` method works by recreating the render target with the new VSync setting. This is necessary because Direct2D doesn't allow changing present options after creation. The method preserves the current state (like antialiasing settings) when recreating the render target.

### Antialiasing Settings

Antialiasing smooths jagged edges for better visual quality. You can control antialiasing with the `setAntialias` method:

```ahk
; Enable antialiasing (default)
d2d.setAntialias(true)

; Disable antialiasing
d2d.setAntialias(false)
```

When to use antialiasing:
- **Enable antialiasing** for most applications to improve visual quality
- **Disable antialiasing** for pixel-perfect rendering or slightly better performance

### Resource Management

The D2D1 class includes a resource manager that tracks and releases COM objects:

```ahk
; The resource manager is created automatically
resourceManager := D2D1ResourceManager()

; Add a resource to the manager
resourceManager.addResource(name, resource, releaseMethod)

; Release a specific resource
resourceManager.releaseResource(name)

; Release all resources
resourceManager.releaseAll()
```

The resource manager is used internally by the D2D1 class to ensure proper cleanup of Direct2D resources.

### Custom Shapes and Effects

You can create custom shapes by extending the D2D1Shape class:

```ahk
class MyCustomShape extends D2D1Shape {
    __New(x, y, color) {
        super.__New(x, y, color)
        ; Initialize custom properties
    }
    
    draw(d2d) {
        ; Custom drawing logic
        d2d.fillRectangle(this._x, this._y, 50, 50, this._color)
        d2d.drawCircle(this._x + 25, this._y + 25, 20, 0x000000)
    }
}
```

### Integration with Other Libraries

The D2D1 class can be integrated with other AutoHotkey libraries:

```ahk
; Integration with GUI controls
myGui := Gui()
myButton := myGui.Add("Button", "w100 h30", "Click Me")
myButton.OnEvent("Click", (*) => {
    ; Update D2D1 drawing
})

; Integration with keyboard/mouse input
OnMessage(0x200, MouseMove)  ; WM_MOUSEMOVE
MouseMove(wParam, lParam, msg, hwnd) {
    global mouseX := lParam & 0xFFFF
    global mouseY := lParam >> 16
}
```

## 9. Performance Optimization

### Efficient Drawing Strategies

To optimize performance:

1. **Minimize drawing operations**:
   ```ahk
   ; Inefficient (multiple draw calls)
   d2d.fillRectangle(10, 10, 10, 10, 0xFF0000)
   d2d.fillRectangle(30, 10, 10, 10, 0xFF0000)
   
   ; More efficient (single draw call)
   d2d.fillRectangle(10, 10, 30, 10, 0xFF0000)
   ```

2. **Use appropriate shapes**:
   ```ahk
   ; Inefficient (complex polygon)
   d2d.fillPolygon([[0,0], [100,0], [100,100], [0,100]], 0xFF0000)
   
   ; More efficient (simple rectangle)
   d2d.fillRectangle(0, 0, 100, 100, 0xFF0000)
   ```

3. **Batch similar operations**:
   ```ahk
   ; Draw all rectangles first, then all circles
   for rect in rectangles
       d2d.fillRectangle(rect.x, rect.y, rect.w, rect.h, rect.color)
   
   for circle in circles
       d2d.fillCircle(circle.x, circle.y, circle.r, circle.color)
   ```

### Resource Caching

The D2D1 class includes several caching mechanisms:

1. **Color caching**: The `_setBrushColor` method only updates the brush if the color has changed
2. **Font caching**: The text rendering system caches fonts for reuse
3. **Shape reuse**: Create shapes once and reuse them instead of recreating them each frame

The font caching system is particularly important for text-heavy applications. It maintains a cache of up to 50 fonts (by default) to avoid the overhead of creating text formats repeatedly.

### Batch Operations

Use the scene graph to batch drawing operations:

```ahk
; Create a scene
scene := D2D1Scene()

; Add all shapes to the scene
for i in range
    scene.addShape(D2D1Rectangle(i*10, i*10, 10, 10, 0xFF0000))

; Draw all shapes in a single operation
scene.draw(d2d)
```

### Memory Usage Considerations

To minimize memory usage:

1. **Limit the number of shapes**: Too many shapes can consume excessive memory
2. **Release unused resources**: Remove shapes from scenes when no longer needed
3. **Use appropriate data structures**: Use arrays or maps efficiently

### Debugging and Profiling

To debug performance issues:

1. **Measure frame times**:
   ```ahk
   startTime := A_TickCount
   ; Drawing operations
   endTime := A_TickCount
   frameTime := endTime - startTime
   ```

2. **Identify bottlenecks**:
   ```ahk
   ; Measure specific operations
   startTime := A_TickCount
   d2d.fillPolygon(complexPolygon, 0xFF0000)
   polygonTime := A_TickCount - startTime
   ```

3. **Optimize critical paths**: Focus on optimizing the most time-consuming operations

## 10. API Reference

### D2D1 Class Methods

#### Constructor and Setup

```ahk
__New(hwnd, x := 100, y := 100, width := 800, height := 600, vsync := true)
setPosition(x, y, w := 0, h := 0)
setAntialias(enable := true)
setVSync(enable := true)
```

#### Drawing Cycle

```ahk
beginDraw()
endDraw()
clear()
```

#### Shape Drawing

```ahk
fillRectangle(x, y, w, h, color)
drawRectangle(x, y, w, h, color, thickness := 1, rounded := 0)
fillRoundedRectangle(x, y, w, h, radiusX, radiusY, color)
drawRoundedRectangle(x, y, w, h, radiusX, radiusY, color, thickness := 1, rounded := 0)
fillCircle(x, y, radius, color)
drawCircle(x, y, radius, color, thickness := 1, rounded := 0)
fillEllipse(x, y, radiusX, radiusY, color)
drawEllipse(x, y, radiusX, radiusY, color, thickness := 1, rounded := 0)
drawLine(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
fillPolygon(points, color, xOffset := 0, yOffset := 0)
drawPolygon(points, color, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0)
```

#### Text Drawing

```ahk
drawText(text, x, y, size := 18, color := 0xFFFFFFFF, fontName := "Arial", extraOptions := "")
createTextFormat(fontFamily, fontSize, fontWeight := "normal", fontStyle := "normal", formatName := "")
```

#### Utility Methods

```ahk
_setBrushColor(color)
_vTable(object, methodIndex)
_createGuid(guidStr, &clsidFactory)
```

### Shape Classes

#### Base Shape Class

```ahk
D2D1Shape(x, y, color := 0xFFFFFFFF)
move(dx, dy)
setColor(color)
draw(d2d)  ; Abstract method
```

#### Rectangle Classes

```ahk
D2D1Rectangle(x, y, width, height, color := 0xFFFFFFFF)
D2D1OutlineRectangle(x, y, width, height, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
D2D1RoundedRectangle(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF)
D2D1OutlineRoundedRectangle(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

#### Circle Classes

```ahk
D2D1Circle(x, y, radius, color := 0xFFFFFFFF)
D2D1OutlineCircle(x, y, radius, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

#### Line Class

```ahk
D2D1Line(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

#### Polygon Classes

```ahk
D2D1Polygon(points, color := 0xFFFFFFFF, xOffset := 0, yOffset := 0)
D2D1OutlinePolygon(points, color := 0xFFFFFFFF, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0)
```

#### Text Class

```ahk
D2D1Text(text, x, y, width, height, color := 0xFF000000, fontName := "Arial", alignment := "left", extraOptions := "")
setText(text)
setFontSize(size)
setFontName(fontName)
setAlignment(alignment)
addDropShadow(color, xOffset := 1, yOffset := 1)
addOutline(color)
```

#### Scene Graph

```ahk
D2D1Scene()
addShape(shape)
removeShape(index)
draw(d2d)
```

### Resource Manager

```ahk
D2D1ResourceManager()
addResource(name, resource, releaseMethod)
getResource(name)
releaseResource(name)
releaseAll()
```

### Structure Definitions

The `D2D1Structs` class provides static methods for creating Direct2D structures:

```ahk
D2D1Structs._MARGINS(cxLeftWidth := -1, cxRightWidth := -1, cyTopHeight := -1, cyBottomHeight := -1)
D2D1Structs.D2D_POINT_2F(x1, y1, x2, y2)
D2D1Structs.gdiplusStartupInput(GdiplusVersion := 1)
D2D1Structs.D2D1_RENDER_TARGET_PROPERTIES(...)
D2D1Structs.D2D1_HWND_RENDER_TARGET_PROPERTIES(...)
D2D1Structs.D2D1_MATRIX_3X2_F(...)
D2D1Structs.D2D1_STROKE_STYLE_PROPERTIES(...)
D2D1Structs.D2D_RECT_F(left := 0, top := 0, right := 0, bottom := 0)
```

### Constants and Enumerations

```ahk
; Render target types
D2D1_RENDER_TARGET_TYPE_DEFAULT := 0
D2D1_RENDER_TARGET_TYPE_SOFTWARE := 1
D2D1_RENDER_TARGET_TYPE_HARDWARE := 2

; Alpha modes
D2D1_ALPHA_MODE_UNKNOWN := 0
D2D1_ALPHA_MODE_PREMULTIPLIED := 1
D2D1_ALPHA_MODE_STRAIGHT := 2
D2D1_ALPHA_MODE_IGNORE := 3

; Present options
D2D1_PRESENT_OPTIONS_NONE := 0  ; VSync enabled
D2D1_PRESENT_OPTIONS_IMMEDIATELY := 2  ; VSync disabled

; Antialiasing modes
D2D1_ANTIALIAS_MODE_PER_PRIMITIVE := 0
D2D1_ANTIALIAS_MODE_ALIASED := 1
```

### Error Handling

The D2D1 class uses exceptions for error handling:

```ahk
try {
    d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)
} catch as e {
    MsgBox("Failed to initialize Direct2D: " e.Message)
    ExitApp
}
```

Common exceptions:
- Failed to create Direct2D factory
- Failed to create render target
- Failed to create brush
- Failed to create stroke object
- Invalid shape dimensions

## 11. Planned Features

The following features are planned for future releases:

### Image Drawing

Support for loading and rendering images from files is planned for a future update. This will include:

- Loading images from various file formats (PNG, JPEG, etc.)
- Rendering images with scaling and positioning options
- Support for transparency and blending
- Potential support for image transformations (rotation, skewing, etc.)

The API will likely include methods such as:

```ahk
; Load an image from a file
image := d2d.loadImage(filePath)

; Draw an image
d2d.drawImage(image, x, y, width, height)

; Draw a portion of an image
d2d.drawImageRect(image, destX, destY, destWidth, destHeight, sourceX, sourceY, sourceWidth, sourceHeight)
```

### Bitmap Effects

Future versions may include support for bitmap effects, such as:

- Blur and other filters
- Color adjustments
- Masking and clipping

### Additional Shape Types

Additional shape types may be added in future releases, such as:

- Bezier curves
- Arcs and pie segments
- Stars and regular polygons
- Path-based shapes with complex geometry

Stay tuned for updates on these planned features.