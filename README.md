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

./db/migrate/create_boards.rb
```rb
class CreateBoards < ActiveRecord::Migration[5.0]
  def change
    create_table :boards do |t|
      t.string :name
      t.string :title
      t.text :body

      # これはcreate_at と update_atのレコードを作成します
      t.timestamps
    end
  end
end
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

## リソースベースルーティングとURL用Helper

### ブラウザでroutesを確認

```
http://localhost:3000/rails/info/routes
```

8つのメソッドを作成
```rb
Rails.application.routes.draw do
  resources :boards
end
```

Routesを制限
```rb
Rails.application.routes.draw do
  resources :boards, only: [:index, :new, :create, :show]
end
```

board.idが1の場合/boards/1がリンク先となる
```erb
<td><%= link_to '詳細', board, class: 'btn btn-outline-dark'%> </td>
```

boards一覧に飛ぶ
```erb
<%= link_to '掲示板一覧', boards_path, class: 'btn btn-outline-dark'%>
```

databaseの書き換え
```rb
 def update
    board = Board.find(params[:id])
    board.updare(boards_params)
  end
```

/board/:idにredirectされる
```rb
def update
    board = Board.find(params[:id])
    board.updare(boards_params)
    redirect_to boards
  end
```

```erb
<div class="ml-auto boards__linkBox">
  <%= link_to '一覧', boards_path, class: 'btn btn-outline-dark'%>
  <%= link_to '編集',edit_board_path(@board), class: 'btn btn-outline-dark'%>
</div>
```

./app/views/boards/_form.html.erb
```erb
<%= form_for board do |f| %>
<div class="form-group">
  <%= f.label :name, '名前' %>
  <%= f.text_field :name, class: 'form-control' %>
</div> 
<div class="form-group">
  <%= f.label :title, 'タイトル' %>
  <%= f.text_field :title, class: 'form-control' %>
</div>
<div class="form-group">
  <%= f.label :body, '本文' %>
  <%= f.text_area :body, class: 'form-control', rows: 10 %>
</div>
<%= f.submit '保存', class: 'btn btn-primary' %>
<% end %>
```

パーシャルを呼び出す
```erb
<%= render partial: 'form', locals: { board: @board } %>
```
 アンダースコアが必要は必要ない

./app/views/boards/_board.html.erb
```erb
<div class="card">
  <div class="card-header">
    <h4><%= @board.title %></h4>
  </div>
  <div class="card-body">
    <p class="card-text"><%= simple_format(board.body) %></p>
    <p class="text-right font-weight-bold mr-10"><%= board.name %></p>
  </div>
</div>
```

./app/views/boards/show.html.erb
```erb
<%= render partial: 'board', object: @board %>

<%= render @board %>
```

objext: @boardとした場合は、パーシャル名(board)と同名のローカル変数が作成されて、パーシャルに渡される。

## 掲示板の削除機能
```erb
<td><%= link_to '削除', board, class: 'btn btn-outline-dark', method: :delete%></td>
```

削除ボタンのクリックにより_method=deleteというパラメータが送信される

## コントローラのフィルタ-機能
```rb
class BoardsController < ApplicationController
  before_action :set_target_board, only: %i[show edit update destroy]

  private

  def set_target_board
    @board = Board.find(params[:id])
  end
end

```

## 手動でdbのデータを編集する

./db/seeds.rb
```rb
if Rails.env == 'development'
  (1..50).each do |i|
    Board.create(name: "ユーザー#{i}", title: "タイトル#{i}", body: "本文#{i}")
  end
end
```

## ページネーションの実装

###　シードデータの投入コマンド
```bash
docker-compose exec web bundle exec rake db:seed
```

### kaminariをGwmfileに追加する
```rb
gem 'kaminari'
```

### kaminariの設定ファイルを生成する
```bash
docker-compose exec web bundle exec rails g kaminari:config
```

### kaminariのviewファイルを生成する
```bash
docker-compose exec web bundle exec rails g kaminari:views bootstrap4
```

./app/controllers/boards_controller.rb
```rb
def index
  @boards = Board.page(params[:page])
end
```

./app/views/boards/index.html.erb
```erb
<div class="d-flex align-items-center">
  ...
</div>
<table class="table table-hover boards__table">
...
</table>

# 追加
<%= paginate @boards%>
```

./config/application.rb
```rb
module App
  class Application < Rails::Application
    config.i18n.default_local = :ja
  end
end
```

./config/locales/ja.yml
```yml
ja:
  views:
    pagination:
      first: '最初'
      last: '最後'
      previous: '前'
      next: '次'
      truncate: '...'
```
### kaminariのページネーションの設定

./config/initializers/kaminari_config.rb
```rb
Kaminari.configure do |config|
  # config.default_per_page = 25
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.max_pages = nil
  # config.params_on_first_page = false
end

```

## フラッシュでメッセージを表示
```rb
def create
  flash[:notice] = "「#{board.title}」の掲示板を作りました"
end
```

./app/views/show.html.erb
```erb
<% if flash[:notice]%>
  <div class="alert alert-primary"><%= flash[:notice] %> </div>
<% end %>
```

redirect_toを使用したflashの表示
```rb
def destroy
  @board.delete
  redirect_to boards_path, flash: {notice: "「#{@board.title}の掲示板が削除されました」"}
end
```
## Boardモデルのバリデーション

./app/models/board.rb

```rb
class Board < ApplicationRecord
validates :name, presence: true, length: {maximum: 10}
validates :title, presence: true, length: {maximum: 30}
validates :body, presence: true, length: {maximum: 1000}
end
```

```rb
   def create
    board = Board.new(board_params)
    if board.save
      flash[:notice] = "「#{board.title}」の掲示板を作りました"
      redirect_to board
    else
      redirect_to new_board_path, flash: {
        board: board,
        error_messages: board.errors.full_messages
      }
    end
  end
```

エラーを日本語表記にする
```Gemfile
gem 'rails-i18n'
```

エラーの中身の表記を日本語にする
```yml
ja:
  activerecord:
    attributes:
      board:
        name: 名前
        title: タイトル
        body: 本文
```

## モデルのアソシエーション, annotationのgem追加

### commentsテーブル

| column　| 用途 |
| :--------|:-------------|
| id       | コメントID  |
| board_id | 関連する　boardのid |
| name     | コメント記入者名 |
| comment  | コメント内容 |

### annotationの追加

``` Gemfile
gem 'annotate', '~> 2.7'
```

```bash
docker-compose run --rm web bundle update rake
docker-compose build
docker-compose run --rm web bundle exec annitate
```
