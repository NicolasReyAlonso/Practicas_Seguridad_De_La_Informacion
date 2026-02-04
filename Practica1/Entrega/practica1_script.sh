#!/usr/bin/env bash
set -euo pipefail

# Script para la práctica 1 - seguridad de la información
# Requisitos: openssl, base64, xxd, od, python3, ripmime (opcional), sendmail (opcional)

OUTDIR="entrega_practica1"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Comandos básicos de OpenSSL
echo "== Comandos básicos OpenSSL =="
openssl version || true
openssl speed || true

# Crear archivos binarios aleatorios y convertir a Base64
echo "\n== Crear archivos binarios aleatorios =="
openssl rand -out rand8.bin 8
openssl rand -out rand256.bin 256

echo "== Convertir a Base64 y con openssl enc -a =="
base64 rand8.bin > rand8.base64
openssl enc -a -in rand8.bin -out rand8.openssl.b64

base64 -d rand8.base64 > rand8.base64.dec
openssl enc -d -a -in rand8.openssl.b64 -out rand8.openssl.dec

if cmp -s rand8.bin rand8.base64.dec && cmp -s rand8.bin rand8.openssl.dec; then
  echo "rand8: conversiones base64 consistentes"
else
  echo "rand8: ¡ERROR en conversiones base64!"
fi

base64 rand256.bin > rand256.base64
openssl enc -a -in rand256.bin -out rand256.openssl.b64
base64 -d rand256.base64 > rand256.base64.dec
openssl enc -d -a -in rand256.openssl.b64 -out rand256.openssl.dec

if cmp -s rand256.bin rand256.base64.dec && cmp -s rand256.bin rand256.openssl.dec; then
  echo "rand256: conversiones base64 consistentes"
else
  echo "rand256: ¡ERROR en conversiones base64!"
fi

echo "\n== Crear ficheros con valores fijos =="
# 16 bytes de 0x00
dd if=/dev/zero bs=1 count=16 of=zeros16.bin status=none
# 64 bytes de 0xFF
python3 - <<'PY'
open('ff64.bin','wb').write(b'\xff'*64)
PY

echo "\n== Visualización hexadecimal (xxd) =="
xxd zeros16.bin | sed -n '1,5p'
xxd ff64.bin | sed -n '1,5p'

echo "\n== Visualización octal (od) =="
od -An -t o1 -v zeros16.bin | sed -n '1,5p'
od -An -t o1 -v ff64.bin | sed -n '1,5p'

echo "\n== Generar imagen pequeña y documento RTF =="
# Imagen PNG 1x1 en base64
cat > image.png.b64 <<'B64'
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2P8z/C/HwAF/gL+2c9qAAAAAElFTkSuQmCC
B64
base64 -d image.png.b64 > image.png
rm image.png.b64

# Documento RTF simple (abre en Word)
cat > doc.rtf <<'RTF'
{\rtf1\ansi
{\fonttbl\f0\fswiss Helvetica;}\f0\fs24
Hola, esta es la práctica 1.\par
}
RTF

ls -l image.png doc.rtf

echo "\n== Crear mensaje .eml con adjuntos (message.eml) =="
# make_email.py se encarga de generar message.eml y opcionalmente enviarlo
if command -v python3 >/dev/null 2>&1; then
  python3 ../make_email.py --to "$RECIPIENT" --from "$SENDER" --image image.png --file doc.rtf --out message.eml || true
else
  echo "python3 no encontrado: no se puede crear .eml automáticamente"
fi

echo "\n== Extraer adjuntos con ripmime =="
if command -v ripmime >/dev/null 2>&1; then
  mkdir -p rip_out
  ripmime -i message.eml -d rip_out || true
  echo "ficheros extraídos en rip_out/"
  echo "Comparando adjuntos extraídos con originales..."
  for f in image.png doc.rtf; do
    if [ -f "rip_out/$f" ]; then
      if cmp -s "$f" "rip_out/$f"; then
        echo "$f: OK"
      else
        echo "$f: DIFERENTE"
      fi
    else
      echo "$f: no extraído"
    fi
  done
else
  echo "ripmime no instalado; instale 'ripmime' para extraer adjuntos" >&2
fi

echo "\n== Fin del script =="

# Notas de uso imprimibles
cat <<USAGE

Uso:
  Antes de ejecutar exporta las variables de entorno (opcional):
    export RECIPIENT=tu@email
    export SENDER=mi@dominio
  Hacer ejecutable y ejecutar:
    chmod +x practica1_script.sh
    ./practica1_script.sh

USAGE
