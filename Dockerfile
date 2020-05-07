FROM ruby:2.2.5

ARG version="3.7.3"

ENV PUPPET_AGENT_VERSION="$version"

WORKDIR /puppet-agent

RUN apt-get update && apt-get install vim -y && mkdir /etc/puppet

COPY bin/Gemfile ./

COPY bin/puppet.conf /etc/puppet/

RUN bundle install

RUN sed -i '/YAML_ENGINE = defined?(YAML::ENGINE) ? YAML::ENGINE.yamler : "syck"/c\  YAML_ENGINE = defined?(YAML::ENGINE) ? YAML::ENGINE.yamler : (defined?(Psych) && YAML == Psych ? "psych" : "syck")' \
    /usr/local/bundle/gems/puppet-3.7.3/lib/puppet/vendor/safe_yaml/lib/safe_yaml.rb

COPY bin/transaction.rb /usr/local/bundle/gems/puppet-3.7.3/lib/puppet/transaction.rb

COPY bin/startup.sh /

RUN ["chmod", "+x", "/startup.sh"]

ENTRYPOINT ["/startup.sh"]
