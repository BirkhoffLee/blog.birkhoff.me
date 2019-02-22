curl \
  --data chat_id="$TELEGRAM_CHATID" \
  --data disable_web_page_preview=true \
  --data parse_mode=HTML \
  --data-binary @- https://api.telegram.org/bot$TELEGRAM_BOT_APIKEY/sendMessage <<EOF
text=
[TravisCI] <a href="https://travis-ci.org/$TRAVIS_REPO_SLUG">$TRAVIS_REPO_SLUG</a>

<a href="https://github.com/$TRAVIS_REPO_SLUG/commit/$TRAVIS_COMMIT">${TRAVIS_COMMIT:0:7}</a>: $TRAVIS_COMMIT_MESSAGE

The commit has been successfully been deployed to https://blog.birkhoff.me.

$TRAVIS_BUILD_WEB_URL
EOF
