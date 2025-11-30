using Clay
using Test

@testset "Clay.jl" begin
    @testset "Basic Data Structures" begin
        # Test Dimensions
        dims = Clay.Dimensions(800f0, 600f0)
        @test dims.width == 800f0
        @test dims.height == 600f0

        # Test Color
        color = Clay.Color(1f0, 0.5f0, 0.25f0, 1f0)
        @test color.r == 1f0
        @test color.g == 0.5f0
        @test color.b == 0.25f0
        @test color.a == 1f0

        # Test Vector2
        vec = Clay.Vector2(10f0, 20f0)
        @test vec.x == 10f0
        @test vec.y == 20f0
    end

    @testset "Sizing Helpers" begin
        # Test CLAY_SIZING_FIXED
        fixed = Clay.CLAY_SIZING_FIXED(100)
        @test fixed.type == Clay.SIZING_TYPE_FIXED
        @test fixed.minMax.min == 100f0

        # Test CLAY_SIZING_GROW
        grow = Clay.CLAY_SIZING_GROW()
        @test grow.type == Clay.SIZING_TYPE_GROW

        # Test CLAY_SIZING_FIT
        fit = Clay.CLAY_SIZING_FIT()
        @test fit.type == Clay.SIZING_TYPE_FIT

        # Test CLAY_PADDING_ALL
        padding = Clay.CLAY_PADDING_ALL(16)
        @test padding.left == 16
        @test padding.right == 16
        @test padding.top == 16
        @test padding.bottom == 16
    end

    @testset "Basic Layout" begin
        # Initialize Clay with screen dimensions
        dims = Clay.Dimensions(800f0, 600f0)
        ctx = Clay.initialize(dims)
        @test !isnothing(ctx)

        # Begin layout
        Clay.begin_layout()

        # Create root element with fixed size
        root = Clay.open_element(UInt32(1))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_FIXED(400),
                Clay.CLAY_SIZING_FIXED(300)
            ),
            Clay.CLAY_PADDING_ALL(16),
            8,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))

        # Add a child element
        child = Clay.open_element(UInt32(2))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_FIXED(100),
                Clay.CLAY_SIZING_FIXED(100)
            ),
            Clay.CLAY_PADDING_ALL(0),
            0,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        Clay.close_element()

        # Add another child
        child2 = Clay.open_element(UInt32(3))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_FIXED(100),
                Clay.CLAY_SIZING_FIXED(100)
            ),
            Clay.CLAY_PADDING_ALL(0),
            0,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        Clay.close_element()

        Clay.close_element()

        # End layout and get render commands
        commands = Clay.end_layout()

        # Verify we got render commands
        @test !isempty(commands)
        @test length(commands) == 4  # implicit root + explicit root + 2 children

        # Check second command (explicit root element ID=1)
        @test commands[2].commandType == Clay.RENDER_COMMAND_TYPE_RECTANGLE
        @test commands[2].boundingBox.width == 400f0
        @test commands[2].boundingBox.height == 300f0
    end

    @testset "Nested Layout with TOP_TO_BOTTOM" begin
        dims = Clay.Dimensions(800f0, 600f0)
        Clay.initialize(dims)
        Clay.begin_layout()

        # Root container with vertical layout
        Clay.open_element(UInt32(10))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_FIXED(200),
                Clay.CLAY_SIZING_FIXED(400)
            ),
            Clay.CLAY_PADDING_ALL(10),
            5,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.TOP_TO_BOTTOM
        ))

        # First child
        Clay.open_element(UInt32(11))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_FIXED(180),
                Clay.CLAY_SIZING_FIXED(50)
            ),
            Clay.CLAY_PADDING_ALL(0),
            0,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        Clay.close_element()

        # Second child
        Clay.open_element(UInt32(12))
        Clay.configure_element(Clay.LayoutConfig(
            Clay.Sizing(
                Clay.CLAY_SIZING_FIXED(180),
                Clay.CLAY_SIZING_FIXED(50)
            ),
            Clay.CLAY_PADDING_ALL(0),
            0,
            Clay.ChildAlignment(Clay.ALIGN_X_LEFT, Clay.ALIGN_Y_TOP),
            Clay.LEFT_TO_RIGHT
        ))
        Clay.close_element()

        Clay.close_element()

        commands = Clay.end_layout()
        @test length(commands) == 4  # implicit root + explicit root + 2 children

        # Verify vertical stacking (children should be at different Y positions)
        @test commands[3].boundingBox.y < commands[4].boundingBox.y
    end

    @testset "GROW Sizing" begin
        dims = Clay.Dimensions(800f0, 600f0)
        Clay.initialize(dims)
        Clay.begin_layout()

        # Root with GROW sizing should fill screen
        Clay.open_element(UInt32(20))
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
        Clay.close_element()

        commands = Clay.end_layout()
        @test commands[2].boundingBox.width == 800f0  # Check explicit root (ID=20)
        @test commands[2].boundingBox.height == 600f0
    end
end
