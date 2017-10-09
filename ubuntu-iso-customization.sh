#!/bin/bash

# Mensaje de ayuda en el uso de la aplicación.
function myhelp(){
  echo "Modo de empleo: $0 <opciones> IMAGEN.ISO 

Donde:
  IMAGEN.ISO es la ruta al archivo ISO original

Opciones:

  -d modo desarrollo, crea un zip apartir de la carpeta actual
  -z archivo.zip el archivo zip como repositorio
  -h muestra esta ayuda

Toma una imagen de Ubuntu, la personaliza de acuerdo al script de configuración y genera el archivo ISO personalizado para ser distribuido.";
}

# Captando parámetros
# Is in development environment ?
DEVELOPMENT=false
ZIP=""

while getopts z:hd option
do
 case "${option}"
 in
 z) ZIP=${OPTARG};;
 d) DEVELOPMENT=true;;
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
        mkdir ubuntu-ucr-master/
        cp -ar plymouth/ gschema/ *.list ubuntu-16.04-ucr-* ubuntu-ucr-master/
        zip -r $SCRIPTDIR/master.zip ubuntu-ucr-master
        rm -rf ubuntu-ucr-master/
    else
        wget -O $SCRIPTDIR/master.zip https://github.com/cslucr/ubuntu-ucr/archive/master.zip
    fi
else
    cp $ZIP master.zip
fi

echo "Se trabajará en el directorio $(pwd)/ubuntu-iso-customization"
mkdir ubuntu-iso-customization
cd ubuntu-iso-customization
mkdir mnt
sudo mount -o loop $ISOPATH mnt
mkdir $EXTRACT
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ $EXTRACT
sudo dd if=$ISOPATH bs=512 count=1 of=$EXTRACT/isolinux/isohdpfx.bin
sudo unsquashfs -d $EDIT mnt/casper/filesystem.squashfs
sudo umount mnt
sudo mv $SCRIPTDIR/master.zip $EDIT/root
sudo mv $EDIT/etc/resolv.conf $EDIT/etc/resolv.conf.bak
sudo cp /etc/resolv.conf /etc/hosts $EDIT/etc/
sudo mount --bind /dev/ $EDIT/dev/

# Ejecuta ordenes dentro de directorio de edicion
cat << EOF | sudo chroot $EDIT
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
bash ubuntu-ucr-master/ubuntu-16.04-ucr-config.sh -y
rm -r ubuntu-ucr-master

rm -rf /tmp/* ~/.bash_history
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
# Sale del directorio de edicion
EOF

sudo umount $EDIT/dev
sudo rm $EDIT/etc/resolv.conf $EDIT/etc/hosts
sudo mv $EDIT/etc/resolv.conf.bak $EDIT/etc/resolv.conf

# CREACION DE NUEVA IMAGEN ISO
# regenera manifest
sudo chmod +w $EXTRACT/casper/filesystem.manifest
sudo chroot $EDIT dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee $EXTRACT/casper/filesystem.manifest
sudo cp $EXTRACT/casper/filesystem.manifest $EXTRACT/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' $EXTRACT/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' $EXTRACT/casper/filesystem.manifest-desktop

# Comprime el sistema de archivos recien editado
sudo mksquashfs $EDIT $EXTRACT/casper/filesystem.squashfs -b 1048576
printf $(sudo du -sx --block-size=1 $EDIT | cut -f1) | sudo tee $EXTRACT/casper/filesystem.size
cd $EXTRACT
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

sudo xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
-isohybrid-gpt-basdat -o ../$CUSTOMISONAME .

echo "Generando sumas de verificación";
cd ..
md5sum $CUSTOMISONAME >> MD5SUMS
sha1sum $CUSTOMISONAME >> SHA1SUMS
sha256sum $CUSTOMISONAME >> SHA256SUMS

