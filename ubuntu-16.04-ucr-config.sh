#!/bin/bash

# Realiza una configuracion base de un sistema Ubuntu 16.04 LTS.
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
  -c directorio_cache Ruta absoluta al directorio donde se encuentra el cache de APT a utilizar
  -h muestra esta ayuda

Toma una instalación fresca de Ubuntu y la personaliza.";
}

# Mensajes de error y salida del script
error_exit(){
	echo "${1:-"Error desconocido"}" 1>&2
	exit 1
}

# Captando parámetros
# Is in development environment ?
NOFORCE=true
APT_CACHE=""

while getopts c:hy option
do
 case "${option}"
 in
 y) NOFORCE=false;;
 c) APT_CACHE=${OPTARG};;
 h) myhelp
    exit 0 ;;
 esac
done

# MENSAJE DE ADVERTENCIA
# pregunta solo si el usuario no puso explicitamente la opcion -y
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

if [[ -d "$APT_CACHE" ]]; then
  echo "Usando cache APT: $APT_CACHE"
  APT_CACHE=$(readlink -f $APT_CACHE)
  rsync -a --link-dest="${APT_CACHE}/" "${APT_CACHE}/" "/var/cache/apt/" || error_exit "Error al sincronizar cache APT desde ${APT_CACHE}"
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
#
sudo sed -i \
-e 's/^\/\/."\${distro_id}:\${distro_codename}-updates";/\t"\${distro_id}:\${distro_codename}-updates";/' \
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

# LibreOffice 5.3
#
# Se anade el repositorio de LibreOffice para actualizar a la ultima version
# estable. Los repositorios de Ubuntu 16.04 tienen una version antigua.
sudo add-apt-repository -y ppa:libreoffice/libreoffice-5-3 || error_exit "Error al agregar PPA: libreoffice/libreoffice-5-3"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-libreoffice-libreoffice-5-3:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages libreoffice libreoffice-l10n-en-za libreoffice-l10n-en-gb libreoffice-help-en-gb libreoffice-style-sifr"

# Plantillas
# Agrega mas diferentes tipos de plantillas para presentaciones, hojas de calculo, entre otras.
# ultima version en https://extensions.openoffice.org/en/project/SunTemplatepack_1_es
wget -O sun_odf_template_pack_es.oxt https://sourceforge.net/projects/aoo-extensions/files/301/1/sun_odf_template_pack_es.oxt/download
sudo unopkg add -s --shared sun_odf_template_pack_es.oxt
rm sun_odf_template_pack_es.oxt

# Firma digital
sudo bash -c 'wget -O - http://repos.solvosoft.com/firmadigitalcr.gpg.key | apt-key add -' || error_exit "Error al agregar llave para repositorio firmadigitalcr"
sudo sh -c 'echo "deb http://repos.solvosoft.com/ubuntu xenial main" > /etc/apt/sources.list.d/repos-firmadigital.list'

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"solvosoft.com:";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages firmadigitalcr"

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
purgepackages="$purgepackages gnome-photos"

# Rhythmbox
#
# Ultima version estable
sudo add-apt-repository -y ppa:fossfreedom/rhythmbox || error_exit "Error al agregar PPA: fossfreedom/rhythmbox"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-fossfreedom-rhythmbox:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages rhythmbox rhythmbox-plugins"
purgepackages="$purgepackages gnome-music"

# Dropbox
#
# Añade el repositorio de dropbox, pero no instala el paquete. Si no que
# lo deja disponible para cuando un usuario requiera utilizarlo.
sudo sh -c 'echo "deb http://linux.dropbox.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/dropbox.list'
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E || error_exit "Error al agregar llave para repositorio dropbox"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"Dropbox.com:wily";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

#packages="$packages dropbox"

# GIMP
#
# Ultima version estable
sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp || error_exit "Error al agregar PPA: otto-kesselgulasch/gimp"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-otto-kesselgulasch-gimp-edge:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages gimp"

# Arc gtk theme
#
# Popular tema gtk que ofrece un mayor atractivo visual. Este se configura,
# una vez instalado, en la seccion de Gnome-shell.
sudo add-apt-repository -y ppa:noobslab/themes || error_exit "Error al agregar PPA: noobslab/themes"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-noobslab-themes:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages arc-theme"

