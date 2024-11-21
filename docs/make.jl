using Documenter
using Overpass

makedocs(
    sitename = "Overpass",
    format = Documenter.HTML(),
    modules = [Overpass]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
