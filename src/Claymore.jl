module Claymore

# Core data structures translated from clay.h

# Utility Structs
struct ClayString
    chars::String
    ClayString(s::String) = new(s)
end

Base.length(s::ClayString) = length(s.chars)

# Element ID system for identifying elements
struct ElementId
    id::UInt32
    offset::UInt32
    baseId::UInt32
    stringId::ClayString

    ElementId(id::UInt32) = new(id, 0, 0, ClayString(""))
    ElementId(id::UInt32, offset::UInt32, baseId::UInt32, str::ClayString) =
        new(id, offset, baseId, str)
end

# Simple FNV-1a hash for strings
function hash_string(str::ClayString, seed::UInt32=UInt32(0))::ElementId
    hash = UInt32(2166136261) ⊻ seed
    for c in str.chars
        hash = (hash ⊻ UInt32(c)) * UInt32(16777619)
    end
    ElementId(hash, 0, seed, str)
end

function hash_string_with_offset(str::ClayString, offset::UInt32, seed::UInt32=UInt32(0))::ElementId
    hash = UInt32(2166136261) ⊻ seed
    for c in str.chars
        hash = (hash ⊻ UInt32(c)) * UInt32(16777619)
    end
    hash = (hash ⊻ offset) * UInt32(16777619)
    ElementId(hash, offset, seed, str)
end

# Dimensions and spatial types
struct Dimensions
    width::Float32
    height::Float32
end

struct Vector2
    x::Float32
    y::Float32
end

struct Color
    r::Float32
    g::Float32
    b::Float32
    a::Float32
end

struct BoundingBox
    x::Float32
    y::Float32
    width::Float32
    height::Float32
end

struct CornerRadius
    topLeft::Float32
    topRight::Float32
    bottomLeft::Float32
    bottomRight::Float32
end

# Layout enums
@enum LayoutDirection::UInt8 begin
    LEFT_TO_RIGHT = 0
    TOP_TO_BOTTOM = 1
end

@enum LayoutAlignmentX::UInt8 begin
    ALIGN_X_LEFT = 0
    ALIGN_X_RIGHT = 1
    ALIGN_X_CENTER = 2
end

@enum LayoutAlignmentY::UInt8 begin
    ALIGN_Y_TOP = 0
    ALIGN_Y_BOTTOM = 1
    ALIGN_Y_CENTER = 2
end

@enum SizingType::UInt8 begin
    SIZING_TYPE_FIT = 0
    SIZING_TYPE_GROW = 1
    SIZING_TYPE_PERCENT = 2
    SIZING_TYPE_FIXED = 3
end

struct ChildAlignment
    x::LayoutAlignmentX
    y::LayoutAlignmentY
end

struct SizingMinMax
    min::Float32
    max::Float32
end

struct SizingAxis
    minMax::SizingMinMax
    percent::Float32
    type::SizingType

    # Constructors for different sizing modes
    SizingAxis(::Type{Val{:fit}}, min=0f0, max=Inf32) =
        new(SizingMinMax(min, max), 0f0, SIZING_TYPE_FIT)
    SizingAxis(::Type{Val{:grow}}, min=0f0, max=Inf32) =
        new(SizingMinMax(min, max), 0f0, SIZING_TYPE_GROW)
    SizingAxis(::Type{Val{:fixed}}, size::Float32) =
        new(SizingMinMax(size, size), 0f0, SIZING_TYPE_FIXED)
    SizingAxis(::Type{Val{:percent}}, pct::Float32) =
        new(SizingMinMax(0f0, Inf32), pct, SIZING_TYPE_PERCENT)
end

struct Sizing
    width::SizingAxis
    height::SizingAxis
end

struct Padding
    left::UInt16
    right::UInt16
    top::UInt16
    bottom::UInt16
end

struct LayoutConfig
    sizing::Sizing
    padding::Padding
    childGap::UInt16
    childAlignment::ChildAlignment
    layoutDirection::LayoutDirection
end

# Text configuration
@enum TextWrapMode::UInt8 begin
    TEXT_WRAP_WORDS = 0
    TEXT_WRAP_NEWLINES = 1
    TEXT_WRAP_NONE = 2
end

@enum TextAlignment::UInt8 begin
    TEXT_ALIGN_LEFT = 0
    TEXT_ALIGN_CENTER = 1
    TEXT_ALIGN_RIGHT = 2
end

struct TextElementConfig
    textColor::Color
    fontId::UInt16
    fontSize::UInt16
    letterSpacing::UInt16
    lineHeight::UInt16
    wrapMode::TextWrapMode
    textAlignment::TextAlignment
