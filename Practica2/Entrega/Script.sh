#!/bin/bash

################################################################################
# Práctica 2: Algoritmos de resumen y de cifrado simétrico
# Fecha: 12 de febrero de 2026
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
echo -e "${BLUE}║  Práctica 2: Algoritmos de resumen y cifrado simétrico       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# PREVIO: Verificación del Provider Legacy
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PREVIO: Verificación del Provider Legacy en OpenSSL${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Versión de OpenSSL instalada:"
openssl version
echo ""

echo "Providers activos:"
openssl list -providers
echo ""

if openssl list -providers | grep -q "legacy"; then
    echo -e "${GREEN}✓ Provider Legacy está ACTIVO${NC}"
else
    echo -e "${RED}✗ Provider Legacy NO está activo${NC}"
    echo "Por favor, activar el provider legacy en el archivo de configuración de OpenSSL"
    echo "Consultar: /etc/ssl/openssl.cnf o /etc/pki/tls/openssl.cnf"
fi
echo ""

################################################################################
# 2.1 GENERACIÓN Y COMPROBACIÓN DE RESÚMENES
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}2.1 Generación y comprobación de Resúmenes${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

TEXTO_RESUMEN="$ORIGINALES/TextFile.txt"

if [ ! -f "$TEXTO_RESUMEN" ]; then
    echo "Creando archivo de texto de prueba..."
    echo "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus bibendum iaculis ante, quis sagittis eros eleifend iaculis. Sed egestas consequat feugiat. Lorem aliquam." > "$TEXTO_RESUMEN"
fi

echo "Archivo de texto: $TEXTO_RESUMEN"
echo "Contenido:"
cat "$TEXTO_RESUMEN"
echo ""
echo "Tamaño: $(wc -c < "$TEXTO_RESUMEN") caracteres"
echo ""

# Aplicar diferentes algoritmos de resumen
echo -e "${GREEN}Aplicando algoritmos de resumen:${NC}"
echo ""

# MD5 (128 bits = 16 bytes = 32 hex)
echo "1. MD5 (128 bits):"
openssl dgst -md5 "$TEXTO_RESUMEN" | tee "$SALIDA/resumen_md5.txt"
echo "   Tamaño esperado: 128 bits (32 caracteres hexadecimales)"
echo ""

# SHA-1 (160 bits = 20 bytes = 40 hex)
echo "2. SHA-1 (160 bits):"
openssl dgst -sha1 "$TEXTO_RESUMEN" | tee "$SALIDA/resumen_sha1.txt"
echo "   Tamaño esperado: 160 bits (40 caracteres hexadecimales)"
echo ""

# SHA-256 (256 bits = 32 bytes = 64 hex)
echo "3. SHA-256 (256 bits):"
openssl dgst -sha256 "$TEXTO_RESUMEN" | tee "$SALIDA/resumen_sha256.txt"
echo "   Tamaño esperado: 256 bits (64 caracteres hexadecimales)"
echo ""

# SHA-512 (512 bits = 64 bytes = 128 hex)
echo "4. SHA-512 (512 bits):"
openssl dgst -sha512 "$TEXTO_RESUMEN" | tee "$SALIDA/resumen_sha512.txt"
echo "   Tamaño esperado: 512 bits (128 caracteres hexadecimales)"
echo ""

# Whirlpool (512 bits = 64 bytes = 128 hex)
echo "5. Whirlpool (512 bits):"
openssl dgst -whirlpool "$TEXTO_RESUMEN" | tee "$SALIDA/resumen_whirlpool.txt"
echo "   Tamaño esperado: 512 bits (128 caracteres hexadecimales)"
echo ""

# Formatos alternativos
echo -e "${GREEN}Formatos alternativos de salida:${NC}"
echo ""

echo "SHA-256 en formato hexadecimal estándar:"
openssl dgst -sha256 "$TEXTO_RESUMEN"
echo ""

echo "SHA-256 en formato hexadecimal con separadores ':':"
openssl dgst -sha256 -c "$TEXTO_RESUMEN"
echo ""

echo "SHA-256 en formato binario (guardado en archivo):"
openssl dgst -sha256 -binary "$TEXTO_RESUMEN" > "$SALIDA/resumen_sha256.bin"
echo "Guardado en: $SALIDA/resumen_sha256.bin"
echo "Tamaño del archivo binario: $(wc -c < "$SALIDA/resumen_sha256.bin") bytes (32 bytes esperados)"
echo ""

# Demostración de sensibilidad: modificar un carácter
echo -e "${GREEN}Demostración de sensibilidad del hash:${NC}"
echo ""
cp "$TEXTO_RESUMEN" "$SALIDA/texto_modificado.txt"
# Cambiar el primer carácter 'L' por 'l'
sed -i '' '1s/L/l/' "$SALIDA/texto_modificado.txt" 2>/dev/null || sed -i '1s/L/l/' "$SALIDA/texto_modificado.txt"

echo "Texto original (SHA-256):"
openssl dgst -sha256 "$TEXTO_RESUMEN"
echo ""
echo "Texto con un único carácter modificado (SHA-256):"
openssl dgst -sha256 "$SALIDA/texto_modificado.txt"
echo ""
echo -e "${BLUE}Nota: Un simple cambio de un carácter produce un hash completamente diferente${NC}"
echo ""

################################################################################
# 2.2 CIFRADO SIMÉTRICO DE DOCUMENTOS
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}2.2 Cifrado Simétrico de documentos${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Crear archivo de texto pequeño (31-81 caracteres, número impar)
TEXTO_CIFRADO="$SALIDA/texto_cifrado_original.txt"
echo "Este es un texto de prueba para cifrado simétrico." > "$TEXTO_CIFRADO"
echo "Archivo para cifrado: $TEXTO_CIFRADO"
echo "Contenido: $(cat "$TEXTO_CIFRADO")"
echo "Tamaño: $(wc -c < "$TEXTO_CIFRADO") caracteres"
echo ""

# Contraseña para cifrado
PASSWORD="Nicololo1234"

echo -e "${GREEN}Cifrando con diferentes algoritmos:${NC}"
echo ""

# 1. AES-256-CBC (modo bloque)
echo "1. AES-256-CBC (cifrado de bloque):"
openssl enc -aes-256-cbc -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_aes256cbc.bin" -pass pass:"$PASSWORD"
TAMANO_AES256=$(wc -c < "$SALIDA/cifrado_aes256cbc.bin")
echo "   Archivo cifrado: cifrado_aes256cbc.bin (Tamaño: $TAMANO_AES256 bytes)"
echo "   Descifrado:"
openssl enc -aes-256-cbc -d -pbkdf2 -in "$SALIDA/cifrado_aes256cbc.bin" -out "$SALIDA/descifrado_aes256cbc.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_aes256cbc.txt")"
echo ""

