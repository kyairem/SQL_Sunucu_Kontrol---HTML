use msdb
DECLARE @name NVARCHAR(MAX),@date NVARCHAR(MAX),@disk NVARCHAR(MAX),@succ NVARCHAR(MAX),@fail NVARCHAR(MAX)
SET @name=N'<html><body bgcolor=''#696b6b''><head>
<meta charset="UTF-8"/><style>*{margin-top:0px}  h2{text-align: center;color:"#00695C"}#div{width:65%;height:auto;margin:auto;background-color:#b2cecc;margin-top: 4%; }#ozl_tbl{border-collapse:collapse}
	 #gizle1{display: none;}#gizle2{display: none;}
	 #button1{margin-left: 33%;background-color:#BDBDBD;width: 35%;height:40px;;border-radius:10px;}
	 #button2{margin-left: 33%;background-color:#BDBDBD;width: 35%;height:40px;border-radius: 10px;}
	 #button1:hover{background-color: gray;}
	 #button2:hover{background-color: gray;} </style></head><body><div  id="div">
<h2 style="color:#00695C">SUNUCU BILGILERI</h2>
<table border=''1'' align="center" bgcolor="#80CBC4" id="ozl_tbl">'+ N'<tr><th bgcolor="#BDBDBD">Sunucu Name</th>'

 + CAST((select @@servername as th 
			
FOR XML RAW(''), ELEMENTS
    ) AS NVARCHAR(MAX))

set @date= N'<tr><th bgcolor="#BDBDBD">Tarih</th>'

 + CAST((select convert(varchar, getdate(), 113) as th 
			
FOR XML RAW(''), ELEMENTS
    ) AS NVARCHAR(MAX))
	
	+ N'</table>'
SET @disk = N'<br><hr><br><h2 style="color:#00695C">DISK BILGISI</h2>
			<table border=''3'' align="center" bgcolor="#80CBC4">'+ N'<tr><th bgcolor="#BDBDBD">Disk Mount Point</th>
			<th bgcolor="#BDBDBD">File System Type</th><th bgcolor="#BDBDBD">Total Size in GB</th>
			<th bgcolor="#BDBDBD">Available Size in GB</th>
		<th bgcolor="#BDBDBD">Space Free %</th></tr>'
    + CAST((
	SELECT DISTINCT 
		volume_mount_point as td, 
		file_system_type as td, 
		CONVERT(DECIMAL(18,2),total_bytes/1073741824.0) as td, ---1GB = 1073741824 bytes
		CONVERT(DECIMAL(18,2),available_bytes/1073741824.0)as td,  
		CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 as td 
FROM sys.master_files 
CROSS APPLY sys.dm_os_volume_stats(database_id, file_id) AS t
FOR XML RAW('tr'), ELEMENTS
    ) AS NVARCHAR(MAX))
	+ N'</table>'
SET @succ = N'<br><hr><br><h2 style="color:#00695C">AGENT JOB STATUS (Succeeded)</h2>
			<button id="button1" align="center" onclick="ac1()">JOB STATUS (Succeeded)</button> <br><br>
			<table id="gizle1" border=''3'' align="center" bgcolor="#80CBC4">'+ N'<tr><th bgcolor="#BDBDBD">Name</th>
			<th bgcolor="#BDBDBD">Run Date</th> <th bgcolor="#BDBDBD">Run Time</th>
			<th bgcolor="#BDBDBD">Run Status</th>
		<th bgcolor="#BDBDBD">Run Duration (DD:HH:MM:SS)</th></tr>'
    + CAST((
	SELECT sj.name  as td,
		sh.run_date  as td,
		STUFF(STUFF(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')  as td,
		sh.run_status  as td,
		STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(sh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') as td
FROM msdb.dbo.sysjobs sj
JOIN msdb.dbo.sysjobhistory sh
ON sj.job_id = sh.job_id
where sh.run_status=1
order by 2
FOR XML RAW('tr'), ELEMENTS
    ) AS NVARCHAR(MAX))
	+ N'</table>'
SET @fail = N'<br><hr><br><h2 style="color:#00695C">AGENT JOB STATUS (Failed)</h2>
			<button id="button2" align="center" onclick="ac2()">JOB STATUS (Failed)</button>  <br><br>
			<table id="gizle2" border=''3'' align="center" bgcolor="#80CBC4">'+ N'<tr><th bgcolor="#BDBDBD">Name</th>
			<th bgcolor="#BDBDBD">Run Date</th> <th bgcolor="#BDBDBD">Run Time</th>
			<th bgcolor="#BDBDBD">Run Status</th>
		<th bgcolor="#BDBDBD">Run Duration (DD:HH:MM:SS)</th></tr>'
    + CAST((
	SELECT sj.name  as td,
		sh.run_date  as td,
		STUFF(STUFF(RIGHT(REPLICATE('0', 6) +  CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')  as td,
		sh.run_status  as td,
		STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(sh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') as td
FROM msdb.dbo.sysjobs sj
JOIN msdb.dbo.sysjobhistory sh
ON sj.job_id = sh.job_id
where sh.run_status=0
order by 2
FOR XML RAW('tr'), ELEMENTS
    ) AS NVARCHAR(MAX))
    + N'</table></div><script>
		function ac1() {document.getElementById("gizle1").style.display="inline-block";
			document.getElementById("button1").style.display="none";}
		function ac2() {document.getElementById("gizle2").style.display="inline-block";
document.getElementById("button2").style.display="none";}
	</script></body></html>'

select @name + @date + @disk +@succ + @fail
