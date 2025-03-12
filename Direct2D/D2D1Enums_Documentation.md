# Direct2D Enumerations (D2D1Enums.ahk)

## Introduction

The `D2D1Enums.ahk` file provides a comprehensive mapping of Direct2D enumerations for use with the Direct2D wrapper in AutoHotkey v2. This document offers both a tutorial-based approach to understanding and using these enumerations, with practical examples, as well as detailed technical information about the underlying Direct2D concepts.

## What are Enumerations?

Enumerations (enums) are named constants that make code more readable and maintainable by replacing magic numbers with descriptive names. In the context of Direct2D, enumerations define various options and modes for rendering operations, such as how lines are drawn, how colors are blended, and how shapes are filled.

The `D2D1Enums.ahk` file organizes these enumerations into a structured class hierarchy, making them easy to access and use in your AutoHotkey code.

## Technical Architecture

The enumerations in `D2D1Enums.ahk` are organized as nested classes within the main `D2D1Enums` class. This structure provides several benefits:

1. **Namespace isolation**: Prevents naming conflicts with other code
2. **Logical grouping**: Related enumerations are grouped together
3. **IntelliSense support**: Enables code completion in supporting editors
4. **Documentation integration**: Allows for structured documentation

Each enumeration class contains static properties representing the enumeration values, with names that match the original Direct2D API constants.

## Enumeration Categories

The enumerations in `D2D1Enums.ahk` are organized into logical categories based on their purpose:

### Interpolation Mode Definitions

Defines the interpolation modes supported by Direct2D APIs and built-in effects.

```autohotkey
; Use nearest neighbor interpolation
interpolationMode := D2D1Enums.INTERPOLATION_MODE_DEFINITION.NEAREST_NEIGHBOR

; Use linear interpolation
interpolationMode := D2D1Enums.INTERPOLATION_MODE_DEFINITION.LINEAR

; Use cubic interpolation
interpolationMode := D2D1Enums.INTERPOLATION_MODE_DEFINITION.CUBIC
```

**Technical Details**:
- **NEAREST_NEIGHBOR (0)**: Also known as nearest pixel or nearest point sampling. Selects the color of the nearest pixel, resulting in a blocky appearance.
- **LINEAR (1)**: Performs linear interpolation between neighboring pixels, resulting in a smoother appearance.
- **CUBIC (2)**: Uses cubic interpolation for smoother results than linear interpolation.
- **MULTI_SAMPLE_LINEAR (3)**: Combines multiple samples with linear interpolation.
- **ANISOTROPIC (4)**: Provides better quality for non-uniform scaling.
- **HIGH_QUALITY_CUBIC (5)**: Higher quality cubic interpolation.
- **FANT (6)**: Fant resampling algorithm.
- **MIPMAP_LINEAR (7)**: Linear interpolation between mipmap levels.

**Usage Context**: These values are used when specifying how images or textures should be sampled during scaling or rotation operations.

### Gamma

Determines what gamma is used for interpolation/blending.

```autohotkey
; Use 2.2 gamma color space
gamma := D2D1Enums.GAMMA.D2D1_GAMMA_2_2

; Use 1.0 gamma color space
gamma := D2D1Enums.GAMMA.D2D1_GAMMA_1_0
```

**Technical Details**:
- **D2D1_GAMMA_2_2 (0)**: Colors are manipulated in 2.2 gamma color space, which is the standard for most displays.
- **D2D1_GAMMA_1_0 (1)**: Colors are manipulated in 1.0 gamma color space (linear color space).
- **D2D1_GAMMA_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when specifying how colors should be blended or interpolated, particularly for operations that involve alpha blending.

### Opacity Mask Content

Specifies what the contents are of an opacity mask.

```autohotkey
; Mask contains geometries or bitmaps
maskContent := D2D1Enums.OPACITY_MASK_CONTENT.D2D1_OPACITY_MASK_CONTENT_GRAPHICS

; Mask contains text rendered using natural text mode
maskContent := D2D1Enums.OPACITY_MASK_CONTENT.D2D1_OPACITY_MASK_CONTENT_TEXT_NATURAL
```

**Technical Details**:
- **D2D1_OPACITY_MASK_CONTENT_GRAPHICS (0)**: The mask contains geometries or bitmaps.
- **D2D1_OPACITY_MASK_CONTENT_TEXT_NATURAL (1)**: The mask contains text rendered using one of the natural text modes.
- **D2D1_OPACITY_MASK_CONTENT_TEXT_GDI_COMPATIBLE (2)**: The mask contains text rendered using one of the GDI compatible text modes.
- **D2D1_OPACITY_MASK_CONTENT_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating opacity masks for complex rendering operations.

