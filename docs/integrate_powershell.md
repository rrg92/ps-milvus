## PowerShell Milvus Client

### About PowerShell

PowerShell is the native shell for Windows operating systems.  
With it, you can execute a variety of commands and create scripts that can perform virtually any action on your computer.  

PowerShell is built on .NET, so you can access all the native classes and objects of .NET.
This makes it an extremely powerful shell: You can query Windows logs, running programs, hardware information, software, read and write files, open programs, connect to SQL, make HTTP requests, etc.  

For example, this is a code snippet to list the collections of a Milvus instance with authentication enabled:

```powershell 
iwr -me POST http://localhost:19530/v2/vectordb/collections/list -h @{ Authorization = "Bearer root:Milvus" } -b '{}'
```

In addition, it has support for the main elements of object-oriented programming: Loops, conditionals, logical operators, support for regular expressions, etc., and with many flexibilities. Unlike a program in C#, to run PowerShell code and scripts, simply open PowerShell in Windows and type commands, or open a simple notepad, write your script and invoke it in the terminal through its path!


PowerShell allows the creation of modules, which are "libraries" that can be imported into your session. These libraries can add several new commands to your PowerShell session, making it even richer and more flexible. Many people and companies create and share these modules!

## The Milvus Module

With the growth of AI, it is natural that at some point someone will want to integrate PowerShell scripts with these technologies, while maintaining all the flexibility of PowerShell. Therefore, the ps-milvus module, or simply `milvus`, was created.  

The command below is a simple example of how you could use the module to index the content, for example, of your Windows logs using Milvus (using embeddings from ollama).  

For the example below, we will use a collection called winlogs, in the database called IaTalking. The structure is this:

![Winlogs collection structure](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSampleWinLogs.png)

```powershell 

# Install the module (do this only once)
Install-Module -Scope CurrentUser milvus;

# Import the module in the section!
import-module milvus

# Create a session with Milvus!
# Optionally, you can inform a default database and collection, where all module commands operate
Connect-Milvus http://localhost:19530 -user root -password Milvus -DefaultDb IaTalking -DefaultCollection winlogs

# This is a simple function that encapsulates the call to ollama 
# It's on one line to keep it compact, but could be created in a script, better formatted and indented!
function GetEmbedding($text){((iwr http://localhost:11434/api/embed -met POST -Body (@{model="nomic-embed-text"; input = $text}|ConvertTo-Json)).Content | ConvertFrom-Json).embeddings[0]}


# Let's get the logs and invoke the command!
Get-WinEvent -Log Application -Max 20 | %{ Add-MilvusVector @{EvtId=$_.Id;embedding=(GetEmbedding $_.message);msg=$_.message}}


# And you can search these logs with this command
Search-MilvusVector -limit 10 (GetEmbedding "performance problems") -outputFields EvtId,msg
```

Below are some images of the above commands executed in a local test Milvus:

_Inserting data_
![inserting](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSamplePowershell.png)

_Inserted data, as seen by Attu_
![data attu](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSampleInsertedUi.png)

_Searching data_
![searching](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSampleSearch.png)



Learn more about the module at: https://github.com/rrg92/ps-milvus