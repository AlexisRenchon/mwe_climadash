using Bonito
using WGLMakie
import GeoMakie as GM
using ClimaAnalysis

### 1. Dashboard, heatmap of lhf or gpp on land, slider for t ###

# Load data via ClimaAnalysis
simdir = SimDir("outdir")
lhf = get(simdir, "lhf")
gpp = get(simdir, "gpp")
lon = gpp.dims["lon"]
lat = gpp.dims["lat"]

function lhf_land(slider, menu, fig, ax)
    s = slider.value
    m = menu.value
    var = @lift(Dict("lhf" => lhf, "gpp" => gpp)[$m])
    varslice = @lift(slice($var, time = $var.dims["time"][$s])) # Get lhf
    slice_land = @lift(apply_oceanmask($varslice)) # Apply oceanmask
    slice_land_data = @lift($slice_land.data) # Get data
    p = heatmap!(ax, lon, lat, slice_land_data) # Plot
    return fig
end

app = App() do
    fig = Figure()
    ax = GM.GeoAxis(fig[1,1]; dest = "+proj=wintri")
    lines!(ax, GM.coastlines())
    menu = Dropdown(["lhf", "gpp"])
    slider = StylableSlider(1:12)
    landmap = lhf_land(slider, menu, fig, ax)
    return DOM.div(slider, menu, landmap)
end