### Extend Mode

Enum which describes how to sample from a source outside its base tile.

```autohotkey
; Clamp to edge
extendMode := D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_CLAMP

; Wrap (repeat)
extendMode := D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_WRAP

; Mirror
extendMode := D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_MIRROR
```

**Technical Details**:
- **D2D1_EXTEND_MODE_CLAMP (0)**: Extend the edges of the source out by clamping sample points outside the source to the edges.
- **D2D1_EXTEND_MODE_WRAP (1)**: The base tile is drawn untransformed and the remainder are filled by repeating the base tile.
- **D2D1_EXTEND_MODE_MIRROR (2)**: The same as wrap, but alternate tiles are flipped. The base tile is drawn untransformed.
- **D2D1_EXTEND_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating bitmap brushes or gradient brushes to specify how the brush should behave when it extends beyond its defined area.

### Antialias Mode

Enum which describes the manner in which we render edges of non-text primitives.

```autohotkey
; Per-primitive antialiasing
antialiasMode := D2D1Enums.ANTIALIAS_MODE.D2D1_ANTIALIAS_MODE_PER_PRIMITIVE

; Aliased (no antialiasing)
antialiasMode := D2D1Enums.ANTIALIAS_MODE.D2D1_ANTIALIAS_MODE_ALIASED
```

**Technical Details**:
- **D2D1_ANTIALIAS_MODE_PER_PRIMITIVE (0)**: The edges of each primitive are antialiased sequentially.
- **D2D1_ANTIALIAS_MODE_ALIASED (1)**: Each pixel is rendered if its pixel center is contained by the geometry.
- **D2D1_ANTIALIAS_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used to control the antialiasing mode for rendering operations, affecting the appearance of edges in shapes and lines.

### Text Antialias Mode

Describes the antialiasing mode used for drawing text.

```autohotkey
; Use system default
textAntialiasMode := D2D1Enums.TEXT_ANTIALIAS_MODE.D2D1_TEXT_ANTIALIAS_MODE_DEFAULT

; Use ClearType
textAntialiasMode := D2D1Enums.TEXT_ANTIALIAS_MODE.D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE

; Use grayscale
textAntialiasMode := D2D1Enums.TEXT_ANTIALIAS_MODE.D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE
```

**Technical Details**:
- **D2D1_TEXT_ANTIALIAS_MODE_DEFAULT (0)**: Render text using the current system setting.
- **D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE (1)**: Render text using ClearType, which enhances text readability on LCD displays.
- **D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE (2)**: Render text using gray-scale antialiasing.
- **D2D1_TEXT_ANTIALIAS_MODE_ALIASED (3)**: Render text aliased (no antialiasing).
- **D2D1_TEXT_ANTIALIAS_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used to control the antialiasing mode specifically for text rendering operations.

### Bitmap Interpolation Mode

Specifies the algorithm that is used when images are scaled or rotated.

```autohotkey
; Use nearest neighbor interpolation
bitmapInterpolationMode := D2D1Enums.BITMAP_INTERPOLATION_MODE.D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR

; Use linear interpolation
bitmapInterpolationMode := D2D1Enums.BITMAP_INTERPOLATION_MODE.D2D1_BITMAP_INTERPOLATION_MODE_LINEAR
```

**Technical Details**:
- **D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR (0)**: Nearest Neighbor filtering. Also known as nearest pixel or nearest point sampling.
- **D2D1_BITMAP_INTERPOLATION_MODE_LINEAR (1)**: Linear filtering.
- **D2D1_BITMAP_INTERPOLATION_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when drawing bitmaps to specify how the bitmap should be interpolated when scaled or rotated.

### Draw Text Options

Modifications made to the draw text call that influence how the text is rendered.

```autohotkey
; No special options
textOptions := D2D1Enums.DRAW_TEXT_OPTIONS.D2D1_DRAW_TEXT_OPTIONS_NONE

; Do not snap the baseline of the text vertically
textOptions := D2D1Enums.DRAW_TEXT_OPTIONS.D2D1_DRAW_TEXT_OPTIONS_NO_SNAP

; Clip the text to the content bounds
textOptions := D2D1Enums.DRAW_TEXT_OPTIONS.D2D1_DRAW_TEXT_OPTIONS_CLIP
```

