source html.sh

project_dir() {
    (
        cd "$TM_DIRECTORY";
        while [ "$(pwd)" != "/" ]; do
            test -e "$(pwd)/AndroidManifest.xml" && \
            echo $(pwd) && \
            break
            cd ..
        done
    )
}

package_name() {
    cat $1 | \
    xpath 'string(//manifest/@package)' 2> /dev/null
}

java_property() {
    cat $1 | \
    grep $2 | \
    cut -d"=" -f2
}

activity_name() {
    cat $1 | \
    xpath 'string(//*/action[@android:name="android.intent.action.MAIN"]/../../@android:name)' 2> /dev/null
}

device_count() {
    echo $[$($ANDROID_ADB devices | grep -v '^\*' | wc | awk '{ print $1 }') - 2]
}

require_file() {
    while [ $# -gt 0 ]; do
        test -e "$1" || \
        put_err "Couldn't find required file $1!"
        shift 1
    done
}