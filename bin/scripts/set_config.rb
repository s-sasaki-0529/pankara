require_relative "../../app/models/util"
mode = ARGV[0]
key = ARGV[1]
value = ARGV[2]

if mode == 'set'
  Util.set_config(key , value)
elsif mode == 'unset'
  Util.unset_config(key)
end