# 2. AES-128-CTR (modo flujo)
echo "2. AES-128-CTR (modo flujo/contador):"
openssl enc -aes-128-ctr -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_aes128ctr.bin" -pass pass:"$PASSWORD"
TAMANO_AES128CTR=$(wc -c < "$SALIDA/cifrado_aes128ctr.bin")
echo "   Archivo cifrado: cifrado_aes128ctr.bin (Tamaño: $TAMANO_AES128CTR bytes)"
echo "   Descifrado:"
openssl enc -aes-128-ctr -d -pbkdf2 -in "$SALIDA/cifrado_aes128ctr.bin" -out "$SALIDA/descifrado_aes128ctr.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_aes128ctr.txt")"
echo ""

# 3. DES-EDE3-CBC / 3DES (modo bloque)
echo "3. DES-EDE3-CBC / 3DES (cifrado de bloque):"
openssl enc -des-ede3-cbc -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_3des.bin" -pass pass:"$PASSWORD"
TAMANO_3DES=$(wc -c < "$SALIDA/cifrado_3des.bin")
echo "   Archivo cifrado: cifrado_3des.bin (Tamaño: $TAMANO_3DES bytes)"
echo "   Descifrado:"
openssl enc -des-ede3-cbc -d -pbkdf2 -in "$SALIDA/cifrado_3des.bin" -out "$SALIDA/descifrado_3des.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_3des.txt")"
echo ""

# 4. DES-EDE3-OFB (modo flujo)
echo "4. DES-EDE3-OFB (modo flujo):"
openssl enc -des-ede3-ofb -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_3des_ofb.bin" -pass pass:"$PASSWORD"
TAMANO_3DES_OFB=$(wc -c < "$SALIDA/cifrado_3des_ofb.bin")
echo "   Archivo cifrado: cifrado_3des_ofb.bin (Tamaño: $TAMANO_3DES_OFB bytes)"
echo "   Descifrado:"
openssl enc -des-ede3-ofb -d -pbkdf2 -in "$SALIDA/cifrado_3des_ofb.bin" -out "$SALIDA/descifrado_3des_ofb.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_3des_ofb.txt")"
echo ""