end

# Aspect Ratio configuration
struct AspectRatioElementConfig
    aspectRatio::Float32  # width / height
end

# Image configuration
struct ImageElementConfig
    imageData::Any  # Pointer/reference to image data
end

# Custom configuration
struct CustomElementConfig
    customData::Any  # Pointer/reference to custom data
end

# Clip/Scroll configuration
struct ClipElementConfig
    horizontal::Bool
    vertical::Bool
    childOffset::Vector2  # For scrolling
end

# Floating configuration
@enum FloatingAttachPointType::UInt8 begin
    ATTACH_POINT_LEFT_TOP = 0
    ATTACH_POINT_LEFT_CENTER = 1
    ATTACH_POINT_LEFT_BOTTOM = 2
    ATTACH_POINT_CENTER_TOP = 3
    ATTACH_POINT_CENTER_CENTER = 4
    ATTACH_POINT_CENTER_BOTTOM = 5
    ATTACH_POINT_RIGHT_TOP = 6
    ATTACH_POINT_RIGHT_CENTER = 7
    ATTACH_POINT_RIGHT_BOTTOM = 8
end

struct FloatingAttachPoints
    element::FloatingAttachPointType
    parent::FloatingAttachPointType
end

@enum PointerCaptureMode::UInt8 begin
    POINTER_CAPTURE_MODE_CAPTURE = 0
    POINTER_CAPTURE_MODE_PASSTHROUGH = 1
end

@enum FloatingAttachToElement::UInt8 begin
    ATTACH_TO_NONE = 0
    ATTACH_TO_PARENT = 1
    ATTACH_TO_ELEMENT_WITH_ID = 2
    ATTACH_TO_ROOT = 3
end

struct FloatingElementConfig
    offset::Vector2
    expand::Dimensions
    parentId::UInt32
    zIndex::Int16
    attachPoints::FloatingAttachPoints
    pointerCaptureMode::PointerCaptureMode
    attachTo::FloatingAttachToElement
end

# Border configuration
struct BorderWidth
    left::UInt16
    right::UInt16
    top::UInt16
    bottom::UInt16
    betweenChildren::UInt16
end

struct BorderElementConfig
    color::Color
    width::BorderWidth
end

# Render command types
@enum RenderCommandType::UInt8 begin
    RENDER_COMMAND_TYPE_NONE = 0
    RENDER_COMMAND_TYPE_RECTANGLE = 1
    RENDER_COMMAND_TYPE_BORDER = 2
    RENDER_COMMAND_TYPE_TEXT = 3
    RENDER_COMMAND_TYPE_IMAGE = 4
    RENDER_COMMAND_TYPE_SCISSOR_START = 5
    RENDER_COMMAND_TYPE_SCISSOR_END = 6
    RENDER_COMMAND_TYPE_CUSTOM = 7
end

struct RectangleRenderData
    backgroundColor::Color
    cornerRadius::CornerRadius
end

struct TextRenderData
    stringContents::ClayString
    textColor::Color
    fontId::UInt16
    fontSize::UInt16
    letterSpacing::UInt16
    lineHeight::UInt16
end

struct BorderRenderData
    color::Color
    cornerRadius::CornerRadius
    width::BorderWidth
end

struct RenderCommand
    boundingBox::BoundingBox
    renderData::Union{RectangleRenderData, TextRenderData, BorderRenderData, Nothing}
    id::UInt32
    zIndex::Int16
    commandType::RenderCommandType
end

# Element types
@enum ElementType::UInt8 begin
    ELEMENT_TYPE_CONTAINER = 0
    ELEMENT_TYPE_TEXT = 1
    ELEMENT_TYPE_IMAGE = 2
    ELEMENT_TYPE_CUSTOM = 3
end

