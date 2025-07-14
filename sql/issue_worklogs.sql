
CREATE TABLE public.issue_worklogs (
	id varchar NULL,
	"self" varchar NULL,
	author jsonb NULL,
	"comment" jsonb NULL,
	created timestamptz NULL,
	"issueId" varchar NULL,
	started timestamptz NULL,
	updated timestamptz NULL,
	"timeSpent" varchar NULL,
	properties jsonb NULL,
	visibility jsonb NULL,
	"updateAuthor" jsonb NULL,
	"timeSpentSeconds" int8 NULL,
	"_airbyte_raw_id" varchar(36) NOT NULL,
	"_airbyte_extracted_at" timestamptz NOT NULL,
	"_airbyte_generation_id" int8 NULL,
	"_airbyte_meta" jsonb NOT NULL
)
WITH (
  OIDS=FALSE
);

CREATE INDEX issue_worklogs__airbyte_extracted_at_idx ON public.issue_worklogs USING btree (_airbyte_extracted_at);
CREATE INDEX issue_worklogs__airbyte_raw_id_idx ON public.issue_worklogs USING btree (_airbyte_raw_id);
CREATE INDEX issue_worklogs_id_updated__airbyte_extracted_at_idx ON public.issue_worklogs USING btree (id, updated, _airbyte_extracted_at);

ALTER TABLE public.ticket_sales
  OWNER TO postgres;
