$ErrorActionPreference = "Stop";

if(!$Global:MILVUS_CLIENT_DATA){
	$Global:MILVUS_CLIENT_DATA = @{
		Session = $null
	}
}


<#
	.SYNOPSIS 
		Send Http Requests to Milvus API
#>
function Invoke-MilvusHttp {
	[CmdletBinding()]
	param(
		 #Path 
		$endpoint
		
		,#Body Data
			$data		= @{}
			
		,#Session to use 
			$session	= $MILVUS_CLIENT_DATA.Session
			
		,#http method 
			$method 	= "POST"
			
		,#Return raw http answer!
			[switch]$raw
	)
	
	$MilvusUrl = $Session.url;

	$VectorDataJSon = $data | ConvertTo-Json -Compress -Depth 5;
	
	$headers = @{}
	
	if($session.User){
		$headers.Authorization = "Bearer $($session.user):$($session.password)"
	}
	
	$VectorReq = @{
		uri 			= "$MilvusUrl/$endpoint" 
		ContentType 	= "application/json; charset=utf-8"
		body 			= $VectorDataJSon
		method 			= $method
		headers 		= $headers
		UseBasicParsing	= $true
	}
	
	$ProgressPreference = "SilentlyContinue";
	$resp = Invoke-WebRequest @VectorReq;
	$respo = $resp.Content | ConvertFrom-Json;
	
	if($raw){
		return $respo;
	}
	
	if($respo.code){
		$msg = "MILVUSCLIENT_ERROR: $($respo.code) $($respo.message)"
		$ex = New-Object System.Exception($msg)
		$ex | Add-Member -force Noteproperty MilvusData @{
			HttpResp 	= $resp
			respo 		= $respo
		}
		
		throw $ex;
	}
	
	write-output -NoEnumerate $respo.data;
}

<#
	.SYNOPSIS
		Create (and reset) a milvus session!
#>
function Connect-Milvus {
	[CmdletBinding()]
	param(
		 #Milvus url
		 $url
		 
		,#Milvus user
			$user				= $Env:MILVUS_USER
			
		,#Milvus password 
			$password			= $Env:MILVUS_PASSWORD
			
		,#Default milvus db 
			$DefaultDb 		= $null
			
		,#Default Milvus collection
			$DefaultCollection	= $null
	)
	
	$Session = [PsCustomObject]@{
					url 		= $url
					user 		= $user 
					password  	= $password
					db 			= $DefaultDb
					collection 	= $DefaultCollection
				}
				
				
	$MILVUS_CLIENT_DATA.Session = $Session
}

<#
	.SYNOPSIS
		List milvus collections
#>
function Get-MilvusCollection {
	[CmdletBinding()]
	param(
		#Db where list. If null, use defaults set with Connect-Milvus
		$dbname
	)
	
	$data 		= @{}
	$Session 	= $MILVUS_CLIENT_DATA.Session
	
	
	if($dbName){
		$data.dbName = $dbName;
	}
	elseif($Session.db){
		$data.dbName = 	$Session.db
	}
	
	Invoke-MilvusHttp 'v2/vectordb/collections/list' -data $data
}

<#
	.SYNOPSIS
		Adds (index) data into milvus
#>
function Add-MilvusVector {
	[CmdletBinding()]
	param(
		 #Data to index, will be converted to json.
		 $Data
		
		,#Db name. If null, use defaults set in Connect-Milvus
			$DbName 			= $null
			
		,#Collection name, if null, use defaults set in Connect-Milvus 
			$CollectionName	= $null
	)
	
	$ReqData 		= @{
		data 	= @($Data)
	}
	$Session 	= $MILVUS_CLIENT_DATA.Session
	
	
	if($dbName){
		$ReqData.dbName = $dbName;
	}
	elseif($Session.db){
		$ReqData.dbName = 	$Session.db
	}
	
	if($CollectionName){
		$ReqData.CollectionName = $CollectionName
	}
	elseif($Session.collection){
		$ReqData.CollectionName = 	$Session.collection
	}
	
	
	Invoke-MilvusHttp 'v2/vectordb/entities/insert' -data $ReqData
	
}

function Set-MilvusEmbeddingConverter {
	param(
		$command
	)
	
	$Global:MILVUS_CLIENT_DATA.Converter = $command;
}


<#
	.SYNOPSIS
		Search data in Milvus and returns
#>
function Search-MilvusVector {
	[CmdletBinding()]
	param(
		 #Embedding to search 
		 #If this a string, then it will call command set in Set-MilvusEmbeddingConverter
			$embeddings
			
		,#Field where check 
			$field = $null
			
		,#Limit results
			$limit 			= $null
			
		,#Skip results 
			$offset 			= $null
			
		,#Array specifying list of fields to return
			[string[]]$outputFields = $null
			
		,#Db name. If null, use defaults set in Connect-Milvus
			$DbName = $null
			
		,#Db name. If null, use defaults set in Connect-Milvus
			$CollectionName	= $null
	)
	
	if($embeddings -is [string]){
		$ConverterCommand = $Global:MILVUS_CLIENT_DATA.Converter;
		
		if($ConverterCommand){
			$embeddings = & $ConverterCommand $embeddings
		} else {
			throw "MILVUS_CONVERTERCOMMAND_NOTSET: Must set a converter command with Set-MilvusEmbeddingConverter"
		}
		
	}
	
	$ReqData 		= @{
		data 		= ,$embeddings
		annsField	= $field	
	}
	$Session 	= $MILVUS_CLIENT_DATA.Session
	
	if($limit){
		$ReqData.limit = $limit 
	}
	
	if($offset){
		$ReqData.offset = $offset  
	}
	
	if($outputFields){
		$ReqData.outputFields = @($outputFields)
	}
	
	if($dbName){
		$ReqData.dbName = $dbName;
	}
	elseif($Session.db){
		$ReqData.dbName = 	$Session.db
	}
	
	if($CollectionName){
		$ReqData.CollectionName = $CollectionName
	}
	elseif($Session.collection){
		$ReqData.CollectionName = 	$Session.collection
	}
	
	
	Invoke-MilvusHttp 'v2/vectordb/entities/search' -data $ReqData
	
}