# フルスタックエンジニアが教える 即戦力Railsエンジニア養成講座のノート

## 内容

[フルスタックエンジニアが教える 即戦力Railsエンジニア養成講座 \| Udemy](https://www.udemy.com/course/rails-kj/)の学習記録です。

## railsの環境構成
### 初期状態

```
.
├── Dockerfile
├── Gemfile
├── Gemfile.lock
└── docker-compose.yml
```

Dockerfile

```Dockerfile
FROM ruby:2.4.5
RUN apt-get update -qq && apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
```

Gemfile

```Gemfile
source 'https://rubygems.org'
gem 'rails', '5.0.0.1'
```

Gemfile.lock

```lock
```

docker-compose.yml

```yml
version: '3'
services:
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/app
    ports:
      - 3000:3000
    depends_on:
      - db
    tty: true
    stdin_open: true
  db:
    image: mysql:5.7
    volumes:
      - db-volume:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: password
volumes:
  db-volume:
```

### 手順

1. 新しいRailsのプロジェクトファイルを作成する

```bash
docker-compose run web rails new . --force --database=mysql
```

2. `/config/database.yml`を編集する

3. データベースを作成する

```bash
docker-compose run web bundle exec rake db:create
```

## Railsの基本理念

- 同じことは繰り返すな (Don't Repeat Yourself:DRY)

- 設定よりも規約が優先される (Convention Over Configuration)

## 新しいWebページの作成

rootは,localhost:3000にアクセスが来た場合のルーティング

/config/routes.rb
```rb
Rails.application.routes.draw do
  root 'boards#index'
end

```
### BoardsControllerクラスのindexメソッドを実行するように定義

app/controllers.boards_controller.rb
```rb
class BoardsController < ApplicationController
  def index
  end
end
```

app/view/boards/index.html.erb

app/view配下にController名を同じdirectoryを作成する

## Bootstrapの導入

Gemfile
```Gemfile
gem 'bootstrap', '~> 4.0.0'
gem 'mini_racer'
```

docker-compose buildでbuildし直す

app/assets/stylesheets配下にあるapplication.cssをapplication.scssに変更する

application.scss
```scss
@import "bootstrap";
```

app/assets/javascripts/application.js
```js
//= require jquery3
//= require popper
//= require bootstrap-sprockets
```
