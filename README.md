batsh(1)
=======

Queue bash commands to run with a given concurrency. Similar to
`batch(1)` without the crap

## install

```sh
$ bpkg install batsh
```

## usage

```
usage: batsh [-hV]
   or: batsh push <script>
   or: batsh run [script]
   or: batsh clear
   or: batsh reset
   or: batsh concurrency <n>
```

`batsh(1)` allows the user to queue jobs that will run with a set
concurrency (Default `0`). Jobs are pushed with `batsh push` onto
a queue and are ran with `batsh run`. The queue can be cleared with
`batsh clear`.

## push

Jobs that are pushed are just shell scripts that are invoked with the
batsh jobs are ran.

```sh
$ batsh push 'echo beep'
```

## run

Jobs are ran with `batsh run` which accepts optional code to be executed
when all jobs have completed. This command has an alias of `batsh r`.

```sh
$ batsh run 'echo done'
beep
done
```

## concurrency

Concurrency can be set with `batsh concurrency`. It has an alias of
`batsh c`.

```sh
$ batsh concurrency 2
```

## batsh instance

`batsh(1)` manages its state in a directory set with the `BATSH`
environment variable. The default is `${HOME}/.batsh`. A user can manage
multiple `batsh` instances by settings this variable.

## batch scripts

`batsh(1)` can run a script exposing a few helper functions. Batsh
script is just bash.

```sh
#!/usr/bin/env batsh

## jobs
push 'echo beep'
push 'echo boop'
push 'sleep 1 && echo beeps'
push 'sleep 1 && echo boops'

## set concurrency
concurrency 2

## run
run 'echo done'
```

## license

MIT

