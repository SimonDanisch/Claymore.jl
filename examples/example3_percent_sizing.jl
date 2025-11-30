using Clay
using GLMakie

include("glmakie_renderer.jl")

# Example 3: PERCENT Sizing Demo
println("\n" * "=" ^ 70)
println("Example 3: PERCENT Sizing Demo")
println("=" ^ 70)

# Initialize Clay
dims = Clay.Dimensions(1000f0, 600f0)
Clay.initialize(dims)
Clay.set_measure_text_function!(measure_text_glmakie, nothing)

# Build layout
Clay.begin_layout()

# Root container
Clay.open_element(UInt32(1))
root = Clay.CURRENT_CONTEXT[].currentElement
root.backgroundColor = Clay.Color(0.1f0, 0.1f0, 0.1f0, 1f0)
Clay.configure_element(Clay.LayoutConfig(
    Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_GROW()),
    Clay.CLAY_PADDING_ALL(30), 20,
    Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
    Clay.TOP_TO_BOTTOM
))

    # Title
    Clay.open_text_element("Proportional Layout Demo", Clay.TextElementConfig(
        Clay.Color(1f0, 1f0, 1f0, 1f0),
        UInt16(0), UInt16(28), UInt16(0), UInt16(34),
        Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
    ))

    # Row 1: 25% - 50% - 25%
    Clay.open_element(UInt32(10))
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(100)),
        Clay.CLAY_PADDING_ALL(0), 10,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))

        # 25%
        Clay.open_element(UInt32(101))
        elem = Clay.CURRENT_CONTEXT[].currentElement
        elem.backgroundColor = Clay.Color(0.8f0, 0.3f0, 0.3f0, 1f0)
        elem.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.25), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(10), 0,
            Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
            Clay.TOP_TO_BOTTOM
        ))

        Clay.open_text_element("25%", Clay.TextElementConfig(
            Clay.Color(1f0, 1f0, 1f0, 1f0),
            UInt16(0), UInt16(20), UInt16(0), UInt16(24),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
        ))

        Clay.close_element()

        # 50%
        Clay.open_element(UInt32(102))
        elem = Clay.CURRENT_CONTEXT[].currentElement
        elem.backgroundColor = Clay.Color(0.3f0, 0.7f0, 0.3f0, 1f0)
        elem.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.50), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(10), 0,
            Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
            Clay.TOP_TO_BOTTOM
        ))

        Clay.open_text_element("50%", Clay.TextElementConfig(
            Clay.Color(1f0, 1f0, 1f0, 1f0),
            UInt16(0), UInt16(20), UInt16(0), UInt16(24),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
        ))

        Clay.close_element()

        # 25%
        Clay.open_element(UInt32(103))
        elem = Clay.CURRENT_CONTEXT[].currentElement
        elem.backgroundColor = Clay.Color(0.3f0, 0.5f0, 0.9f0, 1f0)
        elem.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.25), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(10), 0,
            Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
            Clay.TOP_TO_BOTTOM
        ))

        Clay.open_text_element("25%", Clay.TextElementConfig(
            Clay.Color(1f0, 1f0, 1f0, 1f0),
            UInt16(0), UInt16(20), UInt16(0), UInt16(24),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
        ))

        Clay.close_element()

    Clay.close_element()

    # Row 2: 33% - 33% - 33%
    Clay.open_element(UInt32(20))
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(100)),
        Clay.CLAY_PADDING_ALL(0), 10,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))

        for i in 1:3
            Clay.open_element(UInt32(200 + i))
            elem = Clay.CURRENT_CONTEXT[].currentElement
            elem.backgroundColor = Clay.Color(0.6f0, 0.4f0 + i*0.1f0, 0.8f0, 1f0)
            elem.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
            Clay.configure_element(Clay.LayoutConfig(
                Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.333), Clay.CLAY_SIZING_GROW()),
                Clay.CLAY_PADDING_ALL(10), 0,
                Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
                Clay.TOP_TO_BOTTOM
            ))

            Clay.open_text_element("33%", Clay.TextElementConfig(
                Clay.Color(1f0, 1f0, 1f0, 1f0),
                UInt16(0), UInt16(20), UInt16(0), UInt16(24),
                Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
            ))

            Clay.close_element()
        end

    Clay.close_element()

    # Row 3: 70% - 30%
    Clay.open_element(UInt32(30))
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(Clay.CLAY_SIZING_GROW(), Clay.CLAY_SIZING_FIXED(100)),
        Clay.CLAY_PADDING_ALL(0), 10,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))

        # 70%
        Clay.open_element(UInt32(301))
        elem = Clay.CURRENT_CONTEXT[].currentElement
        elem.backgroundColor = Clay.Color(0.9f0, 0.6f0, 0.2f0, 1f0)
        elem.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.70), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(10), 0,
            Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
            Clay.TOP_TO_BOTTOM
        ))

        Clay.open_text_element("70%", Clay.TextElementConfig(
            Clay.Color(1f0, 1f0, 1f0, 1f0),
            UInt16(0), UInt16(20), UInt16(0), UInt16(24),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
        ))

        Clay.close_element()

        # 30%
        Clay.open_element(UInt32(302))
        elem = Clay.CURRENT_CONTEXT[].currentElement
        elem.backgroundColor = Clay.Color(0.2f0, 0.8f0, 0.8f0, 1f0)
        elem.cornerRadius = Clay.CLAY_CORNER_RADIUS(8)
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(Clay.CLAY_SIZING_PERCENT(0.30), Clay.CLAY_SIZING_GROW()),
            Clay.CLAY_PADDING_ALL(10), 0,
            Clay.ChildAlignment(Clay.ALIGN_X_CENTER, Clay.ALIGN_Y_CENTER),
            Clay.TOP_TO_BOTTOM
        ))

        Clay.open_text_element("30%", Clay.TextElementConfig(
            Clay.Color(1f0, 1f0, 1f0, 1f0),
            UInt16(0), UInt16(20), UInt16(0), UInt16(24),
            Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_CENTER
        ))

        Clay.close_element()

    Clay.close_element()

Clay.close_element()

# Generate layout
commands = Clay.end_layout()

println("\n✓ Layout generated: $(length(commands)) render commands")
println("✓ Demonstrating PERCENT sizing:")
println("  Row 1: 25% | 50% | 25%")
println("  Row 2: 33% | 33% | 33%")
println("  Row 3: 70% | 30%")

# Render with GLMakie
println("\n✓ Rendering with GLMakie...")
fig = render_clay_to_glmakie(commands)

println("✓ Done! Displaying figure...")
display(fig)

fig
