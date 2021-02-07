import re

OUTPUTDIR = "/kurara_os/outputs"
BOOTLST = "{}/{}".format(OUTPUTDIR, "boot.lst")
KERNELLST = "{}/{}".format(OUTPUTDIR, "kernel.lst")
DATA = ""

def remove_comments(LSTFILE):
    with open(LSTFILE, "r", encoding="utf-8", errors="ignore") as lst:
        DATA = lst.read()

    regex1 = r";.*"
    regex1 = re.compile(regex1)
    regex2 = r"\d{1,5}\s*\n"
    regex2 = re.compile(regex2)

    DATA = re.sub(regex1, "", DATA)
    DATA = re.sub(regex2, "\n", DATA)

    with open(LSTFILE, "w") as lst:
        lst.write(DATA)
    
    return

remove_comments(BOOTLST)
remove_comments(KERNELLST)