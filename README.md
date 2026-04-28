# GRUPO 3 — Herramienta de Administración de Sistemas en Bash

## Descripción

Hemos desarrollado una aplicación de administración de sistemas en Bash. Permite al administrador realizar tareas habituales de monitorización, seguridad y gestión de red desde un menú interactivo, con mensajes claros que guían al usuario en todo momento.

El proyecto está compuesto por múltiples scripts estructurados con funciones, redirecciones de salida y de error, variables de posición y de sistema, y control de errores en ejecución mediante la variable especial `$?`.

---

## Interfaz Web

Para poder usar la interfaz, **todos los scripts tienen que tener esta cabecera** para que Apache2 pueda interpretar el código y mostrarlo como HTML:

    #!/bin/bash
    # --- CABECERA CGI ---
    echo "Content-type: text/html"
    echo ""

Los scripts se pueden usar independientemente ejecutándolos por terminal (ej: `./estado_red.sh`), pero si quieres probarlos todos de forma gráfica, busca en el navegador [cuatrovientos.grupo3.com](http://cuatrovientos.grupo3.com).

> Los scripts que se ejecutan en la interfaz tienen que estar en `/usr/lib/cgi-bin/` y con permisos de ejecución.
> El HTML principal está en `/var/www/html/index.html` (requiere tener el servicio `apache2` activo).

---

## Antes de Empezar

Es necesario que todo el mundo que quiera ver la interfaz modifique estos archivos:

### 1. Cambiar el DNS en Ubuntu — apuntar a la IP del servidor web

De forma gráfica en Ajustes, o modificando `/etc/netplan/0….yaml`:

    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        enp0s8:  # <--- Sustituye por el nombre que te dio 'ip a'
          dhcp4: true
          nameservers:
            addresses: [IP_DEL_SERVIDOR]

### 2. Cambiar el DNS en Windows — fichero hosts

Ruta: `C:\Windows\System32\drivers\etc\hosts`

> **Comenta la línea que te salga antes de modificarlo.**

    # ===== PROYECTO SISTEMAS 1DAM =====
    172.30.2.187    cuatrovientos.grupo3.com

---

## Funcionalidades Implementadas

### 1. Conectividad entre Máquinas Virtuales (ping)

- Realiza ping a todas las MVs del entorno y muestra cuáles responden y cuáles fallan.
- Script: `verificar.sh` — accesible desde el botón correspondiente en la interfaz.

Ejemplo de salida:

    ✅ 172.30.1.10 - Responde
    ✅ 172.30.1.11 - Responde
    ❌ 172.30.1.12 - No responde

### 2. ...
