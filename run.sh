#!/bin/bash

FIRST_TIME_SETUP_RUNNING="false"

 __cleanup () {
    if [ "$FIRST_TIME_SETUP_RUNNING" == "true" ]; then
        rm -rf ./build-files
    fi
 }

trap __cleanup EXIT

logo () {
    echo "YOCTO BUILD ENVIRONMENT"
    echo "POWERED BY DOCKER"
    echo "Author: korodit"
    echo "For Public Use"
}

if [ ! -d "build-files" ]; then
    clear
    logo
    echo
    echo '"build-files" directory does not exist. You need to run first-time setup.'
    echo 'Would you like to run it now? Make sure you have set proper proxy settings'
    echo 'if you are inside corporate network, since setup will also download various open'
    echo 'source yocto related repositories.'
    echo
    echo 'Press ENTER to initiate first time setup.'
    echo 'Press any OTHER KEY to abort.'
    read -rsn1 input
    case $input in
    "")
        FIRST_TIME_SETUP_RUNNING="true"
        ./setup.sh || exit 1
        FIRST_TIME_SETUP_RUNNING="false"
        echo
        echo "Setup done, press any key to continue..."
        read -rsn1 input
        ;;
    *)
        exit 0
    esac
fi

if ! sudo docker inspect --type=image yocto-mini > /dev/null 2>&1 ; then
    clear
    logo
    echo
    echo 'Docker image "yocto-mini" not found. The image is needed for'
    echo 'the yocto build environment to run. Would you like to create'
    echo 'the image now? If you are behind corporate proxy, you must'
    echo 'make sure you have set the correct settings before proceeding.'
    echo 'Creating the image will require root privileges.'
    echo
    echo 'Press ENTER to initiate "yocto-mini" docker image creation.'
    echo 'Press any OTHER KEY to abort.'
    read -rsn1 input
    case $input in
    "")
        ./create-yocto-mini.sh || exit 1
        echo
        echo '"yocto-mini" image creation completed, press any key to continue...'
        read -rsn1 input
        ;;
    *)
        exit 0
    esac

fi

if [ ! -f ".env" ]; then
  echo "ERROR: File '.env' does not exist. Have you run 'setup.sh'? "
  exit 1
fi

LEFT_SIDE_LENGTH=43

GIT_USERNAME="placeholder_username"
GIT_PASSWORD="placeholder_token"
GIT_NAME="Placeholder Name"
GIT_EMAIL="placeholder.name@mail.com"
USE_PROXY="off"
UNAME_WRAP="on"
NO_CONF_RESET="false"
YOCTO_BUILD_PARALLEL=4

. .env

