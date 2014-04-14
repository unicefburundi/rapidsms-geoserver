SELECT b.wkb_geometry,
	b.id_0, 
	b.iso ,
	b.name_0 AS country, 
	b.name_1 AS province, 
	b.type_1 AS location_type,  
	b.engtype_1,
	g.district,
	g.poll_id AS poll,
	g.deployment_id AS app,
	g.yes,
	g.no,
	CASE WHEN (COALESCE(g.yes)+COALESCE(g.no)) <> 0 
	THEN (g.yes/(COALESCE(g.yes)+COALESCE(g.no)) * 100) 
	ELSE 0 END AS percentage_yes,
	g.unknown,
	g.uncategorized 
FROM public.bdi_adm1 b, public.geoserver_polldata g 
WHERE g.poll_id=591 AND g.deployment_id=1 AND b.name_1 = g.district
GROUP BY g.district, g.deployment_id, g.poll_id, g.yes, g.no, g.unknown, g.uncategorized, b.id_0, b.iso, b.name_0, b.name_1, b.type_1, b.engtype_1 
ORDER BY b.name_1 DESC;

