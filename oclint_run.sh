source ~/.bash_profile
 
hash oclint &> /dev/null
if [ $? -eq 1 ]; then
    echo >&2 "oclint not found, analyzing stopped"
    exit 1
fi

if [ ! -z "${SRCROOT}" ]; then 
    cd ${SRCROOT}
fi

xcodebuild -verbose -project RestGoatee-Core.xcodeproj -scheme RestGoateeCoreiOS -sdk iphonesimulator9.2 -destination "platform=iOS simulator,name=iPhone 5" clean build | xcpretty -r json-compilation-database -o ./compile_commands.json

oclint-json-compilation-database | sed 's/\(.*\.\m\{1,2\}:[0-9]*:[0-9]*:\)/\1 warning:/'

printf '\7\7' # notify user that the task is done
