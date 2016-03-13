# coding: utf-8

@path = `echo $ZENRA`
@path.chomp!
worker_processes 1
working_directory @path
timeout 300
listen '/tmp/zenra.sock'
stderr_path "#{@path}/logs/stderr.log"
stdout_path "#{@path}/logs/stdout.log"
