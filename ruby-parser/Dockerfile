FROM ruby:latest

# Build general linux dependencies
RUN apt-get update && apt-get install -y llvm libgc-dev libpcre3-dev libevent-dev

# Build rails dependencies
WORKDIR /app
COPY Gemfile* ./
RUN bundle install

# Link project files
COPY . .
