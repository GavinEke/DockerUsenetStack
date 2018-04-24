datastore:
  build: .
  volumes:
    - /srv/data/downloads:/downloads
  restart: always

sabnzbd:
  image: linuxserver/sabnzbd:latest
  volumes:
    - ./sabnzbd:/config
  volumes_from:
    - datastore
  ports:
    - 8080:8080
    - 9090:9090
  env_file: uidgid.env
  restart: always

sonarr:
  image: linuxserver/sonarr:latest
  volumes:
    - ./sonarr:/config
    - /srv/data/tv:/tv
  volumes_from:
    - datastore
  ports:
    - 8989:8989
  env_file: uidgid.env
  links:
    - sabnzbd
    - plex
  restart: always 

radarr:
  image: linuxserver/radarr:latest
  volumes:
    - ./radarr:/config
    - /srv/data/movies:/movies
  volumes_from:
    - datastore
  ports:
    - 7878:7878
  env_file: uidgid.env
  links:
    - sabnzbd
    - plex
  restart: always

plex:
  image: linuxserver/plex:latest
  volumes:
    - ./plex:/config
    - /srv/data/tv:/data/tv
    - /srv/data/movies:/data/movies
  ports:
    - 32400:32400
    - 32469:32469
    - 5353:5353/udp
    - 1900:1900/udp
  env_file: uidgid.env
  environment:
    - VERSION=public
  restart: always

ombi:
  image: linuxserver/ombi:latest
  volumes:
    - ./ombi:/config
  ports:
    - 3579:3579
  env_file: uidgid.env
  links:
    - plex
    - sonarr
    - radarr
  restart: always

nginx:
  image: linuxserver/nginx:latest
  volumes:
    - ./nginx:/config
  ports:
    - 80:80
    - 443:443
  env_file: uidgid.env
  environment:
    - DOMAIN_NAME=yourdomain.com
    - VIRTUAL_HOST=yourdomain.com
    - LETSENCRYPT_HOST=yourdomain.com
    - LETSENCRYPT_EMAIL=youremail@yourdomain.com
  links:
    - sabnzbd
    - sonarr
    - radarr
    - plex
    - ombi
  restart: always
