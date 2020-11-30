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

# En esta variable se iran concatenando los nombres de los programas snap, 
# que se instalaran, de la forma:
#  snaps="$snaps paquete1 paquete2 paquete3"
snaps=""

# En esta variable se iran concatenando los nombres de los programas flatpak, 
# del repositorio flathub, que se instalaran, de la forma:
#  flathubs="$flathubs ID1 ID2 ID3"
flathubs=""

# En esta variable se iran concatenando las rutas de
# archivos .desktop, de aplicaciones que deben iniciar
# al cargar sesion, de la forma:
#  autostart="$autostart ruta1 ruta2 ruta3"
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

#sudo sed -i \
#-e 's!^//Unattended-Upgrade::MinimalSteps "false";!Unattended-Upgrade::MinimalSteps "true";!' \
#-e 's!^//Unattended-Upgrade::Remove-Unused-Dependencies "false";!Unattended-Upgrade::Remove-Unused-Dependencies "true";!' \
#/etc/apt/apt.conf.d/50unattended-upgrades


# Codecs, tipografias de Microsoft y Adobe Flash
#
# Se aprueba previamente la licencia de uso de las tipografias Microsoft
# utilizando la herramienta debconf-set-selections
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
packages="$packages ubuntu-restricted-extras"

# OpenJDK 8
#
packages="$packages openjdk-8-jdk" #OpenJDK Runtime Environment

# LibreOffice 6 (Still)
#
# Versión estable de LibO
sudo add-apt-repository -y ppa:libreoffice/libreoffice-6-4 || error_exit "Error al agregar PPA: libreoffice/libreoffice-6-4"
packages="$packages libreoffice"

# Firma digital
# TODO

# Google Chrome
#
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - || error_exit "Error al agregar llave para repositorio google-chrome"
packages="$packages google-chrome-stable"

# Dropbox
#
# Añade el repositorio de dropbox, pero no instala el paquete. Si no que
# lo deja disponible para cuando un usuario requiera utilizarlo.
sudo sh -c 'echo "deb [arch=i386,amd64] http://linux.dropbox.com/ubuntu bionic main" > /etc/apt/sources.list.d/dropbox.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E || error_exit "Error al agregar llave para repositorio dropbox"

#packages="$packages dropbox python3-gpg"

# Spotify
#
# Alternativa a YouTube para escuchar musica, haciendo un uso mucho menor del
# ancho de banda.
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo wget -qO - https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - || error_exit "Error al agregar llave para repositorio spotify"
packages="$packages spotify-client"

# Anydesk
#
# Software para escritorio remoto.
sudo wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
sudo sh -c 'echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list'
packages="$packages anydesk"

# Flatpak
#
# Soporte de paquetes en este formato.
sudo add-apt-repository -y ppa:alexlarsson/flatpak || error_exit "Error al agregar PPA: lexlarsson/flatpak"
packages="$packages flatpak"

# Paquetes varios (apt)
# - unattended-upgrades para actualizaciones automaticas
# - caffeine para inibir el descansador de pantalla, ideal para una exposicion
# - thunderbird, cliente de correo
# - vlc para reproduccion de videos
# - Shotwell, gestor de fotografías.
# - Soporte para archivos rar.
# - Soporte para sistema de archivos exfat, hfs, ntfs.
# - Drivers comunes para algunas tarjetas de red.
# - Arc-theme, popular tema flat.
# - Yaru theme (iconos, cursores, sonidos).
# - OpenVPN y VPNC
packages="$packages unattended-upgrades caffeine thunderbird vlc shotwell rar p7zip-rar exfat-fuse exfat-utils hfsplus hfsutils ntfs-3g linux-firmware firmware-b43-installer arc-theme yaru-theme-icon yaru-theme-sound openconnect network-manager-openconnect network-manager-openconnect-gnome vpnc network-manager-vpnc network-manager-vpnc-gnome"

