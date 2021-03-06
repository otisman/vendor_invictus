# invictus functions that extend build/envsetup.sH

function invictus_device_combos()
{
    local T list_file variant device

    T="$(gettop)"
    list_file="${T}/vendor/invictus/invictus.devices"
    variant="userdebug"

    if [[ $1 ]]
    then
        if [[ $2 ]]
        then
            list_file="$1"
            variant="$2"
        else
            if [[ ${VARIANT_CHOICES[@]} =~ (^| )$1($| ) ]]
            then
                variant="$1"
            else
                list_file="$1"
            fi
        fi
    fi

    if [[ ! -f "${list_file}" ]]
    then
        echo "unable to find device list: ${list_file}"
        list_file="${T}/vendor/invictus/invictus.devices"
        echo "defaulting device list file to: ${list_file}"
    fi

    while IFS= read -r device
    do
        add_lunch_combo "inv_${device}-${variant}"
    done < "${list_file}"
}

function gzosp_device_combos()
{
    local T list_file variant device

    T="$(gettop)"
    list_file="${T}/vendor/invictus/gzosp.devices"
    variant="userdebug"

    if [[ $1 ]]
    then
        if [[ $2 ]]
        then
            list_file="$1"
            variant="$2"
        else
            if [[ ${VARIANT_CHOICES[@]} =~ (^| )$1($| ) ]]
            then
                variant="$1"
            else
                list_file="$1"
            fi
        fi
    fi

    if [[ ! -f "${list_file}" ]]
    then
        echo "unable to find device list: ${list_file}"
        list_file="${T}/vendor/invictus/gzosp.devices"
        echo "defaulting device list file to: ${list_file}"
    fi

    while IFS= read -r device
    do
        add_lunch_combo "gzosp_${device}-${variant}"
    done < "${list_file}"
}

function lineage_device_combos()
{
    local T list_file variant device

    T="$(gettop)"
    list_file="${T}/vendor/invictus/lineage.devices"
    variant="userdebug"

    if [[ $1 ]]
    then
        if [[ $2 ]]
        then
            list_file="$1"
            variant="$2"
        else
            if [[ ${VARIANT_CHOICES[@]} =~ (^| )$1($| ) ]]
            then
                variant="$1"
            else
                list_file="$1"
            fi
        fi
    fi

    if [[ ! -f "${list_file}" ]]
    then
        echo "unable to find device list: ${list_file}"
        list_file="${T}/vendor/invictus/lineage.devices"
        echo "defaulting device list file to: ${list_file}"
    fi

    while IFS= read -r device
    do
        add_lunch_combo "lineage_${device}-${variant}"
    done < "${list_file}"
}

function invictus_rename_function()
{
    eval "original_invictus_$(declare -f ${1})"
}

function _invictus_build_hmm() #hidden
{
    printf "%-8s %s" "${1}:" "${2}"
}

function invictus_append_hmm()
{
    HMM_DESCRIPTIVE=("${HMM_DESCRIPTIVE[@]}" "$(_invictus_build_hmm "$1" "$2")")
}

function invictus_add_hmm_entry()
{
    for c in ${!HMM_DESCRIPTIVE[*]}
    do
        if [[ "${1}" == $(echo "${HMM_DESCRIPTIVE[$c]}" | cut -f1 -d":") ]]
        then
            HMM_DESCRIPTIVE[${c}]="$(_invictus_build_hmm "$1" "$2")"
            return
        fi
    done
    invictus_append_hmm "$1" "$2"
}

function invictusremote()
{
    local proj pfx project

    if ! git rev-parse &> /dev/null
    then
        echo "Not in a git directory. Please run this from an Android repository you wish to set up."
        return
    fi
    git remote rm invictus 2> /dev/null

    proj="$(pwd -P | sed "s#$ANDROID_BUILD_TOP/##g")"

    if (echo "$proj" | egrep -q 'external|system|build|bionic|art|libcore|prebuilt|dalvik') ; then
        pfx="android_"
    fi

    project="${proj//\//_}"

    git remote add inv "git@github.com:InvictusRom/$pfx$project"
    echo "Remote 'inv' created"
}


function gzospremote()
{
    local proj pfx project

    if ! git rev-parse &> /dev/null
    then
        echo "Not in a git directory. Please run this from an Android repository you wish to set up."
        return
    fi
    git remote rm gzosp 2> /dev/null

    proj="$(pwd -P | sed "s#$ANDROID_BUILD_TOP/##g")"

    if (echo "$proj" | egrep -q 'external|system|build|bionic|art|libcore|prebuilt|dalvik') ; then
        pfx="android_"
    fi

    project="${proj//\//_}"

    git remote add gzosp "git@github.com:GZOSP/$pfx$project"
    echo "Remote 'gzosp' created"
}

function cmremote()
{
    local proj pfx project

    if ! git rev-parse &> /dev/null
    then
        echo "Not in a git directory. Please run this from an Android repository you wish to set up."
        return
    fi
    git remote rm cm 2> /dev/null

    proj="$(pwd -P | sed "s#$ANDROID_BUILD_TOP/##g")"
    pfx="android_"
    project="${proj//\//_}"
    git remote add cm "git@github.com:CyanogenMod/$pfx$project"
    echo "Remote 'cm' created"
}

