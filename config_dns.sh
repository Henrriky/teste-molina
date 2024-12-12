#!/bin/bash

# Função para configurar o servidor DNS em modo Bridge
config_dns_server_bridge() {
    echo "Configurando o servidor DNS no modo Bridge (com IP automático)..."

    # Configurar IP automático com Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Instalar o Bind9 e dependências
    echo "Instalando o Bind9 e ferramentas necessárias..."
    sudo apt-get update
    sudo apt-get install -y bind9 bind9utils bind9-doc

    # Configurar o arquivo /etc/default/named
    echo "Configurando o arquivo /etc/default/named..."
    sudo sed -i 's/^OPTIONS=.*/OPTIONS="-u bind -4"/' /etc/default/named

    # Reiniciar o Bind9
    sudo systemctl restart bind9
    sudo systemctl status bind9

    echo "Servidor DNS configurado no modo Bridge!"
}

# Função para configurar o servidor DNS em Rede Interna com IP estático
config_dns_server_internal() {
    echo "Configurando o servidor DNS em Rede Interna (com IP estático)..."

    # Configurar IP estático no Netplan
    sudo sed -i 's/dhcp4: true/dhcp4: false/g' /etc/netplan/00-installer-config.yaml
    sudo sed -i '/ethernets:/a \ \ \ \ enp0s3:\n\ \ \ \ \ \ \ \ dhcp4: false\n\ \ \ \ \ \ \ \ addresses: [10.20.30.40/24]\n\ \ \ \ \ \ \ \ gateway4: 10.20.30.1\n\ \ \ \ \ \ \ \ nameservers:\n\ \ \ \ \ \ \ \ \ \ \ \ addresses: [8.8.8.8, 8.8.4.4]' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Criar diretório de zonas e copiar o arquivo de exemplo
    echo "Criando diretório de zonas e configurando o arquivo de zona..."
    sudo mkdir -p /etc/bind/zones
    sudo cp /etc/bind/db.local /etc/bind/zones/db.seudominio.com.br

    # Editar /etc/bind/named.conf.local para adicionar a zona
    echo "Adicionando zona ao arquivo /etc/bind/named.conf.local..."
    sudo tee -a /etc/bind/named.conf.local > /dev/null <<EOL
zone "seudominio.com.br" {
    type primary;
    file "/etc/bind/zones/db.seudominio.com.br";
};
EOL

    # Editar o arquivo da zona /etc/bind/zones/db.seudominio.com.br
    echo "Configurando os registros da zona..."
    sudo tee /etc/bind/zones/db.seudominio.com.br > /dev/null <<EOL
\$TTL    604800
@       IN      SOA     ns1.seudominio.com.br. admin.seudominio.com.br. (
                              2024121201 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Minimum TTL
;
@       IN      NS      ns1.seudominio.com.br.
ns1     IN      A       10.20.30.40
www     IN      A       10.20.30.40
ftp     IN      A       201.10.0.3
mail    IN      A       5.6.7.8
espaco  IN      A       100.200.50.25
EOL

    # Reiniciar o Bind9
    sudo systemctl restart bind9
    sudo systemctl status bind9

    echo "Servidor DNS configurado em Rede Interna com IP estático!"
}

# Função para configurar o cliente DNS em Rede Interna com IP estático
config_dns_client() {
    echo "Configurando o cliente DNS em Rede Interna (com IP estático)..."

    # Configurar IP estático no Netplan
    sudo sed -i 's/dhcp4: true/dhcp4: false/g' /etc/netplan/00-installer-config.yaml
    sudo sed -i '/ethernets:/a \ \ \ \ enp0s3:\n\ \ \ \ \ \ \ \ dhcp4: false\n\ \ \ \ \ \ \ \ addresses: [10.20.30.50/24]\n\ \ \ \ \ \ \ \ gateway4: 10.20.30.1\n\ \ \ \ \ \ \ \ nameservers:\n\ \ \ \ \ \ \ \ \ \ \ \ addresses: [10.20.30.40]' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Editar /etc/resolv.conf para apontar para o servidor DNS
    echo "Configurando /etc/resolv.conf para usar o servidor DNS..."
    echo "nameserver 10.20.30.40" | sudo tee /etc/resolv.conf > /dev/null

    echo "Cliente DNS configurado com IP estático!"
}

# Função para testar a resolução DNS
test_dns_resolution() {
    echo "Testando a resolução DNS..."

    # Testar nslookup para os registros configurados
    nslookup www.seudominio.com.br
    nslookup ftp.seudominio.com.br
    nslookup mail.seudominio.com.br
    nslookup espaco.seudominio.com.br
}

# Função principal que executa as etapas do processo
main() {
    # Opção para configurar servidor ou cliente DNS
    echo "Escolha o modo de configuração:"
    echo "1. Servidor DNS - Modo Bridge (IP automático)"
    echo "2. Servidor DNS - Rede Interna (IP estático)"
    echo "3. Cliente DNS - Rede Interna (IP estático)"
    read -p "Digite a opção desejada (1, 2 ou 3): " option

    case $option in
        1)
            config_dns_server_bridge
            ;;
        2)
            config_dns_server_internal
            ;;
        3)
            config_dns_client
            ;;
        *)
            echo "Opção inválida!"
            exit 1
            ;;
    esac

    # Testar resolução DNS
    test_dns_resolution

    echo "Configuração completa!"
}

# Executando a função principal
main
