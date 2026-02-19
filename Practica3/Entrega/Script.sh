#!/bin/bash

################################################################################
# Práctica 3: Algoritmos de cifrado asimétrico
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
echo -e "${BLUE}║  Práctica 3: Algoritmos de cifrado asimétrico                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# PREVIO: Verificación de OpenSSL
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PREVIO: Verificación de OpenSSL${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Versión de OpenSSL instalada:"
openssl version
echo ""

echo "Providers activos:"
openssl list -providers
echo ""

################################################################################
# 3.1 GENERACIÓN DE CLAVES ASIMÉTRICAS, FIRMA DE RESÚMENES Y DERIVACIÓN DH
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}3.1 Generación de claves asimétricas, firma y derivación DH${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# RSA: Generación de claves
# ============================================================================
echo -e "${GREEN}── RSA: Generación de claves ──${NC}"
echo ""

RSA_PASS="rsapassword123"

# Generar par de claves RSA de 2048 bits con contraseña
echo "1. Generando par de claves RSA de 2048 bits (PEM con contraseña)..."
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
    -aes-256-cbc -pass pass:"$RSA_PASS" \
    -out "$SALIDA/rsa_privkey.pem"
echo "   Clave privada guardada en: rsa_privkey.pem"
echo ""

echo "   Contenido de la clave privada (cifrada con contraseña):"
head -5 "$SALIDA/rsa_privkey.pem"
echo "   ..."
echo ""

# Exportar clave pública
echo "2. Exportando clave pública RSA..."
openssl pkey -in "$SALIDA/rsa_privkey.pem" -passin pass:"$RSA_PASS" \
    -pubout -out "$SALIDA/rsa_pubkey.pem"
echo "   Clave pública guardada en: rsa_pubkey.pem"
echo ""

echo "   Contenido de la clave pública:"
cat "$SALIDA/rsa_pubkey.pem"
echo ""

# Exportar clave privada a DER y de vuelta a PEM
echo "3. Exportando clave privada RSA a formato DER (binario)..."
openssl pkey -in "$SALIDA/rsa_privkey.pem" -passin pass:"$RSA_PASS" \
    -outform DER -out "$SALIDA/rsa_privkey.der"
echo "   Clave privada DER guardada en: rsa_privkey.der"
echo "   Tamaño DER: $(wc -c < "$SALIDA/rsa_privkey.der") bytes"
echo ""

echo "   Convirtiendo DER de vuelta a PEM (sin contraseña)..."
openssl pkey -in "$SALIDA/rsa_privkey.der" -inform DER \
    -out "$SALIDA/rsa_privkey_from_der.pem"
echo "   Clave PEM (sin protección) guardada en: rsa_privkey_from_der.pem"
echo ""

echo -e "${BLUE}   Comparación de cabeceras:${NC}"
echo "   Original (con contraseña):"
head -2 "$SALIDA/rsa_privkey.pem"
echo "   Desde DER (sin contraseña):"
head -2 "$SALIDA/rsa_privkey_from_der.pem"
echo ""
echo -e "${RED}   ⚠ La conversión a DER elimina la protección con contraseña de la clave privada${NC}"
echo ""

# RSA: Firma y verificación
echo -e "${GREEN}── RSA: Firma y verificación de resumen SHA-256 ──${NC}"
echo ""

echo "4. Firmando resumen SHA-256 del fichero de texto con clave privada RSA..."
# Crear resumen SHA-256 en binario
openssl dgst -sha256 -binary -out "$SALIDA/rsa_digest.bin" "$TEXTO"
echo "   Resumen SHA-256 binario guardado en: rsa_digest.bin"

# Firmar el resumen con la clave privada RSA
openssl pkeyutl -sign -in "$SALIDA/rsa_digest.bin" \
    -inkey "$SALIDA/rsa_privkey.pem" -passin pass:"$RSA_PASS" \
    -out "$SALIDA/rsa_firma.bin"
echo "   Firma guardada en: rsa_firma.bin"
echo "   Tamaño de la firma: $(wc -c < "$SALIDA/rsa_firma.bin") bytes"
echo ""

echo "   Verificando la firma con clave pública RSA..."
openssl pkeyutl -verify -in "$SALIDA/rsa_digest.bin" \
    -sigfile "$SALIDA/rsa_firma.bin" \
    -pubin -inkey "$SALIDA/rsa_pubkey.pem"
echo ""

# ============================================================================
# DSA: Generación de claves
# ============================================================================
echo -e "${GREEN}── DSA: Generación de claves ──${NC}"
echo ""

DSA_PASS="dsapassword123"

# Generar parámetros DSA
echo "5. Generando parámetros DSA de 2048 bits..."
openssl genpkey -genparam -algorithm DSA -pkeyopt dsa_paramgen_bits:2048 \
    -out "$SALIDA/dsa_params.pem"
echo "   Parámetros DSA guardados en: dsa_params.pem"
echo ""

# Generar par de claves DSA con contraseña
echo "6. Generando par de claves DSA con contraseña..."
openssl genpkey -paramfile "$SALIDA/dsa_params.pem" \
    -aes-256-cbc -pass pass:"$DSA_PASS" \
    -out "$SALIDA/dsa_privkey.pem"
echo "   Clave privada DSA guardada en: dsa_privkey.pem"
echo ""

# Exportar clave pública DSA
echo "7. Exportando clave pública DSA..."
openssl pkey -in "$SALIDA/dsa_privkey.pem" -passin pass:"$DSA_PASS" \
    -pubout -out "$SALIDA/dsa_pubkey.pem"
echo "   Clave pública DSA guardada en: dsa_pubkey.pem"
echo ""

echo "   Contenido de la clave pública DSA:"
cat "$SALIDA/dsa_pubkey.pem"
echo ""

# Exportar clave privada DSA a DER y de vuelta a PEM
echo "8. Exportando clave privada DSA a formato DER..."
openssl pkey -in "$SALIDA/dsa_privkey.pem" -passin pass:"$DSA_PASS" \
    -outform DER -out "$SALIDA/dsa_privkey.der"
echo "   Clave privada DSA DER: dsa_privkey.der"
echo "   Tamaño DER: $(wc -c < "$SALIDA/dsa_privkey.der") bytes"
echo ""

echo "   Convirtiendo DER de vuelta a PEM (sin contraseña)..."
openssl pkey -in "$SALIDA/dsa_privkey.der" -inform DER \
    -out "$SALIDA/dsa_privkey_from_der.pem"
echo "   Clave PEM (sin protección): dsa_privkey_from_der.pem"
echo ""

echo -e "${BLUE}   Comparación de cabeceras:${NC}"
echo "   Original (con contraseña):"
head -2 "$SALIDA/dsa_privkey.pem"
echo "   Desde DER (sin contraseña):"
head -2 "$SALIDA/dsa_privkey_from_der.pem"
echo ""
echo -e "${RED}   ⚠ La conversión a DER también elimina la protección en DSA${NC}"
echo ""

# DSA: Firma y verificación
echo -e "${GREEN}── DSA: Firma y verificación de resumen SHA-256 ──${NC}"
echo ""

echo "9. Firmando resumen SHA-256 del fichero de texto con clave privada DSA..."
openssl dgst -sha256 -binary -out "$SALIDA/dsa_digest.bin" "$TEXTO"
echo "   Resumen SHA-256 binario guardado en: dsa_digest.bin"

# Firmar con DSA usando pkeyutl
openssl pkeyutl -sign -in "$SALIDA/dsa_digest.bin" \
    -inkey "$SALIDA/dsa_privkey.pem" -passin pass:"$DSA_PASS" \
    -out "$SALIDA/dsa_firma.bin"
echo "   Firma DSA guardada en: dsa_firma.bin"
echo "   Tamaño de la firma DSA: $(wc -c < "$SALIDA/dsa_firma.bin") bytes"
echo ""

echo "   Verificando la firma DSA con clave pública..."
openssl pkeyutl -verify -in "$SALIDA/dsa_digest.bin" \
    -sigfile "$SALIDA/dsa_firma.bin" \
    -pubin -inkey "$SALIDA/dsa_pubkey.pem"
echo ""

# ============================================================================
# DH: Derivación de secretos compartidos (Diffie-Hellman estándar)
# ============================================================================
echo -e "${GREEN}── DH: Derivación de secretos compartidos (Diffie-Hellman) ──${NC}"
echo ""

echo "10. Generando parámetros DH..."
openssl genpkey -genparam -algorithm DH -pkeyopt dh_paramgen_prime_len:2048 \
    -out "$SALIDA/dh_params.pem"
echo "    Parámetros DH guardados en: dh_params.pem"
echo ""

echo "11. Generando par de claves DH #1..."
openssl genpkey -paramfile "$SALIDA/dh_params.pem" \
    -out "$SALIDA/dh_privkey1.pem"
openssl pkey -in "$SALIDA/dh_privkey1.pem" -pubout -out "$SALIDA/dh_pubkey1.pem"
echo "    Clave privada DH 1: dh_privkey1.pem"
echo "    Clave pública DH 1: dh_pubkey1.pem"
echo ""

echo "12. Generando par de claves DH #2 (con los mismos parámetros)..."
openssl genpkey -paramfile "$SALIDA/dh_params.pem" \
    -out "$SALIDA/dh_privkey2.pem"
openssl pkey -in "$SALIDA/dh_privkey2.pem" -pubout -out "$SALIDA/dh_pubkey2.pem"
echo "    Clave privada DH 2: dh_privkey2.pem"
echo "    Clave pública DH 2: dh_pubkey2.pem"
echo ""

echo "13. Derivando secretos compartidos DH..."
echo ""

# Secreto 1: privada1 + pública2
openssl pkeyutl -derive -inkey "$SALIDA/dh_privkey1.pem" \
    -peerkey "$SALIDA/dh_pubkey2.pem" -out "$SALIDA/dh_secreto1.bin"
echo "    Secreto (privada1 + pública2):"
xxd -p "$SALIDA/dh_secreto1.bin" | head -3
echo "    ..."
echo ""

# Secreto 2: privada2 + pública1
openssl pkeyutl -derive -inkey "$SALIDA/dh_privkey2.pem" \
    -peerkey "$SALIDA/dh_pubkey1.pem" -out "$SALIDA/dh_secreto2.bin"
echo "    Secreto (privada2 + pública1):"
xxd -p "$SALIDA/dh_secreto2.bin" | head -3
echo "    ..."
echo ""

# Comparar secretos
echo "    Comparando ambos secretos DH..."
if diff "$SALIDA/dh_secreto1.bin" "$SALIDA/dh_secreto2.bin" > /dev/null 2>&1; then
    echo -e "    ${GREEN}✓ Los secretos DH son IDÉNTICOS${NC}"
else
    echo -e "    ${RED}✗ Los secretos DH son DIFERENTES (error)${NC}"
fi
echo "    Tamaño del secreto DH: $(wc -c < "$SALIDA/dh_secreto1.bin") bytes"
echo ""

# ============================================================================
# ECDH X25519: Derivación de secretos compartidos (curva elíptica)
# ============================================================================
echo -e "${GREEN}── ECDH X25519: Derivación de secretos compartidos ──${NC}"
echo ""

echo "14. Generando par de claves X25519 #1..."
openssl genpkey -algorithm X25519 -out "$SALIDA/x25519_privkey1.pem"
openssl pkey -in "$SALIDA/x25519_privkey1.pem" -pubout -out "$SALIDA/x25519_pubkey1.pem"
echo "    Clave privada X25519 1: x25519_privkey1.pem"
echo "    Clave pública X25519 1: x25519_pubkey1.pem"
echo ""

echo "15. Generando par de claves X25519 #2..."
openssl genpkey -algorithm X25519 -out "$SALIDA/x25519_privkey2.pem"
openssl pkey -in "$SALIDA/x25519_privkey2.pem" -pubout -out "$SALIDA/x25519_pubkey2.pem"
echo "    Clave privada X25519 2: x25519_privkey2.pem"
echo "    Clave pública X25519 2: x25519_pubkey2.pem"
echo ""

echo "16. Derivando secretos compartidos X25519..."
echo ""

# Secreto 1: privada1 + pública2
openssl pkeyutl -derive -inkey "$SALIDA/x25519_privkey1.pem" \
    -peerkey "$SALIDA/x25519_pubkey2.pem" -out "$SALIDA/x25519_secreto1.bin"
echo "    Secreto (privada1 + pública2):"
xxd -p "$SALIDA/x25519_secreto1.bin"
echo ""

# Secreto 2: privada2 + pública1
openssl pkeyutl -derive -inkey "$SALIDA/x25519_privkey2.pem" \
    -peerkey "$SALIDA/x25519_pubkey1.pem" -out "$SALIDA/x25519_secreto2.bin"
echo "    Secreto (privada2 + pública1):"
xxd -p "$SALIDA/x25519_secreto2.bin"
echo ""

# Comparar secretos
echo "    Comparando ambos secretos X25519..."
if diff "$SALIDA/x25519_secreto1.bin" "$SALIDA/x25519_secreto2.bin" > /dev/null 2>&1; then
    echo -e "    ${GREEN}✓ Los secretos X25519 son IDÉNTICOS${NC}"
else
    echo -e "    ${RED}✗ Los secretos X25519 son DIFERENTES (error)${NC}"
fi
echo "    Tamaño del secreto X25519: $(wc -c < "$SALIDA/x25519_secreto1.bin") bytes"
echo ""

# ============================================================================
# Comparación de tamaños de secretos DH vs X25519
# ============================================================================
echo -e "${GREEN}── Comparación de tamaños: DH vs X25519 ──${NC}"
echo ""

TAMANO_DH=$(wc -c < "$SALIDA/dh_secreto1.bin")
TAMANO_X25519=$(wc -c < "$SALIDA/x25519_secreto1.bin")

echo "   Secreto DH estándar:  $TAMANO_DH bytes ($((TAMANO_DH * 8)) bits)"
echo "   Secreto X25519:       $TAMANO_X25519 bytes ($((TAMANO_X25519 * 8)) bits)"
echo ""
echo -e "${BLUE}   Nota: X25519 logra seguridad comparable con claves mucho más pequeñas${NC}"
echo -e "${BLUE}   gracias a las propiedades de las curvas elípticas.${NC}"
echo ""

################################################################################
# 3.2 INTERCAMBIO DE INFORMACIÓN SEGURA
################################################################################
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}3.2 Intercambio de información segura (Ana y Berto)${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# Generación de claves para Ana y Berto
# ============================================================================
echo -e "${GREEN}── Generación de claves RSA para Ana y Berto ──${NC}"
echo ""

ANA_PASS="anak"
BERTO_PASS="bertok"

echo "17. Generando claves RSA 2048 bits para Ana..."
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
    -aes-256-cbc -pass pass:"$ANA_PASS" \
    -out "$SALIDA/anapriv.pem"
openssl pkey -in "$SALIDA/anapriv.pem" -passin pass:"$ANA_PASS" \
    -pubout -out "$SALIDA/anapub.pem"
echo "    Clave privada Ana: anapriv.pem (protegida con contraseña '$ANA_PASS')"
echo "    Clave pública Ana: anapub.pem"
echo ""

echo "18. Generando claves RSA 2048 bits para Berto..."
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
    -aes-256-cbc -pass pass:"$BERTO_PASS" \
    -out "$SALIDA/bertopriv.pem"
openssl pkey -in "$SALIDA/bertopriv.pem" -passin pass:"$BERTO_PASS" \
    -pubout -out "$SALIDA/bertopub.pem"
echo "    Clave privada Berto: bertopriv.pem (protegida con contraseña '$BERTO_PASS')"
echo "    Clave pública Berto: bertopub.pem"
echo ""

echo -e "${BLUE}   Ana y Berto intercambian sus claves públicas.${NC}"
echo ""

# ============================================================================
# Trabajo de Ana: cifrar, proteger claves y firmar
# ============================================================================
echo -e "${GREEN}── Trabajo de ANA: Cifrado, protección de claves y firma ──${NC}"
echo ""

# Clave AES-256 (32 bytes = 64 hex) y IV (16 bytes = 32 hex) escogidos
ANA_KEY="A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6A7B8C9D0E1F2A3B4C5D6A7B8C9D0E1F2"
ANA_IV="0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D"

# Copiar el texto original como texto.txt (nombre requerido por el enunciado)
cp "$TEXTO" "$SALIDA/texto.txt"

echo "19. Cifrando texto.txt con AES-256-CBC (clave+IV sin sal, salida BASE64)..."
echo "    Clave: $ANA_KEY"
echo "    IV:    $ANA_IV"
openssl enc -aes-256-cbc -in "$SALIDA/texto.txt" \
    -out "$SALIDA/cifrado.txt" \
    -K "$ANA_KEY" -iv "$ANA_IV" -nosalt -a
echo "    Fichero cifrado: cifrado.txt (BASE64)"
echo "    Contenido cifrado:"
cat "$SALIDA/cifrado.txt"
echo ""

# Crear claves.hex con la concatenación de clave + IV
echo "20. Creando claves.hex con la concatenación de clave e IV..."
echo "${ANA_KEY}${ANA_IV}" > "$SALIDA/claves.hex"
echo "    Contenido de claves.hex:"
cat "$SALIDA/claves.hex"
echo ""

# Cifrar claves.hex con la clave pública de Berto (salida binaria)
echo "21. Cifrando claves.hex con la clave pública de Berto..."
openssl pkeyutl -encrypt -in "$SALIDA/claves.hex" \
    -pubin -inkey "$SALIDA/bertopub.pem" \
    -out "$SALIDA/claves.bin"
echo "    Fichero cifrado binario: claves.bin"
echo "    Tamaño: $(wc -c < "$SALIDA/claves.bin") bytes"
echo ""

# Convertir claves.bin a claves.txt en BASE64
echo "22. Convirtiendo claves.bin a claves.txt en formato BASE64..."
openssl enc -a -in "$SALIDA/claves.bin" -out "$SALIDA/claves.txt"
echo "    Fichero BASE64: claves.txt"
echo "    Contenido:"
cat "$SALIDA/claves.txt"
echo ""

# Obtener resumen SHA-256 del texto original y firmarlo
echo "23. Obteniendo resumen SHA-256 del texto original..."
openssl dgst -sha256 -binary -out "$SALIDA/resumen.bin" "$SALIDA/texto.txt"
echo "    Resumen SHA-256 binario: resumen.bin"
echo "    Tamaño: $(wc -c < "$SALIDA/resumen.bin") bytes"
echo ""

echo "24. Firmando el resumen con la clave privada de Ana..."
openssl pkeyutl -sign -in "$SALIDA/resumen.bin" \
    -inkey "$SALIDA/anapriv.pem" -passin pass:"$ANA_PASS" \
    -out "$SALIDA/firma.bin"
# Convertir firma a BASE64
openssl enc -a -in "$SALIDA/firma.bin" -out "$SALIDA/firma.txt"
echo "    Firma digital (BASE64): firma.txt"
echo "    Contenido:"
cat "$SALIDA/firma.txt"
echo ""

echo -e "${BLUE}   ═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Ana envía a Berto los tres ficheros:${NC}"
echo -e "${BLUE}     1. cifrado.txt  (texto cifrado con AES-256-CBC en BASE64)${NC}"
echo -e "${BLUE}     2. claves.txt   (clave+IV cifrados con RSA en BASE64)${NC}"
echo -e "${BLUE}     3. firma.txt    (firma digital SHA-256+RSA en BASE64)${NC}"
echo -e "${BLUE}   Meta-información: AES-256-CBC, clave=64hex + IV=32hex${NC}"
echo -e "${BLUE}   ═══════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# Trabajo de Berto: descifrar, verificar firma
# ============================================================================
echo -e "${GREEN}── Trabajo de BERTO: Descifrado y verificación ──${NC}"
echo ""

# Convertir claves.txt a binario
echo "25. Convirtiendo claves.txt a binario claves2.bin..."
openssl enc -a -d -in "$SALIDA/claves.txt" -out "$SALIDA/claves2.bin"
echo "    Fichero binario: claves2.bin"
echo "    Tamaño: $(wc -c < "$SALIDA/claves2.bin") bytes"
echo ""

# Descifrar claves2.bin con la clave privada de Berto
echo "26. Descifrando claves2.bin con la clave privada de Berto..."
openssl pkeyutl -decrypt -in "$SALIDA/claves2.bin" \
    -inkey "$SALIDA/bertopriv.pem" -passin pass:"$BERTO_PASS" \
    -out "$SALIDA/claves2.hex"
echo "    Fichero descifrado: claves2.hex"
echo "    Contenido de claves2.hex:"
cat "$SALIDA/claves2.hex"
echo ""

# Comparar claves.hex y claves2.hex
echo "    Comparando claves.hex y claves2.hex..."
if diff "$SALIDA/claves.hex" "$SALIDA/claves2.hex" > /dev/null 2>&1; then
    echo -e "    ${GREEN}✓ claves.hex y claves2.hex son IDÉNTICOS${NC}"
else
    echo -e "    ${RED}✗ claves.hex y claves2.hex son DIFERENTES${NC}"
fi
echo ""

# Extraer clave y vector de claves2.hex
echo "27. Extrayendo clave y IV de claves2.hex..."
CLAVES2_CONTENIDO=$(cat "$SALIDA/claves2.hex" | tr -d '\n')
# Clave AES-256 = 64 caracteres hex, IV = 32 caracteres hex
BERTO_KEY="${CLAVES2_CONTENIDO:0:64}"
BERTO_IV="${CLAVES2_CONTENIDO:64:32}"
echo "    Clave extraída: $BERTO_KEY"
echo "    IV extraído:    $BERTO_IV"
echo ""

# Descifrar cifrado.txt con la clave y vector obtenidos
echo "28. Descifrando cifrado.txt con la clave y IV obtenidos..."
openssl enc -aes-256-cbc -d -in "$SALIDA/cifrado.txt" \
    -out "$SALIDA/mensaje2.txt" \
    -K "$BERTO_KEY" -iv "$BERTO_IV" -nosalt -a
echo "    Fichero descifrado: mensaje2.txt"
echo "    Contenido:"
cat "$SALIDA/mensaje2.txt"
echo ""

# Comparar texto original y mensaje descifrado
echo "    Comparando texto.txt y mensaje2.txt..."
if diff "$SALIDA/texto.txt" "$SALIDA/mensaje2.txt" > /dev/null 2>&1; then
    echo -e "    ${GREEN}✓ El mensaje descifrado es IDÉNTICO al original${NC}"
else
    echo -e "    ${RED}✗ El mensaje descifrado es DIFERENTE al original${NC}"
fi
echo ""

# Verificación de la firma
echo -e "${GREEN}── Verificación de la firma digital ──${NC}"
echo ""

echo "29. Verificando la firma de Ana..."
echo ""

# Convertir firma.txt a binario
echo "    Convirtiendo firma.txt a binario firma2.bin..."
openssl enc -a -d -in "$SALIDA/firma.txt" -out "$SALIDA/firma2.bin"
echo "    Fichero binario: firma2.bin"
echo ""

# Descifrar la firma con la clave pública de Ana (recuperar el resumen)
echo "    Descifrando firma con clave pública de Ana (-verifyrecover)..."
openssl pkeyutl -verifyrecover -in "$SALIDA/firma2.bin" \
    -pubin -inkey "$SALIDA/anapub.pem" \
    -out "$SALIDA/resumen_ana.bin"
echo "    Resumen recuperado de la firma de Ana: resumen_ana.bin"
echo "    Hash de Ana (hex):"
xxd -p "$SALIDA/resumen_ana.bin" | tr -d '\n'
echo ""
echo ""

# Calcular resumen SHA-256 del mensaje descifrado por Berto
echo "    Calculando resumen SHA-256 de mensaje2.txt..."
openssl dgst -sha256 -binary -out "$SALIDA/resumen_berto.bin" "$SALIDA/mensaje2.txt"
echo "    Resumen calculado por Berto: resumen_berto.bin"
echo "    Hash de Berto (hex):"
xxd -p "$SALIDA/resumen_berto.bin" | tr -d '\n'
echo ""
echo ""

# Comparar ambos resúmenes
echo "    Comparando resúmenes (Ana vs Berto)..."
if diff "$SALIDA/resumen_ana.bin" "$SALIDA/resumen_berto.bin" > /dev/null 2>&1; then
    echo -e "    ${GREEN}✓ Los resúmenes COINCIDEN: Firma verificada correctamente${NC}"
    echo -e "    ${GREEN}  → Integridad del mensaje CONFIRMADA${NC}"
    echo -e "    ${GREEN}  → Autenticidad del remitente (Ana) CONFIRMADA${NC}"
else
    echo -e "    ${RED}✗ Los resúmenes NO coinciden: Firma inválida${NC}"
fi
echo ""

################################################################################
# RESUMEN FINAL
################################################################################
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    PRÁCTICA 3 COMPLETADA                      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Todos los archivos han sido generados en: $SALIDA"
echo ""
echo "Resumen de operaciones realizadas:"
echo "  ✓ Generación de claves RSA (2048 bits) con contraseña"
echo "  ✓ Exportación de claves RSA (pública, DER, PEM)"
echo "  ✓ Firma y verificación RSA con SHA-256"
echo "  ✓ Generación de claves DSA con contraseña"
echo "  ✓ Exportación de claves DSA (pública, DER, PEM)"
echo "  ✓ Firma y verificación DSA con SHA-256"
echo "  ✓ Derivación de secretos DH (Diffie-Hellman estándar)"
echo "  ✓ Derivación de secretos ECDH X25519 (curva elíptica)"
echo "  ✓ Comparación de tamaños DH vs X25519"
echo "  ✓ Intercambio seguro de información (Ana → Berto)"
echo "  ✓ Cifrado simétrico AES-256-CBC del texto"
echo "  ✓ Cifrado asimétrico RSA de las claves simétricas"
echo "  ✓ Firma digital SHA-256 + RSA del documento"
echo "  ✓ Descifrado y verificación por Berto"
echo ""
echo -e "${GREEN}¡Script finalizado exitosamente!${NC}"
echo ""
