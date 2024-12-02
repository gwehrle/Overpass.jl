[timeout:180];
(
way[highway=construction]["opening_date"](if:date(t["opening_date"])>date("{{date:1 day}}"))(52.15624211595189,12.841649913704128,52.88073375719345,14.014440441047878);
);
out body geom qt;