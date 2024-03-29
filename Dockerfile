FROM ruby:latest
RUN apt-get update -qq && apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN bundle install
