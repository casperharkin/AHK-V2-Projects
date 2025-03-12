;==================================================================================================================
; Direct2D Enumerations
;==================================================================================================================
; Description:    Complete mapping of Direct2D enumerations for use with the Direct2D wrapper.
;                 This file contains all enumerations from the d2d1.h.c header file.
;
; Features:       - Comprehensive mapping of all Direct2D enumerations
;                 - Organized in a structured way using nested classes
;                 - Documented with descriptions from the original header file
;
; Usage:          Include this file in your Direct2D wrapper:
;                 #Include "D2D1Enums.ahk"
;
; Dependencies:   - None
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   12/03/2025
;==================================================================================================================

class D2D1Enums {
    ; ==================== Interpolation Mode Definitions ====================
    ; This defines the superset of interpolation mode supported by D2D APIs and built-in effects
    class INTERPOLATION_MODE_DEFINITION {
        static NEAREST_NEIGHBOR := 0
        static LINEAR := 1
        static CUBIC := 2
        static MULTI_SAMPLE_LINEAR := 3
        static ANISOTROPIC := 4
        static HIGH_QUALITY_CUBIC := 5
        static FANT := 6
        static MIPMAP_LINEAR := 7
    }

    ; ==================== Gamma ====================
    ; This determines what gamma is used for interpolation/blending
    class GAMMA {
        ; Colors are manipulated in 2.2 gamma color space
        static D2D1_GAMMA_2_2 := 0
        
        ; Colors are manipulated in 1.0 gamma color space
        static D2D1_GAMMA_1_0 := 1
        
        static D2D1_GAMMA_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Opacity Mask Content ====================
    ; Specifies what the contents are of an opacity mask
    class OPACITY_MASK_CONTENT {
        ; The mask contains geometries or bitmaps
        static D2D1_OPACITY_MASK_CONTENT_GRAPHICS := 0
        
        ; The mask contains text rendered using one of the natural text modes
        static D2D1_OPACITY_MASK_CONTENT_TEXT_NATURAL := 1
        
        ; The mask contains text rendered using one of the GDI compatible text modes
        static D2D1_OPACITY_MASK_CONTENT_TEXT_GDI_COMPATIBLE := 2
        
        static D2D1_OPACITY_MASK_CONTENT_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Extend Mode ====================
    ; Enum which describes how to sample from a source outside its base tile
    class EXTEND_MODE {
        ; Extend the edges of the source out by clamping sample points outside the source to the edges
        static D2D1_EXTEND_MODE_CLAMP := 0
        
        ; The base tile is drawn untransformed and the remainder are filled by repeating the base tile
        static D2D1_EXTEND_MODE_WRAP := 1
        
        ; The same as wrap, but alternate tiles are flipped. The base tile is drawn untransformed
        static D2D1_EXTEND_MODE_MIRROR := 2
        
        static D2D1_EXTEND_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Antialias Mode ====================
    ; Enum which describes the manner in which we render edges of non-text primitives
    class ANTIALIAS_MODE {
        ; The edges of each primitive are antialiased sequentially
        static D2D1_ANTIALIAS_MODE_PER_PRIMITIVE := 0
        
        ; Each pixel is rendered if its pixel center is contained by the geometry
        static D2D1_ANTIALIAS_MODE_ALIASED := 1
        
        static D2D1_ANTIALIAS_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Text Antialias Mode ====================
    ; Describes the antialiasing mode used for drawing text
    class TEXT_ANTIALIAS_MODE {
        ; Render text using the current system setting
        static D2D1_TEXT_ANTIALIAS_MODE_DEFAULT := 0
        
        ; Render text using ClearType
        static D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE := 1
        
        ; Render text using gray-scale
        static D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE := 2
        
        ; Render text aliased
        static D2D1_TEXT_ANTIALIAS_MODE_ALIASED := 3
        
        static D2D1_TEXT_ANTIALIAS_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Bitmap Interpolation Mode ====================
    ; Specifies the algorithm that is used when images are scaled or rotated
    class BITMAP_INTERPOLATION_MODE {
        ; Nearest Neighbor filtering. Also known as nearest pixel or nearest point sampling
        static D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR := D2D1Enums.INTERPOLATION_MODE_DEFINITION.NEAREST_NEIGHBOR
        
