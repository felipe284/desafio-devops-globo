# Considerações Gerais

O provedor de Cloud Computing utilizado é a AWS.
É utilizado Terraform como ferramenta de IaC e o Github Actions para pipeline de deploy automatizado.

O script de Terraform cria a VPC, uma subnet pública, o internet gateway e as rotas necessárias. Após a criação da rede, o Terraform cria uma instância EC2 utilizando Amazon Linux 2 dentro dessa mesma subnet e cria um Security Group que libera o acesso a porta 8000. Após a criação, é exibido o IP público para que seja possível acessar a aplicação.

A instância que é lançada utiliza o sistema operacional Amazon Linux 2 e no "Userdata" tem o script que instala os pacotes necessários para rodar o Gunicorn. Após isso, é baixado a aplicação de um repositório no github e em seguida é iniciado o serviço.

O pipeline de deploy automático utiliza o Github Actions e em um runner Ubuntu executa o Terraform utilizando as credenciais configuradas nas Actions Secrets. Sendo dessa forma para evitar de ter credeciais nos arquivos. Obs: as credenciais utilizadas já estão desativadas na conta da AWS utilizada para o teste.

Para monitoramento do serviço, é utilizado o Cloudwatch da AWS. O serviço monitora se a instancia EC2 está DOWN e envia um alerta por email caso aconteça.

Os testes iniciais foram feitos diretamente da minha estação rodando o Terraform e criando o ambiente na conta de testes da AWS. Após ter ambiente funcionando, migrei os códigos para o repositório do Github e comecei os testes do deploy automatizado.

Os últimos testes devem apresentar falhas relacionadas ao EC2 pois provavelmente está havendo alguma limitação do Free Tier da minha conta da AWS. Em outra conta os scripts devem funcionar perfeitamente.

Fico a disposição

Obrigado!
