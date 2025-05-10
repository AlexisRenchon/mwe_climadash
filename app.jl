using WGLMakie
using ClimaAnalysis
import GeoMakie as GM

simdir = SimDir("outdir")
lhf = get(simdir, "lhf")
lon = lhf.dims["lon"]
lat = lhf.dims["lat"]
lhf_slice = slice(lhf, time = lhf.dims["time"][1])
lhf_slice_land = apply_oceanmask(lhf_slice)

fig = Figure()
ax = GM.GeoAxis(fig[1,1]; dest = "+proj=wintri")
#lines!(ax, GM.coastlines())
#p = heatmap!(ax, lon, lat, lhf_slice_land.data)
p = GM.meshimage!(ax, extrema(lon), extrema(lat), lhf_slice_land.data, shading = NoShading)
