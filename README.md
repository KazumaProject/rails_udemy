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

### app/assets/stylesheets配下にあるapplication.cssをapplication.scssに変更する

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

## Modelを作成する

```bash
docker-compose run web bundle exec rails g model boards name:string title:string body:text
```
boardsテーブルに作成する
  - String型のname
  - String型のtitle
  - Text型のbody

```rb
t.timestamps
# これは 
# create_at と update_atのレコードを作成します
```

```bash
docker-compose run web bundle exec rake db:migrate

# 直前のmigrationを取り消す
docker-compose run web bundle exec rake db:rollback
```

| HTTPメソッド　| Path | コントローラ#アクション　| 目的 |
| :-----------|:-------------| :-----| :-----|
| GET     | /boards | boards#index | 掲示板の一覧表示 |
| GET     | /boards/new |   boards#new | 掲示板を１つ作成するフォームを表示 |
| POST | /boards | boards#create | 掲示板を1つ作成 |
| GET | /boards/:id | boards#show | 1つの掲示板の詳細を表示 |
| GET | /boards/:id/edit | boards#edit | 掲示板を1つ編集するためのフォームを表示 |
| PATCH/PUT | /boards/:id   | boards#update | 掲示板の内容を更新する |
| DELETE | /boards/:id   | boards#destory | 掲示板を削除する |

## 新規作成ページの作成

```rb
get 'boards', to: 'boards#index'
```

## pry-byebugの導入

```rb
group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry-byebug'
end
```

buildし直す

```rb
def create
  Board.create(board_params)
  binding.pry
end
```

```bash
docker attach rails_web_1
```
```rb
  def create
    Board.create(board_params)
  end

  private

  def board_params
    params.require(:board).permit(:name, :title, :body)
  end
```
```rb
 board = Board.all.first
 ```
## Timezoneを変更する

```rb
module App
  class Application < Rails::Application
    config.time_zone = 'Tokyo'
  end
end
```

## 時間をフォーマットする

```rb
 <th><%= board.created_at.strftime('%Y年 %m月 %d日 %H時 %M分') %></th>
```

## 時間のフォーマットを管理する

./config/initializers/time_formats.rbを作成する

```rb
Time::DATE_FORMATS[datetime_jp] = '%Y年 %m月 %d日 %H時 %M分'
```

```rb
<th><%= board.created_at.to_s(:datetime_jp) %></th>
```
