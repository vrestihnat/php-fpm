#!/bin/sh

set -e
# Handle a kill signal before the final "exec" command runs
trap "{ exit 0; }" TERM INT

# strip off "/bin/sh -c" args from a string CMD
if [ $# -gt 1 ] && [ "$1" = "/bin/sh" ] && [ "$2" = "-c" ]; then
  shift 2
  eval "set -- $1"
fi


for ep in /docker-entrypoint.d/*; do
  ext="${ep##*.}"
  if [ "${ext}" = "env" ] && [ -f "${ep}" ]; then
    # source files ending in ".env"
    echo "Sourcing: ${ep} $@"
    set -a && . "${ep}" "$@" && set +a
  elif [ "${ext}" = "sh" ] && [ -x "${ep}" ]; then
    # run scripts ending in ".sh"
    echo "Running: ${ep} $@"
    "${ep}" "$@"
  fi
done


# run command with exec to pass control
echo "Running CMD: $@"
exec "$@"


