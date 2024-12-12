#!/bin/bash

# Função para configurar o servidor FTP (vsftpd)
config_ftp_server() {
    echo "Configurando o servidor FTP vsftpd no modo Bridge (IP automático)..."

    # Configurar IP automático no Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Atualizar pacotes e instalar o vsftpd
    echo "Atualizando pacotes e instalando o vsftpd..."
    sudo apt update
    sudo apt install -y vsftpd

    # Verificar o status do vsftpd
    echo "Verificando o status do vsftpd..."
    sudo systemctl status vsftpd

    # Editar o arquivo de configuração do vsftpd
    echo "Editando o arquivo de configuração do vsftpd..."
    sudo sed -i 's/#listen=YES/listen=YES/' /etc/vsftpd.conf
    sudo sed -i 's/listen_ipv6=YES/listen_ipv6=NO/' /etc/vsftpd.conf
    sudo sed -i 's/#anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
    sudo sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
    sudo sed -i 's/#anon_upload_enable=NO/anon_upload_enable=YES/' /etc/vsftpd.conf
    sudo sed -i 's/#anon_mkdir_write_enable=NO/anon_mkdir_write_enable=YES/' /etc/vsftpd.conf
    sudo sed -i 's/#ascii_upload_enable=NO/ascii_upload_enable=YES/' /etc/vsftpd.conf
    sudo sed -i 's/#ascii_download_enable=NO/ascii_download_enable=YES/' /etc/vsftpd.conf

    # Reiniciar o serviço vsftpd para aplicar as configurações
    sudo systemctl restart vsftpd

    # Exibir o IP do servidor FTP
    ip_servidor=$(hostname -I | awk '{print $1}')
    echo "O servidor FTP está acessível em: ftp://$ip_servidor"
}

# Função para dar instruções sobre como usar o FileZilla
instrucoes_filezilla() {
    echo "Agora, baixe e instale o cliente FileZilla."
    echo "Acesse o link abaixo para fazer o download do FileZilla:"
    echo "https://filezilla-project.org/download.php?type=client"
    echo "Após a instalação do FileZilla, siga os passos abaixo para conectar ao servidor FTP:"
    echo "1. Abra o FileZilla."
    echo "2. No campo 'Host', insira o IP do servidor FTP: $ip_servidor."
    echo "3. No campo 'Nome de usuário', insira: ifsp01."
    echo "4. No campo 'Senha', insira: ifsp01."
    echo "5. Clique em 'Conectar'."
    echo "6. Após conectar, você pode realizar a transferência de arquivos para o servidor e do servidor para o seu computador."
}

# Função principal que executa as etapas do processo
main() {
    # Configurar o servidor FTP
    config_ftp_server

    # Fornecer instruções sobre o uso do FileZilla
    instrucoes_filezilla

    echo "Configuração completa! Acesse o servidor FTP usando o FileZilla."
}

# Executando a função principal
main
