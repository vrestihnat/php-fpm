#!/bin/bash

[[ -f "/web/dist/${DEKSHOPID}/.env.${DEKENV}.local" ]] && cp -f "/web/dist/${DEKSHOPID}/.env.${DEKENV}.local" /web/. 

composer install  --no-interaction --optimize-autoloader -d /web
composer dumpautoload -o  -d /web

composer dump-env ${DEKENV}


