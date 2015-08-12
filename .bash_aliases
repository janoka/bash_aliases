#!/bin/bash
# @see http://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
# Ls aliases
alias ll='ls --color=auto -alF'
alias la='ls --color=auto -A'
alias l='ls --color=auto -CF'

# Root only aliases.
alias apti='apt-get install'
alias apts='apt-cache search'
alias aptp='apt-get purge'
alias u='apt-get update && apt-get upgrade -y'

# General aliases.
alias du1='du --max-depth=1 -m | sort -n'
alias duh1='du --max-depth=1 -h'
alias p='ps axf'
alias df='df -h'
alias chjanoka='chown janoka:janoka . -R; find . -type d -exec chmod 775 \{} \; ; find . -type f -exec chmod 664 \{} \;'
alias detox='detox -rs lower *'
alias h='history'
alias hg='history | grep'
# Background jobs
alias j='jobs -l'
# Open ports
alias ports='netstat -tulanp'
# Weblap fejléc, tömörített is
alias header='curl -I'
alias headerc='curl -I --compress'
# Sudo
alias vim-hosts='sudo vim /etc/hosts'
alias subl-hosts='sudo subl /etc/hosts'
# Edit
alias vim-sshconfig='vim ~/.ssh/config'
alias subl-sshconfig='subl ~/.ssh/config'
# Drupal Code Sniffer
alias drupalcs="phpcs --standard=~/.drush/coder/coder_sniffer/Drupal --extensions='php,module,inc,install,test,profile,theme,js,css,info,txt'"

db() {
  # Display the help text.
  HELP=$(echo -e "Usage:\n  db <parameters>\n  \nParameters:\n  list|l          [<filter for databases>]                  - listing databases.\n  table|t         <database> [<table filter>]               - tables of database.\n  create|c        <database> [<user> [<password>]]          - create a database, with full grants for user@localhost.\n  drupal|d        <database>                                - create a database, drupal@localhost user has a full rights.\n  drop            <database>                                - drop the database.\n  drop-tables|dt  <database>                                - drop tables in database.\n  dump|du         <database> [<gzip file path>]             - database dump creating.\n  restore|re      <database> <gzip dump file path>          - restore from database dump.\n  copy|co         <source database> <destination database>  - copy from source to destination (table of destination will be dropped before).\n  grant|g         <database> <user>  [<password>]           - for user@localhost gives rights.\n  revoke|rv       <database> <user>                         - revoke rights of a user@localhost.\n  rights|ri       <user>                                    - user@localhost rights.\n  \n")
  if [ -z "${1}" ]; then echo -e "Nincs paraméter megadva.\n\n$HELP"
  else
    case $1 in
      list | l)
        # List the databases.
        # If you give a parameter, than it fiter the databases names.
        if [ ! -z "${2}" ]; then
          mysql -e "show databases like '%${2}%'"
        else
          mysql -e "show databases"
        fi;;
      create | c)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          # Adatbázis létrehozása
          mysql -e "create database ${2} default character set utf8 default collate utf8_hungarian_ci";
          if [ ! -z "${4}" ]; then
            # Jelszó megadása is
            mysql -e "grant all on ${2}.* to ${3}@localhost identified by '${4}'; show grants for ${3}@localhost"
          elif [ ! -z "${3}" ]; then
            # Nincs jelszó megadva, csak a jogok beállítva
            mysql -e "grant all on ${2}.* to ${3}@localhost; show grants for ${3}@localhost"
          fi
        fi ;;
      drupal | d)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          # Adatbázis létrehozása
          mysql -e "create database ${2} default character set utf8 default collate utf8_hungarian_ci; grant all on ${2}.* to drupal@localhost; show grants for drupal@localhost"
        fi ;;
      drop)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          mysql -e "drop database if exists ${2};"
        fi ;;
      drop-tables | dt)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          mysql -e "drop database if exists ${2}; create database ${2}"
        fi ;;
      grant | g)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          if [ ! -z "${4}" ]; then
            # Jelszó megadása is
            mysql -e "grant all on ${2}.* to ${3}@localhost identified by '${4}'; show grants for ${3}@localhost"
          elif [ ! -z "${3}" ]; then
            # Nincs jelszó megadva, csak a jogok beállítva
            mysql -e "grant all on ${2}.* to ${3}@localhost; show grants for ${3}@localhost"
          fi
        fi ;;
      revoke | rv)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        elif [ -z "${3}" ]; then echo -e "Nincs user megadva.\n\n$HELP"
        else
          mysql -e "revoke all on ${2}.* from ${3}@localhost; show grants for ${3}@localhost"
        fi ;;
      rights | ri)
        if [ -z "${2}" ]; then echo -e "Username is missing.\n\n$HELP"
        else
          mysql -e "show grants for ${2}@localhost"
        fi ;;
      tables | t)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          # Ha megadott a tábla szűkítése is.
          if [ ! -z "${3}" ]; then
            mysql -e "show tables like '%${3}%'" ${2}
          else
            mysql -e "show tables" ${2}
          fi
        fi ;;
      dump | du)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        else
          DATE=$(date +%Y%m%d-%H%M)
          # Ha megadott fájlnév is.
          if [ ! -z "${3}" ]; then
            mysqldump ${2} | gzip > ${3}-$DATE.mysql.gz
          else
            mysqldump ${2} | gzip > ${2}-$DATE.mysql.gz
          fi
        fi ;;
      restore | re)
        if [ -z "${2}" ]; then echo -e "Database name is missing.\n\n$HELP"
        elif [ -z "${3}" ]; then echo -e "Dump filename is missing.\n\n$HELP"
        elif [ ! -f "${3}" ]; then echo -e "Not existing ${3} dump file.\n\n$HELP"
        else
          zcat ${3} | mysql ${2}
        fi ;;
      copy | co)
        if [ -z "${2}" ]; then echo -e "Undefined source database.\n\n$HELP"
        elif [ -z "${3}" ]; then echo -e "Undefined destination database.\n\n$HELP"
        else
          mysql -e "drop database if exists ${3}; create database ${3} default character set utf8;"
          # mysqladmin create ${3}
          mysqldump ${2} | mysql ${3}
        fi ;;
    esac
  fi
}


