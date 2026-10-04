# Uni zusammen – GitHub-Version

Diese Version enthält Home, Monatskalender, Seminare mit Sitzungen, Mitschriften-Uploads, Chat, Seminarsuche, bearbeitbare Profile und Yades privates Logbuch. Sie ist für iPhone und MacBook vorbereitet.

## 1. Website auf GitHub hochladen

1. ZIP-Datei auf dem MacBook entpacken.
2. In GitHub ein neues Repository anlegen, z. B. `uni-zusammen`.
3. Den **Inhalt** des Ordners `GITHUB_HOCHLADEN` in die oberste Ebene des Repositorys hochladen. Dort müssen `index.html`, `config.js`, `assets` und die Icon-Dateien direkt liegen. Nicht die ZIP-Datei hochladen.
4. Im Repository unter **Settings → Pages** die Quelle **Deploy from a branch**, Branch **main** und Ordner **/ (root)** wählen und speichern.
5. Nach der Veröffentlichung steht dort der Website-Link, ungefähr `https://DEIN-GITHUB-NAME.github.io/uni-zusammen/`.

Der Ordner `QUELLCODE` enthält den bearbeitbaren React-Quellcode für spätere Änderungen. Für die Veröffentlichung der fertigen Version ist kein Installieren oder Bauen nötig.

## 2. Gemeinsamen Speicher einrichten

Die Website wird über GitHub Pages veröffentlicht. Die Anmeldung, Kurse, Profile, Nachrichten, Mitschriften und das Logbuch liegen bei Supabase.

Deine vorhandene Supabase-Adresse und der veröffentlichbare Schlüssel sind bereits in `config.js` eingetragen. Dein anderes Planer-Projekt nutzt weiterhin seine bisherigen Tabellen. Diese neue Version verwendet eigene Tabellen mit dem Präfix `uz_` und einen eigenen privaten Datei-Bucket.

1. Öffne dein Supabase-Projekt.
2. Öffne **SQL Editor → New query**.
3. Kopiere den vollständigen Inhalt von `supabase-setup.sql` hinein und führe ihn aus.
4. Unter **Authentication → URL Configuration** deinen GitHub-Pages-Link als **Site URL** und unter **Redirect URLs** eintragen, jeweils mit dem abschließenden `/`.
5. Unter **Authentication → Providers / Sign In → Email** E-Mail-Anmeldung und E-Mail-Bestätigung aktiviert lassen. Die Bestätigung schützt die Zuordnung deines privaten Logbuchs zu deinem Konto.

**Eigentümerinnen-Adresse:** Im Einrichtungsskript ist `yade.akkus2293@gmail.com` eingetragen. Melde dich mit dieser Adresse an. Falls du eine andere Adresse verwenden möchtest, ändere die Zeile mit `uz_workspace` vor der ersten Einrichtung. Danach ist die Eigentümerinnen-Rolle an dein angemeldetes Konto gebunden, nicht an deinen frei wählbaren Anzeigenamen.

## 3. Eure beiden Konten

1. Du öffnest die Website und erstellst unter **Registrieren** dein eigenes Konto. Falls für diese E-Mail-Adresse in diesem Supabase-Projekt schon ein Konto existiert, melde dich mit dessen Passwort an.
2. Bestätige die E-Mail-Adresse über die E-Mail von Supabase und melde dich an.
3. Öffne links **Gemeinsamer Bereich → Zugang verwalten**.
4. Trage die E-Mail-Adresse deiner Freundin ein und klicke auf **Zugang freischalten**. Dies verschickt keine Nachricht; gib ihr selbst den Website-Link.
5. Deine Freundin registriert sich mit genau dieser E-Mail-Adresse, bestätigt sie und meldet sich an.

Jede Person hat ein eigenes Passwort. Das frühere gemeinsame Passwort `MAVIE` wird für diese neue Version nicht verwendet. Der Planer erlaubt zwei persönliche Konten. Außenstehende können die Anmeldeseite öffnen, erhalten aber keinen Zugriff auf eure Inhalte.

## 4. So benutzt ihr den Planer

- **Home:** kommende Ankündigungen, Tests und Abgaben. Neue Einträge über **Eintrag hinzufügen** erstellen.
- **Kalender:** alle Wochen des gewählten Monats. Mit den Pfeilen zwischen Monaten wechseln und einen Tag öffnen.
- **Kurse & Mitschriften:** Kurse eintragen und über das Suchfeld nach Seminarname, Lehrperson oder Raum suchen.
- **Seminar → Sitzung:** Eine Sitzung nach Datum öffnen. Hier Mitschriften hochladen (bis 15 MB pro Datei), herunterladen und Notizen schreiben.
- **Profil bearbeiten:** Unten links auf das eigene Profil klicken. Namen ändern und JPG, PNG oder WebP bis 4 MB als Profilbild hochladen.
- **Chat:** Nachrichten schreiben. Aktualisierung alle vier Sekunden, solange der Chat geöffnet ist.
- **Mein Logbuch:** nur für Yade. Zeigt Person, Konto-Adresse, Zeitpunkt, Aktion, Datei bzw. Titel, Seminar und Sitzungsdatum. Uploads und Notizänderungen werden von der Datenbank selbst protokolliert. Auch nach dem Entfernen einer Datei bleibt die Aktion im Logbuch. Das Logbuch kann von der Freundin weder gelesen noch verändert werden.

Kurse dürfen einen Zeitraum von bis zu zwei Jahren haben. Bereits hochgeladene Mitschriften schützen die zugehörigen Sitzungstermine vor einer Änderung des Wochentags oder Zeitraums, die sie entfernen würde. Vor dem Entfernen eines Seminars müssen seine Dateien gesichert und entfernt werden.

## 5. Wie eine App verwenden

- **iPhone:** Website in Safari öffnen → Teilen → **Zum Home-Bildschirm** → gegebenenfalls **Als Web-App öffnen** aktivieren → Hinzufügen.
- **MacBook:** In Safari **Ablage → Zum Dock hinzufügen**, sofern deine macOS-Version diese Funktion unterstützt. Die Website funktioniert auch direkt im Browser.

Für Kalender, Dateien und Chat braucht ihr Internet. Eure Inhalte werden online gespeichert, nicht nur auf einem Gerät. Der Supabase-Anmeldezustand wird auf dem jeweiligen Gerät gespeichert. Beim Abmelden wird dieser Zugang entfernt.

## 6. Hamster-Icon

Das freigestellte Hamsterbild mit rosa Schleife ist als Website- und App-Icon eingebaut. Die PNG-Dateien behalten ihren transparenten Hintergrund.

## Prüfung und Einrichtung

Der Quellcode und der GitHub-Build wurden geprüft. Die produktive Supabase-Einrichtung kann ohne Zugriff auf deinen SQL Editor nicht automatisch durchgeführt werden. Der erste gemeinsame Upload und der Zugriff von beiden Konten müssen nach den Schritten oben in deinem Projekt geprüft werden. Vorhandene Daten der zuvor erstellten ChatGPT-Site werden nicht automatisch in dieses neue Supabase-Schema übertragen.

## Offizielle Anleitungen

- GitHub Pages: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
- Supabase Weiterleitungsadressen: https://supabase.com/docs/guides/auth/redirect-urls
- Supabase Zugriffsregeln: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase privater Dateispeicher: https://supabase.com/docs/guides/storage/security/access-control
