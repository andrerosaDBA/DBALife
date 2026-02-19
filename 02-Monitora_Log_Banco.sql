

--backup database TESTE to disk = 'C:\Users\Administrator\Documents\Databases\Backup\TESTE.bak' with compression, format, init, stats = 1;
--backup log TESTE to disk = N'Nul'

--dbcc sqlperf(logspace) with no_infomsgs;






  SELECT  DB_NAME() AS DatabaseName,
        mf.name AS FileName,
        mf.physical_name AS PhysicalName,
        CAST(ls.total_log_size_in_bytes / 1048576.0 AS DECIMAL(18,2)) AS TotalLogSizeMB,
        --Count(vlf.database_id) AS Qtd_Vlf, --quantidade de VLFs
        --Sum(vlf.vlf_size_mb) As [Size_Vlf (MB)],
        --Case When vlf.vlf_status = 2 Then COUNT(vlf.database_id) Else 0 End AS Qtd_Vlf_Ativos, --quantidade de VLFs ativos
        CAST(ls.used_log_space_in_bytes / 1048576.0 AS DECIMAL(18,2)) AS UsedLogSpaceMB,
        CAST(ls.used_log_space_in_percent AS DECIMAL(10,2)) AS [UsedSpacePercent %],
        CAST((ls.total_log_size_in_bytes - ls.used_log_space_in_bytes) / 1048576.0 AS DECIMAL(18,2)) AS FreeLogSpaceMB,
        CASE WHEN mf.max_size = 268435456 And mf.type_desc = 'LOG' THEN '2 TB'
             WHEN mf.max_size = -1 And mf.type_desc = 'ROWS' THEN 'Until Disk Is Full'
             ELSE CAST(CAST((mf.max_size * 8.0 / 1024) AS DECIMAL(10,2)) AS VARCHAR(20)) + ' MB'
        END AS MaxSizeMB
FROM sys.master_files AS mf CROSS APPLY sys.dm_db_log_space_usage AS ls
                            cross apply sys.dm_db_log_info ( mf.database_id ) AS VLF
WHERE mf.database_id = DB_ID()
  AND mf.type_desc = 'LOG'
 GROUP BY --DB_NAME(), 
 mf.name, mf.physical_name, ls.total_log_size_in_bytes, /*vlf.vlf_status,*/ ls.used_log_space_in_bytes, ls.used_log_space_in_percent, mf.max_size, mf.type_desc
  



























--select  log_reuse_wait_desc
--from sys.databases
--where name = DB_NAME()

--select @@SERVERNAME as ServerName, db.name As DatabaseName, count(1) as Qtd_Vlfs 
--from sys.databases as db cross apply sys.dm_db_log_info ( db.database_id )
--where db.name = DB_NAME()
----group by db.name
--order by Qtd_Vlfs desc

--select * from sys.dm_db_log_info ( DB_ID() )

--select 2.43
--+2.43
--+2.43
--+2.67


--SELECT [name], COUNT(l.database_id) AS 'vlf_count'
--FROM sys.databases AS s
--CROSS APPLY sys.dm_db_log_info(s.database_id) AS l
--WHERE s.name = DB_NAME()
--GROUP BY [name]
--HAVING COUNT(l.database_id) > 100;


--;WITH cte_vlf AS (
--SELECT ROW_NUMBER() OVER(ORDER BY vlf_begin_offset) AS vlfid, DB_NAME(database_id) AS [Database Name], vlf_sequence_number, vlf_active, vlf_begin_offset, vlf_size_mb
--    FROM sys.dm_db_log_info(DEFAULT)),
--cte_vlf_cnt AS (SELECT [Database Name], COUNT(vlf_sequence_number) AS vlf_count,
--    (SELECT COUNT(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 0) AS vlf_count_inactive,
--    (SELECT COUNT(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 1) AS vlf_count_active,
--    (SELECT MIN(vlfid) FROM cte_vlf WHERE vlf_active = 1) AS ordinal_min_vlf_active,
--    (SELECT MIN(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 1) AS min_vlf_active,
--    (SELECT MAX(vlfid) FROM cte_vlf WHERE vlf_active = 1) AS ordinal_max_vlf_active,
--    (SELECT MAX(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 1) AS max_vlf_active
--    FROM cte_vlf
--    GROUP BY [Database Name])
--SELECT [Database Name], vlf_count, min_vlf_active, ordinal_min_vlf_active, max_vlf_active, ordinal_max_vlf_active,
--((ordinal_min_vlf_active-1)*100.00/vlf_count) AS free_log_pct_before_active_log,
--((ordinal_max_vlf_active-(ordinal_min_vlf_active-1))*100.00/vlf_count) AS active_log_pct,
--((vlf_count-ordinal_max_vlf_active)*100.00/vlf_count) AS free_log_pct_after_active_log
--FROM cte_vlf_cnt;
--GO






---- 1. MONITORAMENTO DE ARQUIVOS E GHOST RECORDS

--SELECT
--    -- Arquivos Físicos (MDF/LDF)
--    DB_NAME() AS [Database],
--    f.name AS [Nome Lógico],
--    f.type_desc AS [Tipo Arquivo],
--    CAST(f.size AS BIGINT) * 8 / 1024 AS [Tamanho Total MB],

--    -- Métricas de Log (Uso de Espaço no LDF)
--    CASE
--        WHEN f.type_desc = 'LOG' THEN CAST(ls.active_log_size_mb AS VARCHAR)
--        ELSE 'N/A'
--    END AS [Log Usado MB],

--    -- Fragmentação e Densidade de Páginas
--    ps.index_type_desc AS [Tipo Índice],
--    CAST(ps.avg_fragmentation_in_percent AS DECIMAL(5,2)) AS [Fragmentação Lógica %],
--    CAST(ps.avg_page_space_used_in_percent AS DECIMAL(5,2)) AS [Densidade Páginas %],

--    -- Contagem de Páginas e Ghost Records
--    ps.page_count AS [Total Páginas],
--    ps.record_count AS [Registros],
--    ps.ghost_record_count AS [Registros Fantasma],

--    -- ADR (Accelerated Database Recovery) – Específico para versões novas
--    ps.version_ghost_record_count AS [ADR Versão Fantasmas]

--FROM sys.database_files f
--CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Vendas_Grande'), NULL, NULL, 'DETAILED') ps
--LEFT JOIN sys.dm_db_log_stats(DB_ID()) ls 
--    ON f.type_desc = 'LOG'
--WHERE ps.index_id <= 1; -- 0: Heap, 1: Clustered Index (Evita duplicar por índices secundários na demo)

