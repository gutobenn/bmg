server {
  listen      [::]:80; #IPv6 compatibility
  listen      80;
  server_name ${SERVER_NAME};

  location ~ ^/(media|photos)/  {
    root /app/media/photos;
    expires max;
    break;
  }

  location    / {
    proxy_pass  http://${APP};
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_set_header X-Request-Start $msec;
  }
}

