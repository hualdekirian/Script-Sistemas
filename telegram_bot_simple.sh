#!/bin/bash

# --- CABECERA CGI ---
echo "Content-type: text/html"
echo ""

# --- CONFIGURACIÓN ---
BOT_TOKEN="AAFatjvTdNPsICXZgc2PIqhzOqD-l0l139I"
ADMIN_CHAT_ID="8460592342"
LAST_UPDATE=0
LOGS_DIR="$HOME/Script/logs"

# Función para enviar mensaje
send_message() {
    # Redirigimos salida y errores del envío a logs
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=$1" \
        -d "text=$2" \
        -d "parse_mode=HTML" > "$LOGS_DIR/bot_sent_messages.log" 2> "$LOGS_DIR/error_bot_send.log"
}

echo "Bot iniciado - Versión simplificada"
echo "Token: ${BOT_TOKEN:0:20}..."
echo "Admin: $ADMIN_CHAT_ID"
echo "Esperando mensajes..."

while true; do
    # Obtener updates - Añadimos un timeout de 10 segundos para que no se cuelgue si falla la conexión
    UPDATES=$(curl -s --max-time 10 "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=$((LAST_UPDATE + 1))" 2> "$LOGS_DIR/error_bot_getupdates.log")
    
    # Procesar cada update
    # Redirigimos errores de jq al log de la carpeta logs
    echo "$UPDATES" | jq -c '.result[]' 2> "$LOGS_DIR/error_jq.log" | while read -r update; do
        UPDATE_ID=$(echo "$update" | jq -r '.update_id')
        CHAT_ID=$(echo "$update" | jq -r '.message.chat.id')
        TEXT=$(echo "$update" | jq -r '.message.text')
        
        if [ "$CHAT_ID" = "$ADMIN_CHAT_ID" ] && [ -n "$TEXT" ]; then
            echo "Recibido: $TEXT"
            
            case "$TEXT" in
                "/start")
                    send_message "$CHAT_ID" "🤖 Bot funcionando correctamente"
                    ;;
                "/crear"*)
                    USERNAME=$(echo "$TEXT" | cut -d' ' -f2)
                    if [ -n "$USERNAME" ]; then
                        PASSWORD=$(openssl rand -base64 12 | cut -c1-10)
                        # Redirección de salida y error a carpeta logs
                        sudo useradd -m -s /bin/bash "$USERNAME" > "$LOGS_DIR/bot_users.log" 2> "$LOGS_DIR/error_crear_usuario.log"
                        if [ $? -eq 0 ]; then
                            echo "$USERNAME:$PASSWORD" | sudo chpasswd
                            send_message "$CHAT_ID" "✅ Usuario $USERNAME creado\n🔑 Contraseña: $PASSWORD"
                        else
                            send_message "$CHAT_ID" "❌ Error técnico. Revisa $LOGS_DIR/error_crear_usuario.log"
                        fi
                    else
                        send_message "$CHAT_ID" "❌ Uso: /crear nombre_usuario"
                    fi
                    ;;
                "/listar")
                    # Redirección de errores del listado
                    USERS=$(awk -F: '$3>=1000 {print $1}' /etc/passwd 2> "$LOGS_DIR/error_listar.log" | tr '\n' ', ' | sed 's/,$//')
                    send_message "$CHAT_ID" "📋 Usuarios: $USERS"
                    ;;
                "/eliminar"*)
                    USERNAME=$(echo "$TEXT" | cut -d' ' -f2)
                    if [ -n "$USERNAME" ]; then
                        # Redirección de errores al eliminar
                        sudo userdel -r "$USERNAME" > "$LOGS_DIR/bot_users.log" 2> "$LOGS_DIR/error_eliminar_usuario.log"
                        if [ $? -eq 0 ]; then
                            send_message "$CHAT_ID" "✅ Usuario $USERNAME eliminado"
                        else
                            send_message "$CHAT_ID" "❌ Error. Revisa $LOGS_DIR/error_eliminar_usuario.log"
                        fi
                    else
                        send_message "$CHAT_ID" "❌ Uso: /eliminar nombre_usuario"
                    fi
                    ;;
                *)
                    send_message "$CHAT_ID" "Comandos:\n/crear nombre\n/eliminar nombre\n/listar"
                    ;;
            esac
        fi
        
        LAST_UPDATE=$UPDATE_ID
    done
    
    sleep 2
done