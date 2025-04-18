# Kikker API

API para gerenciamento de posts e avaliações, desenvolvida em Ruby on Rails.

## Descrição

A Kikker API é uma aplicação que permite criar posts, avaliá-los e visualizar estatísticas. Cada usuário pode criar múltiplos posts e avaliar posts de outros usuários (uma única vez por post). A API também oferece funcionalidades para visualizar posts mais bem avaliados e agrupar autores por IP.

## Funcionalidades

- Criação de posts com título, corpo e IP do autor
- Sistema de avaliação (1-5 estrelas) para posts
- Prevenção de avaliações duplicadas (um usuário só pode avaliar um post uma vez)
- Endpoint para visualizar posts mais bem avaliados
- Endpoint para visualizar autores agrupados por IP
- Processamento assíncrono de avaliações para melhor performance

## Requisitos

- Ruby 3.0.0 ou superior
- Rails 8.0.2 ou superior
- PostgreSQL 12 ou superior
- Redis (para processamento de jobs assíncronos)
- Sidekiq (para processamento de jobs assíncronos)

## Versões Utilizadas

Este projeto utiliza as seguintes versões de dependências:

- Ruby: 3.4.3
- Rails: 8.0.2
- PostgreSQL: 12
- Sidekiq: 6.5.0

## Instalação

1. Clone o repositório:
   ```
   git clone https://github.com/aintluks/kikker_api.git
   cd kikker_api
   ```

2. Instale as dependências:
   ```
   bundle install
   ```

3. Configure o banco de dados:
   ```
   rails db:create
   rails db:migrate
   ```

4. Inicie o Sidekiq em um terminal separado:
   ```
   bundle exec sidekiq
   ```

5. Inicie o servidor Rails:
   ```
   rails server
   ```

## Populando o banco de dados

Para popular o banco de dados com dados de exemplo, execute:
```
rails db:seed
```

Este comando irá:
- Criar 100 usuários
- Gerar 200.000 posts
- Adicionar avaliações para posts (até 750.000 ratings)

## Endpoints da API

### Posts

- `POST /api/v1/posts` - Cria um novo post
  - Parâmetros: `login`, `title`, `body`, `ip`
  - Resposta: 201 Created com os dados do post

- `GET /api/v1/posts/top_rated` - Retorna os posts mais bem avaliados
  - Parâmetros opcionais: `limit` (padrão: 5)
  - Resposta: 200 OK com a lista de posts

- `GET /api/v1/posts/ip_authors` - Retorna autores agrupados por IP
  - Resposta: 200 OK com a lista de IPs e seus autores

### Avaliações

- `POST /api/v1/ratings` - Cria uma nova avaliação
  - Parâmetros: `post_id`, `user_id`, `value` (1-5)
  - Resposta: 202 Accepted com a média de avaliações do post

## Estrutura do Projeto

- `app/controllers/api/v1/` - Controladores da API
- `app/models/` - Modelos de dados
- `app/jobs/` - Jobs assíncronos
- `db/migrate/` - Migrações do banco de dados
- `spec/` - Testes automatizados

## Testes

Para executar os testes:

```
bundle exec rspec
```
