CREATE OR REPLACE VIEW public.vw_kpi_setor
AS SELECT 
   sad.setor
   ,sum(vsb.valor_da_operacao) AS total_val_compra
FROM vw_stg_bov vsb
LEFT JOIN stg_ativos_details sad
   ON vsb.produto = sad.ativo
WHERE (vsb.movimentacao in ('Transferência - Liquidação', 'Desdobro', 'Bonificação em Ativos')) 
GROUP BY sad.setor
ORDER BY sad.setor;