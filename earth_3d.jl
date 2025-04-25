# Possible TODO:
# Add Solar radiation down as a shading to have night as a shade

using Bonito
using WGLMakie
import GeoMakie as GM
using ClimaAnalysis

### 1. Dashboard, surface plot on a sphere ###
# Load data via ClimaAnalysis
simdir = SimDir("outdir")
lhf = get(simdir, "lhf")
gpp = get(simdir, "gpp")
lon = gpp.dims["lon"]
lat = gpp.dims["lat"]

# Create a 3D mesh for the globe with proper coordinate mapping
function create_globe_mesh(lat_array, lon_array, radius=1.01)
    nlat = length(lat_array)
    nlon = length(lon_array)

    # Create arrays for the mesh coordinates
    x = zeros(nlon, nlat)
    y = zeros(nlon, nlat)
    z = zeros(nlon, nlat)

    # Fill the coordinates with 3D positions
    for i in 1:nlon
        lon_rad = deg2rad(lon_array[i])
        for j in 1:nlat
            lat_rad = deg2rad(lat_array[j])

            # Standard spherical to cartesian conversion
            x[i, j] = radius * cos(lat_rad) * cos(lon_rad)
            y[i, j] = radius * cos(lat_rad) * sin(lon_rad)
            z[i, j] = radius * sin(lat_rad)
        end
    end

    return x, y, z
end

function lhf_land(slider, menu, fig, ax)
    s = slider.value
    m = menu.value
    current_var = @lift(Dict("lhf" => lhf, "gpp" => gpp)[$m])

    # Get the current data
    current_time = @lift($current_var.dims["time"][$s])

    # Get the sliced data
    sliced_var = @lift(slice($current_var, time=$current_time))
    land_data = @lift(apply_oceanmask($sliced_var).data)

    # Create the mesh coordinates - use a larger radius for bigger Earth
    x, y, z = create_globe_mesh(lat, lon, 1.5)  # Increased from 1.01 to 1.5

    # Plot a blue sphere for the ocean first - match the radius to mesh
    ocean = mesh!(ax, Sphere(Point3f(0), 1.5), color=:royalblue4,
                  shading=Makie.NoShading)  # Turned off shading

    # Plot land data as a surface
    # Use transparency for NaN values in the data
    # Use a colormap without blue to contrast with ocean
    surf = surface!(ax, x, y, z, color=land_data,
                   colormap=:YlGn,  # Yellow-Green colormap (no blue)
                   transparency=true,
                   shading=Makie.NoShading,  # Turn off shading
                   nan_color=(:blue, 0.0))  # Make NaN transparent

    # Return the figure
    return fig
end

app = App() do
    fig = Figure(size=(1500, 1200))  # Made figure larger

    # Create a 3D axis - adjusted viewing angles
    ax = Axis3(fig[1, 1],
               aspect=:equal,
#               azimuth=0.6π,
#               elevation=0.35π,
               perspectiveness=0.0,  # Use orthographic projection (0.0) instead of perspective
               protrusions=0,        # Remove padding
               viewmode=:fit)        # Fit the view to the data

    # Hide the axis decorations for a cleaner look
    hidedecorations!(ax)
    hidespines!(ax)

    # Set up the menu and slider
    menu = Dropdown(["lhf", "gpp"])
    slider = StylableSlider(1:12)

    # Create the map using our function
    globe_map = lhf_land(slider, menu, fig, ax)

    # Add a colorbar with the new colormap
    # Colorbar(fig[1, 2], colormap=:YlGn, label="Value", height=Relative(0.65))

    return DOM.div(slider, menu, globe_map)
end
