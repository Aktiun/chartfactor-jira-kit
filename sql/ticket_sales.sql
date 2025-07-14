-- Table: public.ticket_sales

-- DROP TABLE public.ticket_sales;

set timezone to 'UTC';

CREATE TABLE public.ticket_sales
(
salesid integer PRIMARY KEY,
listid integer,
sellerid integer,
buyerid integer,
eventid integer,
dateid integer,
qtysold integer,
pricepaid numeric,
commission numeric,
saletime timestamp without time zone,
venueid integer,
catid integer,
eventname character varying,
starttime timestamp without time zone,
catgroup character varying,
catname character varying,
catdesc character varying,
venuename character varying,
venuecity character varying,
venuestate character varying(2),
venueseats integer,
userid character varying,
username character varying,
firstname character varying,
lastname character varying,
city character varying,
state character varying(2),
email character varying,
phone character varying,
likesports character varying,
liketheatre character varying,
likeconcerts character varying,
likejazz character varying,
likeclassical character varying,
likeopera character varying,
likerock character varying,
likevegas character varying,
likebroadway character varying,
likemusicals character varying,
saletime_utc timestamp with time zone,
saletime_min_7 timestamp with time zone,
saletime_plus_8 timestamp with time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.ticket_sales
  OWNER TO postgres;