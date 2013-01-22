#! /bin/sh
# script to setup the postgis database and setup the respective database tables


#create a postgis spatial database template

POSTGIS_SQL_PATH=/usr/share/postgresql/9.1/contrib
sudo -u postgres createdb  -E UTF8 template_postgis1 # Create the template spatial database.
sudo -u postgres createlang  -d template_postgis1 plpgsql # Adding PLPGSQL language support.
sudo -u postgres psql  -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis1';"
sudo -u postgres psql  -d template_postgis1 -f $POSTGIS_SQL_PATH/postgis-1.5/postgis.sql # Loading the PostGIS SQL routines
sudo -u postgres psql  -d template_postgis1 -f $POSTGIS_SQL_PATH/postgis-1.5/spatial_ref_sys.sql
sudo -u postgres psql  -d template_postgis1 -c "GRANT ALL ON geometry_columns TO PUBLIC;" # Enabling users to alter spatial tables.
sudo -u postgres psql   -d template_postgis1 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

# create the database (first drop the old one, if it exists)
#
sudo -u postgres dropdb   geoserver
sudo -u postgres createdb   geoserver -T template_postgis1

#create a table to contain district name, slug,and poll info (yes,or no)
#sudo -u postgres psql -d geoserver  -c "create table district (id char(5), district varchar(100), slug varchar(100),iso_code varchar(5), poll_id integer ,poll_result varchar(3));"

# load the shapefile
#
sudo -u postgres ogr2ogr -f  "PostgreSQL" -t_srs EPSG:900913 PG:"dbname=geoserver user=postgres" Burundi_Adm2013/BDI_adm4/BDI_adm4.shp  -nlt multipolygon -nln BDI_adm4

