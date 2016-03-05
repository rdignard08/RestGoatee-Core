source ~/.bash_profile
 
hash oclint &> /dev/null
if [ $? -eq 1 ]; then
echo >&2 "oclint not found, analyzing stopped"
exit 1
fi
 
cd ${TARGET_TEMP_DIR}
 
    echo "[*] compile_commands.json not found, possibly clean was performed"
    echo "[*] starting xcodebuild to rebuild the project.."
    # clean previous output
    if [ -f xcodebuild.log ]; then
    rm xcodebuild.log
    fi
 
    cd ${SRCROOT}
 
xcodebuild -project RestGoatee-Core.xcodeproj -scheme RestGoatee-Core clean build | xcpretty -r json-compilation-database
ls 
    echo "[*] transforming xcodebuild.log into compile_commands.json..."
    cd ${TARGET_TEMP_DIR}
    #transform it into compile_commands.json
 
    echo "[*] copy compile_commands.json to the project root..."
    cp ${TARGET_TEMP_DIR}/compile_commands.json ${SRCROOT}/compile_commands.json
 
 
echo "[*] starting analyzing"
cd ${TARGET_TEMP_DIR}
oclint-json-compilation-database | sed 's/\(.*\.\m\{1,2\}:[0-9]*:[0-9]*:\)/\1 warning:/'

printf '\7\7' # notify user that the task is done
