using Clay
using GLMakie
using Bonito
using Hyperscript

include("glmakie_renderer.jl")

# Example 5: Bonito DOM integration with Clay layout and GLMakie rendering
#
# This prototype demonstrates:
# 1. Creating UI with Bonito's DOM API (DOM.div, DOM.button, etc.)
# 2. Attaching Julia callbacks to interactive elements (onClick, onChange)
# 3. Converting DOM tree to Clay layout automatically
# 4. Rendering with GLMakie, using native Makie widgets (Button, Slider)
# 5. Connecting callbacks: on(julia_callback, button.clicks)
#
# The flow:
#   Bonito DOM → Clay Layout Engine → GLMakie Rendering + Native Widgets
println("\n" * "=" ^ 70)
println("Example 5: Bonito DOM → Clay Layout → GLMakie Rendering")
println("=" ^ 70)

# Colors
const BG_COLOR = Clay.Color(0.95, 0.95, 0.97, 1.0)
const CARD_COLOR = Clay.Color(1.0, 1.0, 1.0, 1.0)
const PRIMARY_COLOR = Clay.Color(0.2, 0.5, 0.8, 1.0)
const TEXT_COLOR = Clay.Color(0.1, 0.1, 0.1, 1.0)

# Create callbacks
counter = Ref(0)
slider_value = Ref(50)

function increment_counter(clicks)
    counter[] += 1
    println("Button clicked! Counter: $(counter[]) (click #$clicks)")
end

function slider_changed(val)
    slider_value[] = round(Int, val)
    println("Slider changed to: $(slider_value[])")
end

# Create DOM structure with Julia callbacks using Bonito Styles
# The outer div has horizontal cards layout
dom = DOM.div(
    DOM.h1("Interactive Dashboard",
        style=Styles("font-size" => "32px", "color" => "#333", "background-color" => "#3b82f6")),
    DOM.div(
        DOM.div(
            style=Styles("background-color" => "white", "padding" => "16px"),
            DOM.h2("Counter Demo",
                style=Styles("font-size" => "24px")),
            DOM.p("Click the button to increment the counter",
                style=Styles("font-size" => "16px")),
            DOM.button("Click Me!", onClick=increment_counter,
                style=Styles("background-color" => "#3b82f6")),
            DOM.p("Count: 0", id="counter",
                style=Styles("font-size" => "20px", "font-weight" => "bold"))
        ),
        DOM.div(
            style=Styles("background-color" => "white", "padding" => "16px"),
            DOM.h2("Slider Control",
                style=Styles("font-size" => "24px")),
            DOM.p("Adjust the value:",
                style=Styles("font-size" => "16px")),
            DOM.input(type="range", min="0", max="100", value="50", onChange=slider_changed)
        )
    )
)
App(dom)

println("\n✓ DOM structure created")
println("  Root: $(typeof(dom))")

# Registry to store widget callbacks and metadata
struct WidgetInfo
    id::UInt32
    type::Symbol  # :button, :slider, etc.
    callback::Union{Function, Nothing}
    label::String
    attrs::Dict{Symbol, Any}
end

widget_registry = WidgetInfo[]

# Helper to get color from Bonito Styles
function get_color_from_styles(styles::Dict, property::String, default::Clay.Color)
    if !haskey(styles, property)
        return default
    end

    color_str = string(styles[property])

    # Parse hex color #RGB or #RRGGBB
    if startswith(color_str, "#")
        hex = color_str[2:end]
        if length(hex) == 3
            r, g, b = parse(UInt8, hex[1:1], base=16) * 17, parse(UInt8, hex[2:2], base=16) * 17, parse(UInt8, hex[3:3], base=16) * 17
            return Clay.Color(r/255, g/255, b/255, 1.0)
        elseif length(hex) == 6
            r, g, b = parse(UInt8, hex[1:2], base=16), parse(UInt8, hex[3:4], base=16), parse(UInt8, hex[5:6], base=16)
            return Clay.Color(r/255, g/255, b/255, 1.0)
        end
    end

    return default
