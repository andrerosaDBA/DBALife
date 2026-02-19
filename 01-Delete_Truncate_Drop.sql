Use TESTE
go


--criar uma tabela de teste com 3 colunas e 3 linhas, para exemplificar o uso do DELETE, TRUNCATE e DROP, uma das colunas deve ser do tipo IDENTITY para exemplificar o comportamento do TRUNCATE


--CREATE TABLE TesteDeleteTruncateDrop (
--	ID INT IDENTITY(1,1) PRIMARY KEY,
--	Nome VARCHAR(50),
--	Idade INT
--);



--============================================================
--			Delete:: TesteDeleteTruncateDrop				--
--============================================================

--Drop Table If Exists TesteDeleteTruncateDrop_02;

select count(1) 
--into TesteDeleteTruncateDrop_02
from TesteDeleteTruncateDrop;

--delete from TesteDeleteTruncateDrop;


Declare @count int,
		@contador	int = 0,
		@contadorbkp	smallint = 0


select @count = count(1) from TesteDeleteTruncateDrop;
print @count

While @contador <= @count
	Begin
	print 'Contador: ' + cast(@contador as varchar(10)) + ' - Count: ' + cast(@count as varchar(10));
		
		;With cte_delete AS (
								Select top(1) ID from TesteDeleteTruncateDrop order by ID Desc
							)

		delete tbl from TesteDeleteTruncateDrop As tbl Join cte_delete As cte on tbl.id = cte.id;
		
		set @contador = @contador + 1;

		set @contadorbkp = @contadorbkp + 1;

		-- Apenas para simular a execução do bkp de log que geralmente ocorre a cada 10 / 15min no ambiente de produção, 
		--para evitar o crescimento do log e consequentemente o preenchimento do mesmo, 
		--o que pode impedir novas operações de escrita no banco de dados, como o delete, insert, update, etc.
		--While (@contadorbkp <= 5 and @contador > 0)
		--	Begin
		--		print 'Faz o bkp de log:: ';
		--		backup log TESTE to disk = N'Nul'

		--		set @contadorbkp = 0 ;
		--	End

	End




--Qtd de registros da tabela.
select count(1) As Qtd_Reg from TesteDeleteTruncateDrop;

--Retorna o menor valor do ID da tabela.
Select min(ID) As Min_Id from TesteDeleteTruncateDrop;

--Retorna o valor do ID da última linha inserida na tabela.
Select IDENT_CURRENT('TesteDeleteTruncateDrop') as Ident_Current

--Retorna o maior valor do ID da tabela.
Select max(ID) As Max_Id from TesteDeleteTruncateDrop;

--Retorna os 10 primeiros registros da tabela.
Select top(10) * from TesteDeleteTruncateDrop Order By ID;

--Retorna os 10 últimos registros da tabela.
Select top(10) * from TesteDeleteTruncateDrop Order By ID Desc;



--============================================================
--			Truncate:: TesteDeleteTruncateDrop_02			--
--============================================================


--Qtd de registros da tabela.
select count(1) As Qtd_Reg from TesteDeleteTruncateDrop_02;

--Retorna o menor valor do ID da tabela.
Select min(ID) As Min_Id from TesteDeleteTruncateDrop_02;

--Retorna o valor do ID da última linha inserida na tabela.
Select IDENT_CURRENT('TesteDeleteTruncateDrop_02') as Ident_Current

--Retorna o maior valor do ID da tabela.
Select max(ID) As Max_Id from TesteDeleteTruncateDrop_02;

--Retorna os 10 primeiros registros da tabela.
Select top(10) * from TesteDeleteTruncateDrop_02 Order By ID;

--Retorna os 10 últimos registros da tabela.
Select top(10) * from TesteDeleteTruncateDrop_02 Order By ID Desc;

--Trunca os dados da tabela, removendo todas as linhas e reiniciando 
--o valor do IDENTITY para o valor inicial definido na criação da tabela.
Truncate Table TesteDeleteTruncateDrop_02;


--Qtd de registros da tabela.
select count(1) As Qtd_Reg from TesteDeleteTruncateDrop_02;

--Retorna o valor do ID da última linha inserida na tabela.
Select IDENT_CURRENT('TesteDeleteTruncateDrop_02') as Ident_Current


--============================================================
--				Drop:: TesteDeleteTruncateDrop_02			--
--============================================================

--Apaga a tabela do banco de dados, removendo a estrutura e os dados da tabela.
Drop Table TesteDeleteTruncateDrop_02;

--Qtd de registros da tabela, dará erro , pois a tabela foi apagada.
select count(1) As Qtd_Reg from TesteDeleteTruncateDrop_02;

select * from sys.tables where name = 'TesteDeleteTruncateDrop_02'



--Delete

SELECT top(100)
    [Transaction ID],
    [RowLog Contents 0] AS Hexadecimal_Bruto,
    [Log Record Fixed Length],
    [Log Record Length], 
	[AllocUnitName],
    [Begin Time]
FROM fn_dblog(NULL, NULL)
WHERE [AllocUnitName] LIKE '%TesteDeleteTruncateDrop%'
  AND [Operation] = 'LOP_DELETE_ROWS'
  AND [Context] = 'LCX_MARK_AS_GHOST'
ORDER BY [Begin Time] DESC;


--Truncate.

SELECT
    [Transaction ID],
    [Operation],
    [Context],
    [AllocUnitName],
    [Begin Time]
FROM fn_dblog(NULL, NULL)
WHERE [Operation] IN ('LOP_DEALLOC_EXTENT', 'LOP_HOBT_DDL')
ORDER BY [Begin Time] DESC;

--Drop

SELECT
    [Transaction ID],
    [Operation],
    [Context],
    [Transaction Name],
    [AllocUnitName],
    [Begin Time]
FROM fn_dblog(NULL, NULL)
WHERE [Transaction Name] LIKE '%DROPOBJ%'
   OR [Operation] = 'LOP_DROP_OBJECT'
ORDER BY [Begin Time] DESC;




/*

Delete:

1- Para cada registro deletado, o sql marca como "ghost record", ou seja, o registro não é removido fisicamente do banco de dados.
2- Crescimento do log de transações, pois cada registro deletado é registrado no log de transações.
3- Cria "buracos" na sequência do identity.
4- Pode atingir o limite do tipo de dados mais cedo.
5- É possível recuperar os dados deletados a partir do log de transações, caso seja necessário.


Truncate:

1- Remove todas as linhas da tabela, mas mantém a estrutura da tabela e os índices.
2- Reinicia o valor do IDENTITY para o valor inicial definido na criação da tabela.
3- Não registra cada linha deletada no log de transações, apenas registra a desallocação das páginas de dados.
4- Não é possível recuperar os dados truncados a partir do log de transações, apenas voltando os backups do banco de dados.

Drop:

1- Remove a tabela do banco de dados, incluindo a estrutura e os dados da tabela.
2- Remove também os índices, restrições, triggers e outros objetos relacionados à tabela.
3- Não é possível recuperar a tabela e os dados apagados a partir do log de transações, apenas voltando os backups do banco de dados.


Qual a melhor opção? Depende!

*/