#!/bin/bash

yum update -y

## Setup Nginx
amazon-linux-extras install -y nginx1
systemctl enable nginx.service
cat > /etc/nginx/conf.d/mysite.conf << EOS
# refs. https://uwsgi-docs.readthedocs.io/en/latest/tutorials/Django_and_nginx.html#configure-nginx-for-your-site
# mysite_nginx.conf

# the upstream component nginx needs to connect to
upstream django {
    # server unix:///path/to/your/mysite/mysite.sock; # for a file socket
    server 127.0.0.1:8001; # for a web port socket (we'll use this first)
}

# configuration of the server
server {
    # the port your site will be served on
    listen      8000;
    # the domain name it will serve for
    # server_name example.com; # substitute your machine's IP address or FQDN
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   # adjust to taste

    # Django media
    location /media  {
        alias /path/to/your/mysite/media;  # your Django project's media files - amend as required
    }

    location /static {
        alias /path/to/your/mysite/static; # your Django project's static files - amend as required
    }

    location /healthcheck {
        empty_gif;
        access_log off;
        break;
    }

    # Finally, send all non-media requests to the Django server.
    location / {
        proxy_pass  http://django;
        include     /etc/nginx/uwsgi_params; # the uwsgi_params file you installed
    }
}
EOS
systemctl restart nginx

## Setup Django, uWSGI
yum groupinstall "Development Tools"
yum install -y gcc
yum install -y python3
yum install -y python3-devel
pip3 install Django==3.1.1
pip3 install uwsgi==2.0.19.1
mkdir -p /etc/uwsgi/vassals/
cat > /etc/uwsgi/vassals/mysite.ini << EOS
[uwsgi]
http = :8001
chdir = /web/mysite/app
module = config.wsgi
touch-reload = /web/mysite/reload.trigger
EOS
cat > /etc/systemd/system/emperor.uwsgi.service << EOS
[Unit]
Description=uWSGI Emperor
After=syslog.target

[Service]
ExecStart=/usr/local/bin/uwsgi --emperor /etc/uwsgi/vassals
# Requires systemd version 211 or newer
RuntimeDirectory=uwsgi
Restart=always
KillSignal=SIGQUIT
Type=notify
StandardError=syslog
NotifyAccess=all

[Install]
WantedBy=multi-user.target
EOS
systemctl enable emperor.uwsgi.service
systemctl restart emperor.uwsgi.service
