import { Component, signal, computed } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-root',
  imports: [FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  /* ── Caesar Cipher Demo ── */
  caesarInput = signal('Hola Mundo');
  caesarShift = signal(3);
  caesarOutput = computed(() => this.caesarCipher(this.caesarInput(), this.caesarShift()));

  /* ── Hash Demo ── */
  hashInput = signal('Seguridad');
  hashOutput = signal('');

  /* ── Nav state ── */
  mobileMenuOpen = signal(false);

  /* ── Sections ── */
  sections = [
    { id: 'inicio', label: 'Inicio' },
    { id: 'temas', label: 'Temas' },
    { id: 'cifrado-simetrico', label: 'Simétrico' },
    { id: 'cifrado-asimetrico', label: 'Asimétrico' },
    { id: 'hash', label: 'Hash' },
    { id: 'demo', label: 'Demo' },
  ];

  topics = [
    {
      icon: '🔐',
      title: 'Cifrado Simétrico',
      desc: 'Una única clave secreta compartida entre emisor y receptor para cifrar y descifrar.',
      algorithms: ['AES', '3DES', 'ChaCha20', 'RC4'],
      color: 'cyan',
    },
    {
      icon: '🔑',
      title: 'Cifrado Asimétrico',
      desc: 'Un par de claves (pública y privada) que permite comunicación segura sin compartir secretos.',
      algorithms: ['RSA', 'DSA', 'ECDSA', 'Ed25519'],
      color: 'purple',
    },
    {
      icon: '🧬',
      title: 'Funciones Hash',
      desc: 'Funciones unidireccionales que generan una huella digital única de longitud fija.',
      algorithms: ['SHA-256', 'SHA-512', 'MD5', 'Whirlpool'],
      color: 'gold',
    },
    {
      icon: '📜',
      title: 'Certificados Digitales',
      desc: 'Documentos electrónicos que vinculan una clave pública con la identidad de su propietario.',
      algorithms: ['X.509', 'S/MIME', 'PGP', 'TLS'],
      color: 'pink',
    },
    {
      icon: '✍️',
      title: 'Firma Digital',
      desc: 'Mecanismo criptográfico que garantiza autenticidad, integridad y no repudio.',
      algorithms: ['RSA-PSS', 'ECDSA', 'EdDSA', 'DSA'],
      color: 'blue',
    },
    {
      icon: '🛡️',
      title: 'Protocolos Seguros',
      desc: 'Protocolos de red que aseguran confidencialidad e integridad en las comunicaciones.',
      algorithms: ['TLS 1.3', 'SSH', 'IPsec', 'WireGuard'],
      color: 'cyan',
    },
  ];

  symmetricAlgorithms = [
    {
      name: 'AES',
      fullName: 'Advanced Encryption Standard',
      keySize: '128 / 192 / 256 bits',
      blockSize: '128 bits',
      modes: ['ECB', 'CBC', 'CTR', 'GCM'],
      security: 'Muy alta',
      desc: 'Estándar actual adoptado por NIST. Usado mundialmente para proteger datos en reposo y en tránsito.',
    },
    {
      name: '3DES',
      fullName: 'Triple DES',
      keySize: '168 bits (efectivos 112)',
      blockSize: '64 bits',
      modes: ['ECB', 'CBC', 'OFB', 'CFB'],
      security: 'Media (legacy)',
      desc: 'Aplica DES tres veces con claves diferentes. En desuso progresivo a favor de AES.',
    },
    {
      name: 'ChaCha20',
      fullName: 'ChaCha20-Poly1305',
      keySize: '256 bits',
      blockSize: 'Flujo (stream)',
      modes: ['Stream cipher'],
      security: 'Muy alta',
      desc: 'Cifrado de flujo moderno de Daniel Bernstein. Alternativa a AES-GCM muy usada en TLS y VPN.',
    },
  ];

  asymmetricConcepts = [
    {
      icon: '🔓',
      title: 'Clave Pública',
      desc: 'Se distribuye libremente. Cualquiera puede usarla para cifrar mensajes o verificar firmas.',
    },
    {
      icon: '🔒',
      title: 'Clave Privada',
      desc: 'Se mantiene en secreto. Solo el propietario puede descifrar mensajes o generar firmas.',
    },
    {
      icon: '🤝',
      title: 'Intercambio de Claves',
      desc: 'Protocolos como Diffie-Hellman permiten acordar un secreto compartido por un canal inseguro.',
    },
  ];

  /* ── Methods ── */

  toggleMenu() {
    this.mobileMenuOpen.update((v) => !v);
  }

  scrollTo(id: string) {
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
    this.mobileMenuOpen.set(false);
  }

  caesarCipher(text: string, shift: number): string {
    return text
      .split('')
      .map((ch) => {
        const code = ch.charCodeAt(0);
        if (code >= 65 && code <= 90) return String.fromCharCode(((code - 65 + shift) % 26) + 65);
        if (code >= 97 && code <= 122)
          return String.fromCharCode(((code - 97 + shift) % 26) + 97);
        if (code >= 192 && code <= 214)
          return String.fromCharCode(((code - 192 + shift) % 23) + 192);
        if (code >= 224 && code <= 246)
          return String.fromCharCode(((code - 224 + shift) % 23) + 224);
        return ch;
      })
      .join('');
  }

  async computeHash() {
    const encoder = new TextEncoder();
    const data = encoder.encode(this.hashInput());
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    this.hashOutput.set(hashArray.map((b) => b.toString(16).padStart(2, '0')).join(''));
  }
}