function aospremote()
{
    local pfx project

    if ! git rev-parse &> /dev/null
    then
        echo "Not in a git directory. Please run this from an Android repository you wish to set up."
        return
    fi
    git remote rm aosp 2> /dev/null

    project="$(pwd -P | sed "s#$ANDROID_BUILD_TOP/##g")"
    if [[ "$project" != device* ]]
    then
        pfx="platform/"
    fi
    git remote add aosp "https://android.googlesource.com/$pfx$project"
    echo "Remote 'aosp' created"
}

function cafremote()
{
    local pfx project

    if ! git rev-parse &> /dev/null
    then
        echo "Not in a git directory. Please run this from an Android repository you wish to set up."
    fi
    git remote rm caf 2> /dev/null

    project="$(pwd -P | sed "s#$ANDROID_BUILD_TOP/##g")"
    if [[ "$project" != device* ]]
    then
        pfx="platform/"
    fi
    git remote add caf "git://codeaurora.org/$pfx$project"
    echo "Remote 'caf' created"
}

function gzosp_push()
{
    local branch ssh_name path_opt proj
    branch="lp5.1"
    ssh_name="gzosp_review"
    path_opt=

    if [[ "$1" ]]
    then
        proj="$ANDROID_BUILD_TOP/$(echo "$1" | sed "s#$ANDROID_BUILD_TOP/##g")"
        path_opt="--git-dir=$(printf "%q/.git" "${proj}")"
    else
        proj="$(pwd -P)"
    fi
    proj="$(echo "$proj" | sed "s#$ANDROID_BUILD_TOP/##g")"
    proj="$(echo "$proj" | sed 's#/$##')"
    proj="${proj//\//_}"

    if (echo "$proj" | egrep -q 'external|system|build|bionic|art|libcore|prebuilt|dalvik') ; then
        proj="android_$proj"
    fi

    git $path_opt push "ssh://${ssh_name}/GZOSP/$proj" "HEAD:refs/for/$branch"
}


invictus_rename_function hmm
function hmm() #hidden
{
    local i T
    T="$(gettop)"
    original_invictus_hmm
    echo

    echo "vendor/invictus extended functions. The complete list is:"
    for i in $(grep -P '^function .*$' "$T/vendor/invictus/build/envsetup.sh" | grep -v "#hidden" | sed 's/function \([a-z_]*\).*/\1/' | sort | uniq); do
        echo "$i"
    done |column
}

function tclist {
dir=$ANDROID_BUILD_TOP/prebuilts/gcc/linux-x86/
    if [[ -f /usr/bin/tree ]]
       then
          tree -L 2 $dir -I 'host' |
          sed s':'$ANDROID_BUILD_TOP'/prebuilts/gcc/linux-x86/:** Toolchain Options **:' |
          sed s'/aarch64-linux-android-//' |
          sed s'/aarch64-linux-gnu-//'|
          sed s'/arm-eabi-//' |
          sed s'/arm-linux-androideabi-//' |
          sed s'/arm-linux-gnueabi-//' |
          sed s'/x86_64-linux-glibc2.15-//' |
          sed s'/x86_64-w64-mingw32-//' |
          sed s'/x86_64-linux-android-//' |
          sed s'/mips64el-linux-android-//';
     else
          echo
          echo 'The binary "tree" is not installed on your system'
          echo
     fi
}

function buildtype() {
echo "Now choose your rom build type"
echo " 1) Unofficial (clears all buildtypes)"
echo " 2) Experimental"
echo " 3) Nightly"
echo " 4) Weekly"
echo " 5) Release"
echo " 6) Custom entry"
echo "Choose number selection[7 and above = exit]:"
read input
if [[ "$input" == "1" ]];then
unset BUILDTYPE_EXPERIMENTAL
unset BUILDTYPE_NIGHTLY
unset BUILDTYPE_WEEKLY
unset BUILDTYPE_RELEASE
unset INV_BUILD_TYPE
elif [[ "$input" == "2" ]];then
export BUILDTYPE_EXPERIMENTAL=true
elif [[ "$input" == "3" ]]; then
export BUILDTYPE_NIGHTLY=true
elif [ "$input" == "4" ];then
export BUILDTYPE_WEEKLY=true
elif [ "$input" == "5" ];then
export BUILDTYPE_RELEASE=true
elif [ "$input" == "6" ];then
buildtype-custom
elif [ "$input" -gt "6" ];then
echo "Exiting .... "
return
fi
}

function buildtype-custom() {
unset BUILDTYPE_EXPERIMENTAL
unset BUILDTYPE_NIGHTLY
unset BUILDTYPE_WEEKLY
unset BUILDTYPE_RELEASE
if [[ $INV_BUILD_TYPE != "" ]];then
echo "Current custom entry: $DESO_BUILD_TYPE"
echo
fi
echo "Input MUST be alphanumeric!"
echo "Enter your desired text [99 to return to main]:"
read input
if [[ "$input" == "99" ]];then
buildtype
else
export INV_BUILD_TYPE=$input
fi
}

invictus_append_hmm "gzospremote" "Add a git remote for matching gzosp repository"
invictus_append_hmm "aospremote" "Add git remote for matching AOSP repository"
invictus_append_hmm "cafremote" "Add git remote for matching CodeAurora repository."
invictus_add_hmm_entry "tclist"  "List available toolchain options."
invictus_add_hmm_entry "buildtype"  "Adjust release type(s)"
