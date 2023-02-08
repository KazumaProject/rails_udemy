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

### シードデータの投入コマンド
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

# migrateion後自動でannotationが追加される 
docker-compose exec web bundle exec rails g annotate:install
```

## Comentモデルの作成

```bash
docker-compose run web bundle exec rails g \
model comment board:references name:string comment:text
```

`boaed:references`はBoardモデルと紐付ける為のboard_id columnが作成される

### コマンド実行後作成された./db/migrate/<time_stamp>.rb
```rb
class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :board, foreign_key: true
      t.string :name
      t.text :comment

      t.timestamps
    end
  end
end
```

### not null制約をつける
```rb
class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|

      t.string :name, null: false
      t.text :comment, null: false
    end
  end
end
```

./app/models/board.rb
```rb
class Board < ApplicationRecord
  #追加
  has_many :comments
end
```

./app/models/comment.rb
```rb
class Comment < ApplicationRecord
  belongs_to :board
end
```

## コメント書き込み機能のルート追加&コントローラー作成

### commentsコントローラを作成
```bash
docker-compose exec web \
rails g controller comments create destroy --skip-template-engine
```

### ./confug/routes.rbを編集
```rb
Rails.application.routes.draw do
  resources :boards
  resources :comments, only: %i[create destroy]
end
```

## コメント書き込みフォームの作成

./app/views/boards/_comment_form.html.erb
```erb
<div class="p-comment__formBox">
  <p class="p-comment__formTitle">コメント記入</p>
  <%= form_for comment do |f| %>
    <%= f.hidden_field :board_id %>
    <div class="form-group">
      <%= f.label :name, '名前' %>
      <%= f.text_field :name, class: 'form-control' %>
    </div>
    <div class="form-group">
      <%= f.label :comment, 'コメント' %>
      <%= f.text_area :comment, class: 'form-control', rows: 4 %>
    </div>
    <%= f.submit '送信', class: 'btn btn-primary' %>
  <% end %>
</div>
```

hiffen_fieldでboard_idを隠す

## コメント保存機能

### デバッグ結果を整形
```Gemfile
  gem 'rails-flog', require: 'flog'
```

### comments_controller
```rb
class CommentsController < ApplicationController
  def create
    comment = Comment.new(comment_params)
    if comment.save
      flash[:notice] = 'コメントを投稿しました'
      redirect_to comment.board
    else
      redirect_to :bask, flash: {
        comment: comment,
        error_messages: comment.errors.full_messages
      }
      # Rails 5.1以降は
      # flash[:comment] = comment
      # flash[:error_messages] = comment.errors.full_messages
      # redirect_back fallback_location: comment.board
    end
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:board_id, :name, :comment)
  end
end
```
## コメント表示の実装

./app/views/comments/_form.html.erbを指定
```rb
<%= render partial: 'comments/form', locals: { comment: @comment} %>
```

## 多対多の関連づけ

### tag modelの作成
```bash
docker-compose exec web bundle exec \
rails g model tag name:string
```

### 中間テーブルの作成
```bash
docker-compose exec web bundle exec \
rails g model board_tag_relation board:references tag:references
```

### Tagを中間テーブルを通して　Boardと関連づける

#### ./app/models/tag.rb
```rb
class Tag < ApplicationRecord
  has_many :board_tag_relations
  has_many :boards, through: :board_tag_relations
end
```

#### ./app/models/board.rb
```rb
class Board < ApplicationRecord
  has_many :comments
  has_many :board_tag_relations
  has_many :tags, through: :board_tag_relations
end
```

## アソシエーションのdependentオプション

### destroyメソッドから呼ばれる

```rb
class Board < ApplicationRecord
  has_many :board_tag_relations, dependent: :delete_all
end
```

```rb
class Tag < ApplicationRecord
  has_many :board_tag_relations, dependent: :delete_all
end
```

## タグを使用した掲示板検索機能

```rb
  def index
    @boards = params[:tag_id].present? ? Tag.find(params[:tag_id]).boards : Board.all
    @boards = @boards.page(params[:page])
  end
```

もしtag idがあったら Tagに基づく掲示板を取得する

もしtag idがなかった Board.allで全ての掲示板を取得する

## ユーザー認証の仕組み

HTTPプロトコルはステートレスなので状態を持っておらず２回目以降のユーザーが前にアクセスしたユーザーかどうか判別できない。

### セッション

1. ユーザー: 1回目のアクセスでログイン認証
2. サーバー: セッションIDを渡す (Cookieにセットされる)
3. ユーザー: 2回目にCookieに保存されたセッションIDを送る

### ユーザー認証に必要なController, View, Modelの作成
Railsに備わっている `has_secure_password` を使用する

```Gemfile
# コメントアウトを削除する
gem 'bcrypt', '~> 3.1.7'
```

### User Modelを生成する
```bash
docker-compose exec web \
rails g model user name:string password_digest:string
```

`password_digest` は `has_secure_password` で使用され暗号化されたパスワードが入れられる

./db/migrate/ 配下の `create_users` を編集する
```rb
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :name, unique: true
  end
end
```

```bash
docker-compose exec web rails db
:migrate
```

### Sessions Controllerを生成する
```bash
docker-compose exec web \
rails g controller sessions create destory --skip-template-engine
```
view fileはスキップする

### Home Controllerを生成する
Home Controllerはrootで使用される

```bash
docker-compose exec web \
rails g controller home index
```

### Users Controllerを生成する
```bash
docker-compose exec web \
rails g controller users new create me
```

## ユーザー認証で使用するRoutingの設定

```rb
Rails.application.routes.draw do
  get 'mypage', to: 'users#me'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  root 'home#index'
  resources :users, only: %i[new create]
  resources :boards
  resources :comments, only: %i[create destroy]
end
```

- usersをresources形式に直す

- get 'users/me' をmypageにする

- loginをsessions#createで行い、logoutをsessions#destroyで行う

## ユーザーモデルの認証機能の設定
./app/models/user.rb
```rb
class User < ApplicationRecord
  has_secure_password
end
```

`has_secure_password` の設定によりpassword属性とpassword_confirmation属性が追加される

### Validationの追加
```rb
class User < ApplicationRecord
  has_secure_password

  validates :name,
    presence: true,
    uniqueness: true,
    length: { maximum: 16 },
    format: {
      with: /\A[a-z0-9]+\z/,
      message: 'は小文字英数字で入力してください'
    }

  validates :password,
  length: { minimum: 8 }
end

```

## ユーザー登録機能の実装

### UsersController
```rb
 def new
    @user = User.new(flash[:user])
  end

 def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      redirect_to mypage_path
    else
      redirect_to :back, flash: {
        user: user,
        error_massages: user.errors.full_messages
      }
    end
  end
```

`session[:user_id]` でuser_idの変数にuser.idを格納している。ページを跨いで参照できる

user_idに値があるかどうかでログインしているか判断する

`@user = User.new(flash[:user])` で入力に問題があっても記入したものが残る

## ログインユーザの取得
```rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :current_user

  private

  def current_user
    return unless session[:user_id]
    @current_user = User.find_by(id: session[:user_id])
  end
end
```
session[:user_id]があればログインしている

## Railsのバージョンアップ
- Gemを含めてアップデートが必要となる

- バージョンアップにより、そのままではコードが動作しなくなる、動作が変わる可能性有

## Rails 5.0系 -> 5.2系
### Gemfileを編集
```Gemfile
'rails', '~> 5.2.2'
```

### bundle update
```bash
docker-compose run web bundle update rails
```
