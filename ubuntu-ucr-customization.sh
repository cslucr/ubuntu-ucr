#!/bin/bash

# Realiza una configuracion base de un sistema Ubuntu 18.04 LTS.
#
# La configuracion y programas instalados se ajustan al uso tipico de
# estudiantes, docentes y administrativos de la Universidad de Costa Rica.
# Esta personalizacion no intenta imitar otros sistemas, si no ofrecer la
# innovadora experiencia de usuario de un entorno de escritorio libre.
#
# Escrito por la Comunidad de Software Libre de la Universidad de Costa Rica
# http://softwarelibre.ucr.ac.cr
#
# Github: https://github.com/cslucr/ubuntu-ucr

# Mensaje de ayuda en el uso de la aplicación.
function myhelp(){
  echo "Modo de empleo: $0 <opciones>

Opciones:

  -y no cuestiona, fuerza la sobreescritura de configuraciones
  -c evita que se limpie el cache de APT. En caso que se quiera reutilizar
  -w directorio_cache Ruta absoluta al directorio donde se encuentra el cache a utilizar con wget
  -h muestra esta ayuda

Toma una instalación fresca de Ubuntu y la personaliza.";
}

# Mensajes de error y salida del script
error_exit(){
	echo "${1:-"Error desconocido"}" 1>&2
	exit 1
}

# PRE-PROCESAMIENTO ############################################################

# Captando parámetros
# Is in development environment?
NOFORCE=true                # pregunta antes de iniciar los cambios
APT_CACHED=false            # no guarda cache APT
WGET_CACHED=false           # no guarda cache wget
WGET_CACHE=/tmp/wget_cache  # ruta a donde descargar archivos con wget

while getopts w:ych: option
do
 case "${option}"
 in
 y) NOFORCE=false;;
 c) APT_CACHED=true;;
 w) WGET_CACHED=true
    WGET_CACHE=$(readlink -f ${OPTARG}) ;;
 h) myhelp
    exit 0 ;;
 esac
done

# MENSAJE DE ADVERTENCIA
# Pregunta solo si el usuario no puso explicitamente la opcion -y
if $NOFORCE
then
  echo ""
  echo "Este script podría sobreescribir la configuración actual, se recomienda ejecutarlo en una instalación limpia. Si este no es un sistema recién instalado o no ha realizado un respaldo, cancele la ejecución."
  echo ""
  read -p "¿Desea continuar? [s/N] " -r
  if [[ ! $REPLY =~ ^[SsYy]$ ]]
  then
    exit 1
  fi
fi

# VARIABLES

# Identifica el directorio en el que se esta ejecutando
SCRIPTPATH=$(readlink -f $0)
BASEDIR=$(dirname "$SCRIPTPATH")

# Identifica la arquitectura de la computadora (x86_64, x86, ...)
arch=$(uname -m)

# En esta variable se iran concatenando los nombres de los paquetes que se
# instalaran mas adelante, de la forma:
#  packages="$packages paquete1 paquete2 paquete3"
packages=""

# En esta variable se iran concatenando los nombres de los paquetes a
# des-instalar, de la forma:
#  purgepackages="$purgepackages paquete1 paquete2 paquete3"
purgepackages=""

# En esta variable se iran concatenando las rutas de
# archivos .desktop, de aplicaciones que deben iniciar
# al cargar sesion, de la forma:
#  autostart="$autostart ruta1 ruta2 ruta2"
autostart=""

# Crea directorio a donde descargar archivos con wget
mkdir -p $WGET_CACHE || error_exit "Error al crear directorio para cache de wget"


# PROCESAMIENTO ################################################################

# REPOSITORIOS Y PAQUETES

# Actualizaciones desatendidas
#
# Incluye las actualizaciones del sistema ademas de las de seguridad
# que se configuran de manera predeterminada.
#
# Simular la instalacion y asi comprobar la configuracion ejecutando:
#  sudo unattended-upgrades --dry-run
#
#
# Nota: puede anadir origenes de terceros de la forma:
#  Unattended-Upgrade::Allowed-Origins {
#    "Origin:Suite";
#    ...
#  };
# en el archivo /etc/apt/apt.conf.d/50unattended-upgrades
#
# Consulte los valores 'Origin' y 'Suite' en los archivos *_InRelease o *_Release
# ubicados en /var/lib/apt/lists/

