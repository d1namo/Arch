#!/bin/bash
# ~/.bashrc
#

PS1="\[\e[0;37m\]┌─[\[\e[1;37m\u\e[0;37m\]]──[\[\e[1;37m\]${HOSTNAME%%.*}\[\e[0;37m\]]\[\e[1;37m\]:\w$\[\e[1;34m\]\n\[\e[0;37m\]└──────────┤▶\[\e[00;00m\]"

#export PANEL_FIFO=/tmp/panel-fifo
#export PATH=$PATH:/home/arcibel/.config/bspwm/panel

source "$HOME/.cache/wal/colors.sh"
alias apci='watch -n 1 acpi -V'
alias music='ncmpcpp'
alias wifi='/home/arcibel/.Scrips/.wifi'
alias speed='speedtest-cli'
alias purge='sudo pacman -Ru $(pacman -Qdtq)'
alias cpu='sudo /home/arcibel/.Scrips/cpuf'
#alias cpu='sudo cpupower frequency-set  -r -g schedutil'
alias Up='sudo Up'
alias Up1='sudo /home/arcibel/.Scrips/Up1'
alias AUR='yaourt -Syyu devel --aur'
alias clean='sudo /home/arcibel/.Scrips/clean'
alias unix='cat /home/arcibel/Plantillas/Unix'
alias slurm='slurm -i wlan0'
alias red='nbwmon'
alias clock='tty-clock -c'
alias speedm='speedometer -rx wlan0'
alias freq='watch grep \"cpu MHz\" /proc/cpuinfo'
#alias rs='redshift -l 55.7:12.6 -t 5700:3600 -g 0.8 -m randr -v'
alias rs='redshift -l -2.23:-80.85'
alias limpia='sudo /home/arcibel/.Scrips/limpiar'
alias mac='sudo /home/arcibel/.Scrips/max'
alias wal='/home/arcibel/.Scrips/wal'
(/home/arcibel/.Scrips/wal -r &)