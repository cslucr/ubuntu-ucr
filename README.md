# Ubuntu personalizado para la Universidad de Costa Rica

**Ubuntu UCR** es una propuesta por parte de la *Comunidad de Software Libre de la Universidad de Costa Rica* para ser utilizada en la Institución.

Consiste en una personalización de Ubuntu, la popular distribución GNU/Linux. Este es un sistema operativo innovador y de fácil manejo, además es libre, lo que significa que se puede utilizar con cualquier fin, se puede copiar y distribuir sin restricción e incluso se puede modificar para ser adaptado a diversas necesidades. La mayoría del software incluido también es de licencia libre.

Estas son algunas de sus características:

- Se basa en la versión de Ubuntu con soporte extendido, lo que ofrece mayor estabilidad y gran soporte técnico por parte de la comunidad.
- Tema gráfico moderno y atractivo.
- Versiones actualizadas del software base, como LibreOffice, Mozilla Firefox, Shotwell, Rhythmbox y otros.
- Extras de terceros preinstalados, como tipografías Arial, Times New Roman, etc., plugins Oracle Java, Adobe Flash, o codecs multimedia.
- Software adicional como Gimp, Google Chrome, Spotify o la herramienta de configuración de AURI y Eduroam.
- Actualizaciones automáticas del sistema operativo y de todos los programas instalados. Estas son silenciosas y no requieren intervención del usuario.
- Soporte para lectores de firma digital, certificados de la CA nacional y programas instalados del BCCR.
- Complementos para LibreOffice como sinónimos, corrección ortográfica, entre otros; los cuales permiten tener un mejor aprovechamiento de la herramienta.

## Capturas de pantalla

![Ubuntu 16.04 UCR](https://raw.githubusercontent.com/cslucr/ubuntu-ucr/master/screenshot-1.png)

![Ubuntu 16.04 UCR](https://raw.githubusercontent.com/cslucr/ubuntu-ucr/master/screenshot-2.png)

![Ubuntu 16.04 UCR](https://raw.githubusercontent.com/cslucr/ubuntu-ucr/master/screenshot-3.png)


## Descarga

Imagenes de **Ubuntu UCR**, listas para instalar, pueden ser descargadas desde nuestro servidor de espejos:
http://espejos.ucr.ac.cr/cslucr/


## Trabajo conjunto

Todas las modificaciones se han escrito en un script bash para poder recrear la personalización fácilmente, tanto en una instalación en limpio como para generar un ISO para la distribución.

Si usted desea reportar problemas, hacer sugerencias o aportar mejoras, puede hacerlo a través de esta plataforma.

Se toma como base Ubuntu por las siguientes razones:

- Ubuntu es un sistema GNU/Linux muy popular, con mucha documentación y mucho soporte.
- Fuerte enfoce en el usuario final.
- Al tener una versión de soporte extendido, ofrece mucha estabilidad.

### Criterios para la personalización

- Se incluye únicamente software estable, no en desarrollo, no experimental
- Las modificaciones al entorno de escritorio son mínimas, después de todo existe un equipo enfocado en experiencia de usuario (UX) detrás de su desarrollo, con criterios suficientes para diseñar el entorno de esa manera.
- No intenta parecerse a ningún otro sistema, si no que ofrece las innovadoras características de los entornos libres.
- Se modifica el aspecto gráfico para mostrar una alternativa atractiva pero sin sacrificar la usabilidad del sistema. Todo tema o set de íconos debe ser de fácil visualización, sin que confunda al usuario.
- Se enfoca en el usuario final o en los usuarios que inician en GNU/Linux. Los usuarios avanzados sabrán buscar distribuciones alternativas, instalar sus herramientas o personalizar los entornos de escritorio a su manera.
- Los entornos a utilizar son: Unity (Ubuntu 16.04), Gnome-shell (Ubuntu 18.04+) y MATE, ideal para equipos antiguos.


## ¿Cómo ejecutar los scripts?

### En una instalación en limpio:

1. Realice una instalación en limpio de Ubuntu 16.04 LTS, funciona con Unity, Gnome-Shell y MATE.
2. Conéctese a Internet
3. Descargue el proyecto: `wget https://github.com/cslucr/ubuntu-ucr/archive/master.zip`
4. Descomprima: `unzip master.zip`
5. Ingrese al directorio: `cd ubuntu-ucr-master`
6. De permisos de ejecución al script: `chmod +x ubuntu-16.04-ucr-config.sh`
7. Ejecútelo: `./ubuntu-16.04-ucr-config.sh`

### Para generar una imagen ISO

El script *ubuntu-iso-customization.sh* toma una imagen ISO de Ubuntu y genera un ISO personalizado. El mismo descarga y ejecuta el script de configuración.
1. Instale las herramientas requeridas: `sudo apt install squashfs-tools xorriso`
2. Descargue un ISO soportado por este proyecto. Actualmente Ubuntu 16.04 con Unity, Gnome-Shell o MATE.
3. Descargue el script *ubuntu-iso-customization.sh*: `wget https://github.com/cslucr/ubuntu-ucr/raw/master/ubuntu-iso-customization.sh`
3. De permisos de ejecución al script: `chmod +x ubuntu-iso-customization.sh`
4. Ejecútelo indicando la ruta al archivo ISO: `./ubuntu-iso-customization.sh ubuntu-16.04.x-desktop-arch.iso`

Para más opciones ejecute `./ubuntu-iso-customization.sh -h`

*Comunidad de Software Libre de la Universidad de Costa Rica*

*http://softwarelibre.ucr.ac.cr*
