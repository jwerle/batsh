#!/bin/bash

## batsh directory
BATSH="${BATSH:-${HOME}/.batsh}"

## batsh queue
QUEUE="${QUEUE:-${BATSH}/.queue}"

## batsh concurrency file
CONCURRENCY="${STORE:-${BATSH}/.concurrency}"

## batsh lock file
LOCK="${LOCK:-${BATSH}/.LOCK}"

## batsh version
BATSH_VERSION="0.0.1"

## init state
init () {
  ## ensure batsh directory
  if ! test -d "${BATSH}"; then
    mkdir "${BATSH}"
  fi

  ## ensure queue exists
  if ! test -f "${QUEUE}"; then
    touch "${QUEUE}"
  fi

  ## ensure concurrency file exists
  if ! test -f "${CONCURRENCY}"; then
    touch "${CONCURRENCY}"
  fi

  return $?
}

## outputs usage
usage () {
  echo "usage: batsh [-hV]"
  echo "   or: batsh push <script>"
  echo "   or: batsh run <script>"
  echo "   or: batsh clear"
  echo "   or: batsh reset"
  echo "   or: batsh concurrency <n>"
  return $?
}

## main
main () {
  local arg="${1}"; shift

  ## init
  (init)

  ## parse arg
  case "${arg}" in
    -h|--help)
      usage
      ;;

    -V|--version)
      echo "${BATSH_VERSION}"
      ;;

    push|p)
      batsh_push "${@}" ;;

    run|end|r)
      batsh_end "${@}" ;;

    concurrency|c)
      batsh_concurrency "${@}" ;;

    clear)
      batsh_clear "${@}" ;;

    reset)
      batsh_reset "${@}" ;;

    *)
      if test -f "${arg}"; then
        {
          shopt -s expand_aliases
          alias push='batsh_push'
          alias run='batsh_end'
          alias end='batsh_end'
          alias concurrency='batsh_concurrency'
          alias clear='batsh_clear'
          alias reset='batsh_reset'
          source "${arg}"
        }
        return $?
      fi
       if ! [ -z "${arg}" ]; then
         if [ "-" == "${arg:0:1}" ]; then
           echo >&2 "error: Unkown option \`${arg}'"
         else
           echo >&2 "error: Unkown command \`${arg}'"
         fi
       fi

       usage >&2
       return 1
      ;;
  esac

  return $?
}

## push job
batsh_push () {
  local job="${@}"
  if test -f "${LOCK}"; then
    echo >& "error: batsh currently locked"
    return 1
  fi
  echo "${job}" >> "${QUEUE}"
  return $?
}

## set concurrency
batsh_concurrency () {
  rm -f "${CONCURRENCY}"
  echo "${1}" > "${CONCURRENCY}"
  return $?
}

## clear all jobs
batsh_clear () {
  rm -f "${QUEUE}"
  return $?
}

## run all jobs running code when complete
batsh_end () {
  if test -f "${LOCK}"; then
    return 1
  fi
  touch "${LOCK}"
  local end="${@}"
  local queue=()
  IFS=$'\n' queue=($(<${QUEUE}))
  declare -i i=0
  declare -i len=${#queue[@]}
  declare -i local concurrency=$(<"${CONCURRENCY}")

  for ((; i < ${concurrency}; ++i )); do
    eval "${queue[$i]}" &
  done

  for ((; i < ${len}; ++i )); do
    (eval "${queue[$i]}")
  done

  wait
  (eval "${end}")
  rm -f "${LOCK}"
  return $?
}

## reset batsh state
batsh_reset () {
  batsh_clear
  batsh_concurrency 1
  return $?
}

## run
(main "${@}")
exit $?

