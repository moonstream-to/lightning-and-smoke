with  dedup_events as (
    SELECT
        DISTINCT ON(transaction_hash, log_index) *
    FROM wyrm_labels
    WHERE label='moonworm-alpha'
        AND address='0xC90F37D09f2f8fB2e9D1Aa9a9d5142f5aE100d84'
        AND log_index IS NOT NULL
), AtBats as (
    SELECT
        label_data->'args'->>'sessionID' as session_id,
        label_data->'args'->>'outcome' as outcome,
        label_data->'args'->>'batterAddress' as batter_address,
        label_data->'args'->>'batterTokenID' as batter_token_id,
        label_data->'args'->>'pitcherAddress' as pitcher_address,
        label_data->'args'->>'pitcherTokenID' as pitcher_token_id,
        log_index
    FROM dedup_events
    WHERE label_data->>'name'='AtBatProgress' AND label_data->'args'->>'outcome'!='0'
), batter_stats as ( 
    SELECT
        SUM(CASE
            WHEN outcome = '1' THEN 1 ELSE 0 
        END) as strikeouts,
        SUM(CASE
            WHEN outcome = '2' THEN 1 ELSE 0 
        END) as walks,
        SUM(CASE
            WHEN outcome = '3' THEN 1 ELSE 0 
        END) as singles,
        SUM(CASE
            WHEN outcome = '4' THEN 1 ELSE 0 
        END) as doubles,
        SUM(CASE
            WHEN outcome = '5' THEN 1 ELSE 0 
        END) as triples,
        SUM(CASE
            WHEN outcome = '6' THEN 1 ELSE 0 
        END) as home_runs,
        SUM(CASE
            WHEN outcome = '7' THEN 1 ELSE 0 
        END) as in_play_outs,
        count(*) as total_batter_events,
        batter_address as batter_address,
        batter_token_id as batter_token_id
    FROM AtBats
    GROUP BY batter_address, batter_token_id
    ORDER BY home_runs DESC
)
select 
    batter_address || '_' || batter_token_id as address,
    home_runs as score,
    json_build_object(
        'home_runs', home_runs
    ) as points_data
from batter_stats