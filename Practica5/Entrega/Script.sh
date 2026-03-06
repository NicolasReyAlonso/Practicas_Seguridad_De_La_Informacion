#!/bin/bash

################################################################################
# Práctica 5: CORREO ELECTRÓNICO SEGURO OpenPGP
# Apartado 5.2: Decodificación manual con GnuPG
# Fecha: 5 de marzo de 2026
#
# PREREQUISITOS (colocar en ArchivosOriginales/ antes de ejecutar):
#   · claveprivada.asc  → tu clave privada OpenPGP exportada de Thunderbird
#   · clave.asc         → clave pública del compañero que envió el mensaje
#   · mensaje.eml       → el mensaje cifrado y firmado exportado de Thunderbird
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

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Práctica 4: CORREO ELECTRÓNICO SEGURO S/MIME                ║${NC}"
echo -e "${BLUE}║  Práctica 5: CORREO ELECTRÓNICO SEGURO OpenPGP               ║${NC}"
echo -e "${BLUE}║  Apartado 5.2: Decodificación manual con GnuPG               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Variables de ficheros de entrada
################################################################################
CLAVE_PRIVADA="$ORIGINALES/claveprivada.asc"   # Tu clave privada OpenPGP
CLAVE_PUBLICA="$ORIGINALES/clave.asc"           # Clave pública del compañero
MENSAJE_EML="$ORIGINALES/mensaje.eml"           # Mensaje cifrado y firmado

# Ficheros de salida
MENSAJE_MIME="$SALIDA/mensaje.mime"             # Salida bruta del descifrado
DIR_FINAL="$SALIDA/dir_final"                   # Adjuntos extraídos por ripmime

################################################################################
# PASO 0 – Comprobación de prerrequisitos
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PASO 0: Comprobación de prerrequisitos${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Comprobar gpg
if ! command -v gpg &>/dev/null; then
    echo -e "${RED}ERROR: 'gpg' no está instalado.${NC}"
    echo "  · En macOS:  brew install gnupg"
    echo "  · En Debian: sudo apt install gnupg"
    exit 1
fi
echo -e "${GREEN}✓ gpg encontrado: $(gpg --version | head -1)${NC}"

# Comprobar ripmime (no obligatorio, pero avisamos)
RIPMIME_OK=true
if ! command -v ripmime &>/dev/null; then
    echo -e "${YELLOW}⚠ 'ripmime' no está instalado (se usará solo si la salida es MIME/Base64).${NC}"
    echo "  · En macOS:  brew install ripmime"
    echo "  · En Debian: sudo apt install ripmime"
    RIPMIME_OK=false
else
    echo -e "${GREEN}✓ ripmime encontrado: $(ripmime --version 2>&1 | head -1)${NC}"
fi

echo ""

# Comprobar ficheros de entrada
FALTAN=false
for f in "$CLAVE_PRIVADA" "$CLAVE_PUBLICA" "$MENSAJE_EML"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}ERROR: No se encuentra el fichero: $f${NC}"
        FALTAN=true
    else
        echo -e "${GREEN}✓ Encontrado: $f${NC}"
    fi
done

if [ "$FALTAN" = true ]; then
    echo ""
    echo -e "${RED}Coloca los ficheros que faltan en $ORIGINALES/ y vuelve a ejecutar.${NC}"
    echo "  · claveprivada.asc → exportar desde Thunderbird > OpenPGP Key Manager > tu clave > Exportar clave secreta"
    echo "  · clave.asc        → exportar la clave pública del compañero desde Thunderbird"
    echo "  · mensaje.eml      → Guardar como... el correo cifrado recibido en Thunderbird"
    exit 1
fi

echo ""

