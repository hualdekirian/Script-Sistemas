#!/bin/bash

# --- CABECERA OBLIGATORIA PARA CGI ---
echo "Content-type: text/html"
echo ""

# --- CONFIGURACIÓN ---
INTERFAZ="ens33" 

# Estilos básicos para que se vea bien en el panel
echo "<div style='font-family: monospace; line-height: 1.4;'>"
echo "<h3>==============================================</h3>"
echo "<h3>        INFORME DE ESTADO DE RED              </h3>"
echo "<h3>==============================================</h3>"

# 1. IDENTIFICACIÓN LOCAL
# Intentamos detectar la interfaz si ens33 no existe (por seguridad)
if [ ! -d "/sys/class/net/$INTERFAZ" ]; then
    INTERFAZ=$(ip route | grep default | awk '{print $5}' | head -n 1)
fi

IP_PRIVADA=$(hostname -I | awk '{print $1}')
MAC_ADDR=$(cat /sys/class/net/$INTERFAZ/address 2>/dev/null || echo "No detectada")
GATEWAY=$(ip route | grep default | awk '{print $3}')

echo "📍 <strong>IP Privada:</strong> $IP_PRIVADA<br>"
echo "🆔 <strong>MAC Address:</strong> $MAC_ADDR<br>"
echo "🚪 <strong>Puerta de Enlace:</strong> $GATEWAY<br>"

# 2. PUERTOS EN ESCUCHA
echo "<br>--- 🔌 <strong>PUERTOS ABIERTOS (LISTEN)</strong> ---<br>"
PUERTOS=$(ss -tuln | grep LISTEN | awk '{print $5}' | awk -F: '{print $NF}' | sort -nu | xargs)

if [ -z "$PUERTOS" ]; then
    echo "<span style='color:red;'>No hay puertos abiertos detectados.</span><br>"
else
    echo "<span style='color:green;'>Puertos activos:</span> $PUERTOS<br>"
fi

# 3. CONEXIÓN EXTERNA (IP PÚBLICA)
echo "<br>--- 🌍 <strong>CONEXIÓN EXTERNA</strong> ---<br>"
echo "Consultando IP Pública... "
IP_PUBLICA=$(curl -s --connect-timeout 3 https://ifconfig.me)

if [ -z "$IP_PUBLICA" ]; then
    echo "<span style='color:red;'>No se pudo obtener (¿Hay internet?)</span><br>"
else
    echo "<span style='color:green;'>$IP_PUBLICA</span><br>"
fi

# 4. PRUEBA DE SALIDA (GOOGLE)
echo "<br>📡 <strong>Probando conexión con Google (8.8.8.8):</strong> "
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "<span style='color:green;'>[CONECTADO]</span><br>"
else
    echo "<span style='color:red;'>[SIN ACCESO A INTERNET]</span><br>"
fi

echo "<h3>==============================================</h3>"
echo "</div>"
