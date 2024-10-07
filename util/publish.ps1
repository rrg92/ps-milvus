<#
	Publica na PSGalery!
#>
[CmdletBinding()]
param(
	$ApiKey = $Env:PSGALERY_KEY
	,[switch]$Publish
	,[switch]$CheckVersion
)

$ErrorActionPreference = "Stop";

[string]$ModuleRoot = Resolve-Path "milvus"


# Module version!
if($CheckVersion){
	# Current version!
	$LastTaggedVersion = git describe --tags --match "v*" --abbrev=0;
	
	if(!$LastTaggedVersion){
		throw "No version tags!";
	}

	$TaggedVersion = [Version]($LastTaggedVersion.replace("v",""))


	$Mod = import-module $ModuleRoot -force -PassThru;

	if($TaggedVersion -ne $Mod.Version){
		throw "MILVUS_PUBLISH_INCORRECT_VERSION: Module = $($Mod.Version) Git = $TaggedVersion";
	}
}

if($Publish){
	$PublishParams = @{
		Path 		= $ModuleRoot
		NuGetApiKey = $ApiKey
		Force 		= $true
		Verbose 	= $true;
	}
	Publish-Module -Path $ModuleRoot -NuGetApiKey $ApiKey -Force -Verbose
}