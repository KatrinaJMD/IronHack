USE p2_sql_fao;

DROP TEMPORARY TABLE IF EXISTS val;
CREATE TEMPORARY TABLE val AS
SELECT
    SUM(dispo_alim_kcal_p_j) AS total_alim,
    SUM(dispo_prot) AS total_prot,
    STDDEV_SAMP(dispo_alim_kcal_p_j) AS std_alim,
    STDDEV_SAMP(dispo_prot) AS std_prot,
    AVG(dispo_alim_kcal_p_j) AS avg_alim,
    AVG(dispo_prot) AS avg_prot
FROM dispo_alim;

DROP TEMPORARY TABLE IF EXISTS zscores;
CREATE TEMPORARY TABLE zscores AS
SELECT
    ROUND((total_alim - avg_alim) / std_alim, 2) AS zscore_LocalProduce,
    ROUND((total_prot - avg_prot) / std_prot, 2) AS zscore_AvailableProtein
FROM val;

select * from zscores;

# Top 15 countries with highest Local Produce
SELECT pays, zscore_LocalProduce FROM zscores
ORDER BY zscore_LocalProduce DESC LIMIT 15;

# Top 15 countries with lowest Local Produce
SELECT pays, zscore_LocalProduce FROM zscores
ORDER BY zscore_LocalProduce LIMIT 15;

# Top 15 countries with highest Available Protein Source
SELECT pays, zscore_AvailableProtein FROM zscores
ORDER BY zscore_AvailableProtein DESC LIMIT 15;

# Top 15 countries with lowest Available Protein Source
SELECT pays, zscore_AvailableProtein FROM zscores
ORDER BY zscore_AvailableProtein LIMIT 15;