FROM ruby:2.3.0

LABEL maintainer = "Jnpr-community-netdev <jnpr-community-netdev@juniper.net>"

LABEL version="1.0"

ENV VERSION "1.0"

ENV NAME "chef-client"

WORKDIR /chef-client

COPY chef-client/Gemfile ./

COPY chef-client/client.rb ./

RUN mkdir /etc/chef

RUN apt-get update \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN gem uninstall -i /usr/local/lib/ruby/gems/2.3.0 bundler

RUN gem install bundler -v "1.17.3"

RUN gem install bundle -v "0.0.1"

RUN bundle install

COPY chef-client/startup.sh /

ENTRYPOINT ["/bin/bash", "-e", "/startup.sh"]
