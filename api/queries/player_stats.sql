with  dedup_events as (
    SELECT
        DISTINCT ON(transaction_hash, log_index) *
    FROM wyrm_labels
    WHERE label='moonworm-alpha'
        AND address='0x391FFCcea2BC1a615e2d4923fFd9373278707504'
        AND log_index IS NOT NULL
), SessionResolved as (
    SELECT
        label_data->'args'->>'sessionID' as session_id,
        label_data->'args'->>'outcome' as outcome,
        label_data->'args'->>'batterAddress' as batter_address,
        label_data->'args'->>'batterTokenID' as batter_token_id,
        label_data->'args'->>'pitcherAddress' as pitcher_address,
        label_data->'args'->>'pitcherTokenID' as pitcher_token_id,
        log_index
    FROM dedup_events
    WHERE label_data->>'name'='SessionResolved'
), batter_stats as ( 
    SELECT
        SUM(CASE
            WHEN outcome = '0' THEN 1 ELSE 0 
        END) as strikeouts,
        SUM(CASE
            WHEN outcome = '1' THEN 1 ELSE 0 
        END) as walks,
        SUM(CASE
            WHEN outcome = '2' THEN 1 ELSE 0 
        END) as singles,
        SUM(CASE
            WHEN outcome = '3' THEN 1 ELSE 0 
        END) as doubles,
        SUM(CASE
            WHEN outcome = '4' THEN 1 ELSE 0 
        END) as triples,
        SUM(CASE
            WHEN outcome = '5' THEN 1 ELSE 0 
        END) as home_runs,
        SUM(CASE
            WHEN outcome = '6' THEN 1 ELSE 0 
        END) as in_play_outs,
        count(*) as total_batter_events,
        batter_address as batter_address,
        batter_token_id as batter_token_id
    FROM SessionResolved
    GROUP BY batter_address, batter_token_id
), pitcher_stats as (
    SELECT
        SUM(CASE
            WHEN outcome = '0' THEN 1 ELSE 0 
        END) as strikeouts,
        SUM(CASE
            WHEN outcome = '1' THEN 1 ELSE 0 
        END) as walks,
        SUM(CASE
            WHEN outcome = '2' THEN 1 ELSE 0 
        END) as singles,
        SUM(CASE
            WHEN outcome = '3' THEN 1 ELSE 0 
        END) as doubles,
        SUM(CASE
            WHEN outcome = '4' THEN 1 ELSE 0 
        END) as triples,
        SUM(CASE
            WHEN outcome = '5' THEN 1 ELSE 0 
        END) as home_runs,
        SUM(CASE
            WHEN outcome = '6' THEN 1 ELSE 0 
        END) as in_play_outs,
        count(*) as total_pitcher_events,
        pitcher_address,
        pitcher_token_id
    FROM SessionResolved
    GROUP BY pitcher_address, pitcher_token_id
), pitcher_data as (
    select 
        pitcher_address || '_' || pitcher_token_id as address,
        json_build_object(
            'strikeouts', strikeouts,
            'walks', walks,
            'singles', singles,
            'doubles', doubles,
            'triples', triples,
            'home_runs', home_runs,
            'in_play_outs', in_play_outs,
            'innings', strikeouts + in_play_outs,
            'earned_runs', 1.5 * singles + 2.5 * doubles + 3 * triples + 4 * home_runs,
            'earned_run_average', COALESCE(EXP(LN(NULLIF(9.0 * (1.5 * singles + 2.5 * doubles + 3 * triples + 4 * home_runs),0)) - LN(NULLIF(strikeouts + in_play_outs, 0))), 0),
            'whip', COALESCE(EXP(LN(NULLIF((walks + singles + doubles + triples + home_runs),0)) - LN(NULLIF(strikeouts + in_play_outs, 0))), 0),
            'batting_average_against', COALESCE(EXP(LN(NULLIF(1.0 * (singles + doubles + triples + home_runs),0)) - LN(NULLIF(total_pitcher_events - walks, 0))), 0)   
        ) as points_data
    from pitcher_stats
), batter_data as (
    select 
        batter_address || '_' || batter_token_id as address,
        json_build_object(
            'strikeouts', strikeouts,
            'walks', walks,
            'singles', singles,
            'doubles', doubles,
            'triples', triples,
            'home_runs', home_runs,
            'in_play_outs', in_play_outs,
            'at_bats', total_batter_events - walks,
            'hits', singles + doubles + triples + home_runs,
            'runs_batted_in', walks + 1.5 * singles + 2.5 * doubles + 3 * triples + 4 * home_runs,
            'batting_average', COALESCE(EXP(LN(NULLIF(1.0 * (singles + doubles + triples + home_runs),0)) - LN(NULLIF(total_batter_events - walks, 0))), 0),
            'on-base', COALESCE(EXP(LN(NULLIF(1.0 * (walks + singles + doubles + triples + home_runs),0)) - LN(NULLIF(total_batter_events, 0))), 0),
            'slugging', COALESCE(EXP(LN(NULLIF((1.0 * singles + 2.0 * doubles + 3.0 * triples + 4.0 * home_runs),0)) - LN(NULLIF(total_batter_events - walks, 0))), 0),
            'ops', COALESCE(EXP(LN(NULLIF((walks + singles + doubles + triples + home_runs),0)) - LN(NULLIF(total_batter_events, 0))) +
                COALESCE(EXP(LN(NULLIF((1.0 * singles + 2.0 * doubles + 3.0 * triples + 4.0 * home_runs),0)) - LN(NULLIF(total_batter_events - walks, 0))),0), 0)
        ) as points_data
    from batter_stats
)
select 
    COALESCE(batter_data.address, pitcher_data.address) as address,
    0 as score,
    json_build_object(
        'batting_data', batter_data.points_data,
        'pitching_data', pitcher_data.points_data
    ) as points_data
from batter_data full outer join pitcher_data on batter_data.address = pitcher_data.address