# Direct2D Wrapper for AutoHotkey v2 (d2d1.ahk)

## Introduction

The `d2d1.ahk` file is the core component of the Direct2D wrapper for AutoHotkey v2. It provides an object-oriented interface to the Windows Direct2D API, enabling hardware-accelerated 2D graphics rendering in AutoHotkey applications. This document offers comprehensive documentation for the `D2D1` class and related components, including both tutorial-based examples and detailed technical information.

## Overview

Direct2D is a hardware-accelerated, immediate-mode 2D graphics API from Microsoft that provides high-performance and high-quality rendering for 2D geometry, bitmaps, and text. The `d2d1.ahk` wrapper abstracts away much of the complexity of working directly with the COM-based API, providing a simpler, more AutoHotkey-friendly interface.

### Key Features

- **Hardware Acceleration**: Utilizes GPU for faster rendering
- **Object-Oriented Design**: Clean, modular architecture
- **Resource Management**: Automatic cleanup of Direct2D resources
- **Event System**: Flexible event handling for various rendering events
- **Shape Classes**: High-level abstraction for common shapes
- **Scene Graph**: Manage multiple shapes efficiently
- **Text Rendering**: Comprehensive text formatting and effects
- **Performance Controls**: VSync and antialiasing options

## Architecture

The Direct2D wrapper consists of several components that work together:

1. **D2D1 Class** (`d2d1.ahk`): Main class for Direct2D operations
2. **D2D1Structs** (`d2d1Structs.ahk`): Structure definitions for Direct2D
3. **D2D1Enums** (`D2D1Enums.ahk`): Enumeration values for Direct2D
4. **D2D1Shapes** (`d2d1Shapes.ahk`): Shape classes for higher-level abstraction
5. **D2D1Events** (`d2d1Events.ahk`): Event system for Direct2D operations

### Technical Architecture

The wrapper uses a layered architecture:

1. **Application Layer**: Your AutoHotkey code
2. **Wrapper Layer**: D2D1 class and related components
3. **COM Interface Layer**: Direct communication with Direct2D COM objects
4. **Direct2D Layer**: Microsoft's Direct2D API
5. **DirectX/GPU Layer**: Hardware acceleration

## Getting Started

### Basic Setup

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Begin drawing
d2d.beginDraw()

; Draw something
d2d.fillRectangle(100, 100, 200, 150, 0xFF0000)

; End drawing
d2d.endDraw()
```

### Animation Setup

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Animation")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create a drawing function
drawFunc := DrawFrame.Bind(d2d)

; Set up animation timer (60 FPS)
SetTimer(drawFunc, 16)

; Drawing function
DrawFrame(d2d) {
    static angle := 0
    
    ; Update animation state
    angle += 2
    if (angle >= 360)
        angle := 0
        
    ; Calculate position
    x := 400 + 150 * Cos(angle * 0.0174533)
    y := 300 + 150 * Sin(angle * 0.0174533)
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw animated circle
    d2d.fillCircle(x, y, 50, 0x0000FF)
    
    ; End drawing
    d2d.endDraw()
}
```

## D2D1 Class Reference

The `D2D1` class is the main entry point for Direct2D operations. It provides methods for creating and managing Direct2D resources, as well as drawing operations.

### Constructor

```autohotkey
d2d := D2D1(hwnd, x := 0, y := 0, width := 800, height := 600, vsync := true)
```

**Parameters**:
- `hwnd` (Integer): Window handle
- `x` (Integer): X position of the window
- `y` (Integer): Y position of the window
- `width` (Integer): Width of the render target
- `height` (Integer): Height of the render target
- `vsync` (Boolean): Whether to enable VSync (default: true)

**Returns**: D2D1 instance

**Technical Details**:
- Creates a Direct2D factory
- Initializes GDI+ for compatibility
- Creates a window render target
- Sets up event handling
- Allocates memory buffers for drawing operations

### Drawing Control Methods

#### beginDraw

```autohotkey
d2d.beginDraw()
```

Begins a drawing operation. Must be called before any drawing methods.

**Returns**: 1 if successful, 0 otherwise

**Technical Details**:
- Calls ID2D1RenderTarget::BeginDraw()
- Triggers the "beforeDraw" event
- Sets the drawing flag to prevent nested drawing operations

#### endDraw

```autohotkey
d2d.endDraw()
```

Ends a drawing operation. Must be called after all drawing methods.

**Technical Details**:
- Calls ID2D1RenderTarget::EndDraw()
- Triggers the "afterDraw" event
- Clears the drawing flag

