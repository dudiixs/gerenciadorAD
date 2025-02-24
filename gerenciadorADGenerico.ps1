# Função para gerar senha aleatória sem I, l, O, 0
function Generate-RandomPassword {
    $Chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789@#$%&*!"
    $Password = -join (Get-Random -InputObject $Chars.ToCharArray() -Count 12)
    return $Password
}

# Função para gerar um UPN único
function Get-UniqueUPN {
    param (
        [string]$BaseUPN,
        [string]$Dominio
    )

    $UPN = "$BaseUPN$Dominio"
    $i = 1

    # Verificar se o UPN já existe e tentar um novo
    while (Get-ADUser -Filter {UserPrincipalName -eq $UPN}) {
        $UPN = "$BaseUPN$i$Dominio"
        $i++
    }

    return $UPN
}

# Função para sincronizar usuários do AD
function Sync-ADUsers {
    $UsuariosAD = Get-ADUser -Filter * -Properties SamAccountName, Name, UserPrincipalName, Enabled
    if ($UsuariosAD) {
        Write-Host "`n🔍 Sincronização realizada com sucesso! Aqui estão os usuários encontrados:"
        $UsuariosAD | ForEach-Object {
            Write-Host "Nome: $($_.Name) | SamAccountName: $($_.SamAccountName) | UPN: $($_.UserPrincipalName) | Status: $($_.Enabled)"
        }
    } else {
        Write-Host "❌ Nenhum usuário encontrado no AD!" -ForegroundColor Red
    }
    Pause
}

# Menu Principal
# Definindo a função Show-Menu
function Show-Menu {
    param (
        [string]$Title,
        [array]$Options
    )
    
    Clear-Host
    Write-Host "===============================" -ForegroundColor DarkMagenta
    Write-Host "       $Title" -ForegroundColor Magenta
    Write-Host "===============================" -ForegroundColor DarkMagenta
    
    for ($i = 0; $i -lt $Options.Length; $i++) {
        Write-Host "$($i + 1). $($Options[$i])"
    }

    Write-Host ""
    $opcao = Read-Host "Escolha uma opção (1-$($Options.Length))"
    return $Options[$opcao - 1]
}

# Variáveis e opções de domínio e OUs
$Dominios = @("dominio1.com", "dominio2.com.br", "dominio3.com")
$OUs = @{
    "EMPRESA 1" = @("Recepcao", "Laboratorio", "Suporte", "Marketing")
    "EMPRESA 2" = @("Recepcao2", "Suporte2", "Marketing2")
}
$DominioPrincipal = "dominio.com"