# 5. RC4 (cifrador de flujo)
echo "5. RC4 (cifrador de flujo):"
openssl enc -rc4 -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_rc4.bin" -pass pass:"$PASSWORD"
TAMANO_RC4=$(wc -c < "$SALIDA/cifrado_rc4.bin")
echo "   Archivo cifrado: cifrado_rc4.bin (Tamaño: $TAMANO_RC4 bytes)"
echo "   Descifrado:"
openssl enc -rc4 -d -pbkdf2 -in "$SALIDA/cifrado_rc4.bin" -out "$SALIDA/descifrado_rc4.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_rc4.txt")"
echo ""

# 6. ChaCha20 (cifrador de flujo)
echo "6. ChaCha20 (cifrador de flujo moderno):"
openssl enc -chacha20 -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_chacha20.bin" -pass pass:"$PASSWORD"
TAMANO_CHACHA20=$(wc -c < "$SALIDA/cifrado_chacha20.bin")
echo "   Archivo cifrado: cifrado_chacha20.bin (Tamaño: $TAMANO_CHACHA20 bytes)"
echo "   Descifrado:"
openssl enc -chacha20 -d -pbkdf2 -in "$SALIDA/cifrado_chacha20.bin" -out "$SALIDA/descifrado_chacha20.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_chacha20.txt")"
echo ""

# 7. AES-256-GCM (modo autenticado)
echo "7. AES-256-GCM (modo autenticado):"
openssl enc -aes-256-gcm -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_aes256gcm.bin" -pass pass:"$PASSWORD"
TAMANO_GCM=$(wc -c < "$SALIDA/cifrado_aes256gcm.bin")
echo "   Archivo cifrado: cifrado_aes256gcm.bin (Tamaño: $TAMANO_GCM bytes)"
echo "   Descifrado:"
openssl enc -aes-256-gcm -d -pbkdf2 -in "$SALIDA/cifrado_aes256gcm.bin" -out "$SALIDA/descifrado_aes256gcm.txt" -pass pass:"$PASSWORD"
echo "   Resultado: $(cat "$SALIDA/descifrado_aes256gcm.txt")"
echo ""

# Análisis de tamaños
echo -e "${GREEN}Análisis de tamaños de archivos cifrados:${NC}"
echo ""
TAMANO_ORIGINAL=$(wc -c < "$TEXTO_CIFRADO")
echo "Tamaño original: $TAMANO_ORIGINAL bytes"
echo ""
echo "Algoritmo            | Tamaño | Overhead | Tamaño bloque | Explicación"
echo "---------------------+--------+----------+---------------+----------------------------"
echo "AES-256-CBC          | $TAMANO_AES256    | $(($TAMANO_AES256 - $TAMANO_ORIGINAL))      | 16 bytes      | 16 (sal) + padding bloque"
echo "AES-128-CTR          | $TAMANO_AES128CTR    | $(($TAMANO_AES128CTR - $TAMANO_ORIGINAL))      | No aplica     | 16 (sal) + sin padding"
echo "3DES-CBC             | $TAMANO_3DES    | $(($TAMANO_3DES - $TAMANO_ORIGINAL))      | 8 bytes       | 16 (sal) + padding bloque"
echo "3DES-OFB             | $TAMANO_3DES_OFB    | $(($TAMANO_3DES_OFB - $TAMANO_ORIGINAL))      | No aplica     | 16 (sal) + sin padding"
echo "RC4                  | $TAMANO_RC4    | $(($TAMANO_RC4 - $TAMANO_ORIGINAL))      | No aplica     | 16 (sal) + sin padding"
echo "ChaCha20             | $TAMANO_CHACHA20    | $(($TAMANO_CHACHA20 - $TAMANO_ORIGINAL))      | No aplica     | 16 (sal) + sin padding"
echo "AES-256-GCM          | $TAMANO_GCM    | $(($TAMANO_GCM - $TAMANO_ORIGINAL))      | No aplica     | 16 (sal) + tag autenticación"
echo ""
echo -e "${BLUE}Nota: El prefijo 'Salted__' + 8 bytes de sal = 16 bytes de overhead${NC}"
echo ""

