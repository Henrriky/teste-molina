#!/bin/bash

# Função para configurar IP Estático
config_ip_estatico() {
    echo "Configurando IP Estático..."

    # Solicita o IP e Gateway para o usuário
    read -p "Informe o IP Estático (ex: 192.168.10.253): " ip_estatico
    read -p "Informe o Gateway (ex: 192.168.10.254): " gateway
    read -p "Informe o(s) servidor(es) DNS separados por vírgula (ex: 8.8.8.8, 8.8.4.4): " dns

    # Criação do arquivo de configuração Netplan com IP Estático
    cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        enp0s3:
            dhcp4: false
            addresses: [$ip_estatico/24]
            routes:
                - to: default
                  via: $gateway
            nameservers:
                addresses: [$dns]
EOF

    # Aplicar a configuração
    echo "Aplicando a configuração de IP Estático..."
    sudo netplan apply
}

# Função para configurar IP Automático (DHCP)
config_ip_automatico() {
    echo "Configurando IP Automático (DHCP)..."

    # Criação do arquivo de configuração Netplan para DHCP
    cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        enp0s3:
            dhcp4: true
            dhcp-identifier: mac
EOF

    # Aplicar a configuração
    echo "Aplicando a configuração de IP Automático..."
    sudo netplan apply
}

# Função para exibir o menu de escolha
menu() {
    clear
    echo "Escolha o tipo de configuração de rede:"
    echo "1 - Configurar IP Estático"
    echo "2 - Configurar IP Automático (DHCP)"
    echo "3 - Sair"
    read -p "Escolha uma opção [1-3]: " opcao

    case $opcao in
        1)
            config_ip_estatico
            ;;
        2)
            config_ip_automatico
            ;;
        3)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            menu
            ;;
    esac
}

# Executar o menu principal
menu