# total_length, message
padding () {
    local TOTAL_LENGTH=$1
    local QUESTION_LENGTH=${#2}
    local PD_LENGTH=0
    let "PD_LENGTH = $TOTAL_LENGTH - $QUESTION_LENGTH"
    printf ' %.0s' `echo $(seq "$PD_LENGTH")`
}

# total_length, message_length
padding_num () {
    local TOTAL_LENGTH=$1
    local QUESTION_LENGTH=$2
    local PD_LENGTH=0
    let "PD_LENGTH = $TOTAL_LENGTH - $QUESTION_LENGTH"
    printf ' %.0s' `echo $(seq "$PD_LENGTH")`
}

# question, choice1, choice2, variable, true_value, option_num
highlight_choices () {
    local TOTAL_LENGTH=$LEFT_SIDE_LENGTH
    local OPTION_LENGTH=5
    local SELECT1="     "
    local SELECT2="     "

    if [ "$4" == "$5" ]; then
        SELECT1="-----"
    else
        SELECT2="-----"
    fi

    padding "$((TOTAL_LENGTH+5))" "" && echo "$SELECT1   $SELECT2"
    padding $TOTAL_LENGTH "$1" && echo "$1: >|"" $2   $3  |< $6."
    padding "$((TOTAL_LENGTH+5))" "" && echo "$SELECT1   $SELECT2"
}

# question, value, option_num
present_value () {
    local TOTAL_LENGTH=$LEFT_SIDE_LENGTH
    padding $TOTAL_LENGTH "$1" && echo "$1: >|"" $2 |< $3."
}

BEGIN="false"
PADDING=""
while [ $BEGIN != "true" ]
do
    ENV_CONTENTS="
GIT_USERNAME=\"$GIT_USERNAME\"
GIT_PASSWORD=\"$GIT_PASSWORD\"
GIT_NAME=\"$GIT_NAME\"
GIT_EMAIL=\"$GIT_EMAIL\"
USE_PROXY=\"$USE_PROXY\"
UNAME_WRAP=\"$UNAME_WRAP\"
NO_CONF_RESET=\"$NO_CONF_RESET\"
YOCTO_BUILD_PARALLEL=$YOCTO_BUILD_PARALLEL
"
    echo "$ENV_CONTENTS" > .env

    clear
    logo
    highlight_choices "Activate proxy" "  ON " " OFF " "$USE_PROXY" "on" 1
    highlight_choices "Activate uname command wrapper" "  ON " " OFF " "$UNAME_WRAP" "on" 2
    highlight_choices "Reset build configuration on start" "  ON " " OFF " "$NO_CONF_RESET" "false" 3
    echo ""
    present_value "Parallel jobs and build threads (Max 16)" "$YOCTO_BUILD_PARALLEL" " - + "
    echo ""
    present_value "Git username" "$GIT_USERNAME" 4
    present_value "Git password" "*******" 5
    present_value "Git name" "$GIT_NAME" 6
    present_value "Git e-mail" "$GIT_EMAIL" 7
    echo ""
    echo "Press a NUMBER or +/- to change the respective value"
    echo "Press ENTER to start the build environment"
    echo "Press ESC to exit without starting the build environment"
    read -rsn1 input
    case $input in
    1)
        if [ "$USE_PROXY" == "on" ]; then
            USE_PROXY="off"
        else
            USE_PROXY="on"
        fi
        ;;
    2)
        if [ "$UNAME_WRAP" == "on" ]; then
            UNAME_WRAP="off"
        else
            UNAME_WRAP="on"
        fi
        ;;
    3)
        if [ "$NO_CONF_RESET" == "true" ]; then
            NO_CONF_RESET="false"
        else
            NO_CONF_RESET="true"
        fi
        ;;
    4)
        read -p "Enter a new git username: " GIT_USERNAME
        ;;
    5)
        # read -p "Enter a new git password/token : " GIT_PASSWORD
        unset password
        prompt="Enter Password:"
        while IFS= read -p "$prompt" -r -s -n 1 char
        do
            if [[ $char == $'\0' ]]
            then
                break
            elif [[ $char = $'\177' ]] ; then
                # backspace, remove one char
                prompt=''
                if [[ "$password" != "" ]] ; then
                        password=${password%?}
                        printf '\b \b'
                fi
            else
                prompt='*'
                password+="$char"
            fi
            # prompt='*'
            # password+="$char"
        done
        GIT_PASSWORD="$password"
        ;;
    6)
        read -p "Enter a new git name : " GIT_NAME
        ;;
    7)
        read -p "Enter a new git e-mail : " GIT_EMAIL
        ;;
    \+|\-)
        re='^[0-9]+$'
        if ! [[ "$YOCTO_BUILD_PARALLEL" =~ $re ]] ; then
            YOCTO_BUILD_PARALLEL=4
        else
            if [ $input == '+' ]; then
                let YOCTO_BUILD_PARALLEL++
            else
                let YOCTO_BUILD_PARALLEL--
            fi
            if (( YOCTO_BUILD_PARALLEL > 16 )); then
                YOCTO_BUILD_PARALLEL=16
            elif (( YOCTO_BUILD_PARALLEL < 1 )); then
                YOCTO_BUILD_PARALLEL=1
            fi
        fi
        ;;
    $'\e')
        echo "EXITING"
        exit 0
        ;;
    "")
        BEGIN="true"
        ;;
    *)
        # BEGIN="true"
    esac
    # BEGIN="true"
done

clear
sudo docker compose run --rm yocto-build