#!/bin/bash

# Função para configurar o servidor NTP
config_ntp_server() {
    echo "Configurando o servidor NTP no modo Bridge (IP automático)..."

    # Configurar IP automático no Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Definir o fuso horário para São Paulo
    sudo timedatectl set-timezone America/Sao_Paulo

    # Atualizar pacotes e instalar o NTP
    echo "Atualizando pacotes e instalando o NTP..."
    sudo apt update
    sudo apt install -y ntpsec ntp ntpdate

    # Verificar o status do serviço NTP
    echo "Verificando o status do serviço NTP..."
    sudo systemctl status ntp

    # Parar o serviço NTP para sincronizar manualmente
    echo "Parando o serviço NTP para sincronização manual..."
    sudo service ntp stop

    # Sincronizar o tempo com um servidor NTP público (a.ntp.br)
    echo "Sincronizando o tempo com o servidor a.ntp.br..."
    sudo ntpdate a.ntp.br

    # Iniciar o serviço NTP novamente
    echo "Iniciando o serviço NTP..."
    sudo service ntp start

    # Editar o arquivo de configuração do NTP
    echo "Editando o arquivo de configuração do NTP (/etc/ntpsec/ntp.conf)..."
    sudo sed -i 's/^pool .*/#pool/g' /etc/ntpsec/ntp.conf
    sudo sed -i 's/^server .*/#server/g' /etc/ntpsec/ntp.conf
    echo "server a.ntp.br" | sudo tee -a /etc/ntpsec/ntp.conf
    echo "server b.ntp.br" | sudo tee -a /etc/ntpsec/ntp.conf
    echo "server c.ntp.br" | sudo tee -a /etc/ntpsec/ntp.conf

    # Reiniciar o serviço NTP para aplicar as configurações
    echo "Reiniciando o serviço NTP..."
    sudo systemctl restart ntp

    # Verificar a sincronização
    echo "Verificando a sincronização do NTP..."
    sudo ntpdate -q
}

# Função para configurar o cliente NTP
config_ntp_client() {
    echo "Configurando o cliente NTP no modo Bridge (IP automático)..."

    # Configurar IP automático no Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Atualizar pacotes e instalar o NTP
    echo "Atualizando pacotes e instalando o NTP..."
    sudo apt update
    sudo apt install -y ntpsec ntp ntpdate

    # Verificar o status do serviço NTP
    echo "Verificando o status do serviço NTP..."
    sudo systemctl status ntp

    # Editar o arquivo de configuração do NTP
    echo "Editando o arquivo de configuração do NTP (/etc/ntpsec/ntp.conf)..."
    sudo sed -i 's/^pool .*/#pool/g' /etc/ntpsec/ntp.conf
    sudo sed -i 's/^server .*/#server/g' /etc/ntpsec/ntp.conf
    echo "server <ip_do_servidor_npt>" | sudo tee -a /etc/ntpsec/ntp.conf

    # Reiniciar o serviço NTP para aplicar as configurações
    echo "Reiniciando o serviço NTP..."
    sudo systemctl restart ntp

    # Sincronizar o tempo com o servidor NTP configurado
    echo "Sincronizando o tempo com o servidor NTP..."
    sudo ntpdate <ip_do_servidor_npt>
}

# Função principal
main() {
    echo "Iniciando a configuração do servidor NTP..."
    
    # Configurar o servidor NTP
    config_ntp_server

    echo "Iniciando a configuração do cliente NTP..."
    
    # Configurar o cliente NTP
    config_ntp_client

    echo "Configuração completa! O servidor e cliente NTP estão sincronizados."
}

# Executando a função principal
main
