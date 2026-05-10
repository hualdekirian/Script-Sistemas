#!/bin/bash

# Cabecera para Apache
echo "Content-type: text/html"
echo ""

# 1. Leer los datos que envía el formulario (vienen por POST)
read -n $CONTENT_LENGTH QUERY_STRING

# 2. Decodificar las variables (quitar los + y los códigos raros)
# Usamos sed para extraer y python3 para limpiar caracteres especiales de forma segura
DESTINO=$(echo "$QUERY_STRING" | sed -n 's/.*destino=\([^&]*\).*/\1/p' | sed 's/%40/@/g')
ASUNTO=$(echo "$QUERY_STRING" | sed -n 's/.*asunto=\([^&]*\).*/\1/p' | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.stdin.read()))")
CUERPO=$(echo "$QUERY_STRING" | sed -n 's/.*cuerpo=\([^&]*\).*/\1/p' | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.stdin.read()))")

# 3. Enviar el correo usando las variables reales
# Usamos -F para que en Gmail no aparezca "www-data" sino un nombre amigable
{
    echo "To: $DESTINO"
    echo "Subject: $ASUNTO"
    echo ""
    echo "$CUERPO"
} | ssmtp -F "Panel de Administración" "$DESTINO"

# 4. Respuesta para la web
echo "Mensaje enviado con éxito a $DESTINO"
echo "Asunto: $ASUNTO"
