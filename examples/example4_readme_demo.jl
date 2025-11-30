using Clay
using GLMakie

include("glmakie_renderer.jl")

# Example 4: README Demo - Exact port of the C example
println("\n" * "=" ^ 70)
println("Example 4: README Demo (Clay C → Julia)")
println("=" ^ 70)

# Color constants from the C example
const COLOR_LIGHT = Clay.Color(224/255, 215/255, 210/255, 1.0)
const COLOR_RED = Clay.Color(168/255, 66/255, 28/255, 1.0)
const COLOR_ORANGE = Clay.Color(225/255, 138/255, 50/255, 1.0)
const COLOR_BACKGROUND = Clay.Color(250/255, 250/255, 255/255, 1.0)

# Initialize Clay
screenWidth = 1024f0
screenHeight = 768f0
dims = Clay.Dimensions(screenWidth, screenHeight)
Clay.initialize(dims)

# Use the measure_text_glmakie function from glmakie_renderer.jl
Clay.set_measure_text_function!(measure_text_glmakie, nothing)

# Text config helper
function text_config(fontSize, color)
    return Clay.TextElementConfig(
        color, UInt16(0), UInt16(fontSize), UInt16(0), UInt16(fontSize),
        Clay.TEXT_WRAP_WORDS, Clay.TEXT_ALIGN_LEFT
    )
end

# Reusable component: SidebarItem
function sidebar_item_component(id::UInt32)
    Clay.open_element(id)
    elem = Clay.CURRENT_CONTEXT[].currentElement
    elem.backgroundColor = COLOR_ORANGE
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(
            Clay.CLAY_SIZING_GROW(),
            Clay.CLAY_SIZING_FIXED(50)
        ),
        Clay.CLAY_PADDING_ALL(0),
        0,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))
    # Children would go here in a real app
    Clay.close_element()
end

# Begin layout
Clay.begin_layout()

# OuterContainer
Clay.open_element(UInt32(1))  # CLAY_ID("OuterContainer")
outer = Clay.CURRENT_CONTEXT[].currentElement
outer.backgroundColor = COLOR_BACKGROUND
Clay.configure_element(Clay.LayoutConfig(
    Clay.Sizing(
        Clay.CLAY_SIZING_GROW(),
        Clay.CLAY_SIZING_GROW()
    ),
    Clay.CLAY_PADDING_ALL(16),
    16,  # childGap
    Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
    Clay.LEFT_TO_RIGHT
))

    # SideBar
    Clay.open_element(UInt32(2))  # CLAY_ID("SideBar")
    sidebar = Clay.CURRENT_CONTEXT[].currentElement
    sidebar.backgroundColor = COLOR_LIGHT
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(
            Clay.CLAY_SIZING_FIXED(300),
            Clay.CLAY_SIZING_GROW()
        ),
        Clay.CLAY_PADDING_ALL(16),
        16,  # childGap
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.TOP_TO_BOTTOM  # layoutDirection
    ))

        # ProfilePictureOuter
        Clay.open_element(UInt32(3))  # CLAY_ID("ProfilePictureOuter")
        profile_outer = Clay.CURRENT_CONTEXT[].currentElement
        profile_outer.backgroundColor = COLOR_RED
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_GROW(),
                Clay.CLAY_SIZING_FIT()  # Will fit to contents
            ),
            Clay.CLAY_PADDING_ALL(16),
            16,  # childGap
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_CENTER),
            Clay.LEFT_TO_RIGHT
        ))

            # ProfilePicture (would be an image in real app)
            Clay.open_element(UInt32(4))  # CLAY_ID("ProfilePicture")
            profile_pic = Clay.CURRENT_CONTEXT[].currentElement
            profile_pic.backgroundColor = Clay.Color(0.5, 0.5, 0.5, 1.0)  # Gray placeholder
            Clay.configure_element(Clay.LayoutConfig(
                Clay.Sizing(
                    Clay.CLAY_SIZING_FIXED(60),
                    Clay.CLAY_SIZING_FIXED(60)
                ),
                Clay.CLAY_PADDING_ALL(0),
                0,
                Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
                Clay.LEFT_TO_RIGHT
            ))
            Clay.close_element()

            # Title text
            Clay.open_text_element(
                "Clay - UI Library",
                text_config(16, Clay.Color(1.0, 1.0, 1.0, 1.0))
            )

        Clay.close_element()  # ProfilePictureOuter

        # Sidebar items (using loop like in C example)
        for i in 1:5
            sidebar_item_component(UInt32(100 + i))
        end

    Clay.close_element()  # SideBar

    # MainContent
    Clay.open_element(UInt32(10))  # CLAY_ID("MainContent")
    main_content = Clay.CURRENT_CONTEXT[].currentElement
    main_content.backgroundColor = COLOR_LIGHT
    Clay.configure_element(Clay.LayoutConfig(
        Clay.Sizing(
            Clay.CLAY_SIZING_GROW(),
            Clay.CLAY_SIZING_GROW()
        ),
        Clay.CLAY_PADDING_ALL(0),
        0,
        Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
        Clay.LEFT_TO_RIGHT
    ))
    Clay.close_element()  # MainContent

Clay.close_element()  # OuterContainer

# End layout and get render commands
renderCommands = Clay.end_layout()

println("\n✓ Layout generated: $(length(renderCommands)) render commands")
println("  Screen: $(Int(screenWidth))×$(Int(screenHeight))")
println("  Sidebar width: 300px (FIXED)")
println("  Main content: GROW (fills remaining space)")
println("  Sidebar items: 5 (generated in loop)")

# Detailed breakdown
println("\n📊 Render Command Breakdown:")
for (i, cmd) in enumerate(renderCommands)
    bb = cmd.boundingBox
    if cmd.commandType == Clay.RENDER_COMMAND_TYPE_TEXT
        println("  [$i] TEXT: \"$(cmd.renderData.stringContents.chars)\" @ ($(round(Int,bb.x)),$(round(Int,bb.y))) $(round(Int,bb.width))×$(round(Int,bb.height))")
    elseif cmd.commandType == Clay.RENDER_COMMAND_TYPE_RECTANGLE
        println("  [$i] RECT: ID=$(cmd.id) @ ($(round(Int,bb.x)),$(round(Int,bb.y))) $(round(Int,bb.width))×$(round(Int,bb.height))")
    end
end

# Render with GLMakie
println("\n✓ Rendering with GLMakie...")
fig = render_clay_to_glmakie(renderCommands)

println("✓ Done! Displaying figure...")
println("\n📝 This is a direct port of the Clay C README example:")
println("  • Fixed-width sidebar (300px)")
println("  • Profile section with image placeholder + text")
println("  • 5 sidebar items generated in a loop")
println("  • Growing main content area")
println("  • Exact color matching: COLOR_LIGHT, COLOR_RED, COLOR_ORANGE")

display(fig)

fig