# Element and layout management
mutable struct Element
    id::UInt32
    elementType::ElementType
    children::Vector{Element}

    # Layout config
    config::LayoutConfig
    backgroundColor::Color
    cornerRadius::CornerRadius

    # Element-specific configs
    textConfig::Union{TextElementConfig, Nothing}
    textContent::Union{ClayString, Nothing}
    imageConfig::Union{ImageElementConfig, Nothing}
    aspectRatioConfig::Union{AspectRatioElementConfig, Nothing}
    customConfig::Union{CustomElementConfig, Nothing}
    floatingConfig::Union{FloatingElementConfig, Nothing}
    borderConfig::Union{BorderElementConfig, Nothing}
    clipConfig::Union{ClipElementConfig, Nothing}

    # Computed layout
    boundingBox::BoundingBox

    Element(id::UInt32) = new(
        id,
        ELEMENT_TYPE_CONTAINER,
        Element[],
        LayoutConfig(
            Sizing(SizingAxis(Val{:fit}), SizingAxis(Val{:fit})),
            Padding(0, 0, 0, 0),
            0,
            ChildAlignment(ALIGN_X_LEFT, ALIGN_Y_TOP),
            LEFT_TO_RIGHT
        ),
        Color(0f0, 0f0, 0f0, 0f0),
        CornerRadius(0f0, 0f0, 0f0, 0f0),
        nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing,
        BoundingBox(0f0, 0f0, 0f0, 0f0)
    )
end

# Text measurement callback type
const MeasureTextFunction = Union{Function, Nothing}

# Context for layout state
mutable struct Context
    rootElement::Union{Element, Nothing}
    currentElement::Union{Element, Nothing}
    elementStack::Vector{Element}
    renderCommands::Vector{RenderCommand}
    dimensions::Dimensions
    nextId::UInt32

    # Text measurement
    measureTextFn::MeasureTextFunction
    measureTextUserData::Any

    Context(dims::Dimensions) = new(
        nothing, nothing, Element[], RenderCommand[], dims, UInt32(1),
        nothing, nothing
    )
end

# Global context
const CURRENT_CONTEXT = Ref{Union{Context, Nothing}}(nothing)

# Helper constructors with convenient defaults
CLAY_SIZING_FIT(min=0f0, max=Inf32) = SizingAxis(Val{:fit}, min, max)
CLAY_SIZING_GROW(min=0f0, max=Inf32) = SizingAxis(Val{:grow}, min, max)
CLAY_SIZING_FIXED(size::Real) = SizingAxis(Val{:fixed}, Float32(size))
CLAY_SIZING_PERCENT(pct::Real) = SizingAxis(Val{:percent}, Float32(pct))

CLAY_PADDING_ALL(padding::Integer) = Padding(padding, padding, padding, padding)

CLAY_CORNER_RADIUS(radius::Real) = CornerRadius(radius, radius, radius, radius)

# Core API functions
function initialize(dims::Dimensions)
    ctx = Context(dims)
    CURRENT_CONTEXT[] = ctx
    return ctx
end

function begin_layout()
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized. Call initialize() first.")

    # Reset for new layout
    ctx.rootElement = Element(UInt32(0))
    ctx.currentElement = ctx.rootElement
    ctx.elementStack = [ctx.rootElement]
    empty!(ctx.renderCommands)
    ctx.nextId = UInt32(1)
end

function open_element(id::UInt32)
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized")

    elem = Element(id)
    push!(ctx.currentElement.children, elem)
    push!(ctx.elementStack, elem)
    ctx.currentElement = elem
    return elem
end

function close_element()
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized")

    pop!(ctx.elementStack)
    if !isempty(ctx.elementStack)
        ctx.currentElement = ctx.elementStack[end]
    end
end

function configure_element(config::LayoutConfig)
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized")
    ctx.currentElement.config = config
end

function open_text_element(text::String, textConfig::TextElementConfig)
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized")

    elem = Element(ctx.nextId)
    ctx.nextId += UInt32(1)

    elem.elementType = ELEMENT_TYPE_TEXT
    elem.textContent = ClayString(text)
    elem.textConfig = textConfig

    push!(ctx.currentElement.children, elem)
    return elem
end

function set_measure_text_function!(fn::Function, userData=nothing)
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized")
    ctx.measureTextFn = fn
    ctx.measureTextUserData = userData
end

function measure_text(text::ClayString, config::TextElementConfig)
    ctx = CURRENT_CONTEXT[]
    if !isnothing(ctx.measureTextFn)
        return ctx.measureTextFn(text, config, ctx.measureTextUserData)
    else
        # Fallback: simple monospace approximation
        return Dimensions(Float32(length(text) * config.fontSize * 0.6), Float32(config.fontSize))
    end
end

