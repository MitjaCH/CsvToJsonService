
# Testprotokoll

---

## 1. Testübersicht

- **Testzeitpunkt:** 19.12.2024  
- **Testperson:** Nils Schlegel  
- **Testumgebung:** Automatisierter Test im init.sh-Skript  
- **Testziel:** Die Konvertierung einer CSV-Datei zu einer JSON-Datei  


---

## 2. Testfälle

### Testfall 1: Erstellung und Konfiguration der S3-Buckets

- **Testdatum:** 19.12.2024  
- **Testperson:** Nils Schlegel  
- **Beschreibung:** Testet die erfolgreiche Erstellung und Konfiguration von S3-Buckets für Eingabe und Ausgabe.  
- **Testschritte:**  
  1. Erstellung eines Eingabebuckets (`csv-to-json-in-<timestamp>`).  
  2. Erstellung eines Ausgabebuckets (`csv-to-json-out-<timestamp>`).  
  3. Überprüfung der Bucket-Konfiguration.  
- **Erwartetes Ergebnis:** Die S3-Buckets werden erfolgreich erstellt und konfiguriert.  
- **Tatsächliches Ergebnis:** Erfolgreich.  
- **Status:** Bestanden  

---

### Testfall 2: Erstellung und Bereitstellung der Lambda-Funktion

- **Testdatum:** 19.12.2024  
- **Testperson:** Nils Schlegel  
- **Beschreibung:** Testet die Erstellung und Konfiguration der Lambda-Funktion sowie die Zuweisung der Berechtigungen.  
- **Testschritte:**  
  1. Erstellung der Lambda-Funktion basierend auf den Konfigurationsdateien.  
  2. Zuweisung der Berechtigungen für die S3-Buckets.  
  3. Hinzufügen eines Triggers für den Eingabebucket.  
- **Erwartetes Ergebnis:** Die Lambda-Funktion wird erfolgreich erstellt und mit den S3-Buckets verknüpft.  
- **Tatsächliches Ergebnis:** Erfolgreich.  
- **Status:** Bestanden  
[<img width="1691" alt="image" src="https://github.com/CsvT" />](https://github.com/MitjaCH/CsvToJsonService/edit/main/docs/testcases/testcase_1.png)

---

### Testfall 3: Verarbeitung einer CSV-Datei zu JSON

- **Testdatum:** 19.12.2024  
- **Testperson:** Nils Schlegel  
- **Beschreibung:** Testet den vollständigen Workflow von der CSV-Upload bis zur JSON-Konvertierung.  
- **Testschritte:**  
  1. Upload einer Test-CSV-Datei in den Eingabebucket.  
  2. Überprüfung, ob die Datei korrekt verarbeitet wird.  
  3. Herunterladen der resultierenden JSON-Datei aus dem Ausgabebucket.  
- **Erwartetes Ergebnis:** Die CSV-Datei wird erfolgreich in JSON konvertiert und in den Ausgabebucket hochgeladen.  
- **Tatsächliches Ergebnis:** Erfolgreich.  
- **Status:** Bestanden  
[<img width="1691" alt="image" src="https://github.com/CsvT" />](https://github.com/MitjaCH/CsvToJsonService/edit/main/docs/testcases/testcase_2.png)

---

## 3. Zusammenfassung

- **Gesamtstatus:** Alle Tests erfolgreich bestanden.  
- **Besondere Vorkommnisse:** Keine.  
- **Empfohlene Maßnahmen:** Keine weiteren Maßnahmen erforderlich.  

--- 

*Testprotokoll erstellt am 19.12.2024 durch Nils Schlegel.*
