#!/bin/python

import pprint
from datetime import datetime
import glob
import argparse

pp = pprint.PrettyPrinter(indent=4)


def parseArgs():
    parser = argparse.ArgumentParser(
        description='Prints a markdown table from property files.')
    parser.add_argument(
        '-m', '--mode', help='Mode: linux|gerneric|win|mac|mac-as', required=True)
    args = vars(parser.parse_args())

    mode = args['mode']
    return mode


# list of only "latest patch versions"
# mpsVersions = [
#     "2017.1.3",
#     "2017.2.3",
#     "2017.3.6",
#
#     "2018.1.5",
#     "2018.2.6",
#     "2018.3.7",
#
#     "2019.1.6",
#     "2019.2.4",
#     "2019.3.7",
#
#     "2020.1.7",
#     "2020.2.3",
#     "2020.3.6",
#
#     "2021.1.4",
#     "2021.2.6",
#     "2021.3.5",
#
#     # 2022.1 does not exist
#     "2022.2.4",
#     "2022.3.3",
#
#     # 2023.1 does not exist
#     "2023.2.2",
#     "2023.3.2",
#
#     "2024.1.1"
# ]
mpsVersions = [
    # previous versions are not available to download anymore
    # "2017.1", "2017.1.1" "2017.1.2" "2017.1.3"
    # "2017.2", "2017.2.1" "2017.2.2" "2017.2.3"
    # "2017.3", "2017.3.1" "2017.3.2" "2017.3.3" "2017.3.4" "2017.3.5" "2017.3.6"
    #
    # "2018.1", "2018.1.1" "2018.1.2" "2018.1.3" "2018.1.4" "2018.1.5"
    # "2018.2", "2018.2.1" "2018.2.2" "2018.2.3" "2018.2.4" "2018.2.5" "2018.2.6"
    # "2018.3", "2018.3.1" "2018.3.2" "2018.3.3" "2018.3.4" "2018.3.5" "2018.3.6" "2018.3.7"

    "2017.1.3",
    "2017.2.3",
    "2017.3.6",

    "2018.1.5",
    "2018.2.6",
    "2018.3.7",

    "2019.1", "2019.1.1", "2019.1.2", "2019.1.3", "2019.1.4", "2019.1.5", "2019.1.6",
    "2019.2", "2019.2.1", "2019.2.2", "2019.2.3", "2019.2.4",
    "2019.3", "2019.3.1", "2019.3.2", "2019.3.3", "2019.3.4", "2019.3.5", "2019.3.6", "2019.3.7",

    "2020.1", "2019.1.1", "2020.1.2", "2020.1.3", "2020.1.4", "2020.1.5", "2020.1.6", "2020.1.7",
    "2020.2", "2020.2.1", "2020.2.2", "2020.2.3",
    "2020.3", "2020.3.1", "2020.3.2", "2020.3.3", "2020.3.4", "2020.3.5", "2020.3.6",

    "2021.1", "2021.1.1", "2021.1.2", "2021.1.3", "2021.1.4",
    "2021.2", "2021.2.1", "2021.2.2", "2021.2.3", "2021.2.4", "2021.2.5", "2021.2.6",
    "2021.3", "2021.3.1", "2021.3.2", "2021.3.3", "2021.3.4", "2021.3.5",

    # 2022.1 does not exist
    "2022.2", "2022.2.1", "2022.2.2", "2022.2.3", "2022.2.4",
    "2022.3", "2022.3.1", "2022.3.2", "2022.3.3",

    # 2023.1 does not exist
    "2023.2", "2023.2.1", "2023.2.2",
    "2023.3", "2023.3.1", "2023.3.2",

    "2024.1", "2024.1.1"
]


def getFileMap(basepath):
    files = glob.glob(basepath+"**/build.number") + \
        glob.glob(basepath+"/**/build.properties") + \
        glob.glob(basepath+"/**/jbr/release") +\
        glob.glob(basepath+"/**/release") +\
        glob.glob(basepath+"/**/file.properties")

    filemap = {}
    for f in files:
        filemap.update({f: open(f, 'r').readlines()})

    return filemap


