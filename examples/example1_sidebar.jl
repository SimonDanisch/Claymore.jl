using Clay
using GLMakie

include("glmakie_renderer.jl")

# Example 1: Sidebar Layout
println("\n" * "=" ^ 70)
println("Example 1: Sidebar Layout")
println("=" ^ 70)

# Initialize Clay
dims = Clay.Dimensions(1000f0, 700f0)
Clay.initialize(dims)
Clay.set_measure_text_function!(measure_text_glmakie, nothing)

# Define text styles
heading_style = Clay.TextElementConfig(
    Clay.Color(1f0, 1f0, 1f0, 1f0),  # White
    UInt16(0), UInt16(20), UInt16(0), UInt16(24),
    Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
)

body_style = Clay.TextElementConfig(
    Clay.Color(0.2f0, 0.2f0, 0.2f0, 1f0),  # Dark gray
    UInt16(0), UInt16(14), UInt16(0), UInt16(18),
    Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
)

# Build layout
Clay.begin_layout()

# Root container
Clay.open_element(UInt32(1))
root = Clay.CURRENT_CONTEXT[].currentElement
root.backgroundColor = Clay.Color(0.95f0, 0.95f0, 0.95f0, 1f0)
Clay.configure_element(Clay.LayoutConfig(
    Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_GROW()),
    Clay.CLAY_PADDING_ALL(0), 0,
    Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
    Clay.LEFT_TO_RIGHT
))

    # Sidebar - 20% width
    Clay.open_element(UInt32(10))
    sidebar = Clay.CURRENT_CONTEXT[].currentElement
    sidebar.backgroundColor = Clay.Color(0.2f0, 0.3f0, 0.5f0, 1f0)
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.2), Clay.CLAY_SIZING_GROW()),
        Clay.CLAY_PADDING_ALL(20), 15,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.TOP_TO_BOTTOM
    ))

        Clay.open_text_element("Navigation", heading_style)

        # Menu items
        for (i, item) in enumerate(["Home", "Projects", "About", "Contact"])
            Clay.open_element(UInt32(100 + i))
            menu_item = Clay.CURRENT_CONTEXT[].currentElement
            menu_item.backgroundColor = Clay.Color(0.25f0, 0.35f0, 0.55f0, 1f0)
            menu_item.cornerRadius = Clay.CLAY_CORNER_RADIUS(4)
            Clay.configure_element(Clay.LayoutConfig(
                Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(35)),
                Clay.CLAY_PADDING_ALL(10), 0,
                Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_CENTER),
                Clay.LEFT_TO_RIGHT
            ))
            Clay.close_element()
        end

    Clay.close_element()

    # Main content - 80% width
    Clay.open_element(UInt32(20))
    content = Clay.CURRENT_CONTEXT[].currentElement
    content.backgroundColor = Clay.Color(1f0, 1f0, 1f0, 1f0)
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.8), Clay.CLAY_SIZING_GROW()),
        Clay.CLAY_PADDING_ALL(30), 20,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.TOP_TO_BOTTOM
    ))

        Clay.open_text_element("Welcome to Clay.jl", Clay.TextElementConfig(
            Clay.Color(0.1f0, 0.1f0, 0.1f0, 1f0),
            UInt16(0), UInt16(32), UInt16(0), UInt16(38),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
        ))

        Clay.open_text_element("A high-performance layout library for Julia", body_style)

        # Content cards
        Clay.open_element(UInt32(30))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(150)),
            Clay.CLAY_PADDING_ALL(0), 20,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))

            for i in 1:3
                Clay.open_element(UInt32(300 + i))
                card = Clay.CURRENT_CONTEXT[].currentElement
                card.backgroundColor = Clay.Color(0.9f0, 0.95f0, 1f0, 1f0)
                card.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
                card.borderConfig = Clay.BorderElementConfig(
                    Clay.Color(0.6f0, 0.7f0, 0.9f0, 1f0),
                    Clay.BorderWidth(2, 2, 2, 2, 0)
                )
                Clay.configure_element(Clay.LayoutConfig(
                    Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.32), Clay.CLAY_SIZING_GROW()),
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
