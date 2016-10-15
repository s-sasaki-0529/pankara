require 'yaml'
puts YAML.load_file('../secret.yml')['mysql']['password']