################################################################################
# PASO 1 – Importar nuestra clave privada en el llavero gpg
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PASO 1: Importar clave privada propia${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Importando $CLAVE_PRIVADA ...${NC}"
echo "(Se pedirá la contraseña de tu clave OpenPGP)"
echo ""

gpg --import "$CLAVE_PRIVADA"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error al importar la clave privada.${NC}"
    exit 1
fi
echo -e "${GREEN}Clave privada importada correctamente.${NC}"
echo ""

################################################################################
# PASO 2 – Importar la clave pública del compañero
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PASO 2: Importar clave pública del compañero${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Importando $CLAVE_PUBLICA ...${NC}"
echo ""

gpg --import "$CLAVE_PUBLICA"

if [ $? -ne 0 ]; then
    # Puede fallar por caracteres inconsistentes; intentamos --dearmor primero
    echo -e "${YELLOW}Primer intento fallido. Probando con --dearmor ...${NC}"
    gpg --dearmor "$CLAVE_PUBLICA"          # genera clave.asc.gpg
    gpg --import "${CLAVE_PUBLICA}.gpg"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al importar la clave pública del compañero.${NC}"
        exit 1
    fi
    rm -f "${CLAVE_PUBLICA}.gpg"
fi
echo -e "${GREEN}Clave pública del compañero importada correctamente.${NC}"
echo ""

################################################################################
# PASO 3 – Gestión de confianza de la clave del compañero
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PASO 3: Conferir confianza máxima a la clave del compañero${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Mostrar las claves disponibles para que el usuario identifique la del compañero
echo -e "${BLUE}Claves públicas en el llavero:${NC}"
gpg --list-keys
echo ""

# Obtener el fingerprint de la primera clave que no sea la propia (heurística simple)
# En la práctica, el estudiante puede conocer el fingerprint de antemano.
echo -e "${YELLOW}Para conferir confianza máxima (nivel 5) a la clave del compañero,${NC}"
echo -e "${YELLOW}copia el fingerprint de su clave (40 caracteres hex) y ejecuta:${NC}"
echo ""
echo -e "    ${BLUE}gpg --edit-key <FINGERPRINT_O_EMAIL_COMPANERO>${NC}"
echo -e "    gpg> trust"
echo -e "    Your decision? ${BLUE}5${NC}   (confianza absoluta)"
echo -e "    Do you really want to set this key to ultimate trust? ${BLUE}y${NC}"
echo -e "    gpg> quit"
echo ""

# Intento automático: si el usuario exportó solo la clave del compañero,
# obtenemos su key-id para automatizar la asignación de confianza vía --import-ownertrust
COMPANERO_KEYID=$(gpg --with-colons --import-options show-only --import "$CLAVE_PUBLICA" 2>/dev/null \
    | awk -F: '/^pub/{print $5}' | head -1)

if [ -n "$COMPANERO_KEYID" ]; then
    echo -e "${GREEN}Key-ID del compañero detectado: $COMPANERO_KEYID${NC}"
    echo -e "${YELLOW}Configurando confianza máxima (ultimate) automáticamente...${NC}"
    # ownertrust: 6 = ultimate en el protocolo de gpg
    echo "${COMPANERO_KEYID}:6:" | gpg --import-ownertrust
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Confianza máxima asignada a $COMPANERO_KEYID.${NC}"
    else
        echo -e "${YELLOW}No se pudo asignar confianza automáticamente. Hazlo de forma manual (ver instrucciones arriba).${NC}"
    fi
else
    echo -e "${YELLOW}No se pudo detectar el Key-ID automáticamente. Asigna la confianza de forma manual.${NC}"
fi
echo ""

################################################################################
# PASO 4 – Descifrar y verificar la firma del mensaje
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PASO 4: Descifrar y verificar la firma${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Ejecutando: gpg --decrypt $MENSAJE_EML${NC}"
echo "(Se pedirá la contraseña de tu clave privada OpenPGP)"
echo ""

gpg --decrypt "$MENSAJE_EML" > "$MENSAJE_MIME" 2>&1

GPG_EXIT=$?

# Mostrar la salida (contiene también los mensajes de verificación de firma)
cat "$MENSAJE_MIME"
echo ""

if [ $GPG_EXIT -ne 0 ]; then
    echo -e "${RED}gpg --decrypt devolvió código de error $GPG_EXIT.${NC}"
    echo -e "${YELLOW}Causas comunes:${NC}"
    echo "  · La clave privada no coincide con el receptor del mensaje."
    echo "  · Contraseña incorrecta."
    echo "  · El mensaje no está cifrado con OpenPGP (¿es S/MIME?)."
    exit 1
fi

echo -e "${GREEN}Descifrado completado → $MENSAJE_MIME${NC}"
echo ""

################################################################################
# PASO 5 – Extracción de adjuntos MIME (si el contenido está en Base64/MIME)
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PASO 5: Extracción de adjuntos MIME con ripmime (si aplica)${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Detectar si la salida contiene cabeceras MIME (Content-Type, etc.)
if grep -qi "Content-Type:" "$MENSAJE_MIME"; then
    echo -e "${GREEN}Se detectaron cabeceras MIME en el mensaje descifrado.${NC}"

    if [ "$RIPMIME_OK" = true ]; then
        mkdir -p "$DIR_FINAL"
        echo -e "${GREEN}Extrayendo adjuntos con ripmime en $DIR_FINAL ...${NC}"
        ripmime "$MENSAJE_MIME" "$DIR_FINAL"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Adjuntos extraídos:${NC}"
            ls -lh "$DIR_FINAL"
        else
            echo -e "${RED}ripmime devolvió un error. Revisa $MENSAJE_MIME manualmente.${NC}"
        fi
    else
        echo -e "${YELLOW}ripmime no está instalado. Instálalo y ejecuta manualmente:${NC}"
        echo "  ripmime \"$MENSAJE_MIME\" \"$DIR_FINAL\""
    fi
else
    echo -e "${GREEN}El mensaje descifrado no parece MIME codificado; el texto es legible directamente.${NC}"
    echo -e "${GREEN}Contenido:${NC}"
    echo "---"
    cat "$MENSAJE_MIME"
    echo "---"
fi

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Resumen de ficheros generados                               ║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║  · Mensaje descifrado (raw): $MENSAJE_MIME${NC}"
if [ -d "$DIR_FINAL" ]; then
echo -e "${BLUE}║  · Adjuntos MIME extraídos:  $DIR_FINAL/${NC}"
fi
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