**Technical Details**:
- **D2D1_DRAW_TEXT_OPTIONS_NO_SNAP (0x00000001)**: Do not snap the baseline of the text vertically.
- **D2D1_DRAW_TEXT_OPTIONS_CLIP (0x00000002)**: Clip the text to the content bounds.
- **D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT (0x00000004)**: Render color versions of glyphs if defined by the font.
- **D2D1_DRAW_TEXT_OPTIONS_DISABLE_COLOR_BITMAP_SNAPPING (0x00000008)**: Bitmap origins of color glyph bitmaps are not snapped.
- **D2D1_DRAW_TEXT_OPTIONS_NONE (0x00000000)**: No special options.
- **D2D1_DRAW_TEXT_OPTIONS_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when drawing text to specify various rendering options.

### Arc Size

Differentiates which of the two possible arcs could match the given arc parameters.

```autohotkey
; Small arc
arcSize := D2D1Enums.ARC_SIZE.D2D1_ARC_SIZE_SMALL

; Large arc
arcSize := D2D1Enums.ARC_SIZE.D2D1_ARC_SIZE_LARGE
```

**Technical Details**:
- **D2D1_ARC_SIZE_SMALL (0)**: The smaller of the two possible arcs.
- **D2D1_ARC_SIZE_LARGE (1)**: The larger of the two possible arcs.
- **D2D1_ARC_SIZE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating arc segments in path geometries to specify which of the two possible arcs should be drawn.

### Cap Style

Enum which describes the drawing of the ends of a line.

```autohotkey
; Flat cap
capStyle := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_FLAT

; Square cap
capStyle := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_SQUARE

; Round cap
capStyle := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND

; Triangle cap
capStyle := D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_TRIANGLE
```

**Technical Details**:
- **D2D1_CAP_STYLE_FLAT (0)**: Flat line cap. The end of the line is a flat edge perpendicular to the line itself.
- **D2D1_CAP_STYLE_SQUARE (1)**: Square line cap. The end of the line is a square that has an extra half line width beyond the end of the line.
- **D2D1_CAP_STYLE_ROUND (2)**: Round line cap. The end of the line is a semicircle with a diameter equal to the line width.
- **D2D1_CAP_STYLE_TRIANGLE (3)**: Triangle line cap. The end of the line is a triangle.
- **D2D1_CAP_STYLE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating stroke styles to specify how the ends of lines should be drawn.

### Dash Style

Describes the sequence of dashes and gaps in a stroke.

```autohotkey
; Solid line (no dashes)
dashStyle := D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_SOLID

; Dashed line
dashStyle := D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_DASH

; Dotted line
dashStyle := D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_DOT

; Dash-dot pattern
dashStyle := D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_DASH_DOT
```

**Technical Details**:
- **D2D1_DASH_STYLE_SOLID (0)**: A solid line with no breaks.
- **D2D1_DASH_STYLE_DASH (1)**: A dashed line.
- **D2D1_DASH_STYLE_DOT (2)**: A dotted line.
- **D2D1_DASH_STYLE_DASH_DOT (3)**: A line with alternating dashes and dots.
- **D2D1_DASH_STYLE_DASH_DOT_DOT (4)**: A line with alternating dashes and double dots.
- **D2D1_DASH_STYLE_CUSTOM (5)**: A custom pattern of dashes and gaps.
- **D2D1_DASH_STYLE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating stroke styles to specify the dash pattern of lines.

### Line Join

Enum which describes the drawing of the corners on the line.

```autohotkey
; Miter join
lineJoin := D2D1Enums.LINE_JOIN.D2D1_LINE_JOIN_MITER

; Bevel join
lineJoin := D2D1Enums.LINE_JOIN.D2D1_LINE_JOIN_BEVEL

; Round join
lineJoin := D2D1Enums.LINE_JOIN.D2D1_LINE_JOIN_ROUND
```

**Technical Details**:
- **D2D1_LINE_JOIN_MITER (0)**: Miter join. The outer edges of the lines are extended until they meet at an angle.
- **D2D1_LINE_JOIN_BEVEL (1)**: Bevel join. The outer corner of the lines is filled with a triangle.
- **D2D1_LINE_JOIN_ROUND (2)**: Round join. The outer corner of the lines is filled with a circle with a diameter equal to the line width.
- **D2D1_LINE_JOIN_MITER_OR_BEVEL (3)**: Miter/Bevel join. The join is mitered if the miter length is less than the miter limit; otherwise, it's beveled.
- **D2D1_LINE_JOIN_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating stroke styles to specify how the corners of lines should be drawn.

