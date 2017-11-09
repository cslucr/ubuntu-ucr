#!/bin/bash

# Mensaje de ayuda en el uso de la aplicación.
function myhelp(){
  echo "Modo de empleo: $0 <opciones> IMAGEN.ISO 

Donde:
  IMAGEN.ISO es la ruta al archivo ISO original

Opciones:

  -d modo desarrollo, crea un zip apartir de la carpeta actual
  -z archivo.zip el archivo zip como repositorio
  -c directorio_cache Ruta absoluta al directorio donde se encuentra el cache de APT a utilizar
  -w directorio_cache Ruta absoluta al directorio donde se encuentra el cache de WGET a utilizar
  -h muestra esta ayuda

Toma una imagen de Ubuntu, la personaliza de acuerdo al script de configuración y genera el archivo ISO personalizado para ser distribuido.";
}
CLOSE_ERROR=0

# Mensajes de error y salida del script
error_exit(){
	echo "${1:-"Error desconocido"}" 1>&2
	CLOSE_ERROR=1
    exit 1
}

# Desmontaje de sistemas de archivos
function umountmntfs() {
  sudo umount mnt
}
function umountcachefs() {
  if [ $APT_CACHED ]; then sudo umount $EDIT/var/cache/apt; fi
  if [ $WGET_CACHED ]; then sudo umount $EDIT$WGET_CACHE_GUEST; fi
}
function umountdevfs() {
  sudo umount $EDIT/dev
}

# Captando parámetros
# Is in development environment ?
DEVELOPMENT=false
ZIP=""
APT_CACHE=""
APT_CACHED=false
BUILDER_ARGUMENTS="-y "
WGET_CACHED=false
WGET_CACHE_GUEST=/tmp/wget_cache/ 
while getopts zc:hdw: option
do
 case "${option}"
 in
 z) ZIP=${OPTARG};;
 d) DEVELOPMENT=true;;
 c) APT_CACHE=$(readlink -f ${OPTARG})
    APT_CACHED=true
    BUILDER_ARGUMENTS=$BUILDER_ARGUMENTS" -c" ;;
 w) WGET_CACHE=$(readlink -f ${OPTARG})
    WGET_CACHED=true
    BUILDER_ARGUMENTS=$BUILDER_ARGUMENTS" -w" ;;
 h) myhelp
    exit 0 ;;
 esac
done

shift $((OPTIND -1))

if [ -z $1 ]; then
  myhelp
  exit 1
fi

## VARIABLES

# ruta absoluta al archivo ISO original
ISOPATH=$(cd "$(dirname "$1")"; pwd)/$(basename "$1")

# directorio del script
SCRIPTPATH=$(readlink -f $0)
SCRIPTDIR=$(dirname "$SCRIPTPATH")

# directorio para perzonalizacion
CUSTOMIZATIONDIR=$(pwd)/ubuntu-iso-customization
mkdir -p $CUSTOMIZATIONDIR

# nombre del archivo ISO original
ISONAME=$(basename "$ISOPATH")
# nombre del archivo ISO personalizado,
# de la forma nombre-original-ucr-yyyymmdd.iso
CUSTOMISONAME="${ISONAME%.*}-ucr-`date +%Y%m%d`.iso"

# directorio donde extraer iso
EXTRACT=${ISONAME%.*}-extract
# directorio donde editar sistema de archivos
EDIT=${ISONAME%.*}-squashfs

## PERSONALIZACION