        ; Linear filtering
        static D2D1_BITMAP_INTERPOLATION_MODE_LINEAR := D2D1Enums.INTERPOLATION_MODE_DEFINITION.LINEAR
        
        static D2D1_BITMAP_INTERPOLATION_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Draw Text Options ====================
    ; Modifications made to the draw text call that influence how the text is rendered
    class DRAW_TEXT_OPTIONS {
        ; Do not snap the baseline of the text vertically
        static D2D1_DRAW_TEXT_OPTIONS_NO_SNAP := 0x00000001
        
        ; Clip the text to the content bounds
        static D2D1_DRAW_TEXT_OPTIONS_CLIP := 0x00000002
        
        ; Render color versions of glyphs if defined by the font
        static D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT := 0x00000004
        
        ; Bitmap origins of color glyph bitmaps are not snapped
        static D2D1_DRAW_TEXT_OPTIONS_DISABLE_COLOR_BITMAP_SNAPPING := 0x00000008
        
        static D2D1_DRAW_TEXT_OPTIONS_NONE := 0x00000000
        
        static D2D1_DRAW_TEXT_OPTIONS_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Arc Size ====================
    ; Differentiates which of the two possible arcs could match the given arc parameters
    class ARC_SIZE {
        static D2D1_ARC_SIZE_SMALL := 0
        static D2D1_ARC_SIZE_LARGE := 1
        static D2D1_ARC_SIZE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Cap Style ====================
    ; Enum which describes the drawing of the ends of a line
    class CAP_STYLE {
        ; Flat line cap
        static D2D1_CAP_STYLE_FLAT := 0
        
        ; Square line cap
        static D2D1_CAP_STYLE_SQUARE := 1
        
        ; Round line cap
        static D2D1_CAP_STYLE_ROUND := 2
        
        ; Triangle line cap
        static D2D1_CAP_STYLE_TRIANGLE := 3
        
        static D2D1_CAP_STYLE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Dash Style ====================
    ; Describes the sequence of dashes and gaps in a stroke
    class DASH_STYLE {
        static D2D1_DASH_STYLE_SOLID := 0
        static D2D1_DASH_STYLE_DASH := 1
        static D2D1_DASH_STYLE_DOT := 2
        static D2D1_DASH_STYLE_DASH_DOT := 3
        static D2D1_DASH_STYLE_DASH_DOT_DOT := 4
        static D2D1_DASH_STYLE_CUSTOM := 5
        static D2D1_DASH_STYLE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Line Join ====================
    ; Enum which describes the drawing of the corners on the line
    class LINE_JOIN {
        ; Miter join
        static D2D1_LINE_JOIN_MITER := 0
        
        ; Bevel join
        static D2D1_LINE_JOIN_BEVEL := 1
        
        ; Round join
        static D2D1_LINE_JOIN_ROUND := 2
        
        ; Miter/Bevel join
        static D2D1_LINE_JOIN_MITER_OR_BEVEL := 3
        
        static D2D1_LINE_JOIN_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Combine Mode ====================
    ; This enumeration describes the type of combine operation to be performed
    class COMBINE_MODE {
        ; Produce a geometry representing the set of points contained in either the first or the second geometry
        static D2D1_COMBINE_MODE_UNION := 0
        
        ; Produce a geometry representing the set of points common to the first and the second geometries
        static D2D1_COMBINE_MODE_INTERSECT := 1
        
        ; Produce a geometry representing the set of points contained in the first geometry or the second geometry, but not both
        static D2D1_COMBINE_MODE_XOR := 2
        
        ; Produce a geometry representing the set of points contained in the first geometry but not the second geometry
        static D2D1_COMBINE_MODE_EXCLUDE := 3
        
        static D2D1_COMBINE_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Geometry Relation ====================
    ; Describes how one geometry object is spatially related to another geometry object
    class GEOMETRY_RELATION {
        ; The relation between the geometries couldn't be determined. This value is never returned by any D2D method
        static D2D1_GEOMETRY_RELATION_UNKNOWN := 0
        
