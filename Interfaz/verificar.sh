#!/bin/bash

# --- CABECERA CGI ---
echo "Content-type: text/html"
echo ""

# --- CONFIGURACIÓN DE VARIABLES Y LOGS (Fuente) ---
# Redireccionamos los errores técnicos a un archivo para cumplir el requisito de administrador [1].
LOG_ERRORES="/tmp/log_conectividad.err"
VICTOR="172.30.3.230"
KIRIAN="172.30.2.9"
ANNE="172.30.3.126"
OSCAR="172.30.3.153"

# --- REQUISITO: Uso de funciones (Fuente) ---
# Definimos una función que recibe el nombre y la IP como argumentos [3].
verificar_equipo() {
    # REQUISITO: Variables de posición (Fuente)
    local nombre=$1
    local ip=$2

    # Ejecutamos el ping redirigiendo la salida estándar al vacío
    # y la de error al archivo de log para cumplir con la rúbrica [1, 4].
    ping -c 2 "$ip" > /dev/null 2>> "$LOG_ERRORES"

    # --- REQUISITO: Control de errores con variable $? (Fuente) ---
    # Comprobamos si el comando anterior (ping) tuvo éxito [5].
    if [ $? -eq 0 ]; then
        # Salida formateada con clases CSS para la interfaz "User-Friendly" [2].
        echo "<div class='status success'><b>✓ $nombre:</b> Conexión establecida con la IP $ip</div>"
    else
        echo "<div class='status error'><b>✗ $nombre:</b> Sin respuesta desde la IP $ip</div>"
    fi
}

# --- CUERPO DEL SCRIPT: Generación del contenido HTML ---
echo "<h3>Resultados del Test de Conectividad</h3>"
echo "<p>Iniciando comprobación de las 4 máquinas del grupo...</p>"

# Llamadas a la función para cada compañero [1].
verificar_equipo "VICTOR" "$VICTOR"
verificar_equipo "KIRIAN" "$KIRIAN"
verificar_equipo "ANNE" "$ANNE"
verificar_equipo "OSCAR" "$OSCAR"

echo "<hr><p style='font-size: 0.8em; color: #666;'>Log de errores actualizado en: $LOG_ERRORES</p>"
