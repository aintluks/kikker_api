# Kikker API

API para gerenciamento de posts e avaliações, desenvolvida em Ruby on Rails.

## Descrição

A Kikker API é uma aplicação que permite criar posts, avaliá-los e visualizar estatísticas. Cada usuário pode criar múltiplos posts e avaliar posts de outros usuários (uma única vez por post). A API também oferece funcionalidades para visualizar posts mais bem avaliados e agrupar autores por IP.

## Funcionalidades

- Criação de posts com título, corpo e IP
- Sistema de avaliação de posts (1-5)
- Prevenção de avaliações duplicadas por usuário
- Processamento assíncrono de avaliações
- Consulta de posts mais bem avaliados
- Agrupamento de autores por IP

## Requisitos do Sistema

- Ruby 3.0.0 ou superior
- Rails 8.0.2 ou superior
- PostgreSQL 12 ou superior
- Sidekiq (para processamento de jobs assíncronos)

## Versões Utilizadas

Este projeto utiliza as seguintes versões de dependências:

- Ruby: 3.4.3
- Rails: 8.0.2
- PostgreSQL: 12
- Sidekiq: 6.5.0

## Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/aintluks/kikker_api.git
   cd kikker_api
   ```

2. Instale as dependências:
   ```bash
   bundle install
   ```

3. Configure o banco de dados:
   ```bash
   rails db:create db:migrate
   ```

4. Inicie o servidor:
   ```bash
   rails server
   ```

5. Em outro terminal, inicie o Sidekiq:
   ```bash
   bundle exec sidekiq
   ```

## Populando o Banco de Dados

Para criar dados de exemplo, execute:
```bash
rails db:seed
```

Este comando irá:
- Criar 100 usuários
- Gerar 200.000 posts
- Adicionar avaliações para posts (até 750.000 ratings)

## Endpoints da API

### Posts

#### Criar Post
```
POST /api/v1/posts
```
Parâmetros:
- `title`: Título do post
- `body`: Conteúdo do post
- `ip`: Endereço IP
- `login`: Login do usuário (será criado se não existir)

Resposta (201 Created):
```json
{
  "id": 1,
  "title": "Título do Post",
  "body": "Conteúdo do post",
  "ip": "192.168.1.1",
  "user_id": 1,
}

```

#### Posts Mais Bem Avaliados
```
GET /api/v1/posts/top_rated
```
Parâmetros:
- `page`: Número da página (padrão: 1)
- `per_page`: Itens por página (padrão: 10)

Resposta (200 OK):
```json
{
  "data": [
    {
      "id": 3,
      "title": "Molestiae facilis inventore totam sed.",
      "body": "Veniam neque expedita ad illo odit. In itaque autem corrupti."
    },
    {
      "id": 9,
      "title": "Enim labore harum ad iusto.",
      "body": "Cum provident suscipit consectetur consequatur iusto beatae."
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 2
  }
}
```

#### Autores por IP
```
GET /api/v1/posts/ip_authors
```
Parâmetros:
- `page`: Número da página (padrão: 1)
- `per_page`: Itens por página (padrão: 10)

Resposta (200 OK):
```json
{
  "data": [
    {
      "ip": "192.168.1.1",
      "logins": ["usuario1", "usuario2"]
    },
    {
      "ip": "10.0.0.1",
      "logins": ["usuario3"]
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 2
  }
}
```

### Avaliações

#### Criar Avaliação
```
POST /api/v1/ratings
```
Parâmetros:
- `post_id`: ID do post
- `user_id`: ID do usuário
- `value`: Valor da avaliação (1-5)

Resposta (202 Accepted):
```json
{
  "average_rating": 4.5
}
```

Possíveis erros:
- 404 Not Found: Post ou usuário não encontrado
- 422 Unprocessable Entity: 
  - Usuário já avaliou este post
  - Valor da avaliação inválido
- 500 Internal Server Error: Erro interno do servidor

## Estrutura do Projeto

- `app/controllers/api/v1/`: Controladores da API
- `app/models/`: Modelos do sistema
- `app/jobs/`: Jobs para processamento assíncrono
- `db/seeds.rb`: Script para população do banco
- `spec/`: Testes da aplicação

## Processamento Assíncrono

A API utiliza Sidekiq para processar avaliações de forma assíncrona:

1. Quando uma avaliação é criada, um job é enfileirado
2. O job tenta criar a avaliação
3. Se ocorrer um erro, o job é reenfileirado

## Testes

Para executar os testes:
```bash
bundle exec rspec
```
