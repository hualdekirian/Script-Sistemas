#!/bin/bash

# Configuración
BOT_TOKEN="AAFatjvTdNPsICXZgc2PIqhzOqD-l0l139I"
ADMIN_CHAT_ID="8460592342"
LAST_UPDATE=0

# Función para enviar mensaje
send_message() {
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=$1" \
        -d "text=$2" \
        -d "parse_mode=HTML" > /dev/null
}

echo "Bot iniciado - Versión simplificada"
echo "Token: ${BOT_TOKEN:0:20}..."
echo "Admin: $ADMIN_CHAT_ID"
echo "Esperando mensajes..."

while true; do
    # Obtener updates
    UPDATES=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=$((LAST_UPDATE + 1))")
    
    # Procesar cada update
    echo "$UPDATES" | jq -c '.result[]' 2>/dev/null | while read -r update; do
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
                        sudo useradd -m -s /bin/bash "$USERNAME" 2>/dev/null
                        echo "$USERNAME:$PASSWORD" | sudo chpasswd
                        send_message "$CHAT_ID" "✅ Usuario $USERNAME creado\n🔑 Contraseña: $PASSWORD"
                    else
                        send_message "$CHAT_ID" "❌ Uso: /crear nombre_usuario"
                    fi
                    ;;
                "/listar")
                    USERS=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | tr '\n' ', ' | sed 's/,$//')
                    send_message "$CHAT_ID" "📋 Usuarios: $USERS"
                    ;;
                "/eliminar"*)
                    USERNAME=$(echo "$TEXT" | cut -d' ' -f2)
                    if [ -n "$USERNAME" ]; then
                        sudo userdel -r "$USERNAME" 2>/dev/null
                        send_message "$CHAT_ID" "✅ Usuario $USERNAME eliminado"
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