        ; The two geometries do not intersect at all
        static D2D1_GEOMETRY_RELATION_DISJOINT := 1
        
        ; The passed in geometry is entirely contained by the object
        static D2D1_GEOMETRY_RELATION_IS_CONTAINED := 2
        
        ; The object entirely contains the passed in geometry
        static D2D1_GEOMETRY_RELATION_CONTAINS := 3
        
        ; The two geometries overlap but neither completely contains the other
        static D2D1_GEOMETRY_RELATION_OVERLAP := 4
        
        static D2D1_GEOMETRY_RELATION_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Geometry Simplification Option ====================
    ; Specifies how simple the output of a simplified geometry sink should be
    class GEOMETRY_SIMPLIFICATION_OPTION {
        static D2D1_GEOMETRY_SIMPLIFICATION_OPTION_CUBICS_AND_LINES := 0
        static D2D1_GEOMETRY_SIMPLIFICATION_OPTION_LINES := 1
        static D2D1_GEOMETRY_SIMPLIFICATION_OPTION_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Figure Begin ====================
    ; Indicates whether the given figure is filled or hollow
    class FIGURE_BEGIN {
        static D2D1_FIGURE_BEGIN_FILLED := 0
        static D2D1_FIGURE_BEGIN_HOLLOW := 1
        static D2D1_FIGURE_BEGIN_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Figure End ====================
    ; Indicates whether the figure is open or closed on its end point
    class FIGURE_END {
        static D2D1_FIGURE_END_OPEN := 0
        static D2D1_FIGURE_END_CLOSED := 1
        static D2D1_FIGURE_END_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Path Segment ====================
    ; Indicates whether the given segment should be stroked, or, if the join between this segment and the previous one should be smooth
    class PATH_SEGMENT {
        static D2D1_PATH_SEGMENT_NONE := 0x00000000
        static D2D1_PATH_SEGMENT_FORCE_UNSTROKED := 0x00000001
        static D2D1_PATH_SEGMENT_FORCE_ROUND_LINE_JOIN := 0x00000002
        static D2D1_PATH_SEGMENT_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Sweep Direction ====================
    ; Defines the direction that an elliptical arc is drawn
    class SWEEP_DIRECTION {
        static D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE := 0
        static D2D1_SWEEP_DIRECTION_CLOCKWISE := 1
        static D2D1_SWEEP_DIRECTION_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Fill Mode ====================
    ; Specifies how the intersecting areas of geometries or figures are combined to form the area of the composite geometry
    class FILL_MODE {
        static D2D1_FILL_MODE_ALTERNATE := 0
        static D2D1_FILL_MODE_WINDING := 1
        static D2D1_FILL_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Layer Options ====================
    ; Specified options that can be applied when a layer resource is applied to create a layer
    class LAYER_OPTIONS {
        static D2D1_LAYER_OPTIONS_NONE := 0x00000000
        
        ; The layer will render correctly for ClearType text. If the render target was set to ClearType previously, the layer will continue to render ClearType. If the render target was set to ClearType and this option is not specified, the render target will be set to render gray-scale until the layer is popped. The caller can override this default by calling SetTextAntialiasMode while within the layer. This flag is slightly slower than the default.
        static D2D1_LAYER_OPTIONS_INITIALIZE_FOR_CLEARTYPE := 0x00000001
        
        static D2D1_LAYER_OPTIONS_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Window State ====================
    ; Describes whether a window is occluded
    class WINDOW_STATE {
        static D2D1_WINDOW_STATE_NONE := 0x0000000
        static D2D1_WINDOW_STATE_OCCLUDED := 0x0000001
        static D2D1_WINDOW_STATE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Render Target Type ====================
    ; Describes whether a render target uses hardware or software rendering, or if Direct2D should select the rendering mode
    class RENDER_TARGET_TYPE {
        ; D2D is free to choose the render target type for the caller
        static D2D1_RENDER_TARGET_TYPE_DEFAULT := 0
        
