using Claymore
using GLMakie

"""
    measure_text_glmakie(text::Claymore.ClayString, config::Claymore.TextElementConfig, userData)

Measure text using GLMakie's text extent functionality.
"""
function measure_text_glmakie(text::Claymore.ClayString, config::Claymore.TextElementConfig, userData)
    # Use Makie's text_bb to get accurate text dimensions
    # text_bb returns a HyperRectangle with origin and widths
    bb = Makie.text_bb(text.chars, to_font("default"), Float64(config.fontSize))
    width = Float32(bb.widths[1])
    height = Float32(bb.widths[2])
    return Claymore.Dimensions(width, height)
end

"""
    render_clay_to_glmakie(commands::Vector{Claymore.RenderCommand}, fig::Figure, ax::Axis)

Render Claymore layout commands to a GLMakie figure.
"""
function render_clay_to_glmakie(commands::Vector{Claymore.RenderCommand})
    fig = Figure(size = (1200, 900), backgroundcolor = :white)
    ax = Axis(fig[1, 1], aspect = DataAspect())

    # Hide axis decorations for UI rendering
    hidedecorations!(ax)
    hidespines!(ax)

    # Calculate screen height for Y-axis flip
    screen_height = isempty(commands) ? 0f0 : maximum(cmd.boundingBox.y + cmd.boundingBox.height for cmd in commands)

    # Render each command
    for cmd in commands
        bb = cmd.boundingBox

        if cmd.commandType == Claymore.RENDER_COMMAND_TYPE_RECTANGLE
            # Render filled rectangle
            data = cmd.renderData
            color = RGBAf(data.backgroundColor.r, data.backgroundColor.g,
                         data.backgroundColor.b, data.backgroundColor.a)

            # Create rectangle polygon
            x = bb.x
            # Flip Y-axis: Claymore uses top-left origin, GLMakie uses bottom-left
            y = screen_height - bb.y - bb.height
            w = bb.width
            h = bb.height

            rect = Rect2f(x, y, w, h)

            poly!(ax, rect, color = color, strokewidth = 0)

            # Add rounded corners if specified
            if data.cornerRadius.topLeft > 0 || data.cornerRadius.topRight > 0 ||
               data.cornerRadius.bottomLeft > 0 || data.cornerRadius.bottomRight > 0
                # For now, skip rounded corners in basic renderer
                # Could be implemented with custom shapes
            end

        elseif cmd.commandType == Claymore.RENDER_COMMAND_TYPE_TEXT
            # Render text
            data = cmd.renderData
            color = RGBAf(data.textColor.r, data.textColor.g,
                         data.textColor.b, data.textColor.a)

            # Flip Y-axis for text
            # Text baseline should be at the bottom of the bounding box
            y_flipped = screen_height - bb.y - bb.height

            text!(ax, bb.x, y_flipped,
                  text = data.stringContents.chars,
                  fontsize = data.fontSize,
                  color = color,
                  align = (:left, :bottom))

        elseif cmd.commandType == Claymore.RENDER_COMMAND_TYPE_BORDER
            # Render border
            data = cmd.renderData
            color = RGBAf(data.color.r, data.color.g, data.color.b, data.color.a)

            x = bb.x
            # Flip Y-axis for border
            y = screen_height - bb.y - bb.height
            w = bb.width
            h = bb.height

            # Draw border lines
            if data.width.left > 0
                lines!(ax, [x, x], [y, y + h], color = color, linewidth = data.width.left)
            end
            if data.width.right > 0
                lines!(ax, [x + w, x + w], [y, y + h], color = color, linewidth = data.width.right)
            end
            if data.width.top > 0
                lines!(ax, [x, x + w], [y + h, y + h], color = color, linewidth = data.width.top)
            end
            if data.width.bottom > 0
                lines!(ax, [x, x + w], [y, y], color = color, linewidth = data.width.bottom)
            end
        end
    end

    # Set axis limits to match layout dimensions
    if !isempty(commands)
        max_x = maximum(cmd.boundingBox.x + cmd.boundingBox.width for cmd in commands)
        limits!(ax, 0, max_x, 0, screen_height)
    end

    return fig
end
