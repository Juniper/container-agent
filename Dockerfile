FROM ruby:2.2.5

LABEL maintainer = "Jnpr-community-netdev <jnpr-community-netdev@juniper.net>"

LABEL version="1.0"

ENV PUPPET_AGENT_VERSION="3.7.3"

RUN apt-get update \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/puppet

WORKDIR /puppet-agent

COPY bin/Gemfile ./

COPY bin/puppet.conf /etc/puppet/

RUN bundle install

RUN sed -i '/YAML_ENGINE = defined?(YAML::ENGINE) ? YAML::ENGINE.yamler : "syck"/c\  YAML_ENGINE = defined?(YAML::ENGINE) ? YAML::ENGINE.yamler : (defined?(Psych) && YAML == Psych ? "psych" : "syck")' \
    /usr/local/bundle/gems/puppet-3.7.3/lib/puppet/vendor/safe_yaml/lib/safe_yaml.rb

COPY bin/transaction.rb /usr/local/bundle/gems/puppet-3.7.3/lib/puppet/transaction.rb

COPY bin/startup.sh /

ENTRYPOINT ["/bin/bash", "-e", "/startup.sh"]
