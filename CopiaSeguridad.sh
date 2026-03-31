#!/bin/bash
# ======================================================================
# CopiaSeguridad - Gestor de Copias de Seguridad con GUI Zenity
# Ubuntu Linux - Version GUI
# ======================================================================

# Colores para terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuracion
BACKUP_DIR="/backup"
CONFIG_DIR="$HOME/.CopiaSeguridad"
DB_FILE="$CONFIG_DIR/backups.db"
LOG_FILE="$CONFIG_DIR/backup.log"

# Crear directorios
mkdir -p "$BACKUP_DIR" "$CONFIG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Funcion principal GUI
show_main_menu() {
    local choice=$(zenity \
        --list \
        --title="CopiaSeguridad - Gestor de Backups" \
        --text="Selecciona una opcion:" \
        --column="Opcion" \
        "Crear Backup" \
        "Listar Backups" \
        "Restaurar Backup" \
        "Eliminar Backup" \
        "Informacion Backup" \
        "Ver Logs" \
        "Salir" \
        --width=350 \
        --height=300)

    case "$choice" in
        "Crear Backup") create_backup_gui ;;
        "Listar Backups") list_backups_gui ;;
        "Restaurar Backup") restore_backup_gui ;;
        "Eliminar Backup") delete_backup_gui ;;
        "Informacion Backup") info_backup_gui ;;
        "Ver Logs") show_logs_gui ;;
        "Salir"|"") exit 0 ;;
        *) zenity --error --text="Opcion no valida" ;;
    esac
    
    show_main_menu
}

