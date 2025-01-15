# Overpass.jl

[![Build Status](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

Julia wrapper for the OpenStreetMap [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API).


- Query Overpass API
- Support for Overpass Turbo shortcuts
- Meaningful error messages
- Few dependencies


Inspired by the python packages [overpy](https://github.com/DinoTools/python-overpy) and [overpass](https://github.com/mvexel/overpass-api-python-wrapper?tab=readme-ov-file).

## Basic usage

```julia
using Overpass

Overpass.query(
    "[out:json];node[amenity=drinking_water]({{bbox}});out;",
    bbox=(48.22, 16.36, 48.22, 16.36)
)
```

```
"{\n  \"version\": 0.6,\n  \"generator\": \"Overpass API 0.7.62.4 …"
```

## See also
| Package           |                                                      |
| ----------------- | ---------------------------------------------------- |
| LightOSM.jl       | Download, save and analyze networks via Overpass API |
| OpenStreetMapX.jl | Analyze OSM roads from .osm or .pbf files            |
| OSMToolset.jl     | Read and analyze OSM XML files              |