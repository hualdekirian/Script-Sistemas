#!/bin/bash

# --- CONFIGURACIÓN ---
INTERFAZ="ens33" 

# Colores
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
NC='\033[0m'

echo -e "${AZUL}==============================================${NC}"
echo -e "${AZUL}       INFORME DE ESTADO DE RED               ${NC}"
echo -e "${AZUL}==============================================${NC}"

# 1. IDENTIFICACIÓN LOCAL (Punto 1 y 4)
IP_PRIVADA=$(hostname -I | awk '{print $1}')
MAC_ADDR=$(cat /sys/class/net/$INTERFAZ/address)
GATEWAY=$(ip route | grep default | awk '{print $3}')

echo -e "📍 ${AMARILLO}IP Privada:${NC} $IP_PRIVADA"
echo -e "🆔 ${AMARILLO}MAC Address:${NC} $MAC_ADDR"
echo -e "🚪 ${AMARILLO}Puerta de Enlace:${NC} $GATEWAY"

# 2. PUERTOS EN ESCUCHA
echo -e "\n--- 🔌 PUERTOS ABIERTOS (LISTEN) ---"
PUERTOS=$(ss -tuln | grep LISTEN | awk '{print $5}' | cut -d':' -f2 | sort -nu | xargs)

if [ -z "$PUERTOS" ]; then
    echo -e "${ROJO}No hay puertos abiertos detectados.${NC}"
else
    echo -e "${VERDE}Puertos activos:${NC} $PUERTOS"
fi

# 3. CONEXIÓN EXTERNA (IP PÚBLICA)
echo -e "\n--- 🌍 CONEXIÓN EXTERNA ---"
echo -n "Consultando IP Pública... "
IP_PUBLICA=$(curl -s --connect-timeout 5 https://ifconfig.me)

if [ -z "$IP_PUBLICA" ]; then
    echo -e "${ROJO}No se pudo obtener (¿Hay internet?)${NC}"
else
    echo -e "${VERDE}$IP_PUBLICA${NC}"
fi

# 4. PRUEBA DE SALIDA (GOOGLE)
echo -n "📡 Probando conexión con Google (8.8.8.8)... "
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${VERDE}[CONECTADO]${NC}"
else
    echo -e "${ROJO}[SIN ACCESO A INTERNET]${NC}"
fi

echo -e "${AZUL}==============================================${NC}"
