# Claymore 

This is a prototype for a port of the [Clay](https://github.com/nicbarker/clay) layouting engine.
By using Julia we can use some of the high level features, and deeply integrate it with Makie.
We also plan to rewrite the API to be more functional and to not use global state and have a better separation of concern (no text representation, only rects, no colors etc which arent strictly needed for layouting).

Rough prototype for the following Bonito.DOM:
```julia
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
```

<img width="2006" height="868" alt="image" src="https://github.com/user-attachments/assets/909d1280-0dcb-4b40-a66f-71cab41b2e21" />
