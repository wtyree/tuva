{{ config(
     enabled = var('provider_attribution_enabled',var('claims_enabled',var('tuva_marts_enabled',False)))
 | as_bool
   )
}}





select * from {{ ref('provider_attribution_seed') }}