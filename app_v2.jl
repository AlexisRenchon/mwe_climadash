using Bonito
using WGLMakie
using ClimaAnalysis

### 1. Dashboard, heatmap of lhf or gpp on land, slider for t ###

# Load data via ClimaAnalysis
simdir = SimDir("outdir")
lhf = get(simdir, "lhf")
gpp = get(simdir, "gpp")

# Create figure
fig = Figure() # outside of function, created once only
ax = Axis(fig[1,1]) # likewise

function lhf_land(slider, menu, fig, ax)
    s = slider.value
    m = menu.value
    var = @lift(Dict("lhf" => lhf, "gpp" => gpp)[$m])
    # Get lhf at first timestep
    varslice = @lift(slice($var, time = $var.dims["time"][$s]))
    # Apply oceanmask
    slice_land = @lift(apply_oceanmask($varslice))
    # Get data
    slice_land_data = @lift($slice_land.data)
    # Plot.
    p = contourf!(ax, slice_land_data)
    return fig
end

app = App() do
    menu = Dropdown(["lhf", "gpp"])
    slider = StylableSlider(1:12)
    landmap = lhf_land(slider, menu, fig, ax)
    return DOM.div(slider, menu, landmap)
end


