CREATE OR REPLACE VIEW public.vw_kpi_categoria
AS SELECT 
   sad.categoria
   ,sum(vsb.valor_da_operacao) AS total_val_compra
   ,round(sum(vsb.valor_da_operacao) * 100.0 / sum(sum(vsb.valor_da_operacao)) OVER (), 2) AS percentual
FROM vw_stg_bov vsb
LEFT JOIN stg_ativos_details sad
   ON vsb.produto = sad.ativo
WHERE (vsb.movimentacao in ('Transferência - Liquidação', 'Desdobro', 'Bonificação em Ativos'))
GROUP BY sad.categoria
ORDER BY total_val_compra DESC;