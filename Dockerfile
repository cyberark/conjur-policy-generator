FROM ruby:2.4.2-alpine

RUN mkdir -p /generator
WORKDIR /generator

COPY Gemfile ./
RUN gem install -g Gemfile

COPY src ./src
COPY spec ./spec
COPY Rakefile .

ENTRYPOINT [ "rake" ]
