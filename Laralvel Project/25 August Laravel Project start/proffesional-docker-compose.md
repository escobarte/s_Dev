> **Structure:**
> **src/** — сюда позже положим код Laravel (или склонируем репо).
> **nginx/default.conf** — наш конфиг веб-сервера (root → /public).
> **docker/php/Dockerfile** — свой образ php-fpm с расширениями и composer.
> **compose.yaml** - web+php+db+node