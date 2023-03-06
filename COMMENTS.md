# Considerações Gerais

O provedor de Cloud Computing utilizado é a AWS.
É utilizado Terraform como ferramenta de IaC e o Github Actions para pipeline de deploy automatizado.

O script de Terraform cria a VPC, uma subnet pública, o internet gateway e as rotas necessárias. Após a criação da rede, o Terraform cria uma instância EC2 utilizando Amazon Linux 2 dentro dessa mesma subnet e cria um Security Group que libera o acesso a porta 8000. Após a criação, é exibido o IP público para que seja possível acessar a aplicação.

A instância que é lançada utiliza o sistema operacional Amazon Linux 2 e no "Userdata" tem o script que instala os pacotes necessários para rodar o Gunicorn. Após isso, é baixado a aplicação de um repositório no github e em seguida é iniciado o serviço.

O pipeline de deploy automático utiliza o Github Actions e em um runner Ubuntu executa o Terraform utilizando as credenciais configuradas nas Actions Secrets. Sendo dessa forma para evitar de ter credeciais nos arquivos. Obs: as credenciais utilizadas já estão desativadas na conta da AWS utilizada para o teste.

Para monitoramento do serviço, é utilizado o Cloudwatch da AWS. O serviço monitora se a CPU da instancia EC2 e gera um alerta caso exceda 80% de processamento.

Os testes iniciais foram feitos diretamente da minha estação rodando o Terraform e criando o ambiente na conta de testes da AWS. Após ter ambiente funcionando, migrei os códigos para o repositório do Github e comecei os testes do deploy automatizado.

Tive alguns problemas com as credenciais que pararam de ter permissão de criação de EC2. Fiz diversos testes, como testar em outra região, mas somente resolveu recriando um novo usuário com uma nova access key.

Fico a disposição

Obrigado!
