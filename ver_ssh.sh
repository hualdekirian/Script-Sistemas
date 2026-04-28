#!/bin/bash

# --- CABECERA CGI ---
echo "Content-type: text/html"
echo ""

# --- CONFIGURACIÓN ---
# Variables necesarias para el envío (no se comparten con otros scripts)
TOKEN="8778430635:AAFatjvTdNPsICXZgc2PIqhzOqD-l0l139I"
ID_CHAT="8460592342"

# Variable de origen (el archivo que lee el script)
ARCHIVO_AUTH="/var/log/auth.log"

# Variable de destino (donde guardas tus logs de control)
LOGS_DIR="$HOME/Script/logs"

# --- FUNCIÓN PARA IDENTIFICAR PERSONAS ---
identificar_persona() {
    local ip=$1
    case $ip in
        "172.30.3.230")  echo "Victor" ;;
        "172.24.75.233") echo "Kirian" ;;
        "172.30.2.12")   echo "Anne" ;;
        "172.30.3.153")  echo "Oscar" ;;
        *)               echo "Desconocido ($ip)" ;;
    esac
}

# --- PROCESAR LOGS ---
# Redirigimos errores de lectura de auth.log a tu carpeta de logs
DATA=$(sudo grep -E "Accepted|Failed" "$ARCHIVO_AUTH" 2> "$LOGS_DIR/error_lectura_ssh.log" | tail -n 8 | while read -r line; do
    HORA=$(echo $line | awk '{print $3}')
    IP=$(echo $line | awk '{print $11}')
    USER=$(echo $line | awk '{print $9}')
    
    PERSONA=$(identificar_persona "$IP")

    if [[ "$line" == *"Accepted"* ]]; then
        echo "✅ *ACCESO EXITOSO*"
        echo "👤 *Persona:* $PERSONA"
        echo "💻 *Usuario Linux:* $USER"
        echo "⏰ *Hora:* $HORA"
        echo "--------------------------"
    else
        echo "⚠️ *INTENTO FALLIDO*"
        echo "🚫 *Origen:* $PERSONA"
        echo "👤 *Intentó entrar como:* $USER"
        echo "⏰ *Hora:* $HORA"
        echo "--------------------------"
    fi
done)

if [ -z "$DATA" ]; then
    DATA="Sin actividad reciente."
fi

# --- MENSAJE FINAL ---
CUERPO="🛡 *REPORTE SSH PERSONALIZADO*%0A"
CUERPO+="━━━━━━━━━━━━━━━━━━%0A%0A"
CUERPO+="${DATA//$'\n'/%0A}"

# --- ENVÍO ---
# Redirección de salida (> log) y error (2> log) a tu carpeta
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$ID_CHAT" \
    -d "text=$CUERPO" \
    -d "parse_mode=Markdown" > "$LOGS_DIR/ver_ssh_envio.log" 2> "$LOGS_DIR/error_telegram_ssh.log"

# Control de ejecución con la variable $?
if [ $? -eq 0 ]; then
    echo "✅ Reporte enviado. ¡Ahora con identificación de nombres!"
else
    echo "❌ Error al enviar reporte. Consulta $LOGS_DIR/error_telegram_ssh.log"
fi