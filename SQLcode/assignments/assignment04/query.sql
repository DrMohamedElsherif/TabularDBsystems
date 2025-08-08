.timer on

SELECT MIN(L_quantity)
FROM read_csv('./resources/lineitem.csv', 
    header=false,
    names=['L_orderkey', 'L_partkey', 'L_suppkey', 'L_linenumber', 
           'L_quantity', 'L_extendedprice', 'L_discount', 'L_tax',
           'L_returnflag', 'L_linestatus', 'L_shipdate', 'L_commitdate',
           'L_receiptdate', 'L_shipinstruct', 'L_shipmode', 'L_comment'])
WHERE L_orderkey < 2000000;