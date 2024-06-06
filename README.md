# Cardápio Digital iOS

Este é um exemplo de uma aplicação iOS para registro de avistamentos de atividades irregulares em oceanos azuis. O app permite que os usuários registrem relatos escritos e apontem a localização pelo celular para encaminhamento às autoridades responsáveis.

## Funcionalidades

- Visualizar registros de avistamentos pelo mapa.
- Adicionar novos registros de avistamentos com relatos totalmente anônimos.
- Atualização do mapa com seu registro de avistamento.

## Repositórios complementares

- [Repositório do Backend Spring](https://github.com/luizgolima/fiap-sighting-server)

## Aplicações no ar (deploy)

- [Backend Spring](https://fiap-sighting-server-1.onrender.com/sightings)

## Requisitos

- Xcode 15
- Swift 5
- iOS 16

## Instalação e Execução Local

1. Clone este repositório:
   ```bash
   git clone https://github.com/luizgolima/fiap-sighting-ios.git
   ```
2. Abra o projeto no Xcode.
3. Execute o aplicativo no simulador iOS ou em um dispositivo físico.

Obs.: Certifique-se de que o servidor Spring backend esteja em execução (local ou em deploy). Se estiver rodando o backend localmente, lembre-se de atualizar a URL da chamada da API do cliente para `http://localhost:8080/sightings`.

