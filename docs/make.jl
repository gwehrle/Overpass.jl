push!(LOAD_PATH,"../src/")

using Documenter
using Overpass

makedocs(
    sitename = "Overpass.jl",
    pages = [
        "Home" => "index.md",
        "tutorial.md",
        "reference.md",
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/gwehrle/Overpass.jl"
)
