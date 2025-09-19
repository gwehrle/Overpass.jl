# Examples

The most common formats for overpass are JSON, XML and CSV.
JSON is recommended, because it can be directly translated into Julia Dicts.

## Parse JSON

!!! info "Important"
You have to add `[out:json];` in front of your query

```
[out:json];
node
  [natural=tree]
  ({{bbox}});
out;
```
*Content of `trees.overpassql`*


```@example overpass
using JSON3

op_response = Overpass.query("trees.overpassql",bbox=(48.22, 16.36, 48.22, 16.36))

json_response = JSON3.read!(op_response)
trees = json_response.elements

trees
```

## Parse XML
If you do not specify a different output format, ovperass api returns xml.
You can parse it like this:

```@exmpale overpass
ovp_resp = Overpass.query("waterfountains.overpassql", bbox=(48.22, 16.36, 48.22, 16.36))
```