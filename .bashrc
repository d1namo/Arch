#!/bin/bash
# ~/.bashrc
#

PS1="\[\e[0;37m\]┌─[\[\e[1;37m\u\e[0;37m\]]──[\[\e[1;37m\]${HOSTNAME%%.*}\[\e[0;37m\]]\[\e[1;37m\]:\w$\[\e[1;34m\]\n\[\e[0;37m\]└───────────────────────┤▶\[\e[00;00m\]"

alias music='ncmpcpp'
alias wifi='stalonetray'
alias speed='speedtest-cli'
alias purge='sudo pacman -Ru $(pacman -Qdtq)'
alias clean='sudo clean'
alias AUR='yaourt --noconfirm -Syyu --devel --aur'
alias unix='cat /home/arcibel/Plantillas/Scripts/Unix'
alias slurm='slurm -i wlan0'
alias red='nbwmon'
alias clock='tty-clock -c'
