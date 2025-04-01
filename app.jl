using Bonito
using WGLMakie
using ClimaAnalysis

### 1. Dashboard, heatmap of lhf on land, slider for t ###

# Load data via ClimaAnalysis
simdir = SimDir("outdir")
lhf = get(simdir, "lhf")

# Create figure
fig = Figure() # outside of function, created once only
ax = Axis(fig[1,1]) # likewise

function lhf_land(slider, fig, ax)
    s = slider.value
    # Get lhf at first timestep
    lhf_slice = @lift(slice(lhf, time = lhf.dims["time"][$s]))
    # Apply oceanmask
    lhf_slice_land = @lift(apply_oceanmask($lhf_slice))
    # Get data
    lhf_slice_land_data = @lift($lhf_slice_land.data)
    # Plot.
    p = contourf!(ax, lhf_slice_land_data)
    return fig
end

app = App() do
    slider = StylableSlider(1:12)
    landmap = lhf_land(slider, fig, ax)
    return DOM.div(slider, landmap)
end

### 2. Add a menu for variable ###
### 3. Style things: title (month, var), axis labels, colorbar, Bonito.Card, layout... ###

# Ask Simon Danish: is this MWE optimal for performance?

#=
### 1. Plot a heatmap of lhf on land at a time ###
# Get lhf at first timestep
lhf_slice = slice(lhf, time = lhf.dims["time"][1])

# Apply oceanmask
lhf_slice_land = apply_oceanmask(lhf_slice)

# Plot that lhf on land at first timestep.
fig = Figure()
ax = Axis(fig[1,1])
p = contourf!(ax, lhf_slice_land.data)
=#

