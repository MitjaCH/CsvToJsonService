# Installation und Konfiguration der AWS CLI

Mit der AWS Command Line Interface (CLI) können Sie AWS-Dienste über die Kommandozeile verwalten. Diese Anleitung führt Sie durch die Installation und Konfiguration der AWS CLI.

---

## Voraussetzungen

- Ein AWS-Konto
- Administratorrechte auf Ihrem Computer
- Ein Terminal oder eine Komanndozeile (WSL oder Linux Terminal)
- **Linux/Unix:** Stellen Sie sicher, dass `curl` und `unzip` installiert sind. Falls nicht, können Sie sie mit folgendem Befehl installieren:

  ```bash
  sudo apt update && sudo apt install curl unzip -y
  ```

---

## Schritt 1: AWS CLI herunterladen und installieren

### Linux

1. Öffnen Sie ein Terminal.
2. Laden Sie die AWS CLI mithilfe von `curl` herunter:

   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   ```

3. Entpacken Sie die heruntergeladene Datei:

   ```bash
   unzip awscliv2.zip
   ```

4. Installieren Sie die AWS CLI:

   ```bash
   sudo ./aws/install
   ```

5. Überprüfen Sie die Installation:

   ```bash
   aws --version
   ```

   Die Ausgabe sollte die installierte Version anzeigen, z. B. `aws-cli/2.x.x`.

---

## Schritt 2: AWS CLI konfigurieren

1. Starten Sie die Konfiguration der AWS CLI, indem Sie den folgenden Befehl im Terminal eingeben:

   ```bash
   aws configure
   ```

2. Geben Sie die folgenden Informationen ein, wenn Sie dazu aufgefordert werden:
   - **AWS Access Key ID**: (vorerst Dummy-Daten eingeben, z. B. `1`)
   - **AWS Secret Access Key**: (ebenfalls Dummy-Daten eingeben, z. B. `1`)
   - **Default region name**: Geben Sie die gewünschte AWS-Region ein, z. B. `us-east-1`.
   - **Default output format**: Wählen Sie ein Format (`json`, `table` oder `text`). Standard ist `json`.

   > **Hinweis**: Diese Zugangsdaten werden in der Datei `~/.aws/credentials` gespeichert.

3. Öffnen Sie [AWS Academy](https://awsacademy.instructure.com/) und starten Sie das entsprechende Lab, falls dies noch nicht geschehen ist.  
   - Sobald das Lab aktiv ist, wird dies mit einem **grünen Kreis** angezeigt.  
   - Klicken Sie anschliessend auf **AWS Details**, um Ihre Zugangsinformationen für die AWS CLI zu sehen.

4. Kopieren Sie die angezeigten Zugangsdaten und ersetzen Sie die Dummy-Daten in der Datei `~/.aws/credentials`.  
   - Navigieren Sie im Terminal in das Verzeichnis `.aws`:

     ```bash
     cd ~/.aws
     ```

   - Bearbeiten Sie die Datei `credentials` mit einem Texteditor wie `nano`:

     ```bash
     nano credentials
     ```

   - Ersetzen Sie den bestehenden Inhalt durch die zuvor kopierten Zugangsdaten von AWS Academy.
   - Um diese Zugangsdaten zu erhalten navigieren Sie auf ihre AWS Academy Lab übersicht.
   - Drücken Sie auf **AWS Details** und drücken Sie auf **Show** unter **AWS CLI**.
     ![image](https://github.com/user-attachments/assets/279994f6-d3b8-49bc-91cb-4133f86ddbb4)
    - Kopieren Sie jetzt den ganzen Inhalt vom blau markierten Feld in die **Credentials** File.
    - ![image](https://github.com/user-attachments/assets/67a3150e-abe5-4655-9a1a-60f608d6adac)


     

5. Speichern Sie die Datei und schliessen Sie den Editor. Ihre AWS CLI ist jetzt korrekt konfiguriert.

---

## Schritt 3: Testen der AWS CLI

Verwenden Sie den folgenden Befehl, um Ihre Konfiguration zu testen:

```bash
aws s3 ls
```

Dieser Befehl listet alle S3-Buckets auf, die in Ihrem AWS-Konto verfügbar sind. Falls keine Fehlermeldung angezeigt wird, ist die Konfiguration erfolgreich abgeschlossen.
