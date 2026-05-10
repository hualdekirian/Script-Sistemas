#!/bin/bash

# Cabecera obligatoria para CGI
echo "Content-type: text/html"
echo ""

# Extraer parámetros de la URL
ACTION=$(echo "$QUERY_STRING" | sed -n 's/^.*accion=\([^&]*\).*$/\1/p')
USERNAME=$(echo "$QUERY_STRING" | sed -n 's/^.*nombre=\([^&]*\).*$/\1/p')

case "$ACTION" in
    "crear")
        if [ -n "$USERNAME" ]; then
            # Generar contraseña aleatoria (lógica del bot original)
            PASSWORD=$(openssl rand -base64 12 | cut -c1-10)

            # Crear usuario y asignar contraseña con sudo
            sudo useradd -m -s /bin/bash "$USERNAME" 2>/dev/null
            echo "$USERNAME:$PASSWORD" | sudo chpasswd

            echo "<div style='color:green;'><h3>✅ Usuario creado con éxito</h3>"
            echo "<p><strong>Usuario:</strong> $USERNAME</p>"
            echo "<p><strong>Contraseña:</strong> <code>$PASSWORD</code></p></div>"
        else
            echo "<p style='color:red;'>❌ Error: Nombre de usuario no proporcionado.</p>"
        fi
        ;;

    "listar")
        echo "<h3>Usuarios del Sistema (UID >= 1000)</h3>"
        # Obtener usuarios con UID >= 1000 (lógica del bot original)
        USERS=$(awk -F: '$3>=1000 {print $1}' /etc/passwd)
        echo "<ul>"
        for user in $USERS; do
            echo "<li>$user</li>"
        done
        echo "</ul>"
        ;;

    "eliminar")
        if [ -n "$USERNAME" ]; then
            sudo userdel -r "$USERNAME" 2>/dev/null
            echo "<p style='color:orange;'>⚠️ Usuario <strong>$USERNAME</strong> eliminado del sistema.</p>"
        else
            echo "<p style='color:red;'>❌ Error: Nombre de usuario no proporcionado.</p>"
        fi
        ;;

    *)
        echo "<p>Seleccione una acción válida.</p>"
        ;;
esac
