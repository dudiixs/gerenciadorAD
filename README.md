# 🏢 Criador de Usuários no Active Directory
Este script em PowerShell automatiza a criação de usuários no Active Directory, oferecendo uma interface gráfica amigável e segura para facilitar o processo.

📌 Funcionalidades
Interface gráfica interativa para uma melhor experiência do usuário.
Escolha intuitiva do domínio de e-mail.
Seleção da Unidade Organizacional (OU) principal.
Seleção de OUs secundárias dentro da OU principal.
Geração automática ou manual do SamAccountName e UserPrincipalName (UPN).
Criação do usuário no Active Directory com senha temporária gerada de forma segura.
Feedback visual no terminal para informar sucesso ou erro na criação do usuário.

🚀 Requisitos
Windows Server com Active Directory configurado.
PowerShell com permissão para execução de scripts.
Módulo Active Directory instalado:
Import-Module ActiveDirectory
Caso o módulo não esteja instalado, execute:
Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature

📥 Instalação e Uso
Clone este repositório ou copie o script para sua máquina.
Abra o PowerShell como Administrador.
Navegue até a pasta onde o script está salvo.

Execute o script:
.\seu_script.ps1

🛠 Estrutura do Script
Solicita ao usuário que escolha o domínio de e-mail.
Permite selecionar a OU principal (SUAOU ou SUAOU2).
Exibe as OUs secundárias para escolha.
Coleta dados do novo usuário (nome, sobrenome, SamAccountName e UPN).
Gera ou solicita manualmente o SamAccountName e UPN.
Gera automaticamente uma senha segura.
Cria o usuário no Active Directory.
Exibe a senha gerada para o novo usuário.

⚠️ Possíveis Erros e Soluções
❌ Erro: "The term '-SamAccountName' is not recognized..."
Solução: Verifique se o módulo Active Directory está instalado e carregado corretamente com:
Import-Module ActiveDirectory

❌ Erro: "Access Denied"
Solução: Certifique-se de que o PowerShell está rodando como Administrador e que sua conta tem permissões para criar usuários no AD.

❌ Erro: "Cannot bind argument to parameter 'Path'"
Solução: Verifique se a estrutura das OUs está correta e se a OU informada existe no AD.

🏗 Melhorias Futuras
Integração com um sistema de logs para auditoria.
Expansão da interface gráfica para facilitar ainda mais o uso.

📌 Desenvolvido para facilitar a criação de usuários no AD de forma rápida, intuitiva e segura. 💡


