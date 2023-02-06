FROM ruby:2.4.5
RUN apt-get update -qq && apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY views_generator.rb /usr/local/bundle/gems/kaminari-core-1.2.2/lib/generators/kaminari/
COPY . /app
