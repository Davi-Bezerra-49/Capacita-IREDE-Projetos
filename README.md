# Capacita iRede — Projeto de Infraestrutura como Código (Unidade 6)

Esse é o meu projeto da atividade Desenvolvimento de Projeto (Avançado).
A proposta era montar a infraestrutura de um e-commerce simulado na AWS usando só Terraform,
com duas APIs (Produtos e Pedidos) se comunicando de forma assíncrona via fila.

## Projeto

Montei o seguinte fluxo:

```
Usuário → API na EC2 (Flask) → Fila SQS (pedidos-a-processar) → Lambda → CloudWatch Logs
```

- Uma **VPC** com subnet pública, Internet Gateway e Route Table, pra EC2 ter saída pra internet.
- Uma **EC2** que já sobe com a API instalada sozinha (usei `user_data` pra isso, assim não preciso entrar na máquina manualmente pra configurar nada).
- A API tem duas rotas: `/produtos` (lista fixa de produtos) e `/pedidos` (recebe um pedido e manda pra fila SQS).
- Uma fila **SQS** chamada `pedidos-a-processar`, que recebe o que a API de Pedidos envia.
- Uma função **Lambda** que é disparada automaticamente sempre que cai uma mensagem na fila, e só registra um log no CloudWatch dizendo que recebeu o pedido.
- Um **Security Group** liberando a porta 22 (SSH, caso eu precise entrar na EC2) e a 5000 (onde a API roda).
- **IAM Roles** separadas: a EC2 só tem permissão de mandar mensagem pro SQS, e a Lambda só tem permissão de ler/apagar da fila e escrever log. Não deixei nada com permissão de administrador à toa.

Toda essa infraestrutura está dividida em arquivos separados dentro da pasta `terraform/`, cada um com uma função pela qual é responsável.

## Estrutura do repositório

```
capacita-irede/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── sqs.tf
│   ├── lambda.tf
│   ├── lambda_function.py
│   ├── user_data.sh.tpl
│   └── outputs.tf
├── api/
│   └── app.py
├── evidencias/
│   ├── 01-api-produtos.jpg
│   ├── 02-api-pedidos.jpg
│   ├── 03-sqs-fila.png
│   └── 04-cloudwatch-log.png
└── README.md
```

## Decisão Do Projeto

- Configurei minha conta AWS na região **`eu-north-1`** (Estocolmo), então deixei ela como padrão nas variáveis do projeto.
- Tive que trocar o tipo da instância de `t2.micro` pra **`t3.micro`**, porque descobri que a família t2 não existe nessa região — deu erro de "não elegível pro Free Tier" até eu perceber isso.

## Pré-requisitos

- Conta AWS configurada (`aws configure` com Access Key, Secret Key e região)
- Terraform instalado
- Um Key Pair já criado na conta AWS (usei o nome `Capacita`)

## Terraform

```powershell
cd terraform
terraform init
terraform apply -var="key_name=Capacita"
```

Se a região da sua CLI for diferente de `eu-north-1`, precisa passar também `-var="aws_region=SUA_REGIAO"`,
senão dá erro de key pair não encontrado (foi o que aconteceu comigo no começo).

Depois do `apply`, o Terraform mostra o IP público da EC2 e a URL da fila SQS. A EC2 demora
uns 1-2 minutos pra terminar de instalar a API sozinha.

## Teste

Como uso Windows, testei pelo PowerShell com `Invoke-RestMethod`.
```powershell
# Listar produtos
Invoke-RestMethod -Uri "http://<IP_DA_EC2>:5000/produtos"

# Criar um pedido (isso manda a mensagem pro SQS)
Invoke-RestMethod -Uri "http://<IP_DA_EC2>:5000/pedidos" -Method Post -ContentType "application/json" -Body '{"produto": "Notebook", "quantidade": 1}'
```

## Como testei o fluxo completo

1. Rodei o `Invoke-RestMethod` de POST em `/pedidos` (acima).
2. Fui no console da AWS em **SQS → pedidos-a-processar** conferir a fila.
3. Fui em **CloudWatch → Log groups → /aws/lambda/capacita-irede-processa-pedido**, abri o log stream mais recente e confirmei a linha `Novo pedido recebido da fila` — isso mostra que a Lambda pegou a mensagem da fila sozinha.

## Evidências

### EC2 rodando (API de Produtos e Pedidos)

![Resposta da API de Produtos](01-api-produtos.jpg)

![Resposta da API de Pedidos enviando ao SQS](02-api-pedidos.jpg)

### Mensagem chegando no SQS

![Fila pedidos-a-processar no console AWS](03-sqs-fila.png)

### Log da Lambda no CloudWatch

![Log da Lambda mostrando o pedido recebido](04-cloudwatch-log.png)

### Saída do `terraform apply`

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:
ec2_public_ip = "13.49.69.179"
lambda_function_name = "capacita-irede-processa-pedido"
sqs_queue_url = "https://sqs.eu-north-1.amazonaws.com/089496391042/pedidos-a-processar"
```

## Encerrando

Depois de tirar as evidências, derrubei a infraestrutura pra não ficar nada rodando à toa na AWS:

```powershell
terraform destroy -var="key_name=Capacita"
```