# Paquetes varios para Gnome (apt)
if grep -q "gnome-shell" /usr/share/xsessions/*
then
  # - Plugin Gnome para OpenVPN y VPNC.
  # - Configuracion avanzada para Gnome.
  packages="$packages gnome-tweak-tool"
fi

# Paquetes varios (snaps)
# - Telegram desktop, cliente de mensajería instantánea.
# - Zoom, popular cliente para videoconferencias.
snaps="$snaps telegram-desktop zoom-client"
  
# Paquetes varios (flathub)
# - Gimp para rotar, recortar, balancear imagenes
flathubs="$flathubs org.gimp.GIMP"

# Paquetes innecesarios
#purgepackages="$purgepackages ubuntu-web-launchers"

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

sudo snap install $snaps

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub $flathubs

#sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list # se elimina repositorio temporal
#sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list.save
#sudo apt update


# ENTORNO DE ESCRITORIO

# El esquema, nombre y valor utilizado puede ser obtenido
# facilmente con el Editor de dconf (apt install dconf-editor)

# Fondo de pantalla y la imagen en la pantalla de autenticacion
sudo cp "$BASEDIR"/backgrounds/*.png /usr/share/backgrounds/

# Gnome-shell
if grep -q "gnome-shell" /usr/share/xsessions/*
then
  # Tema durante arranque
  sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr-text/ /usr/share/plymouth/themes/
  sudo cp "$BASEDIR"/plymouth/ubuntu-ucr-text.so /usr/lib/x86_64-linux-gnu/plymouth/
  sudo update-alternatives --install /usr/share/plymouth/themes/text.plymouth text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth 100
  sudo update-alternatives --set text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth

  sudo update-initramfs -u || error_exit "Error al actualizar initramfs"

  # Plugins de Gnome-shell
  #
  # Como instalar una extension desde la linea de comandos:
  #  http://bernaerts.dyndns.org/linux/76-gnome/283-gnome-shell-install-extension-command-line-script
  #
  # sudo wget -c -O $WGET_CACHE/mediaplayer@patapon.info.v57.shell-extension.zip "https://extensions.gnome.org/download-extension/mediaplayer@patapon.info.shell-extension.zip?version_tag=7152"
  # sudo unzip $WGET_CACHE/mediaplayer@patapon.info.v57.shell-extension.zip -d /usr/share/gnome-shell/extensions/mediaplayer@patapon.info/
  # sudo chmod -R 755 /usr/share/gnome-shell/extensions/mediaplayer@patapon.info/
  #
  # if ! $WGET_CACHED ; then
  #   sudo rm $WGET_CACHE/mediaplayer@patapon.info.v57.shell-extension.zip
  # fi

  # Copia esquema que sobrescribe configuracion de Gnome-shell y lo compila
  sudo cp "$BASEDIR"/gschema/40_ucr-ubuntu.gschema.override /usr/share/glib-2.0/schemas/
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Reinicia todos los valores redefinidos en archivo override para la sesion actual
  # Si no existe una sesion X11 falla y no hace nada
  gsettings reset org.gnome.desktop.interface gtk-theme
  gsettings reset org.gnome.desktop.interface icon-theme
  gsettings reset org.gnome.desktop.interface cursor-theme
  gsettings reset org.gnome.desktop.interface clock-format
  gsettings reset org.gnome.desktop.interface clock-show-date
  gsettings reset org.gnome.desktop.sound theme-name
  gsettings reset org.gnome.desktop.background picture-uri
  gsettings reset org.gnome.desktop.background primary-color
  gsettings reset org.gnome.desktop.background secondary-color
  gsettings reset org.gnome.desktop.screensaver picture-uri
  gsettings reset org.gnome.desktop.screensaver primary-color
  gsettings reset org.gnome.desktop.screensaver secondary-color
  gsettings reset org.gnome.shell enabled-extensions
  gsettings reset org.gnome.shell.extensions.user-theme name
  gsettings reset org.gnome.shell favorite-apps
  gsettings reset org.gnome.desktop.input-sources sources

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
  sudo cp -r "$BASEDIR"/plymouth/spinner/ /usr/share/plymouth/themes/
  sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/spinner/spinner.plymouth 100
  sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/spinner/spinner.plymouth

  sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr-text/ /usr/share/plymouth/themes/
  sudo cp "$BASEDIR"/plymouth/ubuntu-ucr-text.so /usr/lib/x86_64-linux-gnu/plymouth/
  sudo update-alternatives --install /usr/share/plymouth/themes/text.plymouth text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth 100
  sudo update-alternatives --set text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth

  sudo update-initramfs -u || error_exit "Error al actualizar initramfs"

  # Copia esquema que sobrescribe configuracion de MATE y lo compila
  sudo cp "$BASEDIR"/gschema/40_ucr-ubuntu-mate.gschema.override /usr/share/glib-2.0/schemas/
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Configura pantalla de autenticacion
#   sudo sh -c 'echo "[greeter]
# background = /usr/share/backgrounds/ubuntu-16.04-ucr-background.jpg
# icon-theme-name = Numix-Circle" > /etc/lightdm/lightdm-gtk-greeter.conf'
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

# Deshabilita Anydesk en el arranque
sudo systemctl disable anydesk

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

# limpieza de cache de wget
# if ! $WGET_CACHED ; then
#   rm $WGET_CACHE/AURI-eduroam-UCR-Linux.tar.gz
#   rm $WGET_CACHE/LanguageTool-3.9.oxt
#   rm $WGET_CACHE/es_ANY.oxt
#   rm $WGET_CACHE/toolsforedit.oxt
#   rm $WGET_CACHE/firmador-bccr.deb
# fi

# PERFIL PREDETERMINADO

# Aplicaciones al inicio
sudo mkdir -p /etc/skel/.config/autostart
sudo cp $autostart /etc/skel/.config/autostart/

mkdir -p ~/.config/autostart
cp $autostart ~/.config/autostart/

# Terminal
#
# Se habilitan los colores del interprete de comandos para facilitar el uso
# a los usuarios mas novatos.
sudo sed -i \
-e 's/^#force_color_prompt=yes/force_color_prompt=yes/' \
/etc/skel/.bashrc

sudo sed -i \
-e 's/^#force_color_prompt=yes/force_color_prompt=yes/' \
~/.bashrc

exit 0
