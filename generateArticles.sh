#!/bin/bash

readonly appID='asCqw49GNR2QRP7xw1vETNZpW9DoqDtibGWCbg4e';
readonly restID='T8eI5HefBUPlZRQQ6UoSTFqoKgd1raXl1iAhWXw4';

for i in {1..10}; do	
    curl -X POST \
      -H "X-Parse-Application-Id: ${appID}" \
      -H "X-Parse-REST-API-Key: ${restID}" \
      -H "Content-Type: application/json" \
      -d '{"title":"TestArticle '"${i}"'","subtitle":"TestSubtitle '"${i}"'"}' \
      https://api.parse.com/1/classes/News &

done;

wait;
