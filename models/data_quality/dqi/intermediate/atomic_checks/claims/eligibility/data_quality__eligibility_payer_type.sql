{{ config(
    enabled = var('claims_enabled', False)
) }}

SELECT DISTINCT 
    m.data_source
    ,coalesce(cast(m.enrollment_start_date as {{ dbt.type_string() }}),cast('1900-01-01' as {{ dbt.type_string() }})) as source_date
    ,'ELIGIBILITY' AS table_name
    ,'Member ID | Enrollment Start Date' AS drill_down_key
    ,coalesce(m.member_id, 'NULL') as drill_down_value
    ,'ELIGIBILITY' AS claim_type
    ,'PAYER_TYPE' AS field_name
    ,case when m.payer_type is  null then 'null'
          when term.payer_type is null then 'invalid'
                             else 'valid' end as bucket_name
    ,case
        when m.payer_type is not null and term.payer_type is null then 'Payer Type does not join to Terminology Payer Type table'
        else null
    end as invalid_reason
    ,cast(m.payer_type as {{ dbt.type_string() }}) as field_value
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('eligibility')}} m
left join {{ ref('terminology__payer_type')}} term on m.payer_type = term.payer_type