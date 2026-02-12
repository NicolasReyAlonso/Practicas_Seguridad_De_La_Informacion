#!/bin/bash

# Configuración de directorios
BASE_DIR="$(dirname "$0")"
SALIDAS_DIR="$BASE_DIR/../Salidas"
ORIGINALES_DIR="$BASE_DIR/../ArchivosOriginales"
mkdir -p "$SALIDAS_DIR"

echo "========================================"
echo "1. Comandos básicos OpenSSL"
echo "========================================"
echo "Versión de OpenSSL:"
openssl version

echo ""
echo "Nota: 'openssl speed' ejecuta pruebas de rendimiento para todos los algoritmos y tarda mucho."
echo "Ejecutando prueba rápida solo para rsa y md5 como demostración..."
openssl speed rsa md5
# Para ejecutar todos: openssl speed

echo ""
echo "========================================"
echo "2. Crear archivos binarios (8 y 256 bytes) con openssl rand"
echo "========================================"
openssl rand -out "$SALIDAS_DIR/bin_8bytes.bin" 8
openssl rand -out "$SALIDAS_DIR/bin_256bytes.bin" 256
echo "Generados: bin_8bytes.bin y bin_256bytes.bin en $SALIDAS_DIR"

echo ""
echo "========================================"
echo "3. Convertir a Base64 y comparar"
echo "========================================"
# Usando comando base64
base64 "$SALIDAS_DIR/bin_8bytes.bin" > "$SALIDAS_DIR/bin_8bytes.b64"
echo "Codificado bin_8bytes.bin a Base64 (usando base64)"

# Usando openssl enc -a
openssl enc -a -in "$SALIDAS_DIR/bin_256bytes.bin" -out "$SALIDAS_DIR/bin_256bytes.b64"
echo "Codificado bin_256bytes.bin a Base64 (usando openssl enc -a)"

echo "Decodificando para verificar..."
base64 -d "$SALIDAS_DIR/bin_8bytes.b64" > "$SALIDAS_DIR/bin_8bytes_check.bin"
openssl enc -a -d -in "$SALIDAS_DIR/bin_256bytes.b64" -out "$SALIDAS_DIR/bin_256bytes_check.bin"

echo "Comparando originales con decodificados:"
if cmp -s "$SALIDAS_DIR/bin_8bytes.bin" "$SALIDAS_DIR/bin_8bytes_check.bin"; then
    echo "[OK] bin_8bytes.bin coincide."
else
    echo "[ERROR] bin_8bytes.bin NO coincide."
fi

if cmp -s "$SALIDAS_DIR/bin_256bytes.bin" "$SALIDAS_DIR/bin_256bytes_check.bin"; then
    echo "[OK] bin_256bytes.bin coincide."
else
    echo "[ERROR] bin_256bytes.bin NO coincide."
fi

echo ""
echo "========================================"
echo "4. Crear archivos de ceros (00) y unos (FF)"
echo "========================================"
# 16 bytes de 00
dd if=/dev/zero of="$SALIDAS_DIR/zeros_16.bin" bs=1 count=16 2>/dev/null
echo "Creado zeros_16.bin (16 bytes de 0x00)"

# 64 bytes de FF
# Usando perl para generar caracteres 0xFF
perl -e 'print "\xff" x 64' > "$SALIDAS_DIR/ones_64.bin"
echo "Creado ones_64.bin (64 bytes de 0xFF)"

echo ""
echo "========================================"
echo "5. Visualización Hexadecimal y Octal"
echo "========================================"
echo "--> zeros_16.bin en Hexadecimal:"
hexdump -C "$SALIDAS_DIR/zeros_16.bin"
echo "--> zeros_16.bin en Octal:"
od -b "$SALIDAS_DIR/zeros_16.bin"

echo ""
echo "--> ones_64.bin en Hexadecimal:"
hexdump -C "$SALIDAS_DIR/ones_64.bin"
echo "--> ones_64.bin en Octal:"
od -b "$SALIDAS_DIR/ones_64.bin"

echo ""
echo "========================================"
echo "6, 7 & 8. Tratamiento de Correo (.eml)"
echo "========================================"
# Detectar archivo .eml (tomamos el primero que encontremos)
EMAIL_FILE=$(find "$ORIGINALES_DIR" -maxdepth 1 -name "*.eml" | head -n 1)

if [ -n "$EMAIL_FILE" ] && [ -f "$EMAIL_FILE" ]; then
    echo "Archivo de correo encontrado: $EMAIL_FILE"
    
    # Intenta instalar ripmime si no existe (requiere sudo/interacción, comentado por seguridad en script auto)
    if ! command -v ripmime &> /dev/null; then
         echo "AVISO: 'ripmime' no está instalado. Ejecuta: sudo apt install ripmime"
         # Continuar solo si está instalado...
    else
        EXTRACT_DIR="$SALIDAS_DIR/Adjuntos"
        # Limpiamos carpeta anterior para asegurar limpieza
        rm -rf "$EXTRACT_DIR"
        mkdir -p "$EXTRACT_DIR"
        
        echo "Visualizando cabecera del correo (primeras 20 líneas):"
        head -n 20 "$EMAIL_FILE"
        
        echo ""
        echo "Extrayendo adjuntos con ripmime en $EXTRACT_DIR..."
        ripmime -i "$EMAIL_FILE" -d "$EXTRACT_DIR" --no-nameless
        
        echo "Archivos extraídos:"
        ls -l "$EXTRACT_DIR"
        
        echo ""
        echo "Comparando ficheros extraídos con los originales:"
        
        # Definimos los archivos a comparar (pic.png y holo.odt que están en ArchivosOriginales)
        ARCHIVOS_A_COMPARAR=("pic.png" "holo.odt")
        
        for ARCHIVO in "${ARCHIVOS_A_COMPARAR[@]}"; do
            ORIGINAL="$ORIGINALES_DIR/$ARCHIVO"
            EXTRAIDO="$EXTRACT_DIR/$ARCHIVO"
            
            if [ -f "$ORIGINAL" ]; then
                if [ -f "$EXTRAIDO" ]; then
                    echo -n "Verificando $ARCHIVO... "
                    if cmp -s "$ORIGINAL" "$EXTRAIDO"; then
                        echo "[OK] COINCIDE (Los archivos son idénticos)"
                    else
                        echo "[DIFERENTE] Los archivos NO son idénticos"
                        # Información adicional si son diferentes
                        ls -l "$ORIGINAL" "$EXTRAIDO"
                    fi
                else
                    echo "[ERROR] No se encontró el archivo extraído: $ARCHIVO"
                fi
            else
                echo "[AVISO] No existe el archivo original para comparar: $ARCHIVO"
            fi
        done
    fi
else
    echo "ERROR: No se encontró ningún archivo .eml en $ORIGINALES_DIR"
fi

echo ""
echo "Script finalizado."