# Crear backup con progreso
create_backup_gui() {
    if ! zenity --question --title="CopiaSeguridad - Crear Backup" \
        --text="Crear nueva copia de seguridad?\n\nEsto puede tomar varios minutos..." \
        --width=400; then
        return 0
    fi

    (
        echo "# Iniciando creacion de backup..."
        echo "20"
        
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_name="backup_$timestamp"
        local backup_path="$BACKUP_DIR/$backup_name"
        mkdir -p "$backup_path"
        
        echo "# Creando estructura... ($backup_name)" && echo "30"
        
        declare -a SOURCES=(
            "/home"
            "/etc"
            "/var/www"
            "/opt"
        )
        
        local total=${#SOURCES[@]}
        local count=1
        
        for source in "${SOURCES[@]}"; do
            if [[ -d "$source" || -f "$source" ]]; then
                echo "# Respaldando $source... ($count/$total)" && echo $((40 + (count * 40 / total)))
                sudo tar -czf "$backup_path/$(basename "$source").tar.gz" \
                    -C "$(dirname "$source")" "$(basename "$source")" >/dev/null 2>&1 || \
                echo "# Error en $source" && echo $((40 + (count * 40 / total)))
            fi
            ((count++))
        done
        
        echo "# Guardando informacion del sistema..." && echo "90"
        echo "user@host: $(whoami)@$(hostname)" > "$backup_path/info.txt"
        echo "fecha: $(date)" >> "$backup_path/info.txt"
        echo "kernel: $(uname -a)" >> "$backup_path/info.txt"
        
        echo "# Registrando en base de datos..." && echo "95"
        echo "$backup_name|$timestamp|$(du -sh "$backup_path" | cut -f1)|CREATED" >> "$DB_FILE"
        
        echo "100"
    ) | zenity --progress \
        --title="CopiaSeguridad - Creando Backup" \
        --text="Iniciando..." \
        --percentage=0 \
        --width=450 \
        --auto-close \
        --pulsate

    zenity --info --title="CopiaSeguridad - Exito" \
        --text="Backup '$backup_name' creado exitosamente\nTamaño: $(du -sh "$BACKUP_DIR/$backup_name" | cut -f1)" \
        --width=400
    log "CopiaSeguridad: Backup creado: $backup_name"
}

# Listar backups
list_backups_gui() {
    if [[ ! -f "$DB_FILE" ]]; then
        zenity --info --title="CopiaSeguridad" --text="No hay copias de seguridad"
        return 0
    fi

    local backups=$(awk -F'|' '{
        printf "%s|%s|%s|%s\n", NR, $2, $1, $3
    }' "$DB_FILE")

    zenity --list \
        --title="CopiaSeguridad - Backups Disponibles" \
        --text="Selecciona un backup (o Cancelar)" \
        --column="ID" --column="Fecha" --column="Nombre" --column="Tamano" \
        $backups \
        --width=650 \
        --height=450 \
        --separator="|"
}

# Restaurar backup
restore_backup_gui() {
    local selected=$(list_backups_gui)
    local id=$(echo "$selected" | cut -d'|' -f1)
    
    [[ -z "$id" ]] && return 0
    
    local line=$(sed -n "${id}p" "$DB_FILE")
    local backup_name=$(echo "$line" | cut -d'|' -f1)
    
    if zenity --question --title="CopiaSeguridad - Restaurar" \
        --text="ADVERTENCIA!\n\nEsto SOBREESCRIBIRA archivos del sistema\n\nRestaurar: $backup_name\n\nContinuar?" \
        --width=450; then
        
        (
            echo "# Preparando restauracion..."
            echo "10"
            
            local backup_path="$BACKUP_DIR/$backup_name"
            local files=($(ls "$backup_path"/*.tar.gz 2>/dev/null))
            local total=${#files[@]}
            local count=1
            
            for file in "${files[@]}"; do
                local dest_dir=$(dirname "$(echo "$file" | sed 's|.tar.gz||' | sed "s|$backup_path/||")")
                echo "# Restaurando $(basename "$file")... ($count/$total)" 
                echo $((10 + (count * 85 / total)))
                sudo tar -xzf "$file" -C "$dest_dir" >/dev/null 2>&1
                ((count++))
            done
            
            echo "100"
        ) | zenity --progress \
            --title="CopiaSeguridad - Restaurando $backup_name" \
            --text="Iniciando restauracion..." \
            --percentage=0 \
            --width=450 \
            --auto-close \
            --pulsate

        zenity --info --title="CopiaSeguridad - Restauracion Completada" \
            --text="Backup '$backup_name' restaurado correctamente"
        log "CopiaSeguridad: Backup restaurado: $backup_name (ID: $id)"
    fi
}

# Eliminar backup
delete_backup_gui() {
    local selected=$(list_backups_gui)
    local id=$(echo "$selected" | cut -d'|' -f1)
    
    [[ -z "$id" ]] && return 0
    
    local line=$(sed -n "${id}p" "$DB_FILE")
    local backup_name=$(echo "$line" | cut -d'|' -f1)
    
    if zenity --question --title="CopiaSeguridad - Eliminar" \
        --text="Eliminar permanentemente?\n\n$backup_name" \
        --width=400; then
        
        sudo rm -rf "$BACKUP_DIR/$backup_name"
        sed -i "${id}d" "$DB_FILE"
        
        zenity --info --title="CopiaSeguridad - Eliminado" \
            --text="Backup '$backup_name' eliminado"
        log "CopiaSeguridad: Backup eliminado: $backup_name (ID: $id)"
    fi
}

# Informacion backup
info_backup_gui() {
    local selected=$(list_backups_gui)
    local id=$(echo "$selected" | cut -d'|' -f1)
    
    [[ -z "$id" ]] && return 0
    
    local line=$(sed -n "${id}p" "$DB_FILE")
    local backup_name=$(echo "$line" | cut -d'|' -f1)
    local backup_path="$BACKUP_DIR/$backup_name"
    
    local info=$(cat "$backup_path/info.txt" 2>/dev/null || echo "No disponible")
    local files=$(ls -lh "$backup_path"/*.tar.gz 2>/dev/null | head -10 || echo "No hay archivos")
    
    zenity --info --title="CopiaSeguridad - Info: $backup_name" \
        --text="Sistema:\n$info\n\nArchivos (primeros 10):\n$files" \
        --width=550 \
        --height=450
}

# Mostrar logs
show_logs_gui() {
    local logs=$(tail -50 "$LOG_FILE" 2>/dev/null || echo "No hay logs")
    zenity --text-info --title="CopiaSeguridad - Logs Recientes" \
        --filename=- \
        <<< "$logs" \
        --width=650 \
        --height=450
}

# Verificaciones iniciales
if ! command -v zenity &> /dev/null; then
    echo -e "${RED}Error: Zenity no esta instalado${NC}"
    echo -e "${YELLOW}Solucion:${NC} sudo apt update && sudo apt install zenity"
    exit 1
fi

if [[ ! -w "$BACKUP_DIR" ]]; then
    echo -e "${RED}Error: Sin permisos en $BACKUP_DIR${NC}"
    echo -e "${YELLOW}Solucion:${NC} sudo mkdir -p $BACKUP_DIR && sudo chown \$USER:\$USER $BACKUP_DIR"
    exit 1
fi

# Lanzar interfaz
export -f log create_backup_gui list_backups_gui restore_backup_gui delete_backup_gui info_backup_gui show_logs_gui
zenity --info --title="CopiaSeguridad" \
    --text="Gestor de Copias de Seguridad GUI\n\nListo para usar" \
    --width=400

show_main_menu