### Combine Mode

This enumeration describes the type of combine operation to be performed.

```autohotkey
; Union of two geometries
combineMode := D2D1Enums.COMBINE_MODE.D2D1_COMBINE_MODE_UNION

; Intersection of two geometries
combineMode := D2D1Enums.COMBINE_MODE.D2D1_COMBINE_MODE_INTERSECT

; XOR of two geometries
combineMode := D2D1Enums.COMBINE_MODE.D2D1_COMBINE_MODE_XOR
```

**Technical Details**:
- **D2D1_COMBINE_MODE_UNION (0)**: Produce a geometry representing the set of points contained in either the first or the second geometry.
- **D2D1_COMBINE_MODE_INTERSECT (1)**: Produce a geometry representing the set of points common to the first and the second geometries.
- **D2D1_COMBINE_MODE_XOR (2)**: Produce a geometry representing the set of points contained in the first geometry or the second geometry, but not both.
- **D2D1_COMBINE_MODE_EXCLUDE (3)**: Produce a geometry representing the set of points contained in the first geometry but not the second geometry.
- **D2D1_COMBINE_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when combining geometries to create complex shapes.

### Geometry Relation

Describes how one geometry object is spatially related to another geometry object.

```autohotkey
; Geometries do not intersect
relation := D2D1Enums.GEOMETRY_RELATION.D2D1_GEOMETRY_RELATION_DISJOINT

; First geometry contains the second
relation := D2D1Enums.GEOMETRY_RELATION.D2D1_GEOMETRY_RELATION_CONTAINS
```

**Technical Details**:
- **D2D1_GEOMETRY_RELATION_UNKNOWN (0)**: The relation between the geometries couldn't be determined. This value is never returned by any D2D method.
- **D2D1_GEOMETRY_RELATION_DISJOINT (1)**: The two geometries do not intersect at all.
- **D2D1_GEOMETRY_RELATION_IS_CONTAINED (2)**: The passed in geometry is entirely contained by the object.
- **D2D1_GEOMETRY_RELATION_CONTAINS (3)**: The object entirely contains the passed in geometry.
- **D2D1_GEOMETRY_RELATION_OVERLAP (4)**: The two geometries overlap but neither completely contains the other.
- **D2D1_GEOMETRY_RELATION_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are returned by geometry comparison methods to indicate the spatial relationship between geometries.

### Geometry Simplification Option

Specifies how simple the output of a simplified geometry sink should be.

```autohotkey
; Use cubic Beziers and lines
simplificationOption := D2D1Enums.GEOMETRY_SIMPLIFICATION_OPTION.D2D1_GEOMETRY_SIMPLIFICATION_OPTION_CUBICS_AND_LINES

; Use only lines
simplificationOption := D2D1Enums.GEOMETRY_SIMPLIFICATION_OPTION.D2D1_GEOMETRY_SIMPLIFICATION_OPTION_LINES
```

**Technical Details**:
- **D2D1_GEOMETRY_SIMPLIFICATION_OPTION_CUBICS_AND_LINES (0)**: The output can contain cubic Bezier curves and lines.
- **D2D1_GEOMETRY_SIMPLIFICATION_OPTION_LINES (1)**: The output will contain only lines.
- **D2D1_GEOMETRY_SIMPLIFICATION_OPTION_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when simplifying geometries to control the complexity of the output.

### Figure Begin

Indicates whether the given figure is filled or hollow.

```autohotkey
; Filled figure
figureBegin := D2D1Enums.FIGURE_BEGIN.D2D1_FIGURE_BEGIN_FILLED

; Hollow figure
figureBegin := D2D1Enums.FIGURE_BEGIN.D2D1_FIGURE_BEGIN_HOLLOW
```

**Technical Details**:
- **D2D1_FIGURE_BEGIN_FILLED (0)**: The figure is filled.
- **D2D1_FIGURE_BEGIN_HOLLOW (1)**: The figure is hollow (not filled).
- **D2D1_FIGURE_BEGIN_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when beginning a new figure in a path geometry to specify whether the figure should be filled or hollow.

### Figure End

Indicates whether the figure is open or closed on its end point.