#### clear

```autohotkey
d2d.clear()
```

Clears the render target.

**Technical Details**:
- Calls ID2D1RenderTarget::BeginDraw()
- Calls ID2D1RenderTarget::Clear()
- Calls ID2D1RenderTarget::EndDraw()

### Shape Drawing Methods

#### drawRectangle

```autohotkey
d2d.drawRectangle(x, y, w, h, color, thickness := 1, rounded := 0)
```

Draws a rectangle outline.

**Parameters**:
- `x` (Number): Top-left X coordinate
- `y` (Number): Top-left Y coordinate
- `w` (Number): Width
- `h` (Number): Height
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded corners

**Technical Details**:
- Creates a D2D_RECT_F structure
- Sets the brush color
- Calls ID2D1RenderTarget::DrawRectangle()

#### fillRectangle

```autohotkey
d2d.fillRectangle(x, y, w, h, color)
```

Fills a rectangle with the specified color.

**Parameters**:
- `x` (Number): Top-left X coordinate
- `y` (Number): Top-left Y coordinate
- `w` (Number): Width
- `h` (Number): Height
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Creates a D2D_RECT_F structure
- Sets the brush color
- Calls ID2D1RenderTarget::FillRectangle()

#### drawRoundedRectangle

```autohotkey
d2d.drawRoundedRectangle(x, y, w, h, radiusX, radiusY, color, thickness := 1, rounded := 0)
```

Draws a rounded rectangle outline.

**Parameters**:
- `x` (Number): Top-left X coordinate
- `y` (Number): Top-left Y coordinate
- `w` (Number): Width
- `h` (Number): Height
- `radiusX` (Number): X radius of the rounded corners
- `radiusY` (Number): Y radius of the rounded corners
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Creates a D2D1_ROUNDED_RECT structure
- Sets the brush color
- Calls ID2D1RenderTarget::DrawRoundedRectangle()

#### fillRoundedRectangle

```autohotkey
d2d.fillRoundedRectangle(x, y, w, h, radiusX, radiusY, color)
```

Fills a rounded rectangle with the specified color.

**Parameters**:
- `x` (Number): Top-left X coordinate
- `y` (Number): Top-left Y coordinate
- `w` (Number): Width
- `h` (Number): Height
- `radiusX` (Number): X radius of the rounded corners
- `radiusY` (Number): Y radius of the rounded corners
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Creates a D2D1_ROUNDED_RECT structure
- Sets the brush color
- Calls ID2D1RenderTarget::FillRoundedRectangle()

#### drawCircle

```autohotkey
d2d.drawCircle(x, y, radius, color, thickness := 1, rounded := 0)
```

Draws a circle outline.

**Parameters**:
- `x` (Number): Center X coordinate
- `y` (Number): Center Y coordinate
- `radius` (Number): Circle radius
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Creates a D2D_RECT_F structure
- Sets the brush color
- Calls ID2D1RenderTarget::DrawEllipse()

#### fillCircle

```autohotkey
d2d.fillCircle(x, y, radius, color)
```

Fills a circle with the specified color.

**Parameters**:
- `x` (Number): Center X coordinate
- `y` (Number): Center Y coordinate
- `radius` (Number): Circle radius
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Creates a D2D_RECT_F structure
- Sets the brush color
- Calls ID2D1RenderTarget::FillEllipse()

#### drawEllipse

```autohotkey
d2d.drawEllipse(x, y, radiusX, radiusY, color, thickness := 1, rounded := 0)
```

Draws an ellipse outline.

**Parameters**:
- `x` (Number): Center X coordinate
- `y` (Number): Center Y coordinate
- `radiusX` (Number): X radius
- `radiusY` (Number): Y radius
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Creates a D2D_RECT_F structure
- Sets the brush color
- Calls ID2D1RenderTarget::DrawEllipse()

#### fillEllipse

```autohotkey
d2d.fillEllipse(x, y, radiusX, radiusY, color)
```

Fills an ellipse with the specified color.

**Parameters**:
- `x` (Number): Center X coordinate
- `y` (Number): Center Y coordinate
- `radiusX` (Number): X radius
- `radiusY` (Number): Y radius
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Creates a D2D_RECT_F structure
- Sets the brush color
- Calls ID2D1RenderTarget::FillEllipse()

#### drawLine

