# NeoChat :heart_eyes_cat:

neo (meaningless prefix) + chat (chat)

## Usage

TODO

## Official chat room

<http://lingr.com/room/vim>

## NeoChat Archtecture

* neochat framework
    * (glueing)
* neochat protocol
    * to implement network related stuff for each chat backend services
* neochat UI
* neochat core

This repository is the neochat framework, and has a sample protocols and UIs.

* protocol/echoback
    * A dummy protocol. It just returns what you say.
* ui/vanilla
    * TODO

## NeoChat Workflow

* `neochat#establish(protocol)` to get a `connection` object
* `neochat#hear(connection)` to get what people there are talking
* `neochat#say(connection, message)` to post what you want to shre
* `neochat#bye(connection)` to terminate the `connection` (the connection won't be reusable)

All functions are non-blocking.

## License

GPLv3 or any later versions.
