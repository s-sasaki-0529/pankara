# coding: utf-8

@path = `echo $ZENRA`
@path.chomp!
worker_processes 2
working_directory @path
timeout 30
stderr_path "#{@path}/logs/stderr.log"
stdout_path "#{@path}/logs/stdout.log"