# Cifrado con contraseña y descifrado con clave/vector
echo -e "${GREEN}Cifrado con contraseña y descifrado con clave/IV:${NC}"
echo ""

echo "Cifrando con AES-256-CBC y mostrando clave/IV derivados (-p):"
openssl enc -aes-256-cbc -pbkdf2 -in "$TEXTO_CIFRADO" -out "$SALIDA/cifrado_con_sal.bin" -pass pass:"$PASSWORD" -p > "$SALIDA/clave_iv.txt" 2>&1
cat "$SALIDA/clave_iv.txt"
echo ""

# Extraer clave e IV del output
KEY=$(grep "key=" "$SALIDA/clave_iv.txt" | cut -d'=' -f2)
IV=$(grep "iv =" "$SALIDA/clave_iv.txt" | cut -d'=' -f2 | tr -d ' ')

echo "Eliminando los 16 bytes de sal del archivo cifrado:"
dd if="$SALIDA/cifrado_con_sal.bin" of="$SALIDA/cifrado_sin_sal.bin" bs=1 skip=16 2>/dev/null
echo "Archivo sin sal: cifrado_sin_sal.bin"
echo ""

echo "Descifrando con la clave y IV extraídos (sin contraseña):"
openssl enc -aes-256-cbc -d -in "$SALIDA/cifrado_sin_sal.bin" -out "$SALIDA/descifrado_con_clave_iv.txt" -K "$KEY" -iv "$IV"
echo "Resultado: $(cat "$SALIDA/descifrado_con_clave_iv.txt")"
echo ""

################################################################################
# 2.3 APLICACIÓN: DEMOSTRACIÓN DE LA PELIGROSIDAD DEL MODO ECB
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}2.3 Demostración de la peligrosidad del modo ECB${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}NOTA: Esta sección requiere:${NC}"
echo "  1. Una imagen de 20-50KB con colores sólidos en $ORIGINALES/"
echo "  2. ImageMagick instalado (comando 'convert')"
echo ""