# Numix icon theme
#
# Conjundo de iconos visualmente atractivos y de facil lectura. El paquete
# incluye todos o casi todos los iconos utilizados. Este paquete se configura,
# una vez instalado, en la seccion de Gnome-shell.
sudo add-apt-repository -y ppa:numix/ppa || error_exit "Error al agregar PPA: numix/ppa"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-numix:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages numix-icon-theme numix-icon-theme-circle"

# Spotify
#
# Alternativa a YouTube para escuchar musica, haciendo un uso mucho menor del
# ancho de banda.
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 || error_exit "Error al agregar llave para repositorio spotify"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"Spotify LTD:stable";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages spotify-client"

# Paquetes varios
# - Thunderbird, al ser multiplataforma, su perfil se puede migrar facilmente
# - unattended-upgrades para actualizaciones automaticas
# - caffeine para inibir el descansador de pantalla, ideal para una exposicion
packages="$packages thunderbird thunderbird-locale-es thunderbird-locale-es-ar thunderbird-locale-en-gb unattended-upgrades caffeine"
# - configuracion avanzada para reestablecer tema predeterminado o ajustes adicionales
if grep -q "Unity" /usr/share/xsessions/*;        then packages="$packages unity-tweak-tool"; fi
if grep -q "gnome-shell" /usr/share/xsessions/*;  then packages="$packages gnome-tweak-tool"; fi
if grep -q "MATE" /usr/share/xsessions/*;         then packages="$packages mate-tweak"; fi

purgepackages="$purgepackages evolution evolution-plugins evolution-common libevolution evolution-data-server-online-accounts tilda"
autostart="$autostart /usr/share/applications/caffeine.desktop /usr/share/applications/caffeine-indicator.desktop"

# Actualizacion del sistema e instalacion de los paquetes indicados
sudo cp "$BASEDIR"/sources-mirror-ucr.list /etc/apt/sources.list.d/ # temporal, en caso que no este configurado
sudo apt-get update || error_exit "Error al actualizar lista de paquetes"
sudo apt-get -y dist-upgrade || error_exit "Error al actualizar sistema operativo"
sudo apt-get -y install $packages || error_exit "Error al instalar paquetes de personalización"
sudo apt-get -y purge $purgepackages || error_exit "Error al purgar paquetes"
sudo apt-get -y autoremove || error_exit "Error al remover paquetes sin utilizar"
# Salva el cache de APT
if [[ -d "$APT_CACHE" ]]; then
  echo "Salvando cache APT: $APT_CACHE"
  rsync -a --link-dest="${APT_CACHE}/" "/var/cache/apt/" "${APT_CACHE}/" || error_exit "Error salvar cache APT hacia ${APT_CACHE}"
fi
sudo apt-get clean

sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list # se elimina repositorio temporal
sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list.save
sudo apt-get update


# ENTORNO DE ESCRITORIO

# El esquema, nombre y valor utilizado puede ser obtenido
# facilmente con el Editor de dconf (apt install dconf-editor)

# Fondo de pantalla y la imagen en la pantalla de autenticacion
sudo mkdir -p /usr/share/backgrounds/ucr/
sudo cp "$BASEDIR"/ubuntu-16.04-ucr-background.jpg "$BASEDIR"/ubuntu-16.04-ucr-background-cslucr.jpg /usr/share/backgrounds/ucr/

# Unity
if grep -q "Unity" /usr/share/xsessions/*
then
  # Tema durante arranque
  sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr/ /usr/share/plymouth/themes/
  sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/ubuntu-ucr/ubuntu-ucr.plymouth 100
  sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/ubuntu-ucr/ubuntu-ucr.plymouth

  sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr-text/ /usr/share/plymouth/themes/
  sudo update-alternatives --install /usr/share/plymouth/themes/text.plymouth text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth 100
  sudo update-alternatives --set text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth

  sudo update-grub || error_exit "Error al actualizar grub"

  # Copia esquema que sobrescribe configuracion de Unity y lo compila
  sudo cp "$BASEDIR"/gschema/30_ucr-ubuntu-settings.gschema.override /usr/share/glib-2.0/schemas/
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Reinicia todos los valores redefinidos en archivo override para la sesion actual
  # Si no existe una sesion X11 falla y no hace nada
  gsettings reset com.canonical.indicator.datetime show-date
  gsettings reset com.canonical.indicator.datetime time-format
  gsettings reset com.canonical.Unity.Launcher favorites
  gsettings reset org.gnome.desktop.background picture-uri
  gsettings reset org.gnome.desktop.background color-shading-type
  gsettings reset org.gnome.desktop.background primary-color
  gsettings reset org.gnome.desktop.background secondary-color
  gsettings reset org.gnome.desktop.input-sources sources
  gsettings reset org.gnome.desktop.interface gtk-theme
  gsettings reset org.gnome.desktop.interface icon-theme

  echo "*** *** *** *** *** ***"
  echo ""
  echo "AVISO: Si tiene una sesión gráfica abierta, deberá reiniciarla."
  echo ""
  echo "*** *** *** *** *** ***"
fi

# Gnome-shell
if grep -q "gnome-shell" /usr/share/xsessions/*
then
  # Plugins de Gnome-shell
  #
  # Como instalar una extension desde la linea de comandos:
  #  http://bernaerts.dyndns.org/linux/76-gnome/283-gnome-shell-install-extension-command-line-script
  sudo wget -O TopIcons@phocean.net.shell-extension.zip "https://extensions.gnome.org/download-extension/TopIcons@phocean.net.shell-extension.zip?version_tag=6608"
  sudo unzip TopIcons@phocean.net.shell-extension.zip -d /usr/share/gnome-shell/extensions/TopIcons@phocean.net/
  sudo chmod -R 755 /usr/share/gnome-shell/extensions/TopIcons@phocean.net/
  sudo rm TopIcons@phocean.net.shell-extension.zip

  sudo wget -O mediaplayer@patapon.info.v57.shell-extension.zip "https://extensions.gnome.org/download-extension/mediaplayer@patapon.info.shell-extension.zip?version_tag=7152"
  sudo unzip mediaplayer@patapon.info.v57.shell-extension.zip -d /usr/share/gnome-shell/extensions/mediaplayer@patapon.info/
  sudo chmod -R 755 /usr/share/gnome-shell/extensions/mediaplayer@patapon.info/
  sudo rm mediaplayer@patapon.info.v57.shell-extension.zip

  # Copia esquema que sobrescribe configuracion de Gnome-shell y lo compila
  sudo cp "$BASEDIR"/gschema/30_ucr-gnome-default-settings.gschema.override /usr/share/glib-2.0/schemas/
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Reinicia todos los valores redefinidos en archivo override para la sesion actual
  # Si no existe una sesion X11 falla y no hace nada
  gsettings reset org.gnome.desktop.background picture-uri
  gsettings reset org.gnome.desktop.screensaver picture-uri
  gsettings reset org.gnome.desktop.input-sources sources
  gsettings reset org.gnome.desktop.interface clock-format
  gsettings reset org.gnome.desktop.interface clock-show-date
  gsettings reset org.gnome.desktop.interface gtk-theme
  gsettings reset org.gnome.desktop.interface icon-theme
  gsettings reset org.gnome.desktop.wm.preferences button-layout
  gsettings reset org.gnome.shell enabled-extensions
  #gsettings reset org.gnome.shell.extensions.topicons icon-opacity
  #gsettings reset org.gnome.shell.extensions.topicons icon-saturation
  #gsettings reset org.gnome.shell.extensions.topicons tray-order
  gsettings reset org.gnome.shell.extensions.user-theme name
  gsettings reset org.gnome.shell favorite-apps
  gsettings reset org.gnome.nautilus.preferences show-directories-first

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
  sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr/ /usr/share/plymouth/themes/
  sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/ubuntu-ucr/ubuntu-ucr.plymouth 100
  sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/ubuntu-ucr/ubuntu-ucr.plymouth

  sudo cp -r "$BASEDIR"/plymouth/ubuntu-ucr-text/ /usr/share/plymouth/themes/
  sudo update-alternatives --install /usr/share/plymouth/themes/text.plymouth text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth 100
  sudo update-alternatives --set text.plymouth /usr/share/plymouth/themes/ubuntu-ucr-text/ubuntu-ucr-text.plymouth

  sudo update-grub

  # Copia esquema que sobrescribe configuracion de MATE y lo compila
  sudo cp "$BASEDIR"/gschema/30_ucr-mate-settings.gschema.override /usr/share/glib-2.0/schemas/
  sudo cp "$BASEDIR"/gschema/ubuntu-mate.gschema.override /usr/share/glib-2.0/schemas/
  sudo rm /usr/share/glib-2.0/schemas/mate-ubuntu.gschema.override
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ || error_exit "Error al compilar gschemas"

  # Favoritos de menu avanzado
  mkdir -p /etc/skel/.config/mate-menu
  sudo sh -c 'location:/usr/share/applications/firefox.desktop
location:/usr/share/applications/google-chrome.desktop
location:/usr/share/applications/thunderbird.desktop
location:/usr/share/applications/spotify.desktop
separator
location:/usr/share/applications/libreoffice-writer.desktop
location:/usr/share/applications/libreoffice-calc.desktop
location:/usr/share/applications/libreoffice-impress.desktop
separator
location:/usr/share/applications/mate-display-properties.desktop
location:/usr/share/applications/auri.desktop" > /etc/skel/.config/mate-menu/applications.list' 

  # Se sobreescribe icono de menu de inicio de Numix para todos los tamanos, en su lugar se muestra el logo de Ubuntu
  sudo mkdir -p /etc/skel/.icons/Numix/{16,22,24,32,48,64,96,128}/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/16/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/22/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/24/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/32/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/48/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/64/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/96/places/
  sudo ln -s /usr/share/icons/ubuntu-mono-dark/apps/22/start-here.svg /etc/skel/.icons/Numix/128/places/
  
  # Configura pantalla de autenticacion
  sudo sh -c 'echo "[greeter]
background = /usr/share/backgrounds/ucr/ubuntu-16.04-ucr-background.jpg
icon-theme-name = Numix-Circle" > /etc/lightdm/lightdm-gtk-greeter.conf'
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
wget --no-check-certificate -qO- https://ci.ucr.ac.cr/auri/instaladores/AURI-eduroam-UCR-Linux.tar.gz | sudo tar zx -C /opt

sudo sh -c 'echo "[Desktop Entry]
Name=Configurar AURI
Comment=Configurar red Wifi de la UCR y Eduroam
Exec=/opt/AURI-eduroam-UCR-linux.sh
Icon=network-wireless
Terminal=false
Type=Application
Categories=Settings;HardwareSettings;
Keywords=Network;Wireless;Wi-Fi;Wifi;LAN;AURI;Eduroam;Internet;Red" > /usr/share/applications/auri.desktop'


# Uso Horario 
#
# Se activa el uso horario para que la fecha este siempre en hora tica
sudo timedatectl set-timezone America/Costa_Rica

# Complementos para LibreOffice
# LanguageTool.oxt (corrector gramatical)
# ultima version en https://www.languagetool.org/download/
wget https://www.languagetool.org/download/LanguageTool-3.9.oxt
sudo unopkg add --shared LanguageTool-3.9.oxt
rm LanguageTool-3.9.oxt

# es_Any.oxt (ortografia, separacion y sinonimos)
# ultima version en https://github.com/sbosio/rla-es/releases
wget https://github.com/sbosio/rla-es/releases/download/v2.2/es_ANY.oxt
sudo unopkg add --shared es_ANY.oxt
rm es_ANY.oxt

# Calc
# Este complemento permite eliminar las celdas vacias de una tabla en una hoja de calculo
# ultima version en https://extensions.libreoffice.org/extensions/tools-for-calc-edit
wget https://extensions.libreoffice.org/extensions/tools-for-calc-edit/1.0.0/@@download/file/toolsforedit.oxt
sudo unopkg add --shared toolsforedit.oxt
rm toolsforedit.oxt

# Firmador BCCR
if [ "$arch" == 'x86' ]
then
  wget -O firmador-bccr.deb https://www.firmadigital.go.cr/Bccr.Firma.Fva.InstaladoresMultiplataforma/Linux/x86/firmador-bccr_3.0_i386.deb
else
  wget -O firmador-bccr.deb  https://www.firmadigital.go.cr/Bccr.Firma.Fva.InstaladoresMultiplataforma/Linux/x64/firmador-bccr_3.0_amd64.deb
fi

sudo dpkg -i firmador-bccr.deb || error_exit "Error al instalar firmador-bccr"
rm firmador-bccr.deb


# PERFIL PREDETERMINADO

# Aplicaciones al inicio
sudo mkdir -p /etc/skel/.config/autostart
sudo cp $autostart /etc/skel/.config/autostart/

# Terminal
#
# Se habilitan los colores del interprete de comandos para facilitar el uso
# a los usuarios mas novatos.
sudo sed -i \
-e 's/^#force_color_prompt=yes/force_color_prompt=yes/' \
/etc/skel/.bashrc

exit 0
