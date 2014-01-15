/*------------------------------------------
  Static Query
  2013. Jeewhan Kim
------------------------------------------*/

CREATE PROC dbo.get_match
 
@test_id  int = 0 
, @test_name varchar(100) ='' 
, @active  varchar(1) ='' 
, @PageIndex  INT = 1
, @ListCountPerPage INT = 20
 
as 
set nocount on 
set transaction isolation level read uncommitted 
 
if (@PageIndex = 1) 
begin 
 select top(@ListCountPerPage)
 gb.brand_no, gb.test_name, gb.active, gb.reg_id, gb.reg_dt 
 	from brand_table gb with(nolock) 
 		where (  gb.brand_no = @test_id or @test_id = 0) 
  		and ( gb.test_name = @test_name or @test_name = '') 
  		and ( gb.active = @active or @active='' ) 
 	order by brand_no desc 
end 
else 
begin 
 select brand_no, test_name, active, reg_id, reg_dt
 	from( 	select top(@ListCountPerPage * @PageIndex) gb.brand_no, gb.test_name, gb.active, gb.reg_id, gb.reg_dt, row_number() over (order by brand_no desc) as RowNumber 
		from brand_table gb with(nolock) 
  		where (  gb.brand_no = @test_id or @test_id = 0) 
   		and ( gb.test_name = @test_name or @test_name = '') 
   		and ( gb.active = @active or @active='' ) 
 	) as Paging 
	where RowNumber > (@ListCountPerPage * (@PageIndex -1)) 
 	and RowNumber <= (@ListCountPerPage * @PageIndex) 
 order by RowNumber 
end

/*-------------------------------------------
  Dynamic Query
--------------------------------------------*/

CREATE PROC dbo.get_match_dynamic

@test_id  int = 0
, @test_name varchar(100) =''
, @active  varchar(1) =''
, @PageIndex  INT = 1
, @ListCountPerPage INT = 20

as
set nocount on
set transaction isolation level read uncommitted

DECLARE @response            nvarchar(max)
DECLARE @params   nvarchar(512)

SET @params = N'@Ntest_id varchar(10), @Ntest_name varchar(100), @Nactive varchar(1), @NPageIndex int, @NListCountPerPage int '
if (@PageIndex = 1)
begin
 SET @response =
 N'select top(@NListCountPerPage)
 gb.test_id, gb.test_name, gb.active, gb.reg_id, gb.reg_dt
 from brand_table gb with(nolock)'

 IF @test_id <> 0
BEGIN
    SET @response = @response + ' where ( gb.test_id = @Ntest_id)'
END
ELSE
BEGIN
 SET @response = @response + ' where gb.test_id <> '''''
END
IF @test_name <> ''
BEGIN
 SET @response = @response + ' and (gb.test_name LIKE ''%''+@Ntest_name+''%'')'
END
IF @active <> ''
BEGIN
 SET @response = @response + ' and (gb.active = @Nactive)'
END
SET @response = @response + ' order by test_id desc'
end
else
begin
 SET @response =
 N'select test_id, test_name, active, reg_id, reg_dt
 from(
 select top(@NListCountPerPage * @NPageIndex)
 gb.test_id, gb.test_name, gb.active, gb.reg_id, gb.reg_dt
 , row_number() over (order by brand_no desc) as RowNumber
 from brand_table gb with(nolock)'
  IF @test_id <> 0
BEGIN
    SET @response = @response + ' where ( gb.test_id = @test_id)'
END
ELSE
BEGIN
 SET @response = @response + ' where gb.test_id <> '''''
END
IF @test_name <> ''
BEGIN
 SET @response = @response + ' and (gb.test_name LIKE ''%''+@Ntest_name+''%'')'
END
IF @active <> ''
BEGIN
 SET @response = @response + ' and (gb.active = @Nactive)'
END
 SET @response = @response + ' ) as Paging
 where RowNumber > (@NListCountPerPage * (@NPageIndex -1))
 and RowNumber <= (@NListCountPerPage * @NPageIndex)
 order by RowNumber'
end

EXEC SP_EXECUTESQL
	@response, @params,
 	@Ntest_id = @test_id,
 	@Ntest_name = @test_name,
 	@Nactive = @active,
 	@NPageIndex = @PageIndex,
 	@NListCountPerPage = @ListCountPerPage
 