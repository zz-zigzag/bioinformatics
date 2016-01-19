
#customize teminal style
PS1="\[\e]0;\w\a\]\n\[\e[36;1m\]\u@\[\e[32;1m\]\w\[\e[0m\]\n\$ "

#include NGS env if it exist
if [ -f $HOME/bin/NGSENV ]; then
	. $HOME/bin/NGSENV
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib
export LIBRARY_PATH=$LIBRARY_PATH:$HOME/lib
export CPATH=$CPATH:$HOME/include
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# customize aliases
alias samview='samtools view -h'
alias s='ssh hpc'
