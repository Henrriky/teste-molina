#!/bin/bash

# Função para configurar o DHCP no Netplan
config_dhcp_netplan() {
    echo "Configurando a interface para DHCP no Netplan..."

    # Verifica a interface de rede do sistema (usando enp0s3 como exemplo)
    interface=$(ip link show | grep -E 'enp|eth' | awk '{print $2}' | tr -d ':' | head -n 1)

    # Backup do arquivo Netplan
    sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

    # Modificar a configuração do Netplan para usar DHCP
    sudo sed -i "s/addresses: .*/addresses: []/g" /etc/netplan/00-installer-config.yaml
    sudo sed -i "s/dhcp4: false/dhcp4: true/g" /etc/netplan/00-installer-config.yaml

    # Aplicar as mudanças no Netplan
    sudo netplan apply

    echo "A interface foi configurada para DHCP."
}

# Função para instruir o usuário a mudar para o modo Bridge no VirtualBox
instrucoes_virtualbox_bridge() {
    echo "Por favor, altere a configuração de rede do seu VirtualBox para o modo 'Bridge'."
    echo "Siga estas etapas no VirtualBox:"
    echo "1. Selecione a VM em questão."
    echo "2. Vá em 'Configurações' > 'Rede'."
    echo "3. Na placa de rede, altere para 'Adaptador em Bridge'."
    echo "4. Reinicie a VM."
    echo "Depois de concluir, pressione ENTER para continuar com a configuração."
    read -p "Pressione ENTER quando terminar... "
}

# Função para configurar o IP estático no Netplan após a instalação
config_static_netplan() {
    echo "Agora, voltaremos ao modo 'Rede Interna' e configuraremos um IP estático no Netplan."

    # Solicitar o IP estático para o usuário
    echo -n "Digite o IP estático desejado para a interface (ex: 192.168.56.10): "
    read ip_estatico

    # Verificar a interface de rede novamente
    interface=$(ip link show | grep -E 'enp|eth' | awk '{print $2}' | tr -d ':' | head -n 1)

    # Backup do arquivo Netplan
    sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

    # Modificar a configuração do Netplan para IP estático
    sudo sed -i "s/dhcp4: true/dhcp4: false/g" /etc/netplan/00-installer-config.yaml
    sudo sed -i "/ethernets:/a \ \ \ \ $interface:\n\ \ \ \ \ \ \ \ \ dhcp4: false\n\ \ \ \ \ \ \ \ \ addresses: [$ip_estatico/24]\n\ \ \ \ \ \ \ \ \ gateway4: 192.168.56.1\n\ \ \ \ \ \ \ \ \ nameservers:\n\ \ \ \ \ \ \ \ \ \ \ \ \ addresses: [8.8.8.8, 8.8.4.4]" /etc/netplan/00-installer-config.yaml

    # Aplicar as mudanças no Netplan
    sudo netplan apply

    echo "A interface foi configurada com o IP estático $ip_estatico."
}

# Função principal que executa as etapas do processo
main() {
    # Configurar a interface para usar DHCP no Netplan
    config_dhcp_netplan

    # Instruções para mudar para o modo 'Bridge' no VirtualBox
    instrucoes_virtualbox_bridge

    # Configurar o IP estático no Netplan após a instalação
    config_static_netplan

    echo "Configuração completa!"
}

# Executando a função principal
main
