FROM ruby:2.3.0

LABEL maintainer = "Jnpr-community-netdev <jnpr-community-netdev@juniper.net>"

LABEL version="1.0"

ENV PUPPET_AGENT_VERSION="3.7.3"

ENV VERSION "1.1"

ENV NAME "jpuppet-agent"

WORKDIR /puppet-agent

COPY bin/Gemfile ./

RUN mkdir /etc/puppet

COPY bin/puppet.conf /etc/puppet/

RUN apt-get update \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN gem uninstall -i /usr/local/lib/ruby/gems/2.3.0 bundler

RUN gem install bundler -v "< 2.0"

RUN gem install bundle -v "< 2.0"

RUN bundle install

RUN sed -i '/YAML_ENGINE = defined?(YAML::ENGINE) ? YAML::ENGINE.yamler : "syck"/c\  YAML_ENGINE = defined?(YAML::ENGINE) ? YAML::ENGINE.yamler : (defined?(Psych) && YAML == Psych ? "psych" : "syck")' \
    /usr/local/bundle/gems/puppet-3.7.3/lib/puppet/vendor/safe_yaml/lib/safe_yaml.rb

COPY bin/transaction.rb /usr/local/bundle/gems/puppet-3.7.3/lib/puppet/transaction.rb

COPY bin/startup.sh /

ENTRYPOINT ["/bin/bash", "-e", "/startup.sh"]
