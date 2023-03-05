# Considerações Gerais

O provedor de Cloud Computing utilizado é a AWS.
É utilizado Terraform como ferramenta de IaC e o Github Actions para pipeline de deploy automatizado

O script de Terraform cria a VPC e uma subnet pública. Após a criação da rede, o Terraform cria uma instância EC2 utilizando Amazon Linux 2 dentro dessa mesma subnet e, após a criação, é exibido o IP público para que seja possível acessar a aplicação.

A instância que é lançada utiliza o sistema operacional Amazon Linux 2 e no "Userdata" tem o script que instala os pacotes necessários para rodar o Gunicorn. Após isso, é baixado a aplicação de um repositório no github e em seguida é iniciado o serviço.

O pipeline de deploy automático utiliza o Github Actions e em um runner Ubuntu executa o Terraform utilizando as credenciais configuradas nas Actions Secrets. Sendo dessa forma para evitar de ter credeciais nos arquivos. Obs: as credenciais utilizada já estão desativadas na conta da AWS utilizada para o teste.

Para monitoramento do serviço, é utilizado o Cloudwatch da AWS. O serviço monitora se a instancia EC2 está DOWN e envia um alerta por email caso aconteça.
