# Installation von Windows Subsystem for Linux (WSL)

Mit Windows Subsystem for Linux (WSL) können Sie eine Linux-Umgebung direkt auf Ihrem Windows-System ausführen. Diese Anleitung führt Sie durch die Installation und Konfiguration von WSL.

---

## Voraussetzungen

- Windows 10 (Version 1903 oder höher, Build 18362 oder höher) oder Windows 11
- Administratorrechte auf Ihrem Computer

---

## Schritt 1: Aktivieren von WSL

1. Öffnen Sie PowerShell als Administrator:
    - Drücken Sie die **Windows-Taste**, geben Sie `PowerShell` ein, klicken Sie mit der rechten Maustaste auf "Windows PowerShell" und wählen Sie "Als Administrator ausführen".
2. Geben Sie folgenden Befehl ein, um WSL zu aktivieren:

   ```powershell
   wsl --install
   ```

   Dieser Befehl:
   - Aktiviert die erforderlichen Windows-Komponenten
   - Installiert die neueste WSL-Version (WSL 2)
   - Installiert automatisch eine Standard-Linux-Distribution (z. B. Ubuntu)

3. Starten Sie Ihren Computer nach der Installation neu, wenn Sie dazu aufgefordert werden.

--- 

## Schritt 2: Linux-Umgebung starten


1. Öffnen Sie das Startmenü und suchen Sie nach Ihrer installierten Linux-Distribution (z. B. Ubuntu).
2. Klicken Sie darauf, um die Distribution zu starten.
3. Folgen Sie den Anweisungen, um ein Benutzerkonto und ein Passwort für Ihre Linux-Umgebung einzurichten.

---

## Weiterführende Links

- [Offizielle WSL-Dokumentation von Microsoft](https://learn.microsoft.com/windows/wsl/)
