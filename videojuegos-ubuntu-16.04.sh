#!/bin/bash

# Instala videojuegos en un sistema Ubuntu 16.04 LTS para utilizar con el circuito Makey Makey.
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

Instala videojuegos para utilizar con un Makey Makey.";
}

# Mensajes de error y salida del script
error_exit(){
	echo "${1:-"Error desconocido"}" 1>&2
	exit 1
}

# PRE-PROCESAMIENTO

# Captando parámetros
# Is in development environment ?
NOFORCE=true
APT_CACHE=false
WGET_CACHED=false
WGET_CACHE=/tmp/wget_cache/

while getopts chyw option
do
 case "${option}"
 in
 y) NOFORCE=false;;
 c) APT_CACHE=true;;
 w) WGET_CACHED=true;;
 h) myhelp
    exit 0 ;;
 esac
done

# MENSAJE DE ADVERTENCIA
# pregunta solo si el usuario no puso explicitamente la opcion -y
if $NOFORCE
then
  echo ""
  echo "Este script instala algunos videojuegos que pueden ser utilizados a través del circuito Makey Makey."
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

# PROCESAMIENTO

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
-e 's/^\/\/Unattended-Upgrade::MinimalSteps "true";/Unattended-Upgrade::MinimalSteps "true";/'\
-e 's/^\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

#SuperTuxKart
#
#Videojuego de carreras con modalidad de juego individual o multijugador
sudo add-apt-repository -y ppa:stk/daily || error_exit "Error al agregar llave para repositorio SuperTuxKart"

sudo sed -i \
-e 's/Unattended-Upgrade::Allowed-Origins {/Unattended-Upgrade::Allowed-Origins {\n\t"LP-PPA-stk-daily:${distro_codename}";/' \
/etc/apt/apt.conf.d/50unattended-upgrades

packages="$packages supertuxkart-data "
 
#SuperTux
#
#Videojuego de plataformas con Tux como personaje principal
packages="$packages supertux"

#Pacman
#
#Videojuego arcade clásico
packages="$packages pacman"


purgepackages="$purgepackages "

# Actualizacion del sistema e instalacion de los paquetes indicados
sudo cp "$BASEDIR"/sources-mirror-ucr.list /etc/apt/sources.list.d/ # temporal, en caso que no este configurado
sudo apt-get update || error_exit "Error al actualizar lista de paquetes"
sudo apt-get -y dist-upgrade || error_exit "Error al actualizar sistema operativo"
sudo apt-get -y install $packages || error_exit "Error al instalar paquetes de personalización"
sudo apt-get -y purge $purgepackages || error_exit "Error al purgar paquetes"
sudo apt-get -y autoremove || error_exit "Error al remover paquetes sin utilizar"
# Salva el cache de APT
if [ $APT_CACHE ]; then
  echo "Salvando cache APT: $APT_CACHE"
else
  sudo apt-get clean
fi


sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list # se elimina repositorio temporal
sudo rm /etc/apt/sources.list.d/sources-mirror-ucr.list.save
sudo apt-get update

exit 0
