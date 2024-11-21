# Overpass.jl

[![Build Status](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

Julia wrapper for the OpenStreetMap [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API).


- Query Overpass API
- Helper functions
- Meaningful error messages
- Few dependencies


Inspired by the python packages [overpy](https://github.com/DinoTools/python-overpy) and [overpass](https://github.com/mvexel/overpass-api-python-wrapper?tab=readme-ov-file).

## Install
```julia
julia> ]
pkg> add Overpass
```
## Usage

### Query overpass

**💡 Tipp: Use [Overpass Turbo](https://overpass-turbo.eu/) to build your queries and use the *export* feature to save them as `.overpassql`**

```julia
using Overpass
Overpass.query("waterfountains.overpassql")
```
`Overpass.query` can handle `.overpassql` and `.ql` files.
For short queries it is also possible to inline it directly:
```julia
# Standard example of https://overpass-turbo.eu/
Overpass.query("node[amenity=drinking_water]({{bbox}});out;", bbox=(48,16,49,17))
```

| Argument | Description                                   | Datatype          |
| -------- | --------------------------------------------- | ----------------- |
| bbox     | Coordinates to replace `{{bbox}}` shortcut    | NTuple{4, Number} |
| center   | Coordinates to replace `{{center}}`  shortcut | NTuple{2, Number} |

### Result parsing

To keep the package small and flexible, the response is not parsed but returned as a string. Depending on the use case, the string can then be parsed, saved, etc.

### Change Overpass endpoint

Sets the endpoint for the Overpass API.

```julia
Overpass.set_endpoint("https://overpass.private.coffee/api/")
```
Default endpoint is https://overpass-api.de/api/.
See [list of endpoints in OSM Wiki](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances).

⚠️ Endpoint URL must have a trailing slash

### Endpoint status

Receive current Status of Overpass API endpoint.

```julia
Overpass.status()
```

The returned Status struct provides the following fields:
- `connection_id::String`
- `server_time::DateTime`
- `endpoint::Union{Nothing, String}`
- `rate_limit::Int`
- `avalible_slots::Union{Nothing, Int}`

### Overpass turbo URL

```julia
Overpass.turbo_url("waterfountains.overpassql")
```

Transform Overpass Query to Overpass Turbo URL.

The query can be provided directly or as a path to a `.ql`/`.overpassql` file.
Can be helpful to debug queries.

### Overpass Turbo shortcuts

These [Overpass Turbo shortcuts](https://wiki.openstreetmap.org/wiki/Overpass_turbo/Extended_Overpass_Turbo_Queries) are supported:

| Shortcut                 | Status            |
| ------------------------ | ----------------- |
| {{bbox}}                 | supported         |
| {{center}}               | supported         |
| {{date:*string*}}        | support planned   |
| {{geocodeId:*name*}}     | not yet supported |
| {{geocodeArea:*name*}}   | not yet supported |
| {{geocodeBbox:*name*}}   | not yet supported |
| {{geocodeCoords:*name*}} | not yet supported |

## See also
| Package           |                                                      |
| ----------------- | ---------------------------------------------------- |
| LightOSM.jl       | Download, save and analyze networks via Overpass API |
| OpenStreetMapX.jl | Analyze OSM roads from .osm or .pbf files            |
| OSMToolset.jl     | Read and analyze OSM XML files              |