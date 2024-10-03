{{ config(
     enabled = var('claims_preprocessing_enabled',var('claims_enabled',var('tuva_marts_enabled',False))) | as_bool
   )
}}

select patient_data_source_id
,start_date
,dense_rank() over (order by patient_data_source_id, start_date) as old_encounter_id
from {{ ref('outpatient_injections__anchor_events') }} 