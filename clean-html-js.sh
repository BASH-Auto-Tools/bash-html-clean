#!/bin/bash
# clean-html-js.sh

VER="1.3"
GREEN="\033[1;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
ENDCOLOR="\033[0m"

tproc=`basename $0`
echo -e $GREEN"$tproc version $VER"$ENDCOLOR
echo ""

usage()
{
    tproc=`basename $0`
    echo -e $YELLOW"usage:"$ENDCOLOR
    echo -e $GREEN" bash $tproc input.html"$ENDCOLOR
    echo "options:"
    echo "  -c          not clean comment (default = false);"
    echo "  -n          not verify type file (default = false);"
    echo "  -o str      output path (default = input.utf8.html);"
    echo "  -r          rewrite file (default = false);"
    echo "  -h          help."
    echo
    exit 1
}

testcomponent()
{
    tnocomp=""
    tcomp="/usr/bin/iconv"
    tdeb="libc-bin_*.deb"
    if [ ! -f "$tcomp" ]
    then
    tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/enca"
    tdeb="enca_*.deb"
    if [ ! -f "$tcomp" ]
    then
    tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/bin/sed"
    tdeb="sed_*.deb"
    if [ ! -f "$tcomp" ]
    then
    tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/bin/grep"
    tdeb="grep_*.deb"
    if [ ! -f "$tcomp" ]
    then
    tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    if [ "+$tnocomp" != "+" ]
    then
    echo -e $RED"Not found $tnocomp !"$ENDCOLOR
    echo ""
    exit 0
    fi
}

main()
{
while getopts ":cno:rh" opt
do
    case $opt in
        c) tcomment="1"
            ;;
        n) tnoverify="1"
            ;;
        o) tdest="$OPTARG"
            ;;
        r) trewrite="1"
            ;;
        h) usage
            ;;
        *) echo "Unknown option -$OPTARG"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND - 1))"
SRCNAME="$1"
if [ -z "$SRCNAME" ]
then
    usage
fi
echo "$src"
echo ""
if [ -z "$tnoverify" ]
then
    thtml=`file "$SRCNAME" | grep "HTML document"`
else
    thtml="HTML document"
fi
if [ "+$thtml" != "+" ]
then
    NEWNAME="${SRCNAME%.htm*}"
    NEWNAME="$NEWNAME.utf8.html"
    echo " $SRCNAME -> $NEWNAME"

    CODENAME=$(/usr/bin/enca -i "$SRCNAME")
    if [ "+$CODENAME" = "+" -o "+$CODENAME" = "+???" ]
    then
    CODENAME="UTF-8"
    elif [ "+$CODENAME" != "+UTF-8" ]
    then
    echo "  Convert: $CODENAME -> UTF8"
    fi
    cat "$SRCNAME" | iconv -c -f ${CODENAME} -t UTF8 > "$NEWNAME"

echo -e -n "[4]: 0.."

echo -e -n "1.."

    sed -i -e '
    s/\x0D$//
    s/<body/\n\L&/ig
    s/<iframe/\n\L&/ig
    s/<object/\n\L&/ig
    s/<d/\n\L&/ig
    s/<h/\n\L&/ig
    s/<l/\n\L&/ig
    s/<m/\n\L&/ig
    s/<p/\n\L&/ig
    s/<t/\n\L&/ig
    s/<\/body/\n\L&/ig
    s/<\/h/\n\L&/ig
    s/<script/\n\L&/ig
    s/<\/script>/\n\L&\n/ig
    s/<noscript/\n\L&/ig
    s/<\/noscript>/\n\L&\n/ig
    s/<iframe/\n\L&/ig
    s/<\/iframe>/\n\L&\n/ig
    s/<object/\n\L&/ig
    s/<\/object>/\n\L&\n/ig
    s/<ins/\n\L&/ig
    s/<\/ins>/\n\L&\n/ig
    s/<\!--/\n\L&/ig
    s/-->/\n\L&\n/ig
    ' "$NEWNAME"

echo -e -n "2.."

    sed -i -e '
    /^<script/,/^<\/script>/d
    /^<noscript/,/^<\/noscript>/d
    /^<iframe/,/^<\/iframe>/d
    /^<object/,/^<\/object>/d
    /^<ins/,/^<\/ins>/d
    ' "$NEWNAME"

echo -e -n "3.."

    if [ -z "$tcomment" ]
    then
        sed -i -e '
        /^<\!--/,/^-->/d
        ' "$NEWNAME"
    fi

echo -e -n "4.."

    sed -i -e '
    s/content="text\/html; charset=.*">/content="text\/html; charset=utf-8">/ig
    s/[ \t]*$//
    /^$/d
    ' "$NEWNAME"

flgpre=`grep -i "<pre" "$NEWNAME"`
if [ "+$flgpre" = "+" ]
then
    echo -e -n "(5).."

    sed -i -e '
    s/^[ \t]*//
    /^$/d
    ' "$NEWNAME"
fi

echo -e "END"
if [ ! -z "$trewrite" ]
then
    mv -fv "$NEWNAME" "$SRCNAME"
fi
    exit 0
else
    file "$1"
    exit 1
fi
}

testcomponent
main "$@"