```autohotkey
; Open figure
figureEnd := D2D1Enums.FIGURE_END.D2D1_FIGURE_END_OPEN

; Closed figure
figureEnd := D2D1Enums.FIGURE_END.D2D1_FIGURE_END_CLOSED
```

**Technical Details**:
- **D2D1_FIGURE_END_OPEN (0)**: The figure is open (the last point is not connected to the first point).
- **D2D1_FIGURE_END_CLOSED (1)**: The figure is closed (the last point is connected to the first point).
- **D2D1_FIGURE_END_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when ending a figure in a path geometry to specify whether the figure should be open or closed.

### Path Segment

Indicates whether the given segment should be stroked, or, if the join between this segment and the previous one should be smooth.

```autohotkey
; No special options
pathSegment := D2D1Enums.PATH_SEGMENT.D2D1_PATH_SEGMENT_NONE

; Force unstroked
pathSegment := D2D1Enums.PATH_SEGMENT.D2D1_PATH_SEGMENT_FORCE_UNSTROKED

; Force round line join
pathSegment := D2D1Enums.PATH_SEGMENT.D2D1_PATH_SEGMENT_FORCE_ROUND_LINE_JOIN
```

**Technical Details**:
- **D2D1_PATH_SEGMENT_NONE (0x00000000)**: No special options.
- **D2D1_PATH_SEGMENT_FORCE_UNSTROKED (0x00000001)**: The segment should not be stroked.
- **D2D1_PATH_SEGMENT_FORCE_ROUND_LINE_JOIN (0x00000002)**: The join between this segment and the previous one should be round.
- **D2D1_PATH_SEGMENT_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when adding segments to a path geometry to control how the segments are stroked and joined.

### Sweep Direction

Defines the direction that an elliptical arc is drawn.

```autohotkey
; Counter-clockwise
sweepDirection := D2D1Enums.SWEEP_DIRECTION.D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE

; Clockwise
sweepDirection := D2D1Enums.SWEEP_DIRECTION.D2D1_SWEEP_DIRECTION_CLOCKWISE
```

**Technical Details**:
- **D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE (0)**: The arc is drawn in a counter-clockwise direction.
- **D2D1_SWEEP_DIRECTION_CLOCKWISE (1)**: The arc is drawn in a clockwise direction.
- **D2D1_SWEEP_DIRECTION_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating arc segments in path geometries to specify the direction of the arc.

### Fill Mode

Specifies how the intersecting areas of geometries or figures are combined to form the area of the composite geometry.

```autohotkey
; Alternate fill mode
fillMode := D2D1Enums.FILL_MODE.D2D1_FILL_MODE_ALTERNATE

; Winding fill mode
fillMode := D2D1Enums.FILL_MODE.D2D1_FILL_MODE_WINDING
```

**Technical Details**:
- **D2D1_FILL_MODE_ALTERNATE (0)**: Alternate fill mode. Areas are filled based on the even-odd rule: a pixel is filled if it falls within an odd number of overlapping figures.
- **D2D1_FILL_MODE_WINDING (1)**: Winding fill mode. Areas are filled based on the non-zero rule: a pixel is filled if the winding number is non-zero.
- **D2D1_FILL_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating geometries to specify how overlapping areas should be filled.

### Layer Options

Specified options that can be applied when a layer resource is applied to create a layer.

```autohotkey
; No special options
layerOptions := D2D1Enums.LAYER_OPTIONS.D2D1_LAYER_OPTIONS_NONE

; Initialize for ClearType
layerOptions := D2D1Enums.LAYER_OPTIONS.D2D1_LAYER_OPTIONS_INITIALIZE_FOR_CLEARTYPE
```

**Technical Details**:
- **D2D1_LAYER_OPTIONS_NONE (0x00000000)**: No special options.
- **D2D1_LAYER_OPTIONS_INITIALIZE_FOR_CLEARTYPE (0x00000001)**: The layer will render correctly for ClearType text. If the render target was set to ClearType previously, the layer will continue to render ClearType. If the render target was set to ClearType and this option is not specified, the render target will be set to render gray-scale until the layer is popped. The caller can override this default by calling SetTextAntialiasMode while within the layer. This flag is slightly slower than the default.
- **D2D1_LAYER_OPTIONS_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating layers to specify various rendering options.

### Window State

Describes whether a window is occluded.

```autohotkey
; Window is not occluded
windowState := D2D1Enums.WINDOW_STATE.D2D1_WINDOW_STATE_NONE

; Window is occluded
windowState := D2D1Enums.WINDOW_STATE.D2D1_WINDOW_STATE_OCCLUDED
```

