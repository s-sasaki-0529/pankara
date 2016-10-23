# coding: utf-8

@path = `echo $ZENRA`
@path.chomp!
worker_processes 1 
working_directory @path
timeout 300
preload_app true
listen "#{@path}/shared/tmp/unicorn.sock" , backlog: 1024
pid "#{@path}/shared/tmp/unicorn.pid"
stderr_path "#{@path}/logs/stderr.log"
stdout_path "#{@path}/logs/stdout.log"
