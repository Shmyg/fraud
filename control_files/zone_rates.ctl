LOAD DATA
INFILE *
INTO TABLE zone_rates
APPEND
FIELDS TERMINATED BY '|'
(
PRIORITY,
RATE_DES
)
BEGINDATA
0|PRS
1|International
2|Local
3|FOC