**Technical Details**:
- **D2D1_WINDOW_STATE_NONE (0x0000000)**: The window is not occluded.
- **D2D1_WINDOW_STATE_OCCLUDED (0x0000001)**: The window is occluded.
- **D2D1_WINDOW_STATE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used to describe the occlusion state of a window.

### Render Target Type

Describes whether a render target uses hardware or software rendering, or if Direct2D should select the rendering mode.

```autohotkey
; Let Direct2D choose
renderTargetType := D2D1Enums.RENDER_TARGET_TYPE.D2D1_RENDER_TARGET_TYPE_DEFAULT

; Software rendering
renderTargetType := D2D1Enums.RENDER_TARGET_TYPE.D2D1_RENDER_TARGET_TYPE_SOFTWARE

; Hardware rendering
renderTargetType := D2D1Enums.RENDER_TARGET_TYPE.D2D1_RENDER_TARGET_TYPE_HARDWARE
```

**Technical Details**:
- **D2D1_RENDER_TARGET_TYPE_DEFAULT (0)**: D2D is free to choose the render target type for the caller.
- **D2D1_RENDER_TARGET_TYPE_SOFTWARE (1)**: The render target will render using the CPU.
- **D2D1_RENDER_TARGET_TYPE_HARDWARE (2)**: The render target will render using the GPU.
- **D2D1_RENDER_TARGET_TYPE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating render targets to specify the rendering mode.

### Feature Level

Describes the minimum DirectX support required for hardware rendering by a render target.

```autohotkey
; No specific requirement
featureLevel := D2D1Enums.FEATURE_LEVEL.D2D1_FEATURE_LEVEL_DEFAULT

; DX9 compatible
featureLevel := D2D1Enums.FEATURE_LEVEL.D2D1_FEATURE_LEVEL_9

; DX10 compatible
featureLevel := D2D1Enums.FEATURE_LEVEL.D2D1_FEATURE_LEVEL_10
```

**Technical Details**:
- **D2D1_FEATURE_LEVEL_DEFAULT (0)**: The caller does not require a particular underlying D3D device level.
- **D2D1_FEATURE_LEVEL_9 (0x9100)**: The D3D device level is DX9 compatible.
- **D2D1_FEATURE_LEVEL_10 (0xa000)**: The D3D device level is DX10 compatible.
- **D2D1_FEATURE_LEVEL_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating render targets to specify the minimum DirectX feature level required.

### Render Target Usage

Describes how a render target is remoted and whether it should be GDI-compatible.

```autohotkey
; No special options
renderTargetUsage := D2D1Enums.RENDER_TARGET_USAGE.D2D1_RENDER_TARGET_USAGE_NONE

; Force bitmap remoting
renderTargetUsage := D2D1Enums.RENDER_TARGET_USAGE.D2D1_RENDER_TARGET_USAGE_FORCE_BITMAP_REMOTING

; GDI compatible
renderTargetUsage := D2D1Enums.RENDER_TARGET_USAGE.D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE
```

**Technical Details**:
- **D2D1_RENDER_TARGET_USAGE_NONE (0x00000000)**: No special options.
- **D2D1_RENDER_TARGET_USAGE_FORCE_BITMAP_REMOTING (0x00000001)**: Rendering will occur locally, if a terminal-services session is established, the bitmap updates will be sent to the terminal services client.
- **D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE (0x00000002)**: The render target will allow a call to GetDC on the ID2D1GdiInteropRenderTarget interface. Rendering will also occur locally.
- **D2D1_RENDER_TARGET_USAGE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating render targets to specify various usage options.

### Present Options

Describes how present should behave.

```autohotkey
; No special options (VSync enabled)
presentOptions := D2D1Enums.PRESENT_OPTIONS.D2D1_PRESENT_OPTIONS_NONE

; Retain contents through present
presentOptions := D2D1Enums.PRESENT_OPTIONS.D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS

; Do not wait for display refresh (VSync disabled)
presentOptions := D2D1Enums.PRESENT_OPTIONS.D2D1_PRESENT_OPTIONS_IMMEDIATELY
```