end

function get_font_size_from_styles(styles::Dict, default::UInt16)
    if !haskey(styles, "font-size")
        return default
    end

    fs_str = string(styles["font-size"])
    m = match(r"(\d+)px", fs_str)
    isnothing(m) ? default : parse(UInt16, m.captures[1])
end

# Convert DOM to Clay layout
function dom_to_clay(node, id_counter::Ref{UInt32}, registry::Vector{WidgetInfo})
    # Skip non-Node elements (like strings)
    if !(node isa Hyperscript.Node)
        return
    end

    id = id_counter[]
    id_counter[] += 1

    Clay.open_element(id)
    elem = Clay.CURRENT_CONTEXT[].currentElement

    tag = getfield(node, :tag)
    children = getfield(node, :children)
    attrs = getfield(node, :attrs)

    # Extract style attribute (Bonito Styles object)
    styles = if haskey(attrs, "style")
        style_val = attrs["style"]
        if style_val isa Bonito.Styles
            # Bonito Styles stores CSS under empty string key
            css = get(style_val.styles, "", nothing)
            if !isnothing(css)
                css.attributes  # Get the actual style attributes Dict
            else
                Dict{String, Any}()
            end
        elseif style_val isa Dict
            style_val
        else
            Dict{String, Any}()
        end
    else
        Dict{String, Any}()
    end

    # Extract text content and styling from DOM node
    if tag == "h1"
        # Large header - get colors and font size from Bonito Styles
        text_color = get_color_from_styles(styles, "color", Clay.Color(1.0, 1.0, 1.0, 1.0))
        font_size = get_font_size_from_styles(styles, UInt16(28))
        bg_color = get_color_from_styles(styles, "background-color", PRIMARY_COLOR)

        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIT()),
            Clay.CLAY_PADDING_ALL(16),
            8,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        elem.backgroundColor = bg_color

        # Add text
        text_content = string(first(children))
        Clay.open_text_element(text_content, Clay.TextElementConfig(
            text_color, UInt16(0), font_size, UInt16(0), font_size + UInt16(4),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
        ))

    elseif tag == "h2"
        # Medium header - get colors and font size from Bonito Styles
        text_color = get_color_from_styles(styles, "color", TEXT_COLOR)
        font_size = get_font_size_from_styles(styles, UInt16(20))
        bg_color = get_color_from_styles(styles, "background-color", CARD_COLOR)

        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIT()),
            Clay.CLAY_PADDING_ALL(12),
            4,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        elem.backgroundColor = bg_color

        text_content = string(first(children))
        Clay.open_text_element(text_content, Clay.TextElementConfig(
            text_color, UInt16(0), font_size, UInt16(0), font_size + UInt16(4),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
        ))

    elseif tag == "p"
        # Paragraph - get colors and font size from Bonito Styles
        text_color = get_color_from_styles(styles, "color", TEXT_COLOR)
        font_size = get_font_size_from_styles(styles, UInt16(14))
        bg_color = get_color_from_styles(styles, "background-color", Clay.Color(0.0, 0.0, 0.0, 0.0))

        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIT()),
            Clay.CLAY_PADDING_ALL(8),
            4,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        elem.backgroundColor = bg_color

        text_content = string(first(children))
        Clay.open_text_element(text_content, Clay.TextElementConfig(
            text_color, UInt16(0), font_size, UInt16(0), font_size + UInt16(4),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
        ))

    elseif tag == "button"
        # Button - will be rendered as GLMakie button later
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_FIXED(150), Clay.CLAY_SIZING_FIXED(40)),
            Clay.CLAY_PADDING_ALL(8),
            4,
            Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
            Clay.LEFT_TO_RIGHT
        ))
        elem.backgroundColor = PRIMARY_COLOR

        text_content = string(first(children))

        # Extract onClick callback (Bonito converts to "on-click")
        callback = get(attrs, "on-click", get(attrs, "onClick", nothing))
        push!(registry, WidgetInfo(id, :button, callback, text_content, Dict{Symbol, Any}(Symbol(k) => v for (k, v) in attrs)))

        Clay.open_text_element(text_content, Clay.TextElementConfig(
            Clay.Color(1.0, 1.0, 1.0, 1.0), UInt16(0), UInt16(14), UInt16(0), UInt16(18),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
        ))

    elseif tag == "input"
        # Input (slider) - will be rendered as GLMakie slider
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_FIXED(200), Clay.CLAY_SIZING_FIXED(30)),
            Clay.CLAY_PADDING_ALL(8),
            4,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_CENTER),
            Clay.LEFT_TO_RIGHT
        ))
        elem.backgroundColor = CARD_COLOR

        # Extract onChange callback (Bonito converts to "on-change")
        callback = get(attrs, "on-change", get(attrs, "onChange", nothing))
        push!(registry, WidgetInfo(id, :slider, callback, "", Dict{Symbol, Any}(Symbol(k) => v for (k, v) in attrs)))

    elseif tag == "div"
        # Container div - extract layout direction and styling from Bonito Styles
        flex_direction = get(styles, "flex-direction", "column")
        layout_direction = (flex_direction == "row") ? Clay.LEFT_TO_RIGHT : Clay.TOP_TO_BOTTOM

        bg_color = get_color_from_styles(styles, "background-color", Clay.Color(0.0, 0.0, 0.0, 0.0))

        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIT()),
            Clay.CLAY_PADDING_ALL(16),
            12,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            layout_direction
        ))
        elem.backgroundColor = bg_color

        # Process children
        if !isempty(children)
            for child in children
                dom_to_clay(child, id_counter, registry)
            end
        end
    end

    Clay.close_element()
