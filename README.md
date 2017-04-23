# Simple chat server & client

I just read [this article](http://blog.appsignal.com/2017/03/07/ruby-magic-concurrency-processes.html) and it inspired me to refresh concurrency.

As usual I started from scratch with a minimal prototype (`simple_server.rb` and `simple_client.rb`); then wrapped it all in sugar (`server.rb` and `client.rb`).

## Usage

Launch one server and two clients in three consoles, then "chat away" (cit.) :)

Pass option `debug` in the command line to enable debug mode. Alternativey, the client accepts your nickname of choice.
