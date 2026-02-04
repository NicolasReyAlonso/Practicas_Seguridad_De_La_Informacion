#!/usr/bin/env python3
"""Genera un archivo .eml con adjuntos (imagen y fichero). Opcionalmente envía vía sendmail.
Uso mínimo:
  python3 make_email.py --to destino@example.com --from remitente@example.com --image image.png --file doc.rtf --out message.eml
"""
import argparse
import sys
from email.message import EmailMessage
from email import policy

parser = argparse.ArgumentParser()
parser.add_argument('--to', required=True)
parser.add_argument('--from', dest='sender', required=True)
parser.add_argument('--image', required=True)
parser.add_argument('--file', required=True)
parser.add_argument('--out', default='message.eml')
parser.add_argument('--send', action='store_true', help='Enviar usando sendmail (si está disponible)')
args = parser.parse_args()

msg = EmailMessage(policy=policy.SMTP)
msg['Subject'] = 'Práctica 1 - envío de prueba'
msg['From'] = args.sender
msg['To'] = args.to
msg.set_content('Mensaje de prueba con adjuntos (imagen y documento).')

# Adjuntar imagen
with open(args.image, 'rb') as f:
    img_data = f.read()
msg.add_attachment(img_data, maintype='image', subtype='png', filename='image.png')

# Adjuntar fichero RTF
with open(args.file, 'rb') as f:
    doc_data = f.read()
msg.add_attachment(doc_data, maintype='application', subtype='rtf', filename='doc.rtf')

# Guardar .eml
with open(args.out, 'wb') as f:
    f.write(bytes(msg))
print(f'Wrote {args.out}')

if args.send:
    import subprocess
    try:
        p = subprocess.Popen(['/usr/sbin/sendmail', '-t', '-oi'], stdin=subprocess.PIPE)
        p.communicate(bytes(msg))
        if p.returncode == 0:
            print('Mensaje enviado vía sendmail')
        else:
            print('sendmail devolvió código', p.returncode)
    except FileNotFoundError:
        print('sendmail no encontrado; no se envió el mensaje', file=sys.stderr)