```autohotkey
d2d.drawLine(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

Draws a line.

**Parameters**:
- `x1` (Number): Start X coordinate
- `y1` (Number): Start Y coordinate
- `x2` (Number): End X coordinate
- `y2` (Number): End Y coordinate
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Creates a D2D_POINT_2F structure
- Sets the brush color
- Calls ID2D1RenderTarget::DrawLine()
- Handles differences between 32-bit and 64-bit environments

#### drawPolygon

```autohotkey
d2d.drawPolygon(points, color, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0)
```

Draws a polygon outline.

**Parameters**:
- `points` (Array): Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded corners
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Returns**: 1 if successful, 0 otherwise

**Technical Details**:
- Creates a path geometry
- Adds the points to the geometry
- Sets the brush color
- Calls ID2D1RenderTarget::DrawGeometry()

#### fillPolygon

```autohotkey
d2d.fillPolygon(points, color, xOffset := 0, yOffset := 0)
```

Fills a polygon with the specified color.

**Parameters**:
- `points` (Array): Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Returns**: 1 if successful, 0 otherwise

**Technical Details**:
- Creates a path geometry
- Adds the points to the geometry
- Sets the brush color
- Calls ID2D1RenderTarget::FillGeometry()

### Text Drawing Methods

#### drawText

```autohotkey
d2d.drawText(text, x, y, size := 18, color := 0xFFFFFFFF, fontName := "Arial", extraOptions := "")
```

Draws text on the canvas with advanced options.

**Parameters**:
- `text` (String): Text to draw
- `x` (Number): X position
- `y` (Number): Y position
- `size` (Number): Font size
- `color` (Integer): Text color in 0xAARRGGBB or 0xRRGGBB format
- `fontName` (String): Font family name
- `extraOptions` (String): Additional options for text rendering
  - `w[number]` - Width
  - `h[number]` - Height
  - `a[Left/Right/Center]` - Alignment
  - `ds[hex color]` - Drop shadow color
  - `dsx[number]` - Drop shadow X offset
  - `dsy[number]` - Drop shadow Y offset
  - `ol[hex color]` - Outline color

**Technical Details**:
- Creates or retrieves a cached text format
- Sets the brush color
- Parses extra options
- Applies text alignment
- Handles special effects (drop shadow, outline)
- Calls ID2D1RenderTarget::DrawText()

#### createTextFormat

```autohotkey
d2d.createTextFormat(fontFamily, fontSize, fontWeight := "normal", fontStyle := "normal", formatName := "")
```

Create a text format (font).

**Parameters**:
- `fontFamily` (String): Font family name (e.g., "Arial")
- `fontSize` (Number): Font size in points
- `fontWeight` (String): Font weight ("normal", "bold", "light", "black", etc.)
- `fontStyle` (String): Font style ("normal", "italic", "oblique")
- `formatName` (String): Name to reference this format later (optional)

**Returns**: Text format pointer

**Technical Details**:
- Converts font weight and style strings to numeric values
- Creates a DirectWrite text format
- Stores the format in the text formats map if a name is provided
- Adds the format to the resource manager

### Configuration Methods

#### setPosition

```autohotkey
d2d.setPosition(x, y, w := 0, h := 0)
```

Set position of the window.

**Parameters**:
- `x` (Integer): X position
- `y` (Integer): Y position
- `w` (Integer): Width (optional)
- `h` (Integer): Height (optional)

**Technical Details**:
- Triggers "beforePositionChange" event
- Updates position properties
- Resizes the render target if needed
- Moves the window
- Triggers "afterPositionChange" event

#### setAntialias

```autohotkey
d2d.setAntialias(enable := true)
```

Set antialiasing mode.

**Parameters**:
- `enable` (Boolean): Whether to enable antialiasing

**Technical Details**:
- Gets current antialiasing mode
- Triggers "beforeAntialiasChange" event
- Sets the antialiasing mode
- Triggers "afterAntialiasChange" event

#### setVSync

```autohotkey
d2d.setVSync(enable := true)
```

Enable or disable VSync.

**Parameters**:
- `enable` (Boolean): Whether to enable VSync

**Returns**: True if successful, false otherwise

**Technical Details**:
- Triggers "beforeVSyncChange" event
- Updates the VSync setting
- Recreates the render target with the new VSync setting
- Recreates the brush
- Reinitializes function pointers
- Restores previous antialiasing setting
- Triggers "afterVSyncChange" event

#### resize

```autohotkey
d2d.resize(x, y, w, h)
```

Resize the render target.

**Parameters**:
- `x` (Integer): X position (usually 0)
- `y` (Integer): Y position (usually 0)
- `w` (Integer): New width
- `h` (Integer): New height

**Technical Details**:
- Triggers "beforeResize" event
- Updates dimensions
- Resizes the render target
- Triggers "afterResize" event

### Resource Management

#### cleanup

```autohotkey
d2d.cleanup()
```

Explicit cleanup method - Call this before exiting your application for reliable resource cleanup.

**Technical Details**:
- Triggers "beforeCleanup" event
- Ends any ongoing drawing
- Shuts down GDI+
- Releases all resources
- Removes message handler
- Triggers "afterCleanup" event

## D2D1ResourceManager Class

The `D2D1ResourceManager` class is responsible for managing Direct2D resources, ensuring proper cleanup when they are no longer needed.

### Methods

#### addResource

```autohotkey
resourceManager.addResource(name, resource, releaseMethod)
```

Add a resource to the manager.

**Parameters**:
- `name` (String): Resource name
- `resource` (Pointer): Resource pointer
- `releaseMethod` (Pointer): Release method pointer

#### getResource

```autohotkey
resourceManager.getResource(name)
```

Get a resource by name.

**Parameters**:
- `name` (String): Resource name

**Returns**: Resource pointer or 0 if not found

#### releaseResource

```autohotkey
resourceManager.releaseResource(name)
```

Release a resource by name.

**Parameters**:
- `name` (String): Resource name

#### releaseAll

```autohotkey
resourceManager.releaseAll()
```

Release all resources.

## D2D1Scene Class

The `D2D1Scene` class provides a scene graph for managing multiple shapes.

### Methods

#### addShape

```autohotkey
scene.addShape(shape)
```

Add a shape to the scene.

**Parameters**:
- `shape` (D2D1Shape): Shape to add

#### removeShape

```autohotkey
scene.removeShape(index)
```

Remove a shape from the scene.

**Parameters**:
- `index` (Integer): Shape index

#### draw

```autohotkey
scene.draw(d2d)
```

Draw all shapes in the scene.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

## Event System

The Direct2D wrapper includes an event system that allows you to register handlers for various events.

### Available Events

- **beforeDraw**: Triggered before drawing operations begin
- **afterDraw**: Triggered after drawing operations end
- **beforePositionChange**: Triggered before the window position changes
- **afterPositionChange**: Triggered after the window position changes
- **beforeAntialiasChange**: Triggered before the antialiasing mode changes
- **afterAntialiasChange**: Triggered after the antialiasing mode changes
- **beforeVSyncChange**: Triggered before the VSync setting changes
- **afterVSyncChange**: Triggered after the VSync setting changes
- **beforeResize**: Triggered before the render target is resized
- **afterResize**: Triggered after the render target is resized
- **beforeCleanup**: Triggered before resources are cleaned up
- **afterCleanup**: Triggered after resources are cleaned up

### Registering Event Handlers

```autohotkey
d2d.events.on("eventName", callbackFunction, priority := 0)
```

**Parameters**:
- `eventName` (String): Event name
- `callbackFunction` (Function): Event handler function
- `priority` (Integer): Handler priority (higher numbers execute first)

**Returns**: Handler ID for later removal

### Removing Event Handlers

```autohotkey
d2d.events.off("eventName", handlerId)
```

**Parameters**:
- `eventName` (String): Event name
- `handlerId` (Integer): Handler ID returned from on() method

**Returns**: True if handler was removed, false otherwise

## Performance Optimization

### Memory Management

1. **Reuse structures**: Create structures outside of animation loops when possible
2. **Minimize allocations**: Avoid creating new structures in tight loops
3. **Release references**: Set variables to empty (`""`) when you're done with them to help the garbage collector

### Efficient Drawing

1. **Minimize state changes**: Group similar drawing operations together
2. **Use appropriate methods**: Choose the right drawing method for the job
3. **Batch operations**: Perform multiple drawing operations in a single beginDraw/endDraw pair

### VSync Control

1. **Enable VSync** for smooth animations without tearing
2. **Disable VSync** for maximum performance when tearing is not a concern

### Antialiasing Control

1. **Enable antialiasing** for high-quality rendering
2. **Disable antialiasing** for maximum performance when quality is not a concern

## Technical Reference

### COM Interface

The Direct2D wrapper uses COM (Component Object Model) to interact with the Direct2D API. This involves:

1. **Creating COM objects**: Using functions like `D2D1CreateFactory`
2. **Calling COM methods**: Using virtual table (vtable) pointers
3. **Releasing COM objects**: Calling the `Release` method when done

### Virtual Table (VTable)

COM objects use a virtual table (vtable) to expose their methods. The wrapper accesses these methods using the `_vTable` helper method:

```autohotkey
_vTable(object, methodIndex) {
    return NumGet(NumGet(object + 0, 0, "ptr"), methodIndex * A_PtrSize, "Ptr")
}
```

### 32-bit vs. 64-bit Considerations

The wrapper handles differences between 32-bit and 64-bit environments, particularly for:

1. **Pointer sizes**: 4 bytes in 32-bit, 8 bytes in 64-bit
2. **Structure layouts**: Some structures have different layouts in 32-bit and 64-bit
3. **Function calling conventions**: Different in 32-bit and 64-bit

## Examples

### Basic Drawing

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Basic Drawing")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw shapes
d2d.fillRectangle(100, 100, 200, 150, 0xFF0000)
d2d.drawRectangle(350, 100, 200, 150, 0x0000FF, 3)
d2d.fillCircle(200, 350, 75, 0x00FF00)
d2d.drawCircle(450, 350, 75, 0xFF00FF, 3)
d2d.drawLine(100, 500, 700, 500, 0x000000, 5)

; Draw text
d2d.drawText("Hello, Direct2D!", 300, 50, 24, 0x000000, "Arial", "aCenter")

; End drawing
d2d.endDraw()
```

