#!/bin/bash

################################################################################
# Práctica 4: CORREO ELECTRÓNICO SEGURO S/MIME
# Fecha: 19 de febrero de 2026
################################################################################

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
ORIGINALES="../ArchivosOriginales"
SALIDA="../Salida"

# Crear directorio de salida si no existe
mkdir -p "$SALIDA"

# Archivo de texto de la práctica anterior
TEXTO="$ORIGINALES/TextFile.txt"

if [ ! -f "$TEXTO" ]; then
    echo "Creando archivo de texto de prueba..."
    echo "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus bibendum iaculis ante, quis sagittis eros eleifend iaculis. Sed egestas consequat feugiat. Lorem aliquam." > "$TEXTO"
fi

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Práctica 4: CORREO ELECTRÓNICO SEGURO S/MIME                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# PREVIO: Creacion Claves
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PREVIO: Creación de mi clave${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Versión de OpenSSL instalada:"
openssl version

################################################################################
# 1.1 – Creación de nuestro certificado personal
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}1.1: Creación de certificado personal${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Variables de archivos
CERT_RAIZ="$ORIGINALES/certificadoRaiz.crt"
KEY_RAIZ="$ORIGINALES/certificadoRaiz.key"
CERT_PERSONAL_KEY="$SALIDA/certificadoPersonal.key"
CERT_PERSONAL_CSR="$SALIDA/certificadoPersonal.csr"
CERT_PERSONAL_CRT="$SALIDA/certificadoPersonal.crt"

# Comprobar existencia de archivos raíz
if [ ! -f "$CERT_RAIZ" ] || [ ! -f "$KEY_RAIZ" ]; then
    echo -e "${RED}No se encuentran certificadoRaiz.crt o certificadoRaiz.key en $ORIGINALES${NC}"
    exit 1
fi

# 1.1.2.b) Crear clave personal
echo -e "${GREEN}Creando clave personal...${NC}"
openssl genpkey -algorithm RSA -out "$CERT_PERSONAL_KEY" -aes256
echo -e "${GREEN}Clave personal creada en $CERT_PERSONAL_KEY${NC}"

# 1.1.2.c) Crear CSR
echo -e "${GREEN}Creando CSR (solicitud de firma)...${NC}"
openssl req -new -key "$CERT_PERSONAL_KEY" -out "$CERT_PERSONAL_CSR"
echo -e "${GREEN}CSR creado en $CERT_PERSONAL_CSR${NC}"

# 1.1.2.d) Firmar CSR con certificado raíz
echo -e "${GREEN}Firmando CSR con certificado raíz...${NC}"
openssl x509 -req -in "$CERT_PERSONAL_CSR" -CA "$CERT_RAIZ" -CAkey "$KEY_RAIZ" -CAcreateserial -out "$CERT_PERSONAL_CRT" -days 365
echo -e "${GREEN}Certificado personal firmado en $CERT_PERSONAL_CRT${NC}"
echo -e "${BLUE}Proceso completado. Certificados generados en $SALIDA${NC}"
