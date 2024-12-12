#!/bin/bash

# Função para configurar o servidor NFS
config_nfs_server() {
    echo "Configurando o servidor NFS no modo Bridge (IP automático)..."

    # Alterar últimos 4 dígitos do endereço MAC - essa parte depende de como você está fazendo isso no VirtualBox
    # Vamos supor que já foi configurado no VirtualBox, e vamos configurar o IP automático para DHCP no Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Atualizar pacotes e instalar o nfs-kernel-server
    echo "Atualizando pacotes e instalando nfs-kernel-server..."
    sudo apt update
    sudo apt install -y nfs-kernel-server

    # Verificar o status do serviço nfs-kernel-server
    echo "Verificando o status do servidor NFS..."
    sudo systemctl status nfs-kernel-server

    # Criar diretório para compartilhamento
    echo "Criando diretório /diretorio/dir1 para compartilhamento..."
    sudo mkdir -p /diretorio/dir1
    sudo chmod -R 777 /diretorio
    ls -ld /diretorio

    # Configurar exportação no /etc/exports
    echo "Configurando exportação de diretório no /etc/exports..."
    echo "/diretorio/dir1    *(rw,sync)" | sudo tee -a /etc/exports

    # Reiniciar o serviço NFS para aplicar configurações
    echo "Reiniciando o servidor NFS..."
    sudo systemctl restart nfs-kernel-server
    sudo systemctl start nfs-kernel-server

    # Listar diretório compartilhado
    ls /diretorio/dir1
}

# Função para configurar o cliente NFS
config_nfs_client() {
    echo "Configurando o cliente NFS no modo Bridge (IP automático)..."

    # Alterar últimos 4 dígitos do endereço MAC no VirtualBox (supondo que já tenha sido configurado)
    # Configurar IP automático para DHCP no Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Atualizar pacotes e instalar o nfs-common
    echo "Atualizando pacotes e instalando nfs-common..."
    sudo apt update
    sudo apt install -y nfs-common

    # Alterar para Rede Interna
    echo "Configurando a rede para IP estático na Rede Interna..."
    sudo sed -i 's/dhcp4: true/dhcp4: false/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Criar diretório onde o compartilhamento NFS será montado
    echo "Criando diretório /dir/a para montar o compartilhamento NFS..."
    sudo mkdir -p /dir/a

    # Montar diretório compartilhado via NFS
    echo "Montando diretório NFS..."
    sudo mount <endereco_ip_servidor>:/diretorio/dir1 /dir/a

    # Verificar o espaço no diretório montado
    df -h

    # Criar arquivos no diretório montado
    echo "Criando arquivos no diretório montado..."
    sudo touch /dir/a/file1 /dir/a/file2
}

# Função principal para executar as configurações
main() {
    echo "Iniciando a configuração do servidor NFS..."
    
    # Configurar o servidor NFS
    config_nfs_server
    
    echo "Iniciando a configuração do cliente NFS..."
    
    # Configurar o cliente NFS
    config_nfs_client

    echo "Configuração concluída! O compartilhamento NFS está pronto para uso."
}

# Executando a função principal
main
