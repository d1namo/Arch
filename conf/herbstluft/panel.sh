#!/usr/bin/env bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=$((${geometry[2]} - 19))
panel_height=16
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
bgcolor=$(hc get frame_border_normal_color)
selbg=$(hc get window_border_active_color)


####
# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if which textwidth &> /dev/null ; then
    textwidth="textwidth";
elif which dzen2-textwidth &> /dev/null ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi
####
# true if we are using the svn version of dzen2
# depending on version/distribution, this seems to have version strings like
# "dzen-" or "dzen-x.x.x-svn"
if dzen2 -v 2>&1 | head -n 1 | grep -q '^dzen-\([^,]*-svn\|\),'; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

if awk -Wv 2>/dev/null | head -1 | grep -q '^mawk'; then
    # mawk needs "-W interactive" to line-buffer stdout correctly
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=593504
    uniq_linebuffered() {
      awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
else
    # other awk versions (e.g. gawk) issue a warning with "-W interactive", so
    # we don't want to use it there.
    uniq_linebuffered() {
      awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
fi

hc pad $monitor $panel_height

{
    ### Event generator ###
    # based on different input data (mpc, date, hlwm hooks, ...) this generates events, formed like this:
    #   <eventname>\t<data> [...]
    # e.g.
    #   date    ^fg(#efefef)18:33^fg(#909090), 2013-10-^fg(#efefef)29

    #mpc idleloop player &
    while true ; do
        # "date" output is checked once a second, but an event is only
        # generated if the output changed compared to the previous run.
        date +$'date\t^fg(#efefef)%H:%M:%S^fg(#909090), %Y-%m-^fg(#efefef)%d'
        sleep 1 || break
    done > >(uniq_linebuffered) &
    childpid=$!
    hc --idle
    kill $childpid
} 2> /dev/null | {
    IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
    visible=true
    date=""
    windowtitle=""
    while true ; do

        ### Output ###
        # This part prints dzen data based on the _previous_ data handling run,
        # and then waits for the next event to happen.

        bordercolor="#26221C"
        separator="^bg()^fg($selbg)|"
        # draw tags
        for i in "${tags[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+')
                    echo -n "^bg(#9CA668)^fg(#141414)"
                    ;;
                ':')
                    echo -n "^bg()^fg(#ffffff)"
                    ;;
                '!')
                    echo -n "^bg(#FF0675)^fg(#141414)"
                    ;;
                *)
                    echo -n "^bg()^fg(#ababab)"
                    ;;
            esac
            if [ ! -z "$dzen2_svn" ] ; then
                # clickable tags if using SVN dzen
                echo -n "^ca(1,\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "focus_monitor \"$monitor\" && "
                echo -n "\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "use \"${i:1}\") ${i:1} ^ca()"
            else
                # non-clickable tags if using older dzen
                echo -n " ${i:1} "
            fi
        done
        echo -n "$separator"
        echo -n "^bg()^fg()^fn(Hermit:size=8) ${windowtitle//^/^^}"

       
################################################
# small adjustments
################################################       
#battery
        bat=`cat /sys/class/power_supply/BAT1/capacity`
        batstat=`cat /sys/class/power_supply/BAT1/status`
        if (($batstat=='Charging'))
        then
            batico="^i(/usr/share/icons/stlarch_icons/ac10.xbm)"
        else
            batico="^i(/usr/share/icons/stlarch_icons/batt5full.xbm)"
        fi
        bat="^fg($xicon)$batico ^fg($xtitle)battery ^fg($xfg)$bat^fg($xext)%"
#################################################
#up time
        upSeconds=`cat /proc/uptime`;
        upSeconds=${upSeconds%%.*};
        let secs=$((${upSeconds}%60))
        let mins=$((${upSeconds}/60%60))
        let hours=$((${upSeconds}/3600%24))
        let days=$((${upSeconds}/86400))
        uptime="^fg($xtitle)Up: ^fg($xfg)${days}^fg($xext)d ^fg($xfg)${hours}^fg($xext)h ^fg($xfg)${mins}^fg($xext)m"
################################################
#memory
	mem=`free | awk '/Mem:/ {print int($3/$2 * 100.0)}'`
	mem="^fg($xtitle)Ram: ^fg($xfg)$mem^fg($xext)%"
###############################################
#cpu
        cpu=`mpstat | awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { print 100 - $field }'`
        cpu="^fg($xtitle)cpu ^fg($xfg)$cpu^fg($xext)%"
###############################################
        batIco="Bat:"
        volIco="Vol:"
        wifiIco="Red:"
        mpc=$(mpc current)
        volm="$(pacmd list-sinks |grep -A 15 'index: '$active'' |grep 'volume:' |egrep -v 'base volume:' |awk -F : '{print $3}' |grep -o -P '.{0,3}%'|sed s/.$// |tr -d ' ')%"
        wifissid=`if [[ $(iwgetid -r) == "" ]]; then echo -e ""; else iwgetid -r; fi` 
        cpu_temp=$(echo -n $(sensors | grep "Core" | cut -b 16-19))
        

##############################################

##############################################

         right="$separator $date $separator^fg() $uptime $separator^fg() $mem $separator^fg() $volIco^fg($selfg) $volm^fg()$separator^fg() $wifiIco^fg($selfg) $wifissid^fg() $separator^fg()"
#
#>>>>>>>right="  ♫ $mpc_current $separator^fg() $volIco^fg($selfg) $volm^fg() $separator^fg() $wifissid^fg() $separator^fg() $batIco^fg($selfg) $battery^fg() $pacIco^fg($selfg) $package $separator $date"
        right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')


################################################


        # get width of right aligned text.. and add some space..
        #width=$(txtw -f "$font" -F "$font2" "$right_text_only  ")
        width=$($textwidth "$font" "$right_text_only")
        echo -n "^pa($(($panel_width - $width)))$right"
        echo

        ### Data handling ###
        # This part handles the events generated in the event loop, and sets
        # internal variables based on them. The event and its arguments are
        # read into the array cmd, then action is taken depending on the event
        # name.
        # "Special" events (quit_panel/togglehidepanel/reload) are also handled
        # here.

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
            date)
                #echo "resetting date" >&2
                date="${cmd[@]:1}"
                ;;
            quit_panel)
                exit
                ;;
            togglehidepanel)
                currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')
                if [ "${cmd[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    hc pad $monitor 0
                else
                    visible=true
                    hc pad $monitor $panel_height
                fi
                ;;
            reload)
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            #player)
            #    ;;
        esac
    done


    ### dzen2 ###
    # After the data is gathered and processed, the output of the previous block
    # gets piped to dzen2.

} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \
-ta l -bg "$bgcolor" -fg '#efefef'
