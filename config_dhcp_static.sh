#!/bin/bash

# Função para configurar o servidor DHCP
config_dhcp_server() {
    echo "Configurando o Servidor DHCP..."

    # Instalar o servidor DHCP
    sudo apt update
    sudo apt install -y isc-dhcp-server

    # Perguntar as informações de configuração
    read -p "Informe o IP da sub-rede (ex: 192.168.1.0): " ip_subrede
    read -p "Informe a máscara de sub-rede (ex: 255.255.255.0): " mascara_subrede
    read -p "Informe a quantidade de endereços IPs a serem alocados (ex: 50): " quantidade_ips

    # Calcular o último IP do intervalo baseado na quantidade de endereços
    ip_inicio=$(echo $ip_subrede | cut -d'.' -f1-3).$((${ip_subrede##*.}+1))
    ip_fim=$(echo $ip_subrede | cut -d'.' -f1-3).$((${ip_subrede##*.}+quantidade_ips))

    # Configurar o arquivo de configuração do DHCP
    cat <<EOL | sudo tee /etc/dhcp/dhcpd.conf > /dev/null
# Configuração básica do servidor DHCP
option domain-name "example.com";
option domain-name-servers 8.8.8.8, 8.8.4.4;

default-lease-time 600;
max-lease-time 7200;

subnet $ip_subrede netmask $mascara_subrede {
    range $ip_inicio $ip_fim;
    option routers ${ip_subrede%.*}.1;
    option broadcast-address ${ip_subrede%.*}.255;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOL

    # Configurar a interface de rede que o DHCP irá escutar (assumindo eth0 como padrão)
    echo "INTERFACESv4=\"eth0\"" | sudo tee /etc/default/isc-dhcp-server > /dev/null

    # Reiniciar o serviço DHCP
    sudo systemctl restart isc-dhcp-server
    sudo systemctl enable isc-dhcp-server

    echo "Servidor DHCP configurado e iniciado com sucesso!"
}

# Função para configurar o cliente DHCP
config_dhcp_client() {
    echo "Configurando o Cliente DHCP..."

    # Garantir que o cliente DHCP esteja instalado
    sudo apt update
    sudo apt install -y isc-dhcp-client

    # Configurar o cliente para obter um IP via DHCP
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
    echo "auto eth0" | sudo tee -a /etc/network/interfaces > /dev/null
    echo "iface eth0 inet dhcp" | sudo tee -a /etc/network/interfaces > /dev/null

    # Reiniciar a rede para aplicar as configurações
    sudo systemctl restart networking

    echo "Cliente DHCP configurado com sucesso!"
}

# Função para verificar o sistema e aplicar as configurações apropriadas
main() {
    if [ "$1" == "server" ]; then
        config_dhcp_server
    elif [ "$1" == "client" ]; then
        config_dhcp_client
    else
        echo "Uso incorreto. Use 'server' para configurar o servidor ou 'client' para configurar o cliente."
    fi
}

# Executando a função principal
main "$1"
