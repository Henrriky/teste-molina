#!/bin/bash

# Função para configurar o servidor HTTP (Apache)
config_http_server() {
    echo "Configurando o servidor HTTP Apache no modo Bridge (IP automático)..."

    # Configurar IP automático no Netplan
    sudo sed -i 's/dhcp4: false/dhcp4: true/g' /etc/netplan/00-installer-config.yaml
    sudo netplan apply

    # Atualizar pacotes e instalar o Apache2
    echo "Atualizando pacotes e instalando o Apache2..."
    sudo apt update
    sudo apt install -y apache2

    # Verificar o status do Apache2
    echo "Verificando o status do Apache2..."
    sudo systemctl status apache2

    # Obter o IP do servidor
    echo "Obtendo o IP do servidor..."
    ip_servidor=$(hostname -I | awk '{print $1}')

    # Exibir o IP do servidor
    echo "O servidor HTTP Apache está acessível em: http://$ip_servidor"

    # Criar e editar o arquivo index.html
    echo "Editando a página inicial do Apache..."
    sudo bash -c 'echo "<html><body><h1>Bem-vindo ao servidor HTTP Apache!</h1></body></html>" > /var/www/html/index.html'

    echo "Página index.html criada com sucesso!"
}

# Função principal que executa as etapas do processo
main() {
    # Configurar o servidor HTTP Apache
    config_http_server

    echo "Configuração completa! Acesse o servidor no navegador em http://$ip_servidor"
}

# Executando a função principal
main
