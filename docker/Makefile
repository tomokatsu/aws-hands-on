app_name := polls

.PHONY: new_project new_app up upd down start stop

init_project:
	docker-compose run --rm web django-admin.py startproject config .
	cp get_random_secret_key.py app/get_random_secret_key.py
	docker-compose run --rm web python get_random_secret_key.py > app/config/local_settings.py
	rm app/get_random_secret_key.py
	gsed -n "/SECRET_KEY/=" app/config/settings.py | xargs -I {} gsed -i '{}c\\' app/config/settings.py
	gsed -n "/keep the secret key used in production secret/=" app/config/settings.py | xargs -I {} gsed -i '{}c\\' app/config/settings.py
	patch -u app/config/settings.py < settings.py.patch

new_app: 
	docker-compose run --rm web python3 manage.py startapp ${app_name}

up:
	docker-compose up

upd:
	docker-compose up -d

down:
	docker-compose down

start:
	docker-compose start

stop:
	docker-compose stop