# Buscar una imagen en ArchivosOriginales
IMAGEN_ORIGINAL=$(find "$ORIGINALES" -type f \( -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.jpg" \) 2>/dev/null | head -n 1)

if [ -z "$IMAGEN_ORIGINAL" ]; then
    echo -e "${YELLOW}⚠ No se encontró ninguna imagen en $ORIGINALES${NC}"
    echo "Para completar esta sección:"
    echo "  1. Coloca una imagen (PNG, GIF, etc.) de 20-50KB en $ORIGINALES/"
    echo "  2. Vuelve a ejecutar el script"
    echo ""
    echo "Ejemplo para crear una imagen de prueba con ImageMagick:"
    echo "  convert -size 200x200 xc:red -fill blue -draw 'rectangle 0,0 100,200' \\"
    echo "          -fill yellow -draw 'rectangle 100,100 200,200' $ORIGINALES/test_image.png"
    echo ""
else
    if ! command -v convert &> /dev/null; then
        echo -e "${RED}✗ ImageMagick no está instalado${NC}"
        echo "Instalar con: brew install imagemagick (macOS) o apt install imagemagick (Linux)"
        echo ""
    else
        echo -e "${GREEN}✓ Imagen encontrada: $(basename "$IMAGEN_ORIGINAL")${NC}"
        TAMANO_IMG=$(wc -c < "$IMAGEN_ORIGINAL")
        echo "  Tamaño: $TAMANO_IMG bytes"
        echo ""

        # Convertir a PGM
        echo "Paso 1: Convertir imagen a formato PGM..."
        convert "$IMAGEN_ORIGINAL" "$SALIDA/imagen.pgm"
        echo "  Creado: imagen.pgm"
        echo ""

        # Separar cabecera y cuerpo
        echo "Paso 2: Separar cabecera (3 líneas) y cuerpo de la imagen..."
        head -n 3 "$SALIDA/imagen.pgm" > "$SALIDA/imagen_cabecera.txt"
        tail -n +4 "$SALIDA/imagen.pgm" > "$SALIDA/imagen_cuerpo.bin"
        echo "  Cabecera guardada en: imagen_cabecera.txt"
        echo "  Cuerpo guardado en: imagen_cuerpo.bin"
        echo ""

        echo "Contenido de la cabecera:"
        cat "$SALIDA/imagen_cabecera.txt"
        echo ""

        # Cifrar con AES-256-ECB (sin sal)
        echo "Paso 3: Cifrar cuerpo con AES-256-ECB (sin sal)..."
        CLAVE_ECB="0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
        IV_ECB="00000000000000000000000000000000"
        openssl enc -aes-256-ecb -in "$SALIDA/imagen_cuerpo.bin" -out "$SALIDA/imagen_cuerpo_cifrado_ecb.bin" -K "$CLAVE_ECB" -nosalt
        echo "  Cuerpo cifrado: imagen_cuerpo_cifrado_ecb.bin"
        echo ""

        # Reconstruir imagen
        echo "Paso 4: Reconstruir imagen con cabecera original y cuerpo cifrado..."
        cat "$SALIDA/imagen_cabecera.txt" "$SALIDA/imagen_cuerpo_cifrado_ecb.bin" > "$SALIDA/imagen_cifrada_ecb.pgm"
        echo "  Imagen PGM cifrada: imagen_cifrada_ecb.pgm"
        echo ""

        # Convertir a formato original
        echo "Paso 5: Convertir imagen cifrada de vuelta al formato original..."
        convert "$SALIDA/imagen_cifrada_ecb.pgm" "$SALIDA/imagen_cifrada_ecb.png"
        echo "  Imagen final: imagen_cifrada_ecb.png"
        echo ""

        # Repetir con DES-ECB (64 bits de bloque)
        echo "Paso 6: Repetir proceso con DES-ECB (bloque de 64 bits)..."
        CLAVE_DES="0123456789ABCDEF"
        openssl enc -des-ecb -in "$SALIDA/imagen_cuerpo.bin" -out "$SALIDA/imagen_cuerpo_cifrado_des_ecb.bin" -K "$CLAVE_DES" -nosalt
        cat "$SALIDA/imagen_cabecera.txt" "$SALIDA/imagen_cuerpo_cifrado_des_ecb.bin" > "$SALIDA/imagen_cifrada_des_ecb.pgm"
        convert "$SALIDA/imagen_cifrada_des_ecb.pgm" "$SALIDA/imagen_cifrada_des_ecb.png" 2>/dev/null
        echo "  Imagen DES-ECB: imagen_cifrada_des_ecb.png"
        echo ""

        # Comparación con modo CBC (seguro)
        echo "Paso 7: Comparación con modo CBC (más seguro)..."
        openssl enc -aes-256-cbc -in "$SALIDA/imagen_cuerpo.bin" -out "$SALIDA/imagen_cuerpo_cifrado_cbc.bin" -K "$CLAVE_ECB" -iv "$IV_ECB" -nosalt
        cat "$SALIDA/imagen_cabecera.txt" "$SALIDA/imagen_cuerpo_cifrado_cbc.bin" > "$SALIDA/imagen_cifrada_cbc.pgm"
        convert "$SALIDA/imagen_cifrada_cbc.pgm" "$SALIDA/imagen_cifrada_cbc.png" 2>/dev/null
        echo "  Imagen CBC: imagen_cifrada_cbc.png"
        echo ""

        echo -e "${GREEN}✓ Proceso completado${NC}"
        echo ""
        echo -e "${BLUE}RESULTADOS:${NC}"
        echo "  - imagen_cifrada_ecb.png: Muestra patrones de la imagen original (INSEGURO)"
        echo "  - imagen_cifrada_des_ecb.png: Patrones más evidentes por bloque pequeño (64 bits)"
        echo "  - imagen_cifrada_cbc.png: No muestra patrones (SEGURO)"
        echo ""
        echo -e "${RED}¡El modo ECB revela la estructura de la imagen original!${NC}"
        echo ""
    fi
fi

################################################################################
# RESUMEN FINAL
################################################################################
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    PRÁCTICA COMPLETADA                        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Todos los archivos han sido generados en: $SALIDA"
echo ""
echo "Resumen de operaciones realizadas:"
echo "  ✓ Verificación de Provider Legacy"
echo "  ✓ 5 algoritmos de resumen aplicados"
echo "  ✓ 7 algoritmos de cifrado simétrico probados"
echo "  ✓ Cifrado/descifrado con clave y IV"
echo "  ✓ Demostración de peligrosidad del modo ECB"
echo ""
echo -e "${GREEN}¡Script finalizado exitosamente!${NC}"
echo ""
