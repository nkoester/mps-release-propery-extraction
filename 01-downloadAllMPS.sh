#!/bin/bash

SOURCE_MODE=""
TARGET_FOLDER="unknown"

if [[ "$1" == "generic" ]]; then
  SOURCE_MODE=generic
  FILE_NAME_PATTERN="MPS-VERSION.zip"
  TARGET_FOLDER="generic"
elif [[ "$1" == "linux" ]]; then
  SOURCE_MODE=linux
  FILE_NAME_PATTERN="MPS-VERSION.tar.gz"
  TARGET_FOLDER="linux"
elif [[ "$1" == "win" ]]; then
  SOURCE_MODE=win
  FILE_NAME_PATTERN="MPS-VERSION.exe"
  TARGET_FOLDER="win"
elif [[ "$1" == "mac" ]]; then
  SOURCE_MODE=mac
  FILE_NAME_PATTERN="MPS-VERSION-macos.dmg"
  TARGET_FOLDER="mac"
elif [[ "$1" == "mac-as" ]]; then
  SOURCE_MODE=mac-as
  FILE_NAME_PATTERN="MPS-VERSION-macos-aarch64.dmg"
  TARGET_FOLDER="mac-as"
else
  printf "\nError: No mode given.\n"
  echo "Usage: $0 [linux|win|mac|mac-as]"
  exit 1
fi
declare -a V_ARRAY=(
  # previous versions are not available to download anymore
  # "2017.1" "2017.1.1" "2017.1.2" "2017.1.3"
  # "2017.2" "2017.2.1" "2017.2.2" "2017.2.3"
  # "2017.3" "2017.3.1" "2017.3.2" "2017.3.3" "2017.3.4" "2017.3.5" "2017.3.6"
  #
  # "2018.1" "2018.1.1" "2018.1.2" "2018.1.3" "2018.1.4" "2018.1.5"
  # "2018.2" "2018.2.1" "2018.2.2" "2018.2.3" "2018.2.4" "2018.2.5" "2018.2.6"
  # "2018.3" "2018.3.1" "2018.3.2" "2018.3.3" "2018.3.4" "2018.3.5" "2018.3.6" "2018.3.7"

  "2017.1.3"
  "2017.2.3"
  "2017.3.6"

  "2018.1.5"
  "2018.2.6"
  "2018.3.7"

  "2019.1" "2019.1.1" "2019.1.2" "2019.1.3" "2019.1.4" "2019.1.5" "2019.1.6"
  "2019.2" "2019.2.1" "2019.2.2" "2019.2.3" "2019.2.4"
  "2019.3" "2019.3.1" "2019.3.2" "2019.3.3" "2019.3.4" "2019.3.5" "2019.3.6" "2019.3.7"

  "2020.1" "2019.1.1" "2020.1.2" "2020.1.3" "2020.1.4" "2020.1.5" "2020.1.6" "2020.1.7"
  "2020.2" "2020.2.1" "2020.2.2" "2020.2.3"
  "2020.3" "2020.3.1" "2020.3.2" "2020.3.3" "2020.3.4" "2020.3.5" "2020.3.6"

  "2021.1" "2021.1.1" "2021.1.2" "2021.1.3" "2021.1.4"
  "2021.2" "2021.2.1" "2021.2.2" "2021.2.3" "2021.2.4" "2021.2.5" "2021.2.6"
  "2021.3" "2021.3.1" "2021.3.2" "2021.3.3" "2021.3.4" "2021.3.5"

  #2022.1 does not exist
  "2022.2" "2022.2.1" "2022.2.2" "2022.2.3" "2022.2.4"
  "2022.3" "2022.3.1" "2022.3.2" "2022.3.3"

  #2023.1 does not exist
  "2023.2" "2023.2.1" "2023.2.2"
  "2023.3" "2023.3.1" "2023.3.2"

  "2024.1" "2024.1.1")

COUNTER_TOTAL=${#V_ARRAY[*]}

# declare -a V_ARRAY=("2020.2.3" "2020.3.6" "2021.1.4" "2021.2.6" "2021.3.5" "2022.2.4" "2022.3.3" "2023.2.2" "2024.1" "2024.1.1")

echo "Will download ${COUNTER_TOTAL} '${SOURCE_MODE}' MPS versions:\n ${V_ARRAY[*]} ..."

FOLDER_NAME_PATTERN="FOLDER"
DL_URL_PATTERN="https://download.jetbrains.com/mps/FOLDER/FILE"

# declare -a V_ARRAY=("2024.1.1")
mkdir -p $TARGET_FOLDER && cd $TARGET_FOLDER

COUNTER=0
for i in "${V_ARRAY[@]}"; do
  echo -n "------ ${COUNTER} / ${COUNTER_TOTAL}  "
  ((COUNTER = COUNTER + 1))
  echo "----> $i"

  FILE_NAME=${FILE_NAME_PATTERN//VERSION/$i}
  echo "CUR FILEN_NAME $FILE_NAME"

  FOLDER_NAME=${FOLDER_NAME_PATTERN//FOLDER/$(echo $i | cut -d . -f1-2)}
  echo "CUR FOLDER_NAME $FOLDER_NAME"

  DL_URL=${DL_URL_PATTERN//FILE/$FILE_NAME}
  DL_URL=${DL_URL//FOLDER/$FOLDER_NAME}

  echo will download from $DL_URL

  if test -f "$FILE_NAME"; then
    echo "$FILE_NAME already exists in target location $TARGET_FOLDER - skipping download"
  else
    # a parallel download tool for linux
    axel -n 4 ${DL_URL}
  fi

done

echo "Allok"
