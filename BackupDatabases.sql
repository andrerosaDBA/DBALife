

--Se necessário, executar a alteração da credencial.
--Obs: alterar a SAS TOKEN
 ALTER CREDENTIAL [https://labblobdp300.blob.core.windows.net/lab-migracao-sql-to-mi] 
 WITH IDENTITY = 'SHARED ACCESS SIGNATURE',  
 SECRET = 'sp=rwdl&st=2026-01-20T22:58:10Z&se=2026-01-28T07:13:10Z&spr=https&sv=2024-11-04&sr=c&sig=41hcrB%2Fps0%2FpuTFuLhfwoIrCFcSINRPKZc9%2Bv5Yc5XY%3D';  
 GO


 -- Take a full database backup to a URL
 BACKUP DATABASE [AdventureWorksLT]
 TO URL = 'https://labblobdp300.blob.core.windows.net/lab-migracao-sql-to-mi/AdventureWorksLT_full.bak'
 WITH INIT, COMPRESSION, CHECKSUM
 GO
    
 -- Take a differential database backup to a URL
 BACKUP DATABASE [AdventureWorksLT]
 TO URL = 'https://labblobdp300.blob.core.windows.net/lab-migracao-sql-to-mi/AdventureWorksLT_diff.bak'  
 WITH DIFFERENTIAL, COMPRESSION, CHECKSUM
 GO
    
 -- Take a transactional log backup to a URL
 BACKUP LOG [AdventureWorksLT]
 TO URL = 'https://labblobdp300.blob.core.windows.net/lab-migracao-sql-to-mi/AdventureWorksLT_log.trn'  
 WITH COMPRESSION, CHECKSUM


 /*
 TESTE 01 - Backup de banco de dados para URL do Azure Blob Storage
 */