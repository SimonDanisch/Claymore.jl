using Clay
using GLMakie

include("glmakie_renderer.jl")

# Example 2: Dashboard Layout
println("\n" * "=" ^ 70)
println("Example 2: Dashboard Layout")
println("=" ^ 70)

# Initialize Clay
dims = Clay.Dimensions(1200f0, 800f0)
Clay.initialize(dims)
Clay.set_measure_text_function!(measure_text_glmakie, nothing)

# Build layout
Clay.begin_layout()

# Root container
Clay.open_element(UInt32(1))
root = Clay.CURRENT_CONTEXT[].currentElement
root.backgroundColor = Clay.Color(0.98f0, 0.98f0, 0.98f0, 1f0)
Clay.configure_element(Clay.LayoutConfig(
    Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_GROW()),
    Clay.CLAY_PADDING_ALL(20), 15,
    Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
    Clay.TOP_TO_BOTTOM
))

    # Header
    Clay.open_element(UInt32(10))
    header = Clay.CURRENT_CONTEXT[].currentElement
    header.backgroundColor = Clay.Color(0.15f0, 0.25f0, 0.45f0, 1f0)
    header.cornerRadius = Clay.CLAY_CORNER_RADIUS(6)
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(60)),
        Clay.CLAY_PADDING_ALL(20), 0,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_CENTER),
        Clay.LEFT_TO_RIGHT
    ))

        Clay.open_text_element("Dashboard", Clay.TextElementConfig(
            Clay.Color(1f0, 1f0, 1f0, 1f0),
            UInt16(0), UInt16(24), UInt16(0), UInt16(28),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
        ))

    Clay.close_element()

    # Metrics row - 4 equal cards
    Clay.open_element(UInt32(20))
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(120)),
        Clay.CLAY_PADDING_ALL(0), 15,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))

        colors = [
            Clay.Color(0.2f0, 0.6f0, 0.9f0, 1f0),  # Blue
            Clay.Color(0.3f0, 0.8f0, 0.4f0, 1f0),  # Green
            Clay.Color(0.9f0, 0.6f0, 0.2f0, 1f0),  # Orange
            Clay.Color(0.8f0, 0.3f0, 0.5f0, 1f0),  # Pink
        ]

        for i in 1:4
            Clay.open_element(UInt32(100 + i))
            card = Clay.CURRENT_CONTEXT[].currentElement
            card.backgroundColor = colors[i]
            card.cornerRadius = Clay.CLAY_CORNER_RADIUS(6)
            Clay.configure_element(Clay.LayoutConfig(
                Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.24), Clay.CLAY_SIZING_GROW()),
                Clay.CLAY_PADDING_ALL(15), 0,
                Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
                Clay.TOP_TO_BOTTOM
            ))
            Clay.close_element()
        end

    Clay.close_element()

    # Charts row
    Clay.open_element(UInt32(30))
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_GROW()),
        Clay.CLAY_PADDING_ALL(0), 15,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))

        # Large chart - 60%
        Clay.open_element(UInt32(200))
        chart1 = Clay.CURRENT_CONTEXT[].currentElement
        chart1.backgroundColor = Clay.Color(1f0, 1f0, 1f0, 1f0)
        chart1.cornerRadius = Clay.CLAY_CORNER_RADIUS(6)
        chart1.borderConfig = Clay.BorderElementConfig(
            Clay.Color(0.85f0, 0.85f0, 0.85f0, 1f0),
            Clay.BorderWidth(1, 1, 1, 1, 0)
        )
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.6), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(20), 0,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.TOP_TO_BOTTOM
        ))

            Clay.open_text_element("Main Chart", Clay.TextElementConfig(
                Clay.Color(0.2f0, 0.2f0, 0.2f0, 1f0),
                UInt16(0), UInt16(18), UInt16(0), UInt16(22),
                Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
            ))

        Clay.close_element()

        # Side panel - 40%
        Clay.open_element(UInt32(210))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.4), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(0), 15,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.TOP_TO_BOTTOM
        ))

            # Two stacked panels
            for i in 1:2
                Clay.open_element(UInt32(300 + i))
                panel = Clay.CURRENT_CONTEXT[].currentElement
                panel.backgroundColor = Clay.Color(1f0, 1f0, 1f0, 1f0)
                panel.cornerRadius = Clay.CLAY_CORNER_RADIUS(6)
                panel.borderConfig = Clay.BorderElementConfig(
                    Clay.Color(0.85f0, 0.85f0, 0.85f0, 1f0),
                    Clay.BorderWidth(1, 1, 1, 1, 0)
                )
                Clay.configure_element(Clay.LayoutConfig(
                    Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_PERCENT(0.48)),
                    Clay.CLAY_PADDING_ALL(15), 0,
                    Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
                    Clay.TOP_TO_BOTTOM
                ))
                Clay.close_element()
            end

        Clay.close_element()

    Clay.close_element()

Clay.close_element()

# Generate layout
commands = Clay.end_layout()

println("\n✓ Layout generated: $(length(commands)) render commands")

# Render with GLMakie
println("✓ Rendering with GLMakie...")
fig = render_clay_to_glmakie(commands)

println("✓ Done! Displaying figure...")
display(fig)

fig
