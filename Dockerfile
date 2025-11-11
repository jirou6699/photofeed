FROM ruby:3.4.7

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b '0.0.0.0'"]
