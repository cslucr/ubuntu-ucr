# ¿Cómo contribuir?

¿Quiere hacer su aporte? Para la [#CSLUCR](https://twitter.com/search?q=%23CSLUCR) es un honor recibir sus contribuciones. ¡Muchas gracias! 😀

Desde sugerir una idea, hasta hacer un cambio, todo es bienvenido. Hay varias cosas por hacer: documentación, apariencia visual, scripting, pruebas del producto.

No es necesario ser un usuario técnico para contribuir. Necesitamos probar el sistema, así que simplemente instálelo y denos su retroalimentación.

## Entendiendo el proyecto

Puede ver este proyecto como el típico artículo ["¿Qué hacer después de instalar Ubuntu x.x?"](https://duckduckgo.com/?q=Que+hacer+después+de+instalar+Ubuntu) pero aplicado de manera automática por medio de un script. De esta manera es posible reproducir y mejorar el proceso con facilidad.

Un script es básicamente un archivo de texto con comandos, que se ejecutarán secuencialmente. Si usted ya sabe utilizar la terminal, entonces tiene la base para entender y modificar un script bash. Puede buscar [documentación en línea](https://duckduckgo.com/?q=bash+script+tutorial) para comprender un poco más sobre el tema.

La forma de ejecutar un script es la siguiente:
```
# se le da permisos de ejecución
chmod +x script.sh

# se ejecuta
./script.sh
```

Estos son los scripts que utilizamos:

* **ubuntu-ucr-customization.sh**: ejecútelo en una instalación limpia de Ubuntu y aplicará toda la personalización. Este también copiará los archivos incluidos en el proyecto, como fondos de pantalla, tema de arranque o archivos de configuración.
* **ubuntu-ucr-iso-generator.sh**: toma una imagen ISO de Ubuntu y genera una nueva imagen, con nuestra personalización, lista para ser instalada. Ejecute `./ubuntu-ucr-iso-generator.sh -h` para ver las opciones disponibles.

**No tengo idea de cómo entrarle ¿Por dónde comienzo?**. La respuesta es simple: [DuckDuckGléelo](https://duckduckgo.com/) (o [Googléelo](https://www.google.com/)). De esta manera hemos aprendido que con archivos _gschemas_ podemos cambiar la configuración predeterminado del entorno, o que con _unopkg_ es posible instalar complementos para LibreOffice.

Los scripts también cuentan con documentación interna (todo lo que comience con `#`), que explica cada paso incluido.

## Estándares

Nuestros estándares son simples:
 * **Estilos**: Los scripts usan espacios en lugar de tabs. La tabulación es de dos espacios.
 * **Mantenga el orden**: El script de personalización está dividio en secciones, esto para mantener el orden. Antes de añadir su código, revise cuál es la sección más adecuada para hacerlo.
 * **Mantenga el enfoque**: La personalización está enfocada en el uso común, por ejemplo para docentes, oficina, etc.
 * **Documente**, eso ayudará a otros colaboradores:
   * Documentación interna.
   * Mensaje de cada _commit_
   * Archivo README si es necesario.
 * Realice un **pull request** por cada cambio. Sugerencia: haga un _branch_ en su repositorio local por cada uno.

## Issues: Haga pruebas, sugiera una mejora, reporte un error

**No es necesario saber modificar el proyecto para contribuir**. Las pruebas son sumamente importantes, instale Ubuntu UCR en su computadora y reporte sus observaciones.

Podrá observar que el proyecto cuenta con una sección de _issues_. Aquí usted podrá sugerir un aspecto por mejorar, reportar un problema que se haya encontrado o bien, puede realizar consultas.

Cada _issue_ permite añadir respuestas, por lo que aquí mismo se puede discutir un tema para ampliar conceptos, evacuar dudas o llegar a acuerdos.

## Pull requests: Aporte un cambio

Por medio de un _pull request_ es posible aportar una modificación. Básicamente se realiza la mejora en una copia propia del repositorio y luego se envían los cambios al proyecto oficial.

### Fork y clone

Un _fork_ es su propia copia del repositorio, de esta manera podrá modificarlo y trabajar los cambios a sugerir. Para realizar un _fork_ presione el respectivo botón en la esquina superior derecha. El proyecto copiado aparecerá en su perfil, con una dirección como:
```
https://github.com/miusuario/ubuntu-ucr
```

Ahora solo debe clonarlo a su computadora, ahí podrá trabajarlo. Para ello instale la herramienta `git`. En Ubuntu puede hacerlo ejecutando:
```
sudo apt install git
```
En su copia del repositorio verá un botón `Clone or download`, si lo presiona le dará un enlace. Utilice dicho enlace para clonar su repositorio:
```
git clone https://github.com/miusuario/ubuntu-ucr.git
```
Esto creará un directorio en su computadora, llamado `ubuntu-ucr`, con todo el repositorio. Realice los cambios aquí.

### Branch

Se sugiere trabajar cada _pull request_ en una rama o _branch_ aparte. Los cambios realizados en un _branch_ no se reflejarán en la rama `master`, que es la principal.

Así se crea un nuevo _branch_:
```
git branch miaporte
```

Si ejecuta `git branch` sin más parámetros, mostrará las ramas existentes (el `*` indica la rama actual):
```
git branch
* master
  miaporte
```

Para cambiar a la nueva rama se ejecuta:
```
git checkout miaporte
```
Ejecutando `git branch` nuevamente podrá confirmar en cuál rama estamos:
```
git branch
  master
* miaporte
```
### Add y commit

Cada cambio deberíamos registrarlo en un _commit_, un _commit_ puede contener modificaciones de uno o más archivos. No incluya múltiples cambios en un solo _commit_.

Por ejemplo, si editamos los archivos `ubuntu-ucr-customization.sh` y `README.md`, preparamos el _commit_ así:
```
git add ubuntu-ucr-customization.sh README.md
```
Y hacemos el _commit_ de esta manera:
```
git commit -m "Se agrega revisión ortográfica para LibreOffice"
```
donde la opción `-m "Mensaje..."` añade el mensaje para registrar el _commit_. Esto es importante para identificar qué cambio se hizo en cada _commit_.

Es posible que tengamos que hacer más de un _commit_ antes de hacer el _pull request_.

### Push y pull request

Una vez realizados los cambios, deberemos subir todos los _commits_ a nuestra copia del repositorio:
```
git push origin miaporte
```
Si ingresamos a nuestro repositorio (`https://github.com/miusuario/ubuntu-ucr`) podremos ver la nueva rama y los cambios reflejados en esta.

A la par de la rama podremos ver un botón `New pull request`. Presionándolo se nos mostrará un formulario para hacer el envío. Añada una descripción lo más completa posible explicando los cambios y el por qué de estos.

Un mantenedor del proyecto revisará el _pull request_. Si este tiene dudas o sugerencias añadirá una respuesta al mismo.

Si desea crear un nuevo _pull request_, cambie a la rama master: `git checkout master` y repita los pasos, comenzando por crear un _branch_.