# Loop principal para o menu
do {
    $opcao = Show-Menu -Title "Gerenciador AD - $DominioPrincipal" -Options @("Criar usuário", "Redefinir senha", "Bloquear usuário", "Desabilitar usuário", "Reabilitar usuário", "Deletar usuário", "Pesquisar usuário", "Sair")
    
    switch ($opcao) {
        "Criar usuário" {
    # Escolher domínio do e-mail
    $Dominio = Show-Menu -Title "🌐 Escolha o domínio do e-mail" -Options $Dominios
    if (-not $Dominio) { continue }

    # Escolher a OU Principal
    $OU_Principal = Show-Menu -Title "🏢 Escolha a OU Principal" -Options @("EMPRESA 1", "EMPRESA 2")
    if (-not $OU_Principal) { continue }

    # Escolher a OU Secundária dentro da OU Principal escolhida
    $OU_Secundaria = Show-Menu -Title "📂 Escolha a OU dentro de $OU_Principal" -Options $OUs[$OU_Principal]
    if (-not $OU_Secundaria) { continue }

    # Construção do caminho da OU
    $OU_Path = "OU=$OU_Secundaria,OU=$OU_Principal,OU=Users,OU=dominio,DC=dominio,DC=COM"

    # Coletar dados do usuário
    Clear-Host
    Write-Host "==============================" -ForegroundColor DarkGreen
    Write-Host "       🆕 Criar Usuário       " -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor DarkGreen

    $Nome = Read-Host "✏️ Digite o primeiro nome do usuário"
    $Sobrenome = Read-Host "✏️ Digite o sobrenome do usuário"

    # Perguntar se o usuário deseja gerar o SamAccountName automaticamente
    $AutoSamAccountName = Read-Host "🔄 Deseja gerar o SamAccountName automaticamente? (S/N)"
    if ($AutoSamAccountName -eq "S") {
        $SamAccountName = ($Nome.Substring(0,1) + $Sobrenome).ToLower()
    } else {
        $SamAccountName = Read-Host "✏️ Digite o SamAccountName manualmente"
    }

    # Perguntar se o usuário deseja gerar o UPN automaticamente
    $AutoUPN = Read-Host "🔄 Deseja gerar o UPN automaticamente? (S/N)"
    if ($AutoUPN -eq "S") {
        $UPN = "$SamAccountName@$Dominio"
    } else {
        $UPN = Read-Host "✏️ Digite o UPN manualmente (ex: usuario@dominio.com)"
    }

    $Senha = Generate-RandomPassword  # Para testes, depois substitua por Generate-RandomPassword

    # Criar usuário no AD
    try {
        New-ADUser -Name "$Nome $Sobrenome" `
                   -GivenName $Nome `
                   -Surname $Sobrenome `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UPN `
                   -AccountPassword (ConvertTo-SecureString $Senha -AsPlainText -Force) `
                   -Enabled $true `
                   -Path $OU_Path `
                   -DisplayName "$Nome $Sobrenome" `
                   -PassThru | Out-Null

        Write-Host "`n✅ Usuário $Nome $Sobrenome criado com sucesso na OU $OU_Secundaria!" -ForegroundColor Green
        Write-Host "🔑 Senha temporária: $Senha" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Erro ao criar usuário: $_" -ForegroundColor Red
    }
    Pause
}


        "Redefinir senha" {
            Clear-Host
            Write-Host "==============================" -ForegroundColor DarkMagenta
            Write-Host "      🔄 Redefinir Senha      " -ForegroundColor Magenta
            Write-Host "==============================" -ForegroundColor DarkMagenta

            $User = Read-Host "👤 Digite o SamAccountName do usuário"
            $NovaSenha = Generate-RandomPassword
            Set-ADAccountPassword -Identity $User -NewPassword (ConvertTo-SecureString $NovaSenha -AsPlainText -Force) -Reset
            Write-Host "`n✅ Senha redefinida com sucesso!" -ForegroundColor Green
            Write-Host "🔑 Nova senha: $NovaSenha" -ForegroundColor Yellow
            Pause
        }

        "Bloquear usuário" {
            Clear-Host
            Write-Host "==============================" -ForegroundColor DarkRed
            Write-Host "      🔒 Bloquear Usuário      " -ForegroundColor Red
            Write-Host "==============================" -ForegroundColor DarkRed

            $User = Read-Host "👤 Digite o SamAccountName do usuário"
            Lock-ADAccount -Identity $User
            Write-Host "`n✅ Usuário bloqueado com sucesso!" -ForegroundColor Green
            Pause
        }

        "Desabilitar usuário" {
            Clear-Host
            Write-Host "==============================" -ForegroundColor DarkGray
            Write-Host "      ⛔ Desabilitar Usuário      " -ForegroundColor Gray
            Write-Host "==============================" -ForegroundColor DarkGray

            $User = Read-Host "👤 Digite o SamAccountName do usuário"
            Disable-ADAccount -Identity $User
            Write-Host "`n✅ Usuário desabilitado com sucesso!" -ForegroundColor Green
            Pause
        }

        "Reabilitar usuário" {
            Clear-Host
            Write-Host "==============================" -ForegroundColor DarkYellow
            Write-Host "      🔄 Reabilitar Usuário    " -ForegroundColor Yellow
            Write-Host "==============================" -ForegroundColor DarkYellow

            $User = Read-Host "👤 Digite o SamAccountName do usuário"
            Enable-ADAccount -Identity $User
            Write-Host "`n✅ Usuário reabilitado com sucesso!" -ForegroundColor Green
            Pause
        }

        "Deletar usuário" {
            Clear-Host
            Write-Host "==============================" -ForegroundColor DarkCyan
            Write-Host "      🗑️ Deletar Usuário      " -ForegroundColor Cyan
            Write-Host "==============================" -ForegroundColor DarkCyan

            $SamAccountName = Read-Host "👤 Digite o SamAccountName do usuário a ser deletado"
            $User = Get-ADUser -Filter {SamAccountName -eq $SamAccountName}

            if ($User) {
                # Exibir as informações do usuário
                Write-Host "`n🔍 Informações do usuário:"
                Write-Host "Nome: $($User.Name)"
                Write-Host "SamAccountName: $($User.SamAccountName)"
                Write-Host "UPN: $($User.UserPrincipalName)"
                Write-Host "Status: $($User.Enabled)"

                # Perguntar se o usuário deseja realmente excluir
                $ConfirmarDelecao = Read-Host "🔒 Tem certeza que deseja excluir este usuário? (S/N)"
                if ($ConfirmarDelecao -eq "S") {
                    Remove-ADUser -Identity $User -Confirm:$false
                    Write-Host "`n✅ Usuário deletado com sucesso!" -ForegroundColor Green
                } else {
                    Write-Host "❌ Deleção cancelada!" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Usuário não encontrado!" -ForegroundColor Red
            }
            Pause
        }

        "Pesquisar usuário" {
            Clear-Host
            Write-Host "==============================" -ForegroundColor DarkMagenta
            Write-Host "      🔍 Pesquisar Usuário     " -ForegroundColor Magenta
            Write-Host "==============================" -ForegroundColor DarkMagenta

            # Perguntar se deseja pesquisar pelo SamAccountName
            $PesquisarPorSamAccountName = Read-Host "🔄 Deseja pesquisar pelo SamAccountName? (S/N)"
            if ($PesquisarPorSamAccountName -eq "S") {
                $SamAccountName = Read-Host "👤 Digite o SamAccountName do usuário"
                $Usuario = Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -Properties SamAccountName, Name, UserPrincipalName, Enabled

                if ($Usuario) {
                    Write-Host "`n🔍 Informações do usuário:"
                    Write-Host "Nome: $($Usuario.Name)"
                    Write-Host "SamAccountName: $($Usuario.SamAccountName)"
                    Write-Host "UPN: $($Usuario.UserPrincipalName)"
                    Write-Host "Status: $($Usuario.Enabled)"
                } else {
                    Write-Host "❌ Usuário não encontrado!" -ForegroundColor Red
                }
            } else {
                Write-Host "`n🔍 Exibindo todos os usuários ativos:"
                # Sincronizar e listar apenas os usuários ativos
                $UsuariosAD = Get-ADUser -Filter * -Properties SamAccountName, Name, UserPrincipalName, Enabled
                $UsuariosAD | Where-Object { $_.Enabled -eq $true } | ForEach-Object {
                    Write-Host "Nome: $($_.Name) | SamAccountName: $($_.SamAccountName) | UPN: $($_.UserPrincipalName) | Status: $($_.Enabled)"
                }
            }
            Pause
        }
    }
} while ($opcao -ne "Sair")