end

# Initialize Clay
screenWidth = 800f0
screenHeight = 600f0
dims = Clay.Dimensions(screenWidth, screenHeight)
Clay.initialize(dims)
Clay.set_measure_text_function!(measure_text_glmakie, nothing)

# Layout the DOM
Clay.begin_layout()

# Root container
Clay.open_element(UInt32(0))
root = Clay.CURRENT_CONTEXT[].currentElement
root.backgroundColor = BG_COLOR
Clay.configure_element(Clay.LayoutConfig(
    Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_GROW()),
    Clay.CLAY_PADDING_ALL(20),
    16,
    Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
    Clay.TOP_TO_BOTTOM
))

# Convert DOM tree to Clay layout
id_counter = Ref{UInt32}(1)
dom_to_clay(dom, id_counter, widget_registry)

Clay.close_element()

renderCommands = Clay.end_layout()

println("\n✓ Layout generated: $(length(renderCommands)) render commands")
println("  Screen: $(Int(screenWidth))×$(Int(screenHeight))")
println("  Elements created: $(id_counter[] - 1)")

# Enhanced renderer with widget support and reactive layout on resize
function render_clay_with_widgets_v2(commands::Vector{Clay.RenderCommand}, registry::Vector{WidgetInfo}, dom_node)
    fig = Figure(size = (Int(screenWidth), Int(screenHeight)), backgroundcolor = :white)

    # Track widgets and plots for interactivity and repositioning
    widgets = Dict{UInt32, Any}()
    plots = Dict{UInt32, Any}()  # Map element ID -> Makie plot object

    # Create a mapping from element ID to render commands
    cmd_by_id = Dict{UInt32, Vector{Clay.RenderCommand}}()
    for cmd in commands
        if !haskey(cmd_by_id, cmd.id)
            cmd_by_id[cmd.id] = []
        end
        push!(cmd_by_id[cmd.id], cmd)
    end

    # Create a set of widget element IDs to skip rendering
    widget_ids = Set(w.id for w in registry)

    scene = fig.scene

    # Function to relayout and update positions
    function update_layout!(new_width, new_height)
        # Re-run Clay layout with new dimensions
        Clay.initialize(Clay.Dimensions(Float32(new_width), Float32(new_height)))
        Clay.set_measure_text_function!(measure_text_glmakie, nothing)

        Clay.begin_layout()
        Clay.open_element(UInt32(0))
        root = Clay.CURRENT_CONTEXT[].currentElement
        root.backgroundColor = BG_COLOR
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(20),
            16,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.TOP_TO_BOTTOM
        ))

        id_counter_local = Ref{UInt32}(1)
        widget_registry_local = WidgetInfo[]
        dom_to_clay(dom_node, id_counter_local, widget_registry_local)

        Clay.close_element()
        new_commands = Clay.end_layout()

        new_screen_height = isempty(new_commands) ? 0f0 : maximum(cmd.boundingBox.y + cmd.boundingBox.height for cmd in new_commands)

        # Update plot positions
        for cmd in new_commands
            if haskey(plots, cmd.id)
                plot_obj = plots[cmd.id]
                bb = cmd.boundingBox

                # Check type to determine how to update
                if plot_obj isa Observable
                    # Rectangle - update observable
                    x = bb.x
                    y = new_screen_height - bb.y - bb.height
                    plot_obj[] = Rect2f(x, y, bb.width, bb.height)
                else
                    # Text plot - use update!
                    y_flipped = new_screen_height - bb.y - bb.height
                    update!(plot_obj; position=(bb.x, y_flipped))
                end
            end
        end

        # Update widget positions
        new_cmd_by_id = Dict{UInt32, Vector{Clay.RenderCommand}}()
        for cmd in new_commands
            if !haskey(new_cmd_by_id, cmd.id)
                new_cmd_by_id[cmd.id] = []
            end
            push!(new_cmd_by_id[cmd.id], cmd)
        end

        for widget_info in registry
            if haskey(widgets, widget_info.id) && haskey(new_cmd_by_id, widget_info.id)
                widget = widgets[widget_info.id]
                cmds = new_cmd_by_id[widget_info.id]

                rect_cmd_idx = findfirst(c -> c.commandType == Clay.RENDER_COMMAND_TYPE_RECTANGLE, cmds)
                if !isnothing(rect_cmd_idx)
                    rect_cmd = cmds[rect_cmd_idx]
                    bb = rect_cmd.boundingBox
                    y_flipped = new_screen_height - bb.y - bb.height

                    widget.layoutobservables.suggestedbbox[] = BBox(bb.x, bb.x + bb.width, y_flipped, y_flipped + bb.height)
                end
            end
        end
    end

    # Initial layout
    screen_height = isempty(commands) ? 0f0 : maximum(cmd.boundingBox.y + cmd.boundingBox.height for cmd in commands)

    # First pass: render rectangles and text directly into fig.scene
    # Skip rendering elements that will become widgets
    for cmd in commands
        bb = cmd.boundingBox

        # Skip rendering for widget elements
        if cmd.id in widget_ids
            continue
        end

        if cmd.commandType == Clay.RENDER_COMMAND_TYPE_RECTANGLE
            data = cmd.renderData
            color = RGBAf(data.backgroundColor.r, data.backgroundColor.g,
                         data.backgroundColor.b, data.backgroundColor.a)

            x = bb.x
            y = screen_height - bb.y - bb.height
            w = bb.width
            h = bb.height

            rect_obs = Observable(Rect2f(x, y, w, h))
            plot_obj = poly!(scene, rect_obs, color = color, strokewidth = 0, space = :pixel)
            plots[cmd.id] = rect_obs

        elseif cmd.commandType == Clay.RENDER_COMMAND_TYPE_TEXT
            data = cmd.renderData
            color = RGBAf(data.textColor.r, data.textColor.g,
                         data.textColor.b, data.textColor.a)

            y_flipped = screen_height - bb.y - bb.height

            plot_obj = text!(scene, bb.x, y_flipped,
                  text = data.stringContents.chars,
                  fontsize = data.fontSize,
                  color = color,
                  align = (:left, :bottom),
                  space = :pixel)
            plots[cmd.id] = plot_obj
        end
    end

    # Second pass: create interactive widgets with absolute positioning
    for widget_info in registry
        if widget_info.type == :button && widget_info.callback !== nothing
            # Find the bounding box and styling for this widget
            if haskey(cmd_by_id, widget_info.id)
                cmds = cmd_by_id[widget_info.id]

                # Extract background rectangle command (not text)
                rect_cmd_idx = findfirst(c -> c.commandType == Clay.RENDER_COMMAND_TYPE_RECTANGLE, cmds)
                if isnothing(rect_cmd_idx)
                    continue
                end

                rect_cmd = cmds[rect_cmd_idx]
                bb = rect_cmd.boundingBox

                # Extract background color
                bg_color = let data = rect_cmd.renderData
                    RGBAf(data.backgroundColor.r, data.backgroundColor.g,
                          data.backgroundColor.b, data.backgroundColor.a)
                end

                # Convert Clay coordinates to Makie bbox (flip Y axis)
                y_flipped = screen_height - bb.y - bb.height

                # Create GLMakie Button with absolute positioning and styling
                btn = GLMakie.Button(fig,
                    label = widget_info.label,
                    width = bb.width,
                    height = bb.height,
                    bbox = BBox(bb.x, bb.x + bb.width, y_flipped, y_flipped + bb.height),
                    buttoncolor = bg_color)
                widgets[widget_info.id] = btn

                # Connect callback
                on(widget_info.callback, btn.clicks)

                println("  Created button '$(widget_info.label)' at ($(round(Int,bb.x)), $(round(Int,bb.y))) size $(round(Int,bb.width))×$(round(Int,bb.height))")
            end

        elseif widget_info.type == :slider && widget_info.callback !== nothing
            if haskey(cmd_by_id, widget_info.id)
                cmds = cmd_by_id[widget_info.id]

                # Extract background rectangle command (not text)
                rect_cmd_idx = findfirst(c -> c.commandType == Clay.RENDER_COMMAND_TYPE_RECTANGLE, cmds)
                if isnothing(rect_cmd_idx)
                    continue
                end

                rect_cmd = cmds[rect_cmd_idx]
                bb = rect_cmd.boundingBox

                # Extract slider parameters
                min_val = parse(Float64, get(widget_info.attrs, :min, "0"))
                max_val = parse(Float64, get(widget_info.attrs, :max, "100"))
                start_val = parse(Float64, get(widget_info.attrs, :value, "50"))

                # Convert Clay coordinates to Makie bbox (flip Y axis)
                y_flipped = screen_height - bb.y - bb.height

                # Create GLMakie Slider with absolute positioning and size
                sl = GLMakie.Slider(fig,
                    range = min_val:max_val,
                    startvalue = start_val,
                    width = bb.width,
                    height = bb.height,
                    bbox = BBox(bb.x, bb.x + bb.width, y_flipped, y_flipped + bb.height))
                widgets[widget_info.id] = sl

                # Connect callback
                on(widget_info.callback, sl.value)

                println("  Created slider [$min_val-$max_val] at ($(round(Int,bb.x)), $(round(Int,bb.y))) size $(round(Int,bb.width))×$(round(Int,bb.height))")
            end
        end
    end

    # Hook up viewport observer to update layout on resize
    on(scene.viewport) do viewport_rect
        new_width = viewport_rect.widths[1]
        new_height = viewport_rect.widths[2]
        update_layout!(new_width, new_height)
    end

    return fig, widgets
end

# Render
println("\n✓ Rendering with GLMakie...")
println("  Widgets found: $(length(widget_registry))")
fig, widgets = render_clay_with_widgets_v2(renderCommands, widget_registry, dom)

println("✓ Done! Displaying figure...")
println("\n📝 Bonito DOM → Clay Layout → GLMakie Demo:")
println("  • DOM structure with h1, h2, p, button, input elements")
println("  • Automatic layout with Clay")
println("  • Rendered with GLMakie")
println("  • $(length(widgets)) interactive widgets connected")
println("\n💡 Try clicking the button or moving the slider!")

display(fig)

fig