sudo sed -i \
-e 's/^\/\/."\${distro_id}:\${distro_codename}-updates";/\t"\${distro_id}:\${distro_codename}-updates";/' \
-e 's/^\/\/Unattended-Upgrade::MinimalSteps "false";/Unattended-Upgrade::MinimalSteps "true";/' \
-e 's/^\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/' \
/etc/apt/apt.conf.d/50unattended-upgrades


# Codecs, tipografias de Microsoft y Adobe Flash
#
# Se aprueba previamente la licencia de uso de las tipografias Microsoft
# utilizando la herramienta debconf-set-selections
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
packages="$packages ubuntu-restricted-extras"

# Oracle Java 8
#
# Se sustituye la version de Java por la desarrollada por Oracle.
sudo add-apt-repository -y ppa:webupd8team/java || error_exit "Error al agregar PPA: webupd8team/java"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-webupd8team-java:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
packages="$packages oracle-java8-installer"

# LibreOffice 6 (Fresh)
#
# Ante la dificultad de hacer un downgrade a la version Enterprise (5.4), se
# mantiene la rama Fresh (6.x.x) y se anade el repositorio de
# LibreOffice Packgin team, esto para obtener las ultimas actualizaciones.
sudo add-apt-repository -y ppa:libreoffice/libreoffice-6-0 || error_exit "Error al agregar PPA: libreoffice/libreoffice-6-0"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-libreoffice-libreoffice-6-0:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages libreoffice"

# Firma digital
# TODO

# Google Chrome o Chromium
#
# Para sistemas de 64bits se anade el repositorio de Google Chrome. Este no
# soporta sistemas de 32bis por lo que, en este caso, se instala Chromium, el
# proyecto base de Google Chrome.
if [ "$arch" == 'x86_64' ]
then
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - || error_exit "Error al agregar llave para repositorio google-chrome"

  sudo sed -i \
  -e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"Google, Inc.:stable";/' \
  /etc/apt/apt.conf.d/50unattended-upgrades

  packages="$packages google-chrome-stable"
else
  packages="$packages chromium-browser"
fi

# Shotwell
#
# Ultima version estable
sudo add-apt-repository -y ppa:yg-jensge/shotwell || error_exit "Error al agregar PPA: yg-jensge/shotwell"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-yg-jensge-shotwell:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages shotwell"


# Dropbox
#
# Añade el repositorio de dropbox, pero no instala el paquete. Si no que
# lo deja disponible para cuando un usuario requiera utilizarlo.
# TODO: El paquete existe pero no el repositorio.

# GIMP
#
# Ultima version estable
sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp || error_exit "Error al agregar PPA: otto-kesselgulasch/gimp"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-otto-kesselgulasch-gimp:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages gimp"

# Spotify
#
# Alternativa a YouTube para escuchar musica, haciendo un uso mucho menor del
# ancho de banda.
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90 || error_exit "Error al agregar llave para repositorio spotify"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"Spotify LTD:stable";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages spotify-client"

# Driver comunes
# Instala drivers que comunmente son necesarios para hacer funcionar tarjeta de internet (ethernet y wifi)
# y dispositivos de audio

packages="$packages linux-firmware firmware-b43-installer"

# Arc gtk theme
#
# Popular tema gtk que ofrece un mayor atractivo visual. Este se configura,
# una vez instalado, en la seccion de Gnome-shell.
# sudo add-apt-repository -y ppa:noobslab/themes || error_exit "Error al agregar PPA: noobslab/themes"
#
# sudo sed -i \
# -e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-noobslab-themes:${distro_codename}";/' \
# /etc/apt/apt.conf.d/50unattended-upgrades
#
# packages="$packages arc-theme"

# Numix icon theme
#
# Conjundo de iconos visualmente atractivos y de facil lectura. El paquete
# incluye todos o casi todos los iconos utilizados. Este paquete se configura,
# una vez instalado, en la seccion de Gnome-shell.
# sudo add-apt-repository -y ppa:numix/ppa || error_exit "Error al agregar PPA: numix/ppa"
#
# sudo sed -i \
# -e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-numix:${distro_codename}";/' \
# /etc/apt/apt.conf.d/50unattended-upgrades
#
# packages="$packages numix-icon-theme numix-icon-theme-circle"


