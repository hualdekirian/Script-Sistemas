================================================================
        GRUPO 3 - Herramienta de Administración de Sistemas en Bash
================================================================

------------------------------------------------------
DESCRIPCIÓN
------------------------------------------------------

Hemos desarrollado una aplicación de administración de sistemas en Bash. Permite al administrador realizar tareas habituales de monitorización, seguridad y gestión de red desde un menú interactivo, con mensajes claros que guían al usuario en todo momento.

El proyecto está compuesto por múltiples scripts estructurados con funciones, redirecciones de salida y de error, variables de posición y de sistema, y control de errores en ejecución mediante la variable especial "?".


------------------------------------------------------
INTERFAZ
------------------------------------------------------

Para poder usar la interfaz TODOS los scripts tienen que tener esto en la cabecera para que Apache2 pueda interpretar el código y mostrarlo como HTML:

#!/bin/bash

# --- CABECERA CGI ---
echo "Content-type: text/html"
echo ""

Los scripts se pueden usar independientemente ejecutándolos por terminal (ej: ./estado_red.sh), 
pero si quieres probarlos todos de forma gráfica busca en el navegador cuatrovientos.grupo3.com, ahí tendrás todos las herramientas.

Los scripts que se ejecutan en la interfaz tienen que estar la carpeta /usr/lib/cgi-bin/ y con permisos de ejecución. 
Para el HTML que se muestra cuando buscas cuatrovientos.grupo3.com, a parte de que tienes que tener el servicio apache2, esta en la fichero /var/www/html/index.html

------------------------------------------------------
ANTES DE EMPEZAR
------------------------------------------------------

Es necesario que todo el mundo que quiera ver la interfaz modifique estos archivos:

1. CAMBIAR EL DNS EN EL UBUNTU Y PONER LA @IP DEL SERVIDOR WEB
   De forma gráfica en ajustes o modificando el fichero que esta en /etc/netplan/0….yaml:
----------------------------
   network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s8:  # <--- Sustituye 'enp0s3' por el nombre que te dio 'ip a'
      dhcp4: true
      nameservers:
        addresses: [@IP del servidor]
----------------------------

2.  CAMBIAR EL DNS DEL WINDOWS EN EL FICHERO HOSTS A LA IP DEL UBUNTU
    C:\Windows\System32\drivers\etc\hosts
    !COMENTA LA LÍNEA QUE TE SALGA ANTES DE MODIFICARLO

    # ===== PROYECTO SISTEMAS 1DAM=====
    172.30.2.187	cuatrovientos.grupo3.com


------------------------------------------------------
FUNCIONALIDADES IMPLEMENTADAS
------------------------------------------------------

1. CONECTIVIDAD ENTRE MÁQUINAS VIRTUALES (ping)
	- Realiza ping a todas las MVs del entorno, muestra cuales responde  y cuales dan fallo de 	conexión.

	- El script correspondiente es verificar.ssh, y se puede probar pulsando el botón de la interfaz.
	Saldrá una respuesta como esta correspondiendo a cada prueba de conexión: 
	✅ 172.30.1.10 - Responde 
	✅ 192.30.1.11 - Responde 
	❌ 172.30.1.12 - No responde

2. ....
