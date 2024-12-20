# CsvToJsonConverter

## Projektstruktur

```
CsvToJsonService/
├── docs/*               # Tutorials für das einrichten der Voraussetzungen
├── scripts/init.sh       # Initialisation Skript das die ganze Lambda Funktion auf aws einrichtet
├── src/index.ts          # Lambda Funktion programmiert in TypeScript
├── README.md             # Dokumentation
└── config.yml           # Config Datei zum konfigurieren des init.sh skripts
```

## Genutzte NodeJS Dependencies
| **Dependency**       | **Version** |
|-----------------------|-------------|
| `@types/node`        | ^22.10.1    |
| `aws-sdk`            | ^2.1692.0   |
| `csvtojson`          | ^2.0.10     |
| `ts-node`            | ^10.9.2     |
| `typescript`         | ^5.7.2      |
| `@types/aws-lambda`  | ^8.10.146   |
| `@types/aws-sdk`     | ^0.0.42     |

## Installation und Setup

Folgen Sie diesen Schritten, um den CsvToJsonConverter in Betrieb zu nehmen:

### Voraussetzungen
- **Linux-Umgebung**:
  - Verwenden Sie WSL (Windows Subsystem for Linux) oder eine Linux-VM. Eine Anleitung zur Installation finden Sie [hier](docs/wsl-installation.md).
- **AWS CLI**:
  - Installieren, konfigurieren und authentifizieren Sie die AWS CLI. Eine Anleitung finden Sie [hier](docs/aws-cli-setup.md).
- **Git**:
  - Installieren Sie Git auf Ihrem System.
- **Node.js**:
  - Installieren Sie Node.js in Ihrer Linux-Umgebung. Nutzen Sie dazu die [Offiziele Anleitung](https://nodejs.org/en/download/package-manager)

### Repository klonen

Nachdem Sie die oben gennanten Voraussetzungen eingreichtet haben, können Sie das Repository klonen:

```bash
git clone https://github.com/MitjaCH/CsvToJsonService.git

cd CsvToJsonConverter
```

### Abhängigkeiten installieren

Führen Sie den folgenden Befehl aus, um die benötigten Abhängigkeiten zu installieren:

```bash
npm install
```

### Weitere Anforderungen

Installieren Sie zusätzlich die folgende Werkzeuge:

```bash
sudo apt install zip
sudo apt install -y jq
```

### Infrastruktur einrichten

Um die erforderliche Infrastruktur für den Service einzurichten, führen Sie im Verzeichnis ``CsvToJsonConverter`` das folgende Skript aus:

```bash
bash ./scripts/init.sh
```
**Ergebnis**
Nach der erfolgreichen Ausführung des Skripts werden folgende AWS-Ressourcen erstellt:
1. **Zwei S3 Buckets:**
    - Einer der Buckets dient zum Hochladen von CSV-Dateien.
    - Der zweite Bucket speichert die daraus generierten JSON-Dateien.
2. **Eine Lambda-Funktion:**
    - Diese Funktion verarbeitet die in den ersten S3 Bucket hochgeladenen CSV-Dateien und konvertiert sie in JSON der code für dieser funktion finden Sie in ``CsvToJsonConverter/src/index.ts``
3. **Ein S3-Trigger:**
    - Der Trigger aktiviert die Lambda-Funktion automatisch, sobald eine neue CSV-Datei im ersten Bucket hochgeladen wird.

Diese Ressourcen arbeiten zusammen, um die hochgeladene CSV-Dateien zu verarbeiten und die Ergebnisse in den Ziel-Bucket zu speichern

---

### GitHub Accounts
- Nils: https://github.com/PythonIschKeiProgrammiersproch
- Mitja: https://github.com/MitjaCH
- Linus: https://github.com/Linussl