function layout_element!(elem::Element, x::Float32, y::Float32, availWidth::Float32, availHeight::Float32)
    cfg = elem.config

    # Handle text elements specially
    if elem.elementType == ELEMENT_TYPE_TEXT && !isnothing(elem.textContent) && !isnothing(elem.textConfig)
        dims = measure_text(elem.textContent, elem.textConfig)
        elem.boundingBox = BoundingBox(x, y, dims.width, dims.height)
        return
    end

    # Calculate width first (may need to prelayout children for FIT)
    local width::Float32
    if cfg.sizing.width.type == SIZING_TYPE_FIXED
        width = cfg.sizing.width.minMax.min
    elseif cfg.sizing.width.type == SIZING_TYPE_GROW
        width = availWidth
    elseif cfg.sizing.width.type == SIZING_TYPE_PERCENT
        width = availWidth * cfg.sizing.width.percent
    else
        # FIT - need to measure children first
        childX = x + cfg.padding.left
        childY = y + cfg.padding.top
        prelayoutAvailWidth = availWidth - cfg.padding.left - cfg.padding.right
        prelayoutAvailHeight = availHeight - cfg.padding.top - cfg.padding.bottom

        for child in elem.children
            layout_element!(child, childX, childY, prelayoutAvailWidth, prelayoutAvailHeight)
            if cfg.layoutDirection == LEFT_TO_RIGHT
                childX += child.boundingBox.width + cfg.childGap
            else
                childY += child.boundingBox.height + cfg.childGap
            end
        end

        width = Float32(cfg.padding.left + cfg.padding.right)
        if cfg.layoutDirection == LEFT_TO_RIGHT
            width += sum(c.boundingBox.width for c in elem.children; init=0f0)
            width += cfg.childGap * max(0, length(elem.children) - 1)
        else
            width += maximum((c.boundingBox.width for c in elem.children); init=0f0)
        end
    end

    # Calculate height (may need to prelayout children for FIT)
    local height::Float32
    if cfg.sizing.height.type == SIZING_TYPE_FIXED
        height = cfg.sizing.height.minMax.min
    elseif cfg.sizing.height.type == SIZING_TYPE_GROW
        height = availHeight
    elseif cfg.sizing.height.type == SIZING_TYPE_PERCENT
        height = availHeight * cfg.sizing.height.percent
    else
        # FIT - need to measure children if not already done
        if cfg.sizing.width.type != SIZING_TYPE_FIT
            # Children weren't measured yet for width, measure them now
            childX = x + cfg.padding.left
            childY = y + cfg.padding.top
            prelayoutAvailWidth = availWidth - cfg.padding.left - cfg.padding.right
            prelayoutAvailHeight = availHeight - cfg.padding.top - cfg.padding.bottom

            for child in elem.children
                layout_element!(child, childX, childY, prelayoutAvailWidth, prelayoutAvailHeight)
                if cfg.layoutDirection == LEFT_TO_RIGHT
                    childX += child.boundingBox.width + cfg.childGap
                else
                    childY += child.boundingBox.height + cfg.childGap
                end
            end
        end

        height = Float32(cfg.padding.top + cfg.padding.bottom)
        if cfg.layoutDirection == TOP_TO_BOTTOM
            height += sum(c.boundingBox.height for c in elem.children; init=0f0)
            height += cfg.childGap * max(0, length(elem.children) - 1)
        else
            height += maximum((c.boundingBox.height for c in elem.children); init=0f0)
        end
    end

    # Apply aspect ratio constraint if present
    if !isnothing(elem.aspectRatioConfig)
        targetRatio = elem.aspectRatioConfig.aspectRatio
        currentRatio = width / height
        if currentRatio > targetRatio
            # Too wide, constrain width
            width = height * targetRatio
        else
            # Too tall, constrain height
            height = width / targetRatio
        end
    end

    # Apply min/max constraints
    width = clamp(width, cfg.sizing.width.minMax.min, cfg.sizing.width.minMax.max)
    height = clamp(height, cfg.sizing.height.minMax.min, cfg.sizing.height.minMax.max)

    elem.boundingBox = BoundingBox(x, y, width, height)

    # Second pass: layout children with correct parent dimensions
    childX = x + cfg.padding.left
    childY = y + cfg.padding.top

    availWidth = width - cfg.padding.left - cfg.padding.right
    availHeight = height - cfg.padding.top - cfg.padding.bottom

    for child in elem.children
        # Calculate child position first
        local cX::Float32 = childX
        local cY::Float32 = childY

        layout_element!(child, cX, cY, availWidth, availHeight)

        # Apply alignment after layout
        if cfg.layoutDirection == LEFT_TO_RIGHT
            # Vertical alignment for horizontal layout
            if cfg.childAlignment.y == ALIGN_Y_CENTER
                cY = childY + (availHeight - child.boundingBox.height) / 2
            elseif cfg.childAlignment.y == ALIGN_Y_BOTTOM
                cY = childY + availHeight - child.boundingBox.height
            end
            # Update child position
            child.boundingBox = BoundingBox(cX, cY, child.boundingBox.width, child.boundingBox.height)
            childX += child.boundingBox.width + cfg.childGap
        else
            # Horizontal alignment for vertical layout
            if cfg.childAlignment.x == ALIGN_X_CENTER
                cX = childX + (availWidth - child.boundingBox.width) / 2
            elseif cfg.childAlignment.x == ALIGN_X_RIGHT
                cX = childX + availWidth - child.boundingBox.width
            end
            # Update child position
            child.boundingBox = BoundingBox(cX, cY, child.boundingBox.width, child.boundingBox.height)
            childY += child.boundingBox.height + cfg.childGap
        end
    end