def getVersionMap(mode, fileMap):
    versionMap = {}
    for aVersion in mpsVersions:
        # shortVersion = aVersion
        shortVersion = mode+"/"+aVersion
        # print("----- looking at aVersion: " + aVersion +
        #       " / shortVersion: " + shortVersion)
        # shortVersion = ".".join(aVersion.split(".")[0:2])
        versionMap.update({shortVersion: {}})
        currentVersionFiles = []
        for aFile in fileMap.keys():
            # adding / allows also to analyze non patch versions to be analyzed
            if aFile.find(shortVersion + "/") > 0:
                currentVersionFiles.append(aFile)

                for item in fileMap[aFile]:
                    k, v = item.split("=", 1)
                    versionMap[shortVersion].update(
                        {k: v.replace("\n", "").replace("\"", "")})
    return versionMap


def printPropertyList(versionMap):
    allPropertiesAvailable = set()
    for allProps in versionMap.values():
        for i in allProps.keys():
            allPropertiesAvailable.add(i)
    pp.pprint(allPropertiesAvailable)


def printVersionMap(versionMap):
    pp.pprint(versionMap)


def printMarkdownTable(versionMap, printAll=False):
    # -----------------------------------------
    # markdown table printing
    print("Extraction date: " + datetime.today().strftime('%y-%m-%d'))
    print("")

    tableOrder = [
        "filename",
        "filesize",
        "JAVA_ VERSION",
        "JAVA_ RUNTIME_ VERSION",
        "JCEF_VERSION",

        "mps.build. number",
        "mps.runtimeBuild",

        "mps.idea.platform. build.number",
        "IMPLEMENTOR_ VERSION",

        "date",
        "revision.number",
        "SOURCE",
    ]

    # INFO: This is the place to modify the resulting table. Just add from the
    # above what you want and it will be added automatically.
    # use this line to get it all ...
    if printAll:
        allPropertiesAvailable = set()
        for allProps in versionMap.values():
            for i in allProps.keys():
                allPropertiesAvailable.add(i)
        allPropertiesAvailable.remove("filename")
        allPropertiesAvailable.remove("filesize")
        tableOrder = ["filename", "filesize", *sorted(allPropertiesAvailable)]
        tableOrder.remove("MODULES")

    md = " {} |" * len(tableOrder)
    md = "|" + md
    print(md.format(*tableOrder))
    dashlist = []
    for _ in tableOrder:
        dashlist = dashlist + [" ------ "]
    print(md.format(*dashlist))

    defaultEmpty = "-"
    for aVersion, p in reversed(versionMap.items()):
        formatList = []
        for i in tableOrder:
            formatList = formatList + [p.get(i.replace(" ", ""), defaultEmpty)]
        print(md.format(*formatList))


def createMPSbuildChartNumber():
    # TODO: UNUSED
    # create MPS to #builds chart
    print("")
    for aVersion, p in versionMap.items():
        print("\""+aVersion+"\", ", end="")
    print("")
    for aVersion, p in versionMap.items():
        print(p.get("mps.mps.build.counter") + ", ", end="")


if __name__ == "__main__":

    # parse args and check if valid
    inputMode = parseArgs()
    if inputMode in ['generic', 'linux', 'win', 'mac', 'mac-as', 'all']:
        pass
    else:
        print("ERROR: Must specify mode: " +
              "catTable.py -m [linux|gerneric|win|mac|mac-as]")
        exit()

    availableModes = ['generic', 'linux', 'win', 'mac', 'mac-as']
    modesToDo = []
    if inputMode == 'all':
        modesToDo = availableModes
        # print("all not supported yet")
        # exit(0)
    else:
        modesToDo.append(inputMode)

    basepath = "/vol/mps/all/meta/"

    fullFileMap = {}
    fullVersionMap = {}

    # print("Will do modes: " + ", ".join(modesToDo))
    for aMode in modesToDo:
        currentBasepath = "/vol/mps/all/meta/" + aMode
        # print("Will extract from " + currentBasepath)

        fileMap = getFileMap(currentBasepath)
        fullFileMap.update(fileMap)

        versionMap = getVersionMap(aMode, fileMap)
        fullVersionMap.update(versionMap)

    # filters empty files aka. non existing ones
    fullVersionMap = {k: v for k, v in fullVersionMap.items()
                      if v["filesize"] != ""}
    # also filters all empty dictionaries
    fullVersionMap = {k: v for k, v in fullVersionMap.items() if v}

    # INFO: will print the list of properties to choose from
    doPrintPropertyList = False
    if doPrintPropertyList:
        printPropertyList(fullVersionMap)

    # INFO: will print EVERYTHING
    doPrintVersionMap = True
    if doPrintVersionMap:
        printVersionMap(fullVersionMap)

    printMarkdownTable(fullVersionMap, printAll=True)
