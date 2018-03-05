#!/bin/zsh

# This code is licensed under the GPL v2.  See LICENSE.txt for details.

# colorize.sh
# QLColorCode
#
# Created by Nathaniel Gray on 11/27/07.
# Copyright 2007 Nathaniel Gray.

# Expects   $1 = path to resources dir of bundle
#           $2 = name of file to colorize
#           $3 = 1 if you want enough for a thumbnail, 0 for the full file
#
# Produces HTML on stdout with exit code 0 on success

###############################################################################

# Fail immediately on failure of sub-command
setopt err_exit

rsrcDir=$1
target=$2
thumb=$3

debug () {
    if [ "x$qlcc_debug" != "x" ]; then if [ "x$thumb" = "x0" ]; then
        echo "QLColorCode: $@" 1>&2
    fi; fi
}

debug Starting colorize.sh
#echo target is $target

hlDir=$rsrcDir/highlight
cmd=$hlDir/bin/highlight
cmdOpts=(-I --font $font --quiet --add-data-dir $rsrcDir/override \
         --data-dir $rsrcDir/highlight/share/highlight \
         --add-config-dir $rsrcDir/override/config --style $hlTheme \
         --font-size $fontSizePoints --encoding $textEncoding ${=extraHLFlags})

#for o in $cmdOpts; do echo $o\<br/\>; done 

debug Setting reader
reader=(cat $target)

debug Handling special cases
case $target in
    *.graffle )
        # some omnigraffle files are XML and get passed to us.  Ignore them.
        exit 1
        ;;
    *.plist )
        lang=xml
        reader=(/usr/bin/plutil -convert xml1 -o - $target)
        ;;
    *.h )
        if grep -q "@interface" $target &> /dev/null; then
            lang=objc
        else
            lang=h
        fi
        ;;
    *.m )
        # look for a matlab-style comment in the first 10 lines, otherwise
        # assume objective-c.  If you never use matlab or never use objc,
        # you might want to hardwire this one way or the other
        if head -n 10 $target | grep -q "^[ 	]*%" &> /dev/null; then
            lang=m
        else
            lang=objc
        fi
        ;;
    *.groovy )  
        lang=java
        ;;
    *.pro )
        # Can be either IDL or Prolog.  Prolog uses /* */ and % for comments.
        # IDL uses ;
        if head -n 10 $target | grep -q "^[ 	]*;" &> /dev/null; then
            lang=idlang
        else
            lang=pro
        fi
        ;;
    * ) 
        lang=${target##*.}
    ;;
esac
debug Resolved $target to language $lang

go4it () {
    debug Generating the preview
    if [ $thumb = "1" ]; then
        $reader | head -n 100 | head -c 20000 | $cmd --syntax $lang $cmdOpts && exit 0
    elif [ -n "$maxFileSize" ]; then
        $reader | head -c $maxFileSize | $cmd --syntax $lang $cmdOpts && exit 0
    else
        $reader | $cmd --syntax $lang $cmdOpts && exit 0
    fi
}

setopt no_err_exit
debug First try...
go4it
# Uh-oh, it didn't work.  Fall back to rendering the file as plain
debug First try failed, second try...
lang=txt
go4it
debug Reached the end of the file.  That should not happen.
exit 101