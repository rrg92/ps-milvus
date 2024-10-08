# PowerShell Milvus Client

## Sobre o Powershell 

O Powershell é o shell nativo para sistemas operacionais Windows.  
Com ele, você pode executar os mais variados comandos e criar scripts que podem realizar praticamente qualquer ação no seu computador.  

O PowerShell é feito em .NET, e por isso você consegue acessar todas as classes e objetos nativos do .NET
E isso o torna um shell extremamente poderoso: Você pode consultar logs do Windows, programas em execução, informações de hardware, software, ler e escrever arquivos, abrir programas, conectar com sql, realizar requisições HTTP, etc.  

Por exemplo, este é um trecho de código para listar as collections de uma instância Milvus com autenticação habilitada:

```powershell 
iwr -me POST http://localhost:19530/v2/vectordb/collections/list -h @{ Authorization = "Bearer root:Milvus" } -b '{}'
```

Além disso, ele tem suporte aos principais elementos da programação orientada a objetos: Loops, condicionais, operadores lógicos, suporte a expressões regulares, etc., e com muitas flexibilidades. Ao contrário de um programa em C#, para rodar código e script powershell, basta abrir o powershell no Windows e digitar comandos, ou abrir um simples notepad, escrever o seu script e invocá-lo no terminal através do seu caminho!


O powershell permite a criação de módulos, que são "bibliotecas" que podem ser importadas em sua sessão. Estas bibliotecas podem adicionar vários novos comandos na sua sessão do powershell, tornando-o ainda mais rico e flexível. Muitas pessoas e empresas criam e compartilham esses módulos!

## O módulo Milvus

Com o crescimento da IA, é natural que em algum momento alguém queira integrar scripts powershell com estas tecnologias, ao mesmo tempo que mantenha toda a flexibilidade do Powershell. Por isso, o módulo ps-milvus, ou apenas `milvus`, foi criado.  

O comando abaixo é um simples exemplo de como você poderia usar o módulo para indexar o conteúdo, por exemplo, de logs do seu Windows usando Milvus (usando embeddings do ollama).  

Para o exemplo abaixo, iremos usar uma collection chamada winlogs, no banco chamado IaTalking. A estrutura é essa:

![Estrutura da collection winlogs](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSampleWinLogs.png)

```powershell 

# Instale o módulo (isso faz apenas uma vez)
Install-Module -Scope CurrentUser milvus;

# Importe o módulo na seção!
import-module milvus

# Crie uma sessão com o Milvus!
# Opcionalmente, você pode informar um banco e collection default, onde todos os comandos do modulo operam
Connect-Milvus http://localhost:19530 -user root -password Milvus -DefaultDb IaTalking -DefaultCollection winlogs

# Esta é uma função simples que encapsula a chamada pro ollama 
# Está em uma linha para deixar compacto, mas poderia cria-la em um script, melhor formatada e identada!
function GetEmbedding($text){((iwr http://localhost:11434/api/embed -met POST -Body (@{model="nomic-embed-text"; input = $text}|ConvertTo-Json)).Content | ConvertFrom-Json).embeddings[0]}


# Vamos pegar os logs e invocar o comando!
Get-WinEvent -Log Application -Max 20 | %{ Add-MilvusVector @{EvtId=$_.Id;embedding=(GetEmbedding $_.message);msg=$_.message}}


# E você pode buscar estes logs com este comando
Search-MilvusVector -limit 10 (GetEmbedding "performance problems") -outputFields EvtId,msg
```

Abaixo algumas imagens do comandos acima executados em Milvus local de teste:

_Inserindo dados_
![inserindo](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSamplePowershell.png)

_Dados inseridos, visto pelo Attu_
![dados attu](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSampleInsertedUi.png)

_Buscando dados_
![buscando](https://iatalk.ing/wp-content/uploads/2024/10/MilvusSampleSearch.png)



Saiba mais sobre o módulo em: https://github.com/rrg92/ps-milvus