### Animation with Events

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Animation with Events")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Register event handlers
d2d.events.on("beforeDraw", (*) => OutputDebug("Drawing started"))
d2d.events.on("afterDraw", (*) => OutputDebug("Drawing completed"))
d2d.events.on("beforeVSyncChange", (d2d, oldValue, newValue) => 
    OutputDebug("VSync changing from " (oldValue ? "ON" : "OFF") " to " (newValue ? "ON" : "OFF")))

; Animation variables
angle := 0
radius := 150

; Create a drawing function
drawFunc := AnimationFrame.Bind(d2d)

; Set up animation timer (60 FPS)
SetTimer(drawFunc, 16)

; Animation function
AnimationFrame(d2d) {
    global angle, radius
    
    ; Update animation variables
    angle += 2
    if (angle >= 360)
        angle := 0
    
    ; Calculate position
    x := 400 + radius * Cos(angle * 0.0174533)
    y := 300 + radius * Sin(angle * 0.0174533)
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw animated circle
    d2d.fillCircle(x, y, 50, 0x0000FF)
    
    ; Draw connecting line
    d2d.drawLine(400, 300, x, y, 0x000000, 2)
    
    ; End drawing
    d2d.endDraw()
}

; Toggle VSync every 5 seconds
SetTimer(() => d2d.setVSync(!d2d.vsync), 5000)
```

### Using Shape Classes and Scene Graph

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Shape Classes and Scene Graph")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create a scene
scene := D2D1Scene()

; Add shapes to the scene
scene.addShape(D2D1Rectangle(50, 50, 100, 100, 0xFF0000))
scene.addShape(D2D1OutlineRectangle(200, 50, 100, 100, 0x0000FF, 3))
scene.addShape(D2D1RoundedRectangle(350, 50, 100, 100, 10, 10, 0x00FF00))
scene.addShape(D2D1Circle(100, 200, 50, 0xFF00FF))
scene.addShape(D2D1OutlineCircle(250, 200, 50, 0x00FFFF, 3))
scene.addShape(D2D1Line(350, 150, 450, 250, 0x000000, 3))
scene.addShape(D2D1Polygon([[500, 150], [600, 150], [550, 250]], 0xFFFF00))
scene.addShape(D2D1Text("Scene Graph", 300, 300, 24, 0x000000, "Arial", "center"))

; Draw the scene
scene.draw(d2d)
```

## Conclusion

The Direct2D wrapper for AutoHotkey v2 provides a powerful yet easy-to-use interface for creating hardware-accelerated 2D graphics. By abstracting away the complexity of the Direct2D API, it allows AutoHotkey developers to create high-performance graphics applications with minimal code.

For more detailed information about specific components, please refer to the following documentation files:

- [d2d1Structs_Documentation.md](d2d1Structs_Documentation.md): Documentation for structure definitions
- [D2D1Enums_Documentation.md](D2D1Enums_Documentation.md): Documentation for enumeration values
- [d2d1Shapes_Documentation.md](d2d1Shapes_Documentation.md): Documentation for shape classes

## Attribution

This library is based on Spawnova's Direct2D overlay class, which can be found at: https://github.com/Spawnova/ShinsOverlayClass