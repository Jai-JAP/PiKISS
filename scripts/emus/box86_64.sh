#!/bin/bash
#
# Description : Box86-64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com), Jai A P (jai.jap.318@gmail.com)
# Version     : 1.2.0 (16/Apr/22)
# Compatible  : Raspberry Pi 2-4 (tested)
# Repository  : https://github.com/ptitSeb/box86
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INPUT=/tmp/box86.$$

uninstall_box() {
    if [[ ! -f /usr/local/bin/$BOX_VERSION ]]; then
        echo -e "\nNothing to uninstall."
        return 0
    fi

    echo -e "\nUninstalling..."
    sudo rm -rf ~/box86 ~/box64 /usr/local/bin/box86 /usr/local/bin/box64 /etc/binfmt.d/box86.conf /etc/binfmt.d/box64.conf /usr/lib/i386-linux-gnu/libstdc++.so.6 /usr/lib/i386-linux-gnu/libstdc++.so.5 /usr/lib/i386-linux-gnu/libgcc_s.so.1 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libpng12.so.0 /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 2>/dev/null
    echo -e "Done."
}

menu() {
    while true; do
        if is_userspace_64_bits; then
            dialog --clear \
                --title "[ Box86/64 for Raspberry Pi ]" \
                --menu "Choose Box version to install:" 11 80 3 \
                Box86 "Install Box86 for Raspberry Pi" \
                Box64 "Install Box64 for Raspberry Pi" \
                Exit "Return to main menu" 2>"${INPUT}"

            menuitem=$(<"${INPUT}")

            case $menuitem in
                Box86) clear && submenu box86 && return 0 ;;
                Box64) clear && box64_check && submenu box64 && return 0 ;;
                Exit) exit 0 ;;
            esac
        else
            submenu box86 && return 0
        fi

    done
}

box64_check() {
    PIMODEL=$(get_raspberry_pi_model_number)
    if [ $PIMODEL != "4"* ]; then
        dialog --title '[ WARNING! ]' --yesno "Box64 not compatible with Board Raspberry Pi ${PIMODEL}.\nDo you want to continue Box64 installation?" 8 50

        response=$?

        case $response in
            0) return 0;;
            1|255) menu;;
        esac

    fi
}

submenu() {
    if [ $1 == "box86" ]; then
        BOX=Box86
        INSTALL=install_box86
        COMPILE=compile_box86
    elif [ $1 == "box64" ]; then
        BOX=Box64
        INSTALL=install_box64
        COMPILE=compile_box64
    fi

    if is_userspace_64_bits; then
        EXIT_MSG="Return to Previous menu"
        EXIT="menu"
    else
        EXIT_MSG="Return to Main menu"
        EXIT="exit 0"
    fi

    while true; do
        dialog --clear \
            --title "[ ${BOX} for Raspberry Pi ]" \
            --menu "Choose option:" 11 80 3 \
            Binary "Install the binary for Raspberry Pi (14/Apr/22)" \
            Source "Compile sources for Raspberry Pi. Est. time RPi 4: ~5 min." \
            Uninstall "Uninstall ${BOX} from your system." \
            Exit "${EXIT_MSG}" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
            Binary) clear && ${INSTALL} && return 0 ;;
            Source) clear && ${COMPILE} && return 0 ;;
            Uninstall) clear && uninstall_box && return 0 ;;
            Exit) ${EXIT} ;;
        esac

    done
}

menu
exit_message