        ; The render target will render using the CPU
        static D2D1_RENDER_TARGET_TYPE_SOFTWARE := 1
        
        ; The render target will render using the GPU
        static D2D1_RENDER_TARGET_TYPE_HARDWARE := 2
        
        static D2D1_RENDER_TARGET_TYPE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Feature Level ====================
    ; Describes the minimum DirectX support required for hardware rendering by a render target
    class FEATURE_LEVEL {
        ; The caller does not require a particular underlying D3D device level
        static D2D1_FEATURE_LEVEL_DEFAULT := 0
        
        ; The D3D device level is DX9 compatible
        static D2D1_FEATURE_LEVEL_9 := 0x9100
        
        ; The D3D device level is DX10 compatible
        static D2D1_FEATURE_LEVEL_10 := 0xa000
        
        static D2D1_FEATURE_LEVEL_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Render Target Usage ====================
    ; Describes how a render target is remoted and whether it should be GDI-compatible
    class RENDER_TARGET_USAGE {
        static D2D1_RENDER_TARGET_USAGE_NONE := 0x00000000
        
        ; Rendering will occur locally, if a terminal-services session is established, the bitmap updates will be sent to the terminal services client
        static D2D1_RENDER_TARGET_USAGE_FORCE_BITMAP_REMOTING := 0x00000001
        
        ; The render target will allow a call to GetDC on the ID2D1GdiInteropRenderTarget interface. Rendering will also occur locally
        static D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE := 0x00000002
        
        static D2D1_RENDER_TARGET_USAGE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Present Options ====================
    ; Describes how present should behave
    class PRESENT_OPTIONS {
        static D2D1_PRESENT_OPTIONS_NONE := 0x00000000
        
        ; Keep the target contents intact through present
        static D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS := 0x00000001
        
        ; Do not wait for display refresh to commit changes to display
        static D2D1_PRESENT_OPTIONS_IMMEDIATELY := 0x00000002
        
        static D2D1_PRESENT_OPTIONS_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Compatible Render Target Options ====================
    ; Specifies additional features supportable by a compatible render target when it is created
    class COMPATIBLE_RENDER_TARGET_OPTIONS {
        static D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE := 0x00000000
        
        ; The compatible render target will allow a call to GetDC on the ID2D1GdiInteropRenderTarget interface. This can be specified even if the parent render target is not GDI compatible
        static D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_GDI_COMPATIBLE := 0x00000001
        
        static D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_FORCE_DWORD := 0xffffffff
    }

    ; ==================== DC Initialize Mode ====================
    ; Specifies how a device context is initialized for GDI rendering when it is retrieved from the render target
    class DC_INITIALIZE_MODE {
        ; The contents of the D2D render target will be copied to the DC
        static D2D1_DC_INITIALIZE_MODE_COPY := 0
        
        ; The contents of the DC will be cleared
        static D2D1_DC_INITIALIZE_MODE_CLEAR := 1
        
        static D2D1_DC_INITIALIZE_MODE_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Debug Level ====================
    ; Indicates the debug level to be output by the debug layer
    class DEBUG_LEVEL {
        static D2D1_DEBUG_LEVEL_NONE := 0
        static D2D1_DEBUG_LEVEL_ERROR := 1
        static D2D1_DEBUG_LEVEL_WARNING := 2
        static D2D1_DEBUG_LEVEL_INFORMATION := 3
        static D2D1_DEBUG_LEVEL_FORCE_DWORD := 0xffffffff
    }

    ; ==================== Factory Type ====================
    ; Specifies the threading model of the created factory and all of its derived resources
    class FACTORY_TYPE {
        ; The resulting factory and derived resources may only be invoked serially. Reference counts on resources are interlocked, however, resource and render target state is not protected from multi-threaded access
        static D2D1_FACTORY_TYPE_SINGLE_THREADED := 0
        
        ; The resulting factory may be invoked from multiple threads. Returned resources use interlocked reference counting and their state is protected
        static D2D1_FACTORY_TYPE_MULTI_THREADED := 1
        
        static D2D1_FACTORY_TYPE_FORCE_DWORD := 0xffffffff
    }
}