# Overpass.jl

[![Build Status](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gwehrle/Overpass.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![All Contributors](https://img.shields.io/github/all-contributors/gwehrle/Overpass.jl?color=ee8449)](#contributors)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

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

Get requested elements from OpenStreetMap through Overpass API. The result is provided as _string_ and has to be parsed depending on the format you specified in your query.

**💡 Tipp: Use [Overpass Turbo](https://overpass-turbo.eu/) to build your queries and use the *export* feature to save them as `.overpassql` either as `standalone` or `raw`**

```julia
using Overpass
Overpass.query("waterfountains.overpassql", bbox=(48.22, 16.36, 48.22, 16.36))
# "{\n  \"version\": 0.6,\n  \"generator\": \"Overpass API…"
```
`Overpass.query` can handle `.overpassql` and `.ql` files.
For short queries it is also possible to inline it directly:
```julia
# Standard example of https://overpass-turbo.eu/
Overpass.query("[out:json];node[amenity=drinking_water]({{bbox}});out;", bbox=(48.22, 16.36, 48.22, 16.36))
# "{\n  \"version\": 0.6,\n  \"generator\": \"Overpass API…"
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

Get URL to open your query in Overpass Turbo.

Overpass Turbo is a web based graphical user interface for Overpass.
Its very useful to build and debug your queries with Overpass Turbo.

The query can be provided directly or as a path to a `.ql`/`.overpassql` file.

```julia
Overpass.turbo_url("drinking_water.overpassql")
# "https://overpass-turbo.eu/?Q=%5Bout%3Ajson%5D%3Bnode%5Bamenity%3Ddrinking_water…"
```

### Overpass Turbo shortcuts

These [Overpass Turbo shortcuts](https://wiki.openstreetmap.org/wiki/Overpass_turbo/Extended_Overpass_Turbo_Queries) are supported:

| Shortcut                 | Status            |
| ------------------------ | ----------------- |
| {{bbox}}                 | supported         |
| {{center}}               | supported         |
| {{date:*string*}}        | supported         |
| {{geocodeId:*name*}}     | not yet supported |
| {{geocodeArea:*name*}}   | not yet supported |
| {{geocodeBbox:*name*}}   | not yet supported |
| {{geocodeCoords:*name*}} | not yet supported |

#### The `{{date}}` shortcut

The `{{date}}` shortcut can represent:
1. The current UTC date and time.
2. A relative date calculated using offsets (e.g., 7 days ago, 1 month ago).

When using the `{{date}}` shortcut in your query, it is replaced with a date string in [ISO 8601 format](https://en.wikipedia.org/wiki/ISO_8601), ensuring compatibility with Overpass API queries.

| Query Placeholder         | Meaning                             | Replacement Example         |
|---------------------------|-------------------------------------|-----------------------------|
| `{{date}}`                | Current date and time in UTC        | `2024-12-02T12:00:00Z`      |
| `{{date:7 days}}`         | 7 days ago from now in UTC          | `2024-11-25T12:00:00Z`      |
| `{{date:-1 month}}`       | 1 month into the future in UTC      | `2025-01-02T12:00:00Z`      |
| `{{date:2 years}}`        | 2 years ago from now in UTC         | `2022-12-02T12:00:00Z`      |

** ⚠️ Warning: The implementation of Overpass Turbo calculates the offset for the {{date}} shortcut in seconds, ignoring leap years and leap seconds. In contrast, Overpass.jl provides a calculation the actual calendar structure when replacing the placeholder. **

See: [Overpass Turbo Available Shortcuts](https://wiki.openstreetmap.org/wiki/Overpass_turbo/Extended_Overpass_Turbo_Queries#Available_Shortcuts) for more details.

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

## See also
| Package           |                                                      |
| ----------------- | ---------------------------------------------------- |
| LightOSM.jl       | Download, save and analyze networks via Overpass API |
| OpenStreetMapX.jl | Analyze OSM roads from .osm or .pbf files            |
| OSMToolset.jl     | Read and analyze OSM XML files              |