# Paquetes varios
# - unattended-upgrades para actualizaciones automaticas
# - caffeine para inibir el descansador de pantalla, ideal para una exposicion
# - vlc para reproduccion de videos
# - Shutter para capturar la pantalla o solo secciones de ella. También permite editar la captura.
# - Qt 5 extra widget styles para que aplicaciones Qt5, como VLC o VirtualBox, usen un estilo nativo.
packages="$packages unattended-upgrades caffeine vlc shutter qt5-style-plugins"
# - configuracion avanzada para reestablecer tema predeterminado o ajustes adicionales
  if grep -q "gnome-shell" /usr/share/xsessions/*;  then packages="$packages gnome-tweak-tool"; fi
  # if grep -q "MATE" /usr/share/xsessions/*;         then packages="$packages mate-tweak"; fi

# Paquetes innecesarios
# purgepackages="$purgepackages "

# Aplicaciones al inicio
autostart="$autostart /usr/share/applications/caffeine.desktop /usr/share/applications/caffeine-indicator.desktop"

# Actualizacion del sistema e instalacion de los paquetes indicados
#sudo cp "$BASEDIR"/sources-mirror-ucr.list /etc/apt/sources.list.d/ # temporal, en caso que no este configurado
sudo apt update || error_exit "Error al actualizar lista de paquetes"
sudo apt -y purge $purgepackages || error_exit "Error al purgar paquetes"
sudo apt -y dist-upgrade || error_exit "Error al actualizar sistema operativo"
sudo apt -y install $packages || error_exit "Error al instalar paquetes de personalización"
sudo apt -y autoremove || error_exit "Error al remover paquetes sin utilizar"
# Cuando no se guarda el cache apt, se limpia
if ! $APT_CACHED ; then
  sudo apt clean
fi

#sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list # se elimina repositorio temporal
#sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list.save
#sudo apt update


# ENTORNO DE ESCRITORIO

# El esquema, nombre y valor utilizado puede ser obtenido
# facilmente con el Editor de dconf (apt install dconf-editor)

# Fondo de pantalla y la imagen en la pantalla de autenticacion
#sudo cp "$BASEDIR"/backgrounds/*.jpg "$BASEDIR"/backgrounds/*.png /usr/share/backgrounds/

# Gnome-shell
if grep -q "gnome-shell" /usr/share/xsessions/*
then
  # Plugins de Gnome-shell
  #
  # Como instalar una extension desde la linea de comandos:
  #  http://bernaerts.dyndns.org/linux/76-gnome/283-gnome-shell-install-extension-command-line-script
  # sudo wget -c -O $WGET_CACHE/TopIcons@phocean.net.shell-extension.zip "https://extensions.gnome.org/download-extension/TopIcons@phocean.net.shell-extension.zip?version_tag=6608"
  # sudo unzip $WGET_CACHE/TopIcons@phocean.net.shell-extension.zip -d /usr/share/gnome-shell/extensions/TopIcons@phocean.net/
  # sudo chmod -R 755 /usr/share/gnome-shell/extensions/TopIcons@phocean.net/
  #
  #
  # sudo wget -c -O $WGET_CACHE/mediaplayer@patapon.info.v57.shell-extension.zip "https://extensions.gnome.org/download-extension/mediaplayer@patapon.info.shell-extension.zip?version_tag=7152"
  # sudo unzip $WGET_CACHE/mediaplayer@patapon.info.v57.shell-extension.zip -d /usr/share/gnome-shell/extensions/mediaplayer@patapon.info/
  # sudo chmod -R 755 /usr/share/gnome-shell/extensions/mediaplayer@patapon.info/
  #
  #
  # if ! $WGET_CACHED ; then
  #   sudo rm $WGET_CACHE/mediaplayer@patapon.info.v57.shell-extension.zip
  #   sudo rm $WGET_CACHE/TopIcons@phocean.net.shell-extension.zip
  # fi

  # Copia esquema que sobrescribe configuracion de Gnome-shell y lo compila
  # sudo cp "$BASEDIR"/gschema/30_ucr-gnome-default-settings.gschema.override /usr/share/glib-2.0/schemas/
  # sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Reinicia todos los valores redefinidos en archivo override para la sesion actual
  # Si no existe una sesion X11 falla y no hace nada
  # gsettings reset org.gnome.desktop.background picture-uri
  # gsettings reset org.gnome.desktop.screensaver picture-uri
  # gsettings reset org.gnome.desktop.input-sources sources
  # gsettings reset org.gnome.desktop.interface clock-format
  # gsettings reset org.gnome.desktop.interface clock-show-date
  # gsettings reset org.gnome.desktop.interface gtk-theme
  # gsettings reset org.gnome.desktop.interface icon-theme
  # gsettings reset org.gnome.desktop.wm.preferences button-layout
  # gsettings reset org.gnome.shell enabled-extensions
  #gsettings reset org.gnome.shell.extensions.topicons icon-opacity
  #gsettings reset org.gnome.shell.extensions.topicons icon-saturation
  #gsettings reset org.gnome.shell.extensions.topicons tray-order
  # gsettings reset org.gnome.shell.extensions.user-theme name
  # gsettings reset org.gnome.shell favorite-apps
  # gsettings reset org.gnome.nautilus.preferences show-directories-first

  echo "*** *** *** *** *** ***"
  echo ""
  echo "AVISO: Si tiene una sesión gráfica abierta, deberá reiniciarla."
  echo ""
  echo "*** *** *** *** *** ***"
fi

# MATE
if grep -q "MATE" /usr/share/xsessions/*
then
  # Tema durante arranque
  # sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr/ /usr/share/plymouth/themes/
  # sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/ubuntu-ucr/ubuntu-ucr.plymouth 100
  # sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/ubuntu-ucr/ubuntu-ucr.plymouth
  #
  # sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr-text/ /usr/share/plymouth/themes/
  # sudo cp "$BASEDIR"/plymouth/ubuntu-ucr-text.so /usr/lib/x86_64-linux-gnu/plymouth/
  # sudo update-alternatives --install /usr/share/plymouth/themes/text.plymouth text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth 100
  # sudo update-alternatives --set text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth
  #
  # sudo update-grub

  # Basado en https://lauri.võsandi.com/2015/03/dconf.html
  # sudo mkdir -p /etc/dconf/db/mate.d/lock/
  # sudo mkdir -p /etc/dconf/profile/
  # sudo sh -c 'echo "user-db:user" > /etc/dconf/profile/user'
  # sudo sh -c 'echo "system-db:mate" >> /etc/dconf/profile/user'
  # sudo cp "$BASEDIR"/gschema/panel /etc/dconf/db/mate.d/panel
  # sudo dconf update

  # Copia esquema que sobrescribe configuracion de MATE y lo compila
  # sudo cp "$BASEDIR"/gschema/30_ucr-mate-settings.gschema.override /usr/share/glib-2.0/schemas/
  # sudo rm /usr/share/glib-2.0/schemas/mate-ubuntu.gschema.override
  # sudo rm /usr/share/glib-2.0/schemas/ubuntu-mate.gschema.override
  # sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Favoritos de menu avanzado
#   sudo mkdir -p /etc/skel/.config/mate-menu
#   sudo sh -c 'echo "location:/usr/share/applications/firefox.desktop
# location:/usr/share/applications/google-chrome.desktop
# location:/usr/share/applications/thunderbird.desktop
# location:/usr/share/applications/spotify.desktop
# separator
# location:/usr/share/applications/libreoffice-writer.desktop
# location:/usr/share/applications/libreoffice-calc.desktop
# location:/usr/share/applications/libreoffice-impress.desktop
# separator
# location:/usr/share/applications/mate-display-properties.desktop
# location:/usr/share/applications/auri.desktop" > /etc/skel/.config/mate-menu/applications.list'

  # Se sobreescribe icono de menu de inicio de Numix para todos los tamanos, en su lugar se muestra el logo de Ubuntu
  # sudo mkdir -p /etc/skel/.icons/Numix/{16,22,24,32,48,64,96,128}/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/16/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/22/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/24/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/32/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/48/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/64/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/96/places/
  # sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/128/places/

  # Configura pantalla de autenticacion
#   sudo sh -c 'echo "[greeter]
# background = /usr/share/backgrounds/ubuntu-16.04-ucr-background.jpg
# icon-theme-name = Numix-Circle" > /etc/lightdm/lightdm-gtk-greeter.conf'

  # Parche para instalar version mas reciente de Arc-theme, que corrige error de bordes en MATE
  # wget -c -O $WGET_CACHE/arc-theme_1488477732.766ae1a-0_all.deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/all/arc-theme_1488477732.766ae1a-0_all.deb
  # sudo dpkg -i $WGET_CACHE/arc-theme_1488477732.766ae1a-0_all.deb

fi


# CONFIGURACION GENERAL

# Desabilita apport para no mostrar molestos mensajes de fallos
sudo sed -i \
-e 's/enabled=1/enabled=0/' \
/etc/default/apport


# Script de configuración de red inalámbrica de la UCR (AURI)
#
# Descarga la herramienta de configuracion de AURI y Eduroam y crea el
# respectivo .desktop para que se muestre entre las apliciones.
wget -c -O $WGET_CACHE/AURI-eduroam-UCR-Linux.tar.gz --no-check-certificate -q https://ci.ucr.ac.cr/auri/instaladores/AURI-eduroam-UCR-Linux.tar.gz
sudo tar -C /opt -zxf $WGET_CACHE/AURI-eduroam-UCR-Linux.tar.gz


sudo sh -c 'echo "[Desktop Entry]
Name=Configurar AURI
Comment=Configurar red Wifi de la UCR y Eduroam
Exec=/opt/AURI-eduroam-UCR-linux.sh
Icon=network-wireless
Terminal=false
Type=Application
Categories=Settings;HardwareSettings;
Keywords=Network;Wireless;Wi-Fi;Wifi;LAN;AURI;Eduroam;Internet;Red" > /usr/share/applications/auri.desktop'

# POST-PROCESAMIENTO ###########################################################

# Uso Horario
#
# Se activa el uso horario para que la fecha este siempre en hora tica
sudo timedatectl set-timezone America/Costa_Rica

# Complementos para LibreOffice
# LanguageTool.oxt (corrector gramatical)
# ultima version en https://www.languagetool.org/download/
# wget -c -O $WGET_CACHE/LanguageTool-3.9.oxt https://www.languagetool.org/download/LanguageTool-3.9.oxt
# sudo unopkg add --shared $WGET_CACHE/LanguageTool-3.9.oxt

# es_Any.oxt (ortografia, separacion y sinonimos)
# ultima version en https://github.com/sbosio/rla-es/releases
# wget -c -O $WGET_CACHE/es_ANY.oxt https://github.com/sbosio/rla-es/releases/download/v2.2/es_ANY.oxt
# sudo unopkg add --shared $WGET_CACHE/es_ANY.oxt


# Calc
# Este complemento permite eliminar las celdas vacias de una tabla en una hoja de calculo
# ultima version en https://extensions.libreoffice.org/extensions/tools-for-calc-edit
# wget -c -O $WGET_CACHE/toolsforedit.oxt "https://extensions.libreoffice.org/extensions/tools-for-calc-edit/1.0.0/@@download/file/toolsforedit.oxt"
# sudo unopkg add --shared $WGET_CACHE/toolsforedit.oxt


# Firmador BCCR
# if [ "$arch" == 'x86' ]
# then
#   wget -c -O $WGET_CACHE/firmador-bccr.deb https://www.firmadigital.go.cr/Bccr.Firma.Fva.InstaladoresMultiplataforma/Linux/x86/firmador-bccr_3.0_i386.deb
# else
#   wget -c -O $WGET_CACHE/firmador-bccr.deb  https://www.firmadigital.go.cr/Bccr.Firma.Fva.InstaladoresMultiplataforma/Linux/x64/firmador-bccr_3.0_amd64.deb
# fi
#
# sudo dpkg -i $WGET_CACHE/firmador-bccr.deb || error_exit "Error al instalar firmador-bccr"
# sudo rm /etc/xdg/autostart/Firmador-BCCR.desktop

# limpieza de cache de wget
# if ! $WGET_CACHED ; then
#   rm $WGET_CACHE/AURI-eduroam-UCR-Linux.tar.gz
#   rm $WGET_CACHE/LanguageTool-3.9.oxt
#   rm $WGET_CACHE/es_ANY.oxt
#   rm $WGET_CACHE/toolsforedit.oxt
#   rm $WGET_CACHE/firmador-bccr.deb
#   if grep -q "MATE" /usr/share/xsessions/*; then rm $WGET_CACHE/arc-theme_1488477732.766ae1a-0_all.deb; fi
# fi


# PERFIL PREDETERMINADO

# Qt 5 extra widget styles para que aplicaciones Qt5 usen un estilo nativo
echo "export QT_QPA_PLATFORMTHEME=gtk2" >> ~/.profile

# Aplicaciones al inicio
sudo mkdir -p /etc/skel/.config/autostart
sudo cp $autostart /etc/skel/.config/autostart/

# Terminal
#
# Se habilitan los colores del interprete de comandos para facilitar el uso
# a los usuarios mas novatos.
# sudo sed -i \
# -e 's/^#force_color_prompt=yes/force_color_prompt=yes/' \
# /etc/skel/.bashrc

exit 0