end

function end_layout()
    ctx = CURRENT_CONTEXT[]
    isnothing(ctx) && error("Clay not initialized")

    # Perform layout calculation
    if !isnothing(ctx.rootElement)
        layout_element!(ctx.rootElement, 0f0, 0f0, ctx.dimensions.width, ctx.dimensions.height)

        # Generate render commands
        generate_render_commands!(ctx.rootElement, ctx.renderCommands)
    end

    return ctx.renderCommands
end

function generate_render_commands!(elem::Element, commands::Vector{RenderCommand})
    # Generate background rectangle if backgroundColor is set
    if elem.backgroundColor.a > 0f0
        cmd = RenderCommand(
            elem.boundingBox,
            RectangleRenderData(elem.backgroundColor, elem.cornerRadius),
            elem.id,
            0,
            RENDER_COMMAND_TYPE_RECTANGLE
        )
        push!(commands, cmd)
    end

    # Generate element-specific commands
    if elem.elementType == ELEMENT_TYPE_TEXT && !isnothing(elem.textContent) && !isnothing(elem.textConfig)
        cmd = RenderCommand(
            elem.boundingBox,
            TextRenderData(
                elem.textContent,
                elem.textConfig.textColor,
                elem.textConfig.fontId,
                elem.textConfig.fontSize,
                elem.textConfig.letterSpacing,
                elem.textConfig.lineHeight
            ),
            elem.id,
            0,
            RENDER_COMMAND_TYPE_TEXT
        )
        push!(commands, cmd)
    end

    # Generate border command if border is configured
    if !isnothing(elem.borderConfig)
        cmd = RenderCommand(
            elem.boundingBox,
            BorderRenderData(
                elem.borderConfig.color,
                elem.cornerRadius,
                elem.borderConfig.width
            ),
            elem.id,
            0,
            RENDER_COMMAND_TYPE_BORDER
        )
        push!(commands, cmd)
    end

    # Recursively generate commands for children
    for child in elem.children
        generate_render_commands!(child, commands)
    end
end

# Export public API
export Dimensions, Vector2, Color, BoundingBox, CornerRadius
export ClayString, ElementId, hash_string, hash_string_with_offset
export LayoutDirection, LEFT_TO_RIGHT, TOP_TO_BOTTOM
export LayoutAlignmentX, ALIGN_X_LEFT, ALIGN_X_RIGHT, ALIGN_X_CENTER
export LayoutAlignmentY, ALIGN_Y_TOP, ALIGN_Y_BOTTOM, ALIGN_Y_CENTER
export SizingType, SIZING_TYPE_FIT, SIZING_TYPE_GROW, SIZING_TYPE_FIXED, SIZING_TYPE_PERCENT
export ChildAlignment, SizingAxis, Sizing, Padding, LayoutConfig
export TextWrapMode, TextAlignment, TextElementConfig
export AspectRatioElementConfig, ImageElementConfig, CustomElementConfig, ClipElementConfig
export BorderWidth, BorderElementConfig
export FloatingAttachPointType, FloatingAttachPoints, FloatingElementConfig
export PointerCaptureMode, FloatingAttachToElement
export RenderCommandType, RenderCommand, RectangleRenderData, TextRenderData, BorderRenderData
export ElementType, ELEMENT_TYPE_CONTAINER, ELEMENT_TYPE_TEXT, ELEMENT_TYPE_IMAGE, ELEMENT_TYPE_CUSTOM
export Element, Context
export CLAY_SIZING_FIT, CLAY_SIZING_GROW, CLAY_SIZING_FIXED, CLAY_SIZING_PERCENT
export CLAY_PADDING_ALL, CLAY_CORNER_RADIUS
export initialize, begin_layout, open_element, close_element, configure_element, end_layout
export open_text_element, set_measure_text_function!

end # module
