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

# 1.1.2.e) Crear fichero PKCS#12 con la parte pública y privada del certificado personal
CERT_PERSONAL_P12="$SALIDA/certificadoPersonal.p12"

echo -e "${GREEN}Creando fichero PKCS#12 (certificadoPersonal.p12)...${NC}"
echo "(Se pedirá la contraseña de certificadoPersonal.key y luego la contraseña de protección del .p12)"
openssl pkcs12 -export -in "$CERT_PERSONAL_CRT" -inkey "$CERT_PERSONAL_KEY" -out "$CERT_PERSONAL_P12" -name "Certificado Personal"
echo -e "${GREEN}Fichero PKCS#12 creado en $CERT_PERSONAL_P12${NC}"

# Eliminar el CSR (ya no es necesario)
rm -f "$CERT_PERSONAL_CSR"
echo -e "${GREEN}CSR eliminado (ya no necesario)${NC}"

echo -e "${BLUE}Proceso completado. Certificados generados en $SALIDA${NC}"

################################################################################
# 1.3 – Descifrar y verificar la firma del mensaje del compañero
################################################################################
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}1.3: Descifrado y verificación de firma S/MIME del compañero${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Archivos necesarios
EML_COMPANERO="$ORIGINALES/Wafa Azdad Triki - Wafa Azdad Triki <azdadwafa0@gmail.com> - 2026-03-04 2000.eml"
CERT_COMPANERO="$ORIGINALES/WafaAzdadTriki.crt"

# Archivos de salida
MENSAJE_DESCIFRADO="$SALIDA/mensaje_descifrado.eml"
MENSAJE_PLANO="$SALIDA/mensaje_plano.txt"

# Comprobar existencia de los archivos de entrada
if [ ! -f "$EML_COMPANERO" ]; then
    echo -e "${RED}No se encuentra el fichero EML del compañero: $EML_COMPANERO${NC}"
    exit 1
fi

if [ ! -f "$CERT_COMPANERO" ]; then
    echo -e "${RED}No se encuentra el certificado del compañero: $CERT_COMPANERO${NC}"
    exit 1
fi

if [ ! -f "$CERT_PERSONAL_CRT" ] || [ ! -f "$CERT_PERSONAL_KEY" ]; then
    echo -e "${RED}No se encuentran certificadoPersonal.crt o certificadoPersonal.key en $SALIDA${NC}"
    echo -e "${RED}Ejecuta primero la sección 1.1 para generarlos.${NC}"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# 1.3.1 – Descifrar el mensaje cifrado y firmado (SMIME.P7M → SMIME.P7S)
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${GREEN}[1.3.1] Descifrando el mensaje S/MIME del compañero...${NC}"
echo        "(Se pedirá la contraseña de tu clave privada certificadoPersonal.key)"
echo        "Nota: -recip requiere el certificado PEM (.crt) y -inkey la clave privada (.key)"
echo ""

openssl smime -decrypt \
    -in "$EML_COMPANERO" \
    -recip "$CERT_PERSONAL_CRT" \
    -inkey "$CERT_PERSONAL_KEY" \
    -out "$MENSAJE_DESCIFRADO"
# Nota: NO usar el .p12 directamente con -recip; usar .crt + .key por separado

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Mensaje descifrado correctamente → $MENSAJE_DESCIFRADO${NC}"
else
    echo -e "${RED}Error al descifrar el mensaje. Comprueba que el mensaje fue cifrado con tu certificado.${NC}"
    exit 1
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# 1.3.2 – Verificar la firma del mensaje descifrado (SMIME.P7S → texto plano)
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${GREEN}[1.3.2] Verificando la firma del mensaje descifrado...${NC}"
echo ""

# El certificado del compañero puede haber sido emitido por una CA externa.
# Con -noverify se omite la verificación de la cadena de CA y se comprueba
# únicamente que la firma corresponde al certificado del firmante.
openssl smime -verify \
    -in "$MENSAJE_DESCIFRADO" \
    -signer "$CERT_COMPANERO" \
    -noverify \
    -out "$MENSAJE_PLANO"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Firma verificada correctamente.${NC}"
else
    echo -e "${RED}Error al verificar la firma. Comprueba que el certificado del compañero es correcto.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Mensaje en texto plano guardado en: $MENSAJE_PLANO${NC}"
echo ""
cat "$MENSAJE_PLANO"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Proceso 1.3 completado.${NC}"
echo -e "${BLUE}  · Descifrado (SMIME.P7M → SMIME.P7S): $MENSAJE_DESCIFRADO${NC}"
echo -e "${BLUE}  · Texto plano verificado:              $MENSAJE_PLANO${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
