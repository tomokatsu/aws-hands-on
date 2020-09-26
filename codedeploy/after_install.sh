#!/bin/bash

# 本来であれば、特定のシークレットキーを外部から取得してきて、埋め込むことが正しい
# e.g. SSMパラメータストアの利用など
echo "SECRET_KEY = 'dummy_secret_key'" > /web/mysite/app/config/local_settings.py

# uWSGI の reload
touch /web/mysite/reload.trigger
