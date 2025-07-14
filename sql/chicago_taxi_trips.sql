-- Table: public.chicago_taxi_trips

-- DROP TABLE public.chicago_taxi_trips;

set timezone to 'UTC';

CREATE TABLE public.chicago_taxi_trips
(
  fare numeric,
  pickup_census_tract character varying,
  trip_end_hour integer,
  trip_start_hour integer,
  trip_seconds integer,
  trip_start_day_of_week integer,
  trip_miles integer,
  extras numeric,
  dropoff_census_tract character varying,
  tips numeric,
  tolls numeric,
  dropoff_community_area character varying,
  pickup_district character varying,
  company character varying,
  dropoff_community_area_desc character varying,
  trip_end_timestamp timestamp without time zone,
  trip_end_day_of_week integer,
  pickup_community_area_desc character varying,
  trip_id character varying,
  trip_total numeric,
  pickup_location_lat numeric,
  pickup_location_lon numeric,
  trip_start_timestamp timestamp without time zone,
  community_areas integer,
  trip_minutes numeric,
  pickup_community_area character varying,
  payment_type character varying,
  dropoff_district character varying,
  taxi_id character varying,
  dropoff_location_lat numeric,
  dropoff_location_lon numeric,
  dropoff_latitude numeric,
  pickup_latitude numeric,
  pickup_longitude numeric,
  dropoff_longitude numeric,
  trip_start_timestamp_epoch integer,
  trip_start_date_string character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.chicago_taxi_trips
  OWNER TO postgres;