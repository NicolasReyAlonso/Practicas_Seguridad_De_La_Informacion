# Práctica 1 - Entrega

## Descripción
Este directorio contiene la entrega de la Práctica 1.
El script principal `practica1_script.sh` realiza las siguientes actividades obligatorias:

1. Ejecución de comandos básicos de OpenSSL (`version`, `speed`).
2. Creación de archivos binarios aleatorios (8 y 256 bytes).
3. Conversión de binario a Base64 y viceversa, con verificación.
4. Creación de archivos con patrones específicos (0x00 y 0xFF).
5. Visualización de archivos en hexadecimal y octal.
6. Procesamiento de un archivo de correo `.eml` existente para extraer adjuntos usando `ripmime`.

## Estructura
- `practica1_script.sh`: Script Bash que automatiza la tarea.
- `../ArchivosOriginales/Correoeml.eml`: Archivo de correo utilizado para la extracción de adjuntos.
- `../Salidas/`: Directorio donde se generarán todos los archivos resultantes.

## Requisitos previos
El script requiere la herramienta `ripmime` para la parte de extracción de correo.
Instalación en sistemas basados en Debian/Ubuntu (Kali):

```bash
sudo apt update
sudo apt install ripmime
```

## Instrucciones de ejecución

1. Dar permisos de ejecución al script (si aún no los tiene):
   ```bash
   chmod +x practica1_script.sh
   ```

2. Ejecutar el script:
   ```bash
   ./practica1_script.sh
   ```

3. Verificar los resultados en la carpeta `../Salidas/` y `../Salidas/Adjuntos/`.

## Notas
- La prueba de `openssl speed` puede tardar mucho tiempo si se ejecuta completa. El script ejecuta una versión reducida (`rsa` y `md5`) como demostración.
- La comparación de archivos adjuntos extraídos requiere poseer los archivos originales fuera del correo. El script realiza la extracción correctamente en la carpeta de salidas.
