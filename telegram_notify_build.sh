curl --data chat_id="$TELEGRAM_CHATID" --data disable_web_page_preview=true --data-binary @- https://api.telegram.org/bot$TELEGRAM_BOT_APIKEY/sendMessage <<EOF
text=$TRAVIS_REPO_SLUG <$TRAVIS_COMMIT>
$TRAVIS_COMMIT_MESSAGE

The commit has been successfully been deployed to https://blog.birkhoff.me.

$TRAVIS_BUILD_WEB_URL
EOF
