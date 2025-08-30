CREATE OR REPLACE VIEW public.vw_kpi_total_qtd_valor
AS SELECT 
   vsb.produto
   ,sum(vsb.quantidade) AS total_qtd
   ,sum(vsb.valor_da_operacao) AS total_val_compra
FROM vw_stg_bov vsb
LEFT JOIN stg_ativos_details sad 
   ON vsb.produto = sad.ativo
WHERE (vsb.movimentacao in ('Transferência - Liquidação', 'Desdobro', 'Bonificação em Ativos')) 
GROUP BY vsb.produto
ORDER BY (sum(vsb.valor_da_operacao)) DESC;