**Technical Details**:
- **D2D1_PRESENT_OPTIONS_NONE (0x00000000)**: No special options. VSync is enabled.
- **D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS (0x00000001)**: Keep the target contents intact through present.
- **D2D1_PRESENT_OPTIONS_IMMEDIATELY (0x00000002)**: Do not wait for display refresh to commit changes to display. VSync is disabled.
- **D2D1_PRESENT_OPTIONS_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating window render targets to specify how the present operation should behave.

### Compatible Render Target Options

Specifies additional features supportable by a compatible render target when it is created.

```autohotkey
; No special options
compatibleRenderTargetOptions := D2D1Enums.COMPATIBLE_RENDER_TARGET_OPTIONS.D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE

; GDI compatible
compatibleRenderTargetOptions := D2D1Enums.COMPATIBLE_RENDER_TARGET_OPTIONS.D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_GDI_COMPATIBLE
```

**Technical Details**:
- **D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE (0x00000000)**: No special options.
- **D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_GDI_COMPATIBLE (0x00000001)**: The compatible render target will allow a call to GetDC on the ID2D1GdiInteropRenderTarget interface. This can be specified even if the parent render target is not GDI compatible.
- **D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating compatible render targets to specify various options.

### DC Initialize Mode

Specifies how a device context is initialized for GDI rendering when it is retrieved from the render target.

```autohotkey
; Copy contents to DC
dcInitializeMode := D2D1Enums.DC_INITIALIZE_MODE.D2D1_DC_INITIALIZE_MODE_COPY

; Clear DC
dcInitializeMode := D2D1Enums.DC_INITIALIZE_MODE.D2D1_DC_INITIALIZE_MODE_CLEAR
```

**Technical Details**:
- **D2D1_DC_INITIALIZE_MODE_COPY (0)**: The contents of the D2D render target will be copied to the DC.
- **D2D1_DC_INITIALIZE_MODE_CLEAR (1)**: The contents of the DC will be cleared.
- **D2D1_DC_INITIALIZE_MODE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when retrieving a device context from a render target to specify how the device context should be initialized.

### Debug Level

Indicates the debug level to be output by the debug layer.

```autohotkey
; No debug output
debugLevel := D2D1Enums.DEBUG_LEVEL.D2D1_DEBUG_LEVEL_NONE

; Error messages only
debugLevel := D2D1Enums.DEBUG_LEVEL.D2D1_DEBUG_LEVEL_ERROR

; Warning and error messages
debugLevel := D2D1Enums.DEBUG_LEVEL.D2D1_DEBUG_LEVEL_WARNING

; Information, warning, and error messages
debugLevel := D2D1Enums.DEBUG_LEVEL.D2D1_DEBUG_LEVEL_INFORMATION
```

**Technical Details**:
- **D2D1_DEBUG_LEVEL_NONE (0)**: No debug output.
- **D2D1_DEBUG_LEVEL_ERROR (1)**: Error messages only.
- **D2D1_DEBUG_LEVEL_WARNING (2)**: Warning and error messages.
- **D2D1_DEBUG_LEVEL_INFORMATION (3)**: Information, warning, and error messages.
- **D2D1_DEBUG_LEVEL_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating a Direct2D factory to specify the debug output level.

### Factory Type

Specifies the threading model of the created factory and all of its derived resources.

```autohotkey
; Single-threaded
factoryType := D2D1Enums.FACTORY_TYPE.D2D1_FACTORY_TYPE_SINGLE_THREADED

; Multi-threaded
factoryType := D2D1Enums.FACTORY_TYPE.D2D1_FACTORY_TYPE_MULTI_THREADED
```

**Technical Details**:
- **D2D1_FACTORY_TYPE_SINGLE_THREADED (0)**: The resulting factory and derived resources may only be invoked serially. Reference counts on resources are interlocked, however, resource and render target state is not protected from multi-threaded access.
- **D2D1_FACTORY_TYPE_MULTI_THREADED (1)**: The resulting factory may be invoked from multiple threads. Returned resources use interlocked reference counting and their state is protected.
- **D2D1_FACTORY_TYPE_FORCE_DWORD (0xffffffff)**: Used to ensure the enum is 32-bit.

**Usage Context**: These values are used when creating a Direct2D factory to specify the threading model.

## Practical Examples

### Example 1: Creating a Dashed Line

```autohotkey
; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Dashed Line Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a stroke style with dashed line
strokeProps := D2D1Structs.D2D1_STROKE_STYLE_PROPERTIES(
    D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND,  ; Start cap
    D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND,  ; End cap
    D2D1Enums.CAP_STYLE.D2D1_CAP_STYLE_ROUND,  ; Dash cap
    D2D1Enums.LINE_JOIN.D2D1_LINE_JOIN_ROUND,  ; Line join
    10,                                         ; Miter limit
    D2D1Enums.DASH_STYLE.D2D1_DASH_STYLE_DASH, ; Dash style
    0                                           ; Dash offset
)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw a dashed line
d2d.drawLine(100, 100, 700, 500, 0x000000, 5, strokeProps)

; End drawing
d2d.endDraw()
```

### Example 2: Creating a Radial Gradient with Extend Mode

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

; Create radial gradient properties
radialGradientProps := D2D1Structs.D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES(
    400, 300,  ; Center
    0, 0,      ; Offset
    200, 200   ; Radius
)

; Create bitmap brush properties with wrap extend mode
bitmapBrushProps := D2D1Structs.D2D1_BITMAP_BRUSH_PROPERTIES(
    D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_WRAP,
    D2D1Enums.EXTEND_MODE.D2D1_EXTEND_MODE_WRAP
)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw a rectangle filled with the gradient
d2d.fillRectangle(0, 0, 800, 600, gradientStops)

; End drawing
d2d.endDraw()
```

### Example 3: Creating a Path with Different Fill Modes

```autohotkey
; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Fill Mode Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a path geometry with alternate fill mode
pathGeometry1 := d2d.createPathGeometry(D2D1Enums.FILL_MODE.D2D1_FILL_MODE_ALTERNATE)

; Create a path geometry with winding fill mode
pathGeometry2 := d2d.createPathGeometry(D2D1Enums.FILL_MODE.D2D1_FILL_MODE_WINDING)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw the path geometries
d2d.fillGeometry(pathGeometry1, 0xFF0000)
d2d.fillGeometry(pathGeometry2, 0x0000FF)

; End drawing
d2d.endDraw()
```

## Technical Reference

### Enumeration Implementation

The enumerations in `D2D1Enums.ahk` are implemented as nested classes with static properties. This approach provides several benefits:

1. **Namespace isolation**: Prevents naming conflicts with other code
2. **Logical grouping**: Related enumerations are grouped together
3. **IntelliSense support**: Enables code completion in supporting editors
4. **Documentation integration**: Allows for structured documentation

Here's an example of how an enumeration is implemented:

```autohotkey
class D2D1Enums {
    class EXTEND_MODE {
        static D2D1_EXTEND_MODE_CLAMP := 0
        static D2D1_EXTEND_MODE_WRAP := 1
        static D2D1_EXTEND_MODE_MIRROR := 2
        static D2D1_EXTEND_MODE_FORCE_DWORD := 0xffffffff
    }
}
```

### Direct2D API Integration

The enumerations in `D2D1Enums.ahk` are designed to be compatible with the Direct2D API. They follow the same naming conventions and values as the original C++ enumerations, making it easier to understand the Direct2D documentation and apply it to AutoHotkey.

For example, the `D2D1_EXTEND_MODE` enumeration in C++ is defined as:

```cpp
typedef enum D2D1_EXTEND_MODE {
    D2D1_EXTEND_MODE_CLAMP = 0,
    D2D1_EXTEND_MODE_WRAP = 1,
    D2D1_EXTEND_MODE_MIRROR = 2,
    D2D1_EXTEND_MODE_FORCE_DWORD = 0xffffffff
} D2D1_EXTEND_MODE;
```

And the corresponding AutoHotkey implementation is:

```autohotkey
class EXTEND_MODE {
    static D2D1_EXTEND_MODE_CLAMP := 0
    static D2D1_EXTEND_MODE_WRAP := 1
    static D2D1_EXTEND_MODE_MIRROR := 2
    static D2D1_EXTEND_MODE_FORCE_DWORD := 0xffffffff
}
```

### Performance Considerations

Using enumerations instead of magic numbers has a negligible performance impact, but provides significant benefits in terms of code readability and maintainability. The enumerations are implemented as static properties, which are resolved at compile time and do not incur any runtime overhead.

## Conclusion

The `D2D1Enums.ahk` file provides a comprehensive mapping of Direct2D enumerations for use with the Direct2D wrapper in AutoHotkey v2. By using these enumerations instead of magic numbers, you can make your code more readable, maintainable, and less prone to errors.

The examples in this document demonstrate common usage patterns, but there are many more possibilities. Experiment with different combinations of enumerations to create rich, interactive graphics in your applications.