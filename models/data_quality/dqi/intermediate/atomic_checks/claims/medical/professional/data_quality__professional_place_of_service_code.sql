{{ config(
    enabled = var('claims_enabled', False)
) }}

with base as (
    select *
    from {{ ref('medical_claim')}}
    where claim_type = 'professional'
)

select
      m.data_source
    , coalesce(cast(m.claim_start_date as {{ dbt.type_string() }}),cast('1900-01-01' as {{ dbt.type_string() }})) as source_date
    , 'MEDICAL_CLAIM' AS table_name
    , 'Claim ID | Claim Line Number' AS drill_down_key
    , {{ dbt.concat(["coalesce(cast(m.claim_id as " ~ dbt.type_string() ~ "), 'null')",
                    "'|'",
                    "coalesce(cast(m.claim_line_number as " ~ dbt.type_string() ~ "), 'null')"]) }} as drill_down_value
    , 'professional' AS claim_type
    , 'PLACE_OF_SERVICE_CODE' AS field_name
    , case when term.place_of_service_code is not null then 'valid'
          when m.place_of_service_code is not null    then 'invalid'
                                               else 'null' end as bucket_name
    , case
        when m.place_of_service_code is not null
            and term.place_of_service_code is null
            then 'Place of Service Code does not join to Terminology Place of Service table'
        else null
    end as invalid_reason
    , {{ dbt.concat(["m.place_of_service_code", "'|'", "coalesce(term.place_of_service_description, '')"]) }} as field_value
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from base m
left join {{ ref('terminology__place_of_service')}} as term on m.place_of_service_code = term.place_of_service_code