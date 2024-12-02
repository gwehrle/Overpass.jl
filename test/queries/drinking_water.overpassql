// @name Drinking Water

/*
This is an example Overpass query.
source: https://overpass-turbo.eu
*/

[out:json];
node
  [amenity=drinking_water]
  ({{bbox}});
out;