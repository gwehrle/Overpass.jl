// @name Cycle Network

/*
This shows the cycleway and cycleroute network.
source: https://overpass-turbo.eu
*/

[out:json];

(
  // get cycle route relations
  relation[route=bicycle]({{bbox}});
  // get cycleways
  way[highway=cycleway]({{bbox}});
  way[highway=path][bicycle=designated]({{bbox}});
);

out body;
>;
out skel qt;