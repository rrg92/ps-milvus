# Milvus Client Powershell

This is a simple PowerShell module to connect to Milvus Vector DB from your terminal.  

To install:

```powershell
Install-Module milvus 
```

## Basic usage

First, you must create a Milvus session:

```powershell
Connect-Milvus https://mymilvus:19530 -user myuser -password mypass -Defaultdb MyAwesomeVectorDb -DefaultCollection Products

# DefaultDb and DefaultCollection are optional parameters!

```

> [!TIP]
> You can set password and user using environment variables `MILVUS_USER` and `MILVUS_PASSWORD`, respectively.

Now, you can use other Milvus commands available.  

> [!IMPORTANT]
> This module does not support multiple sessions yet. Calling `Connect-Milvus` again will overwrite the previously created session.

For example, to index new data into an existing collection:

```powershell
# For example, using the PowerShell module `Get-OpenaiEmbeddings` to get embeddings.
# You can use any command that produces some embedding!
$SomeEmbeddings = Get-OpenaiEmbeddings -text "my awesome product description"

Add-MilvusVector @{ MyEmbeddingField = $SomeEmbeddings; AnotherData = 123; SomeJsonData = @{a=1;b=2} }
```

Note that the command `Add-MilvusVector` takes a hashtable as input.  
That command accepts an object as input and it will be converted to JSON and sent to the Milvus API. 
Obviously, the schema of your collection must match the schema of the object passed.

You can use `Search-MilvusVector` to search data:

```powershell
# For example, using the PowerShell module `Get-OpenaiEmbeddings` to get embeddings.
# You can use any command that produces some embedding!
$SomeEmbeddings = Get-OpenaiEmbeddings -text "best clothes for spring"

Search-MilvusVector $SomeEmbeddings -limit 10 -outputFields MyField1,MyField2
```

Star this project to keep updated when new commands or fixes are implemented!
