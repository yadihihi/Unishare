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

## 3. Konten mit E-Mail und Passwort, Freigabe durch Yade

1. Du registrierst dich mit `yade.akkus2293@gmail.com` und bestätigst deine E-Mail-Adresse. Dieses Eigentümerinnen-Konto verwaltet den Zugang. Falls es im Supabase-Projekt schon existiert, melde dich mit dessen Passwort an.
2. Deine Freundin öffnet denselben Website-Link und erstellt ihr eigenes Konto mit Name, E-Mail-Adresse und Passwort.
3. Sobald sie ein neues Konto registriert, erscheint bei dir eine Kontoanfrage in der Website. Sie bestätigt zunächst ihre E-Mail-Adresse.
4. Du öffnest den Hinweis **Neue Kontoanfrage → Prüfen**, oder **Profil → Gemeinsamer Zugang**. Nur du kannst **Freigeben** oder **Ablehnen** wählen. Vor der E-Mail-Bestätigung ist Freigeben gesperrt.
5. Nach deiner Freigabe kann sie sich immer wieder mit ihrer E-Mail-Adresse und ihrem Passwort anmelden. Auf demselben Gerät bleibt sie angemeldet, bis sie sich abmeldet oder die Browserdaten löscht.

Solange deine Freigabe fehlt, sieht die Person nur eine Warteseite. Kalender, Chat, Mitschriften und Profile sind noch gesperrt. Abgelehnte Konten erhalten ebenfalls keinen Zugriff. Die Freigabe wird im Online-Speicher dauerhaft gespeichert. Kontoanfragen werden bei geöffneter, sichtbarer Website alle acht Sekunden aktualisiert; es wird keine Push-Nachricht oder Einladung verschickt. Es wird kein ChatGPT-Konto benötigt.

**Update einer bereits eingerichteten Version:** Führe `supabase-update-freigaben.sql` einmal im SQL Editor aus und ersetze die Website-Dateien auf GitHub. Bereits freigegebene Konten und alle Inhalte bleiben erhalten. Vorher eingetragene E-Mail-Einladungen schalten neue Konten nicht mehr automatisch frei.

## 4. So benutzt ihr den Planer

Die Seitenauswahl steht fest am unteren Bildschirmrand. Die Sprechblase ist von jeder Seite erreichbar. Ein kleiner Punkt markiert neue ungelesene Nachrichten der anderen Person. Sobald ihr den Chat öffnet und die Nachrichten geladen wurden, verschwindet der Punkt. Die Prüfung findet alle vier Sekunden bei geöffneter, sichtbarer Website statt; dies ist keine Push-Benachrichtigung bei geschlossener App. Profil und Einstellungen erreicht ihr über das Personen-Icon unten.

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
