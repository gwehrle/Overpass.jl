# Overpass.jl

[![Build Status](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2)](https://github.com/SciML/SciMLStyle)
[![All Contributors](https://img.shields.io/github/all-contributors/gwehrle/Overpass.jl?color=ee8449)](#contributors)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

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

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gwehrle"><img src="https://avatars.githubusercontent.com/u/171450664?v=4?s=100" width="100px;" alt="Gregor Wehrle"/><br /><sub><b>Gregor Wehrle</b></sub></a><br /><a href="#ideas-gwehrle" title="Ideas, Planning, & Feedback">🤔</a> <a href="#userTesting-gwehrle" title="User Testing">📓</a> <a href="#code-gwehrle" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kaat0"><img src="https://avatars.githubusercontent.com/u/142348?v=4?s=100" width="100px;" alt="Martin Scheidt"/><br /><sub><b>Martin Scheidt</b></sub></a><br /><a href="#ideas-kaat0" title="Ideas, Planning, & Feedback">🤔</a> <a href="#userTesting-kaat0" title="User Testing">📓</a> <a href="#code-kaat0" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
