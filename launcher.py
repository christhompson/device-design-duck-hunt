#!/usr/bin/env python2.6


import pymouse
import nfc
import nfc.ndef
import time
import sys


def login(player):
    pass


def play_game(player):
    pass


def main(args):
    clf = nfc.ContactlessFronted()

    # Get player tap to login
    print "Please touch a tag to login to the game"
    while True:
        tag = clf.poll()
        if tag and tag.ndef:
            break

    # Read player ID from tag
    msg = tag.ndef.message


    print "Player found. Remove tag now."
    while tag.is_present:
        time.sleep(1)


if __name__ == '__main__':
    main(sys.argv)