if [ -z $ZIP ]; then
    if $DEVELOPMENT ; then
        echo "Modo Local (Desarrollo) activado"
        mkdir $CUSTOMIZATIONDIR/ubuntu-ucr-master/
        cp -ar $SCRIPTDIR/plymouth/ $SCRIPTDIR/backgrounds $SCRIPTDIR/gschema/ $SCRIPTDIR/*.list ubuntu-16.04-ucr-* $CUSTOMIZATIONDIR/ubuntu-ucr-master/
        ( cd $CUSTOMIZATIONDIR; zip -r master.zip ubuntu-ucr-master; ) || error_exit "Error al generar master.zip"
        rm -rf $CUSTOMIZATIONDIR/ubuntu-ucr-master/
    else
        wget -O $CUSTOMIZATIONDIR/master.zip https://github.com/cslucr/ubuntu-ucr/archive/master.zip || error_exit "No pude descargar master.zip"
    fi
else
    cp $ZIP $CUSTOMIZATIONDIR/master.zip || error_exit "No pude copiar master.zip desde $ZIP "
fi


echo "Se trabajará en el directorio $CUSTOMIZATIONDIR"
cd $CUSTOMIZATIONDIR
mkdir mnt
sudo mount -o loop $ISOPATH mnt || error_exit "Error al montar ISO $ISOPATH"
mkdir $EXTRACT
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ $EXTRACT
sudo dd if=$ISOPATH bs=512 count=1 of=$EXTRACT/isolinux/isohdpfx.bin
sudo unsquashfs -d $EDIT mnt/casper/filesystem.squashfs || (umountmntfs; error_exit "Error al desempaquetar Squashfs")
umountmntfs
  #sudo umount mnt
sudo mv $CUSTOMIZATIONDIR/master.zip $EDIT/root
sudo mv $EDIT/etc/resolv.conf $EDIT/etc/resolv.conf.bak
sudo cp /etc/resolv.conf /etc/hosts $EDIT/etc/
sudo mount --bind /dev/ $EDIT/dev/


# Usa cache de APT
if [ $APT_CACHED ]; then
  echo "Usando cache APT: $APT_CACHE"
    if [ "$(ls -A $APT_CACHE)" ]; then  # esta vacio, crear una copia
      echo "ok, apt"  
    else 
      sudo rsync -a $EDIT/var/cache/apt/ $APT_CACHE
    fi
  sudo mv $EDIT/var/cache/apt $EDIT/var/cache/apt.bak
  sudo mkdir -p $EDIT/var/cache/apt
  sudo mount --bind $APT_CACHE $EDIT/var/cache/apt
fi

# Usa cache para Wget
if [ $WGET_CACHED ]; then
    echo "Usando cache WGET: $WGET_CACHE"
    if [ "$(ls -A $WGET_CACHE)" ]; then  # esta vacio, crear una copia
      echo "ok, wget"  
    else 
      sudo rsync -a $EDIT$WGET_CACHE_GUEST $WGET_CACHE
    fi
    if [ -d "$EDIT$WGET_CACHE_GUEST" ]; then
        sudo mv $EDIT$WGET_CACHE_GUEST $EDIT$WGET_CACHE_GUEST.bak
    fi
    sudo mkdir -p $EDIT$WGET_CACHE_GUEST
    sudo mount --bind $WGET_CACHE $EDIT$WGET_CACHE_GUEST
else
    sudo mkdir -p $EDIT$WGET_CACHE_GUEST
fi
# Ejecuta ordenes dentro de directorio de edicion
cat << EOF | sudo chroot $EDIT || (umountcachefs; umountdevfs; error_exit "Personalización fallida")
function umountchrootfs() {
  umount /proc || umount -lf /proc
  umount /sys
  umount /dev/pts
}

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

export HOME=/root
export LC_ALL=C
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
cd ~

# Descarga y ejecuta script de personalizacion ubuntu-ucr.
# Puede omitir el script y en su lugar realizar una personalizacion manual
unzip master.zip && rm master.zip
bash ubuntu-ucr-master/ubuntu-16.04-ucr-config.sh $BUILDER_ARGUMENTS || (umountchrootfs; exit 1)
rm -r ubuntu-ucr-master ~/.bash_history

rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

umountchrootfs
  #umount /proc || umount -lf /proc
  #umount /sys
  #umount /dev/pts
# Sale del directorio de edicion
EOF

# Actualiza cache de APT
if [ $APT_CACHED ]; then
  echo "Desmontando cache APT: $APT_CACHE"
  sudo umount $EDIT/var/cache/apt
  sudo rmdir $EDIT/var/cache/apt
  sudo mv $EDIT/var/cache/apt.bak $EDIT/var/cache/apt
fi

# Actualiza cache de WGET
if [ $WGET_CACHED ]; then
   echo "Desmontando cache WGET: $WGET_CACHE"
   sudo umount $EDIT$WGET_CACHE_GUEST
   sudo rmdir $EDIT$WGET_CACHE_GUEST
   if [ -d "$EDIT$WGET_CACHE_GUEST.bak" ]; then
        sudo mv $EDIT$WGET_CACHE_GUEST.bak $EDIT$WGET_CACHE_GUEST
   fi
fi

umountdevfs
  #sudo umount $EDIT/dev
sudo rm $EDIT/etc/resolv.conf $EDIT/etc/hosts
sudo mv $EDIT/etc/resolv.conf.bak $EDIT/etc/resolv.conf
sudo rm -rf $EDIT/tmp/* ~/.bash_history

# CREACION DE NUEVA IMAGEN ISO

# regenera manifest
sudo chmod +w $EXTRACT/casper/filesystem.manifest
sudo chroot $EDIT dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee $EXTRACT/casper/filesystem.manifest
sudo cp $EXTRACT/casper/filesystem.manifest $EXTRACT/casper/filesystem.manifest-desktop 
sudo sed -i '/ubiquity/d' $EXTRACT/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' $EXTRACT/casper/filesystem.manifest-desktop

# Comprime el sistema de archivos recien editado
sudo mksquashfs $EDIT $EXTRACT/casper/filesystem.squashfs -b 1048576 || error_exit "Error al generar Squashfs"
printf $(sudo du -sx --block-size=1 $EDIT | cut -f1) | sudo tee $EXTRACT/casper/filesystem.size
cd $EXTRACT
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

sudo xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
-isohybrid-gpt-basdat -o ../$CUSTOMISONAME .  || error_exit "Error al generar ISO en ${CUSTOMISONAME}"

echo "Generando sumas de verificación";
cd ..
md5sum $CUSTOMISONAME >> MD5SUMS
sha1sum $CUSTOMISONAME >> SHA1SUMS
sha256sum $CUSTOMISONAME >> SHA256SUMS

exit 0