ftpadduser() {
  if [ -z "${3}" ]; then echo -e "Használata:\n  ftpadduser <user> <password> <könyvtár>"; else
    if [ ! -d "${3}" ]; then
      echo -e "Nem létező könyvtár, létrehozom: ${3}.";
      mkdir -p "${3}"
    fi
    DIR=$(cd "${3}"; pwd)
    mysql -e "INSERT users (user,password,dir) VALUES ('${1}', '${2}', '${DIR}/./');" ftp
  fi
}
ftpuserdel() {
  if [ -z "${1}" ]; then echo -e "Használata:\n  ftpuserdel <user>"; else
    mysql -e "DELETE FROM users WHERE user='${1}';" ftp
  fi
}
ftpusers() {
  if [ -z "${1}" ]; then
    mysql -e "SELECT user, password, dir FROM users ORDER BY user;" ftp
  else
    mysql -e "SELECT user, password, dir FROM users WHERE (user LIKE '%${1}%') OR (dir LIKE '%${1}%') ORDER BY user;" ftp
  fi
}

# Webserver
alias nginxreload='nginx -s reload'
alias nginxtest='nginx -t'
alias apache2reload='servive apache2 reload'
alias apache2test='apachectl -t && apachectl -t -D DUMP_VHOSTS'

# Firewall
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'

## pass options to free ##
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

## Get server cpu info ##
alias cpuinfo='lscpu'

# Tar
alias tgz='tar cvgz '
alias untgz='tar xvfz '
alias tbz='tar cvjf '
alias untbz='tar xvjf '

# Drush
alias ddl='drush -y dl'
alias dcc='drush -y cc all'
alias duli='drush uli'
alias dwd='drush -y wd-del all'
alias d='drush'
alias dy='drush -y'
alias d7='drush-7'
alias d7y='drush-7 -y'

# Grep
alias g='grep -B 5 -A 10 -n --color=auto -R * -e'

# NGINX
n2ensite() {
  SITENAME=${1}
  if [ -z "${SITENAME}" ]; then
    echo -e "Használata:\n  n2ensite <siteneve>"
  else
    CONFIGFILE="/etc/nginx/sites-available/${SITENAME}"
    SYMLINK="/etc/nginx/sites-enabled/${SITENAME}"
    if [ ! -f "${CONFIGFILE}"]; then
      echo -e "Nincs ilyen config fájl: ${CONFIGFILE}"
    else
      if [ -f "${SYMLINK}" ]; then
        echo -e "Már létezik (bekapcsolt) a: ${SYMLINK}"
      else
        ln -s $CONFIGFILE $SYMLINK
        echo -e " nginxreload ?"
      fi
    fi
  fi
}

n2dissite() {
  SITENAME=${1}
  if [ -z "${SITENAME}" ]; then
    echo -e "Használata:\n  n2dissite <siteneve>"
  else
    SYMLINK="/etc/nginx/sites-enabled/${SITENAME}"
    if [ ! -f "${SYMLINK}"]; then
      echo -e "Nincs symlink: ${SYMLINK}"
    else
      rm $SYMLINK
    fi
  fi
}

# Bash functions
git-init () {
  git init .
  git config user.name 'Janos KUSZING'
  git config user.email 'janos.kuszing@netstudio.hu'
  git config alias.co 'commit -a'
  git config alias.edconfig 'config --edit'
  git add .
  git commit -m 'Initial commit.'
}

# CDPATH
if [ "${HOSTNAME}" == "janoka-pc" ]; then
  export CDPATH=/etc/nginx/:/var/local/:"${CDPATH}"
  export CDPATH=~/netstudio/2015/:~/privat/2015/:"${CDPATH}"
  export CDPATH=~/develop/:~/downloads/:~/www:"${CDPATH}"
  export CDPATH=~/www/c:~/www/l:~/www/t:"${CDPATH}"
  export CDPATH=.:~:~/www/t:~/www/netstudio/:~/www/drupal-7/sites/:~/www/drupal-8/sites/:"${CDPATH}"
elif [ "${HOSTNAME}" == "nginx" ]; then
  export CDPATH=/etc/nginx/:/var/www/:/var/local/:"${CDPATH}"
  export CDPATH=/var/www/netstudio/:"${CDPATH}"
  export CDPATH=.:~:/var/www/netstudio/:/var/www/drupal-7/sites/:"${CDPATH}"
fi

alias ..='cd ..;pwd'
alias ...='cd ../..;pwd'
alias ....='cd ../../..;pwd'
alias .....='cd ../../../..;pwd'
alias ......='cd ../../../../..;pwd'

# Extra
export EDITOR=vim
export PAGER=less

if [ -d ~/bin ] ; then
    export PATH=~/bin:"${PATH}"
fi
# Drupal prompt
# export PS1='\u@\h \w$(__git_ps1 " (%s)")$(__drush_ps1 "[%s]")\$ '

if [ -f ~/.drush_bashrc ] ; then
    . ~/.drush_bashrc
fi
if [ -d ~/.composer ] ; then
  export COMPOSER_HOME=~/.composer
  export PATH=~/.composer/vendor/bin:"${PATH}"
fi
if [ -d ~/www/c/bin ] ; then
  export PATH=~/www/c/bin:"${PATH}"
fi

# NextEuropa project
alias cdproject='cd build/sites/project'
