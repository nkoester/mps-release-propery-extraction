#!/bin/bash

echo "starting .."
FILE_PATH=$1
FILE_NAME_PATTERN="MPS-VERSION.tar.gz"
# FILE_NAME_PATTERN="MPS-VERSION.zip"
FOLDER_NAME_PATTERN="FOLDER"

TMP_FOLDER="/vol/mps/all/meta/"

if [[ "$1" == "generic" ]]; then
  FILE_NAME_PATTERN="MPS-VERSION.zip"
  TMP_FOLDER="${TMP_FOLDER}/generic/"
elif [[ "$1" == "linux" ]]; then
  FILE_NAME_PATTERN="MPS-VERSION.tar.gz"
  TMP_FOLDER="${TMP_FOLDER}/linux/"
elif [[ "$1" == "win" ]]; then
  FILE_NAME_PATTERN="MPS-VERSION.exe"
  TMP_FOLDER="${TMP_FOLDER}/win"
elif [[ "$1" == "mac" ]]; then
  TMP_FOLDER="${TMP_FOLDER}/mac/"
  FILE_NAME_PATTERN="MPS-VERSION-macos.dmg"
elif [[ "$1" == "mac-as" ]]; then
  TMP_FOLDER="${TMP_FOLDER}/mac-as/"
  FILE_NAME_PATTERN="MPS-VERSION-macos-aarch64.dmg"
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

# declare -a V_ARRAY=("2024.1.1")

COUNTER=0
COUNTER_TOTAL=${#V_ARRAY[*]}
for i in "${V_ARRAY[@]}"; do
  echo -n "------ ${COUNTER} / ${COUNTER_TOTAL}  "
  ((COUNTER = COUNTER + 1))
  echo "----> $i"

  FILE_NAME=${FILE_NAME_PATTERN//VERSION/$i}
  echo "CUR FILEN_NAME $FILE_NAME"

  FOLDER_NAME=${FOLDER_NAME_PATTERN//FOLDER/$(echo "${i}" | cut -d . -f1-2)}
  echo "CUR FOLDER_NAME $FOLDER_NAME"

  mkdir -p "${TMP_FOLDER}/${i}/"

  declare -a FILE_LIST_TO_EXTRACT_ARRAY_NO_FOLDER=("build.number" "build.properties" "jbr/release")
  # "MPS 2024.1/MPS 2024.1.app/Contents/build.number"
  # "MPS 2024.1/MPS 2024.1.app/Contents/build.properties"
  # "MPS 2024.1/MPS 2024.1.app/Contents/jbr/Contents/Home/release"
  declare -a FILE_IN_ARCHIVE_MAC=(
    "MPS ${FOLDER_NAME}/MPS ${FOLDER_NAME}.app/Contents/build.number"
    "MPS ${FOLDER_NAME}/MPS ${FOLDER_NAME}.app/Contents/build.properties"
    "MPS ${FOLDER_NAME}/MPS ${FOLDER_NAME}.app/Contents/jbr/Contents/Home/release"
  )

  # TODO: linux specific?
  # declare -a FILE_LIST_TO_EXTRACT_ARRAY=("MPS ${FOLDER_NAME}/build.number" "MPS ${FOLDER_NAME}/build.properties" "MPS ${FOLDER_NAME}/jbr/release")

  # write general file properties
  GENERAL_PROPERTIES_FILE="${TMP_FOLDER}/${i}/file.properties"
  if test -f "${GENERAL_PROPERTIES_FILE}"; then
    echo "file.properties exists in target location ${TMP_FOLDER}/${i}/ - skipping extraction"
  else
    echo "filename=${FILE_NAME}" >>"${GENERAL_PROPERTIES_FILE}"
    echo "filesize=$(du -b ${FILE_PATH}/${FILE_NAME} | awk '{print $1}')" >>"${GENERAL_PROPERTIES_FILE}"
  fi

  for k in "${!FILE_LIST_TO_EXTRACT_ARRAY_NO_FOLDER[@]}"; do
    n=${FILE_LIST_TO_EXTRACT_ARRAY_NO_FOLDER[$k]}
    echo "doing $k which is $n"
    # for n in "${FILE_LIST_TO_EXTRACT_ARRAY_NO_FOLDER[@]}"; do
    if test -f "${TMP_FOLDER}/${i}/${n}"; then
      echo "${n} exists in target location ${TMP_FOLDER}/${i}/${n} - skipping extraction"
    else
      echo "  --> Will extract $n"
      FILE_IN_ARCHIVE=$(echo "${FOLDER_NAME}/${n}" | sed -z '$ s/\n$//')

      if [[ "$1" == "generic" ]]; then
        echo 7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "MPS ${FILE_IN_ARCHIVE}"
        7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "MPS ${FILE_IN_ARCHIVE}" >>/dev/null
      elif [[ "$1" == "linux" ]]; then
        echo tar -zxvf "$FILE_PATH/${FILE_NAME}" --strip-components 1 -C "${TMP_FOLDER}/${i}/" "MPS $FILE_IN_ARCHIVE"
        tar -zxvf "$FILE_PATH/${FILE_NAME}" --strip-components 1 -C "${TMP_FOLDER}/${i}/" "MPS $FILE_IN_ARCHIVE"
      elif [[ "$1" == "win" ]]; then
        echo 7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "${n}"
        7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "${n}" >>/dev/null
      elif [[ "$1" == "mac" ]]; then
        echo 7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "${FILE_IN_ARCHIVE_MAC[$k]}"
        7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "${FILE_IN_ARCHIVE_MAC[$k]}"
      elif [[ "$1" == "mac-as" ]]; then
        echo 7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "${FILE_IN_ARCHIVE_MAC[$k]}"
        7z e -o"${TMP_FOLDER}/${i}/" -y "${FILE_PATH}/${FILE_NAME}" "${FILE_IN_ARCHIVE_MAC[$k]}"
      fi
    fi
  done
  echo ""
  echo ""
done

echo "All OK"
