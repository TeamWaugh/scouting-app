rm -r app/res
cp -r res app/res
rm game.love
cd src
zip -r game.love *
cd ..
rm app/assets/game.love
cp src/game.love game.love
mv src/game.love app/assets/game.love
java -jar apktool.jar build app
rm app.apk
mv app/dist/app.apk app.apk
rm signed_app.apk
./signapk.sh app.apk
rm ~/-v4/www/vex.apk
cp signed_app.apk ~/-v4/www/vex.apk
mv signed_app.apk app.apk
