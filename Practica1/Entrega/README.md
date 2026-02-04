Práctica 1 - Entrega

Descripción
- Script `practica1_script.sh` que realiza todas las operaciones solicitadas: comandos OpenSSL, generación y conversión Base64, creación de archivos con valores 00/FF, visualización en hexadecimal y octal, generación de un correo (.eml) con adjuntos y extracción con `ripmime`.

Archivos incluidos
- `practica1_script.sh` : script principal (bash).
- `make_email.py` : genera `message.eml` con adjuntos y opcionalmente lo envía.

Dependencias
- openssl
- coreutils (dd, base64)
- xxd, od
- python3
- ripmime (para extraer adjuntos desde .eml)
- sendmail (opcional, para enviar el correo)

Instrucciones rápidas
1. Abrir terminal en `Practica1/Entrega`.
2. Hacer ejecutable el script:

   chmod +x practica1_script.sh

3. (Opcional) exportar direcciones de correo:

   export RECIPIENT=tu@email
   export SENDER=mi@dominio

   Si no se exportan, `make_email.py` fallará al crear el .eml por falta de parámetros; puede ejecutarse manualmente:

   python3 make_email.py --to tu@email --from mi@dominio --image entrega_practica1/image.png --file entrega_practica1/doc.rtf --out entrega_practica1/message.eml

4. Ejecutar el script:

   ./practica1_script.sh

5. Si quieres enviar el correo vía sendmail (si está configurado):

   python3 make_email.py --to tu@correo --from yo@dominio --image entrega_practica1/image.png --file entrega_practica1/doc.rtf --out entrega_practica1/message.eml --send

6. Para extraer adjuntos desde `message.eml` use `ripmime`:

   ripmime -i entrega_practica1/message.eml -d salida

Notas
- `openssl speed` puede tardar varios segundos/minutos según la máquina.
- La creación del `.eml` y su envío dependen de que el sistema tenga `sendmail` configurado; alternativa: subir el `.eml` al cliente web y descargarlo desde la interfaz para inspección.
