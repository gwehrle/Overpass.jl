// @name date and bbox

[timeout:180];

(
way[highway=construction]["opening_date"](if:date(t["opening_date"])>date("{{date:1 day}}"))({{bbox}});
);
out body geom qt;