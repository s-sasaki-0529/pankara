# coding: utf-8

@path = `echo $ZENRA`
@path.chomp!
worker_processes 1 
working_directory @path
timeout 30
preload_app true
stderr_path "#{@path}/logs/stderr.log"
stdout_path "#{@path}/logs/stdout.log"
