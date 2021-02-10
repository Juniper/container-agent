current_dir = File.dirname(__FILE__)
log_level               :auto
log_location            STDOUT
chef_server_url         "YOUR SERVER IP HERE"
node_name               "YOUR NODE NAME HERE"
validation_key          "YOUR KEY LOCATION HERE"
validation_client_name  "YOUR KEY NAME HERE"
file_cache_path         "#{current_dir}/cache"
trusted_certs_dir       "/home/root/trusted_certs"
verbose_logging         true
ssl_verify_mode         :verify_none
Ohai::Config[:disabled_plugins] = [ :Network ]