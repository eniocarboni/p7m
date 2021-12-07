## P7M

[![GPL License](https://img.shields.io/badge/license-GPL-blue.svg)](https://www.gnu.org/licenses/) [![Release v 0.5.5](https://img.shields.io/badge/release-v.0.5.5-green.svg)](https://github.com/eniocarboni/p7m) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/EnioCarboni)

**p7m** è un p7m viewer e uno script per la gestione dei file con [firma digitale nel formato CADES](https://quoll.it/firma-digitale-p7m-come-estrarre-il-contenuto/).
Permette di:
* verificare e visualizzare la firma digitale, 
* estrarre l'allegato e visualizzarlo (p7m viewer),
* scaricare il i certificati dei certificatori (CA dal [CNIPA](http://archivio.cnipa.gov.it/site/it-IT/))
* ispezionare il contenuto del file (debug per esperti)
* estrarre l'allegato di una fattura elettronica e visualizzare l'xml con il foglio di stile xsl di fatturapa [**New** (vedi Nota 3 sotto)]

Questo script funziona sotto linux sia in modalità testuale che grafica (usare l'opzione -g)

## SINOSSI
```
  p7m -g                        # Permettere di selezionare un file p7m per estrarne il contenuto [New]
  p7m [-x] [-g] [-h] <file.p7m> # Per estrarre il contenuto
  p7m -v [-g] [-h] <file.p7m>   # Per verificare il p7m
  p7m -c [-g] [-h] <file.p7m>   # Per i certificati
  p7m -d [-g] [-h] <file.p7m>   # Per il debug (esperti)
  p7m -p [-h]                   # Per scaricare la nuova CA
  p7m -t                        # Per test o per poterla usare come libreria (source p7m -t)
```

**dove**
* -h visualizza questo messaggio;
* -x estrae il file e non tenta di visualizzarlo;
* -v per verificare il p7m e la validita dei certificati e delle firme;
* -c visualizza i certificati di firma sia come testuali che come certificati binari (in formato PEM);
* -p per forzare lo scaricamento dei nuovi certificati [CA](https://it.wikipedia.org/wiki/Certificate_authority) registrati al [CNIPA] (https://eidas.agid.gov.it/TL/TSL-IT.xml);
* -d utili per il debug del p7m (per esperti);
* -g con questo flag tutti i risultati vengono visualizzati su finestre grafiche altrimenti tutto finisce sullo standard output.
  Come finestre di dialogo vengono prese in considerazione i comandi **kdialog** se presente, altrimenti **zenity** ed infine **xmessage**.
  L'ordine di ricerca può essere modificato tramite file di configurazione impostando la variabile *DIALOG_ORDER*

Se nessuno dei parametri **-v, -c o -d** viene utilizzato **p7m** controlla e verifica la firma ed estrae l'allegato visualizzandolo con il programma associato dal suo mime-type (p7m viewer).
Per aprire il programma associato ad uno specifico mime type viene utilizzato il comando **xdg-open** se presente, altrimenti **gvfs-open** ed infine **gnome-open**.
Se nessuno dei precedenti comandi esiste viene visualizzato un messaggio con l'indicazione del percorso esatto del file estratto.

## Configurazione
Si possono configurare la maggior parte delle opzioni nel file di configurazione in *$HOME/.config/p7m/p7m_config*
## Scaricamento da github
```
cd $HOME && mkdir p7m && cd p7m
git clone https://github.com/eniocarboni/p7m .
```
se non abbiamo il progarmma *git* scarichiamo tutto in zip
```
cd $HOME && mkdir p7m && cd p7m
wget https://github.com/eniocarboni/p7m/archive/master.zip
unzip master.zip
mv p7m-master p7m
```
## Integrazione con il file manager
Copiare la directory bin .local e .config nella home
```
cd $HOME/p7m && cp -a {bin,.local,.config} $HOME
# la directory p7m non serve più e si può eliminare
# rmdir -rf p7m
```
dove p7m è la directory dei file dell'archivio p7m come scaricato da github.

Verificare che nella variabile **PATH** sia presente $HOME/bin con
```
echo $PATH | grep --color $HOME/bin
```
In caso negativo aggiungiamolo in **.bash_profile** con il comando:
  ``` echo 'PATH=$HOME/bin:$PATH' >>$HOME/.bashrc ```
  A questo punto bisogna riavviare la sessione grafica o se si preferisce si può riavviare il computer.

Ora, sia che utilizziamo **KDE** con **Dolphin**, sia **GNOME** con **Nautilux** oppure **LXDE** con **Thunar** dovremmo avere come menù contestuale (tasto destro del mouse) delle voci in più che permettono di fare ogni operazione prevista da **p7m** se il file attivo è un vero .p7m

### Note sull'integrazione

#### Nota 1: xdg-mime
Potrebbe esser utile in alcuni casi lanciare il comando:
```xdg-mime default p7m.desktop application/pkcs7-mime```
in modo tale da rendere **p7m** l'applicativo di default per il mime type application/pkcs7-mime, ovvero per i file .p7m

#### Nota 2: Thunar (sotto Xfce)
Per il file manager Thunar (sotto Xfce) per avere il menù contestuale **p7m** bisogna aggiungere al file standard delle azioni *.config/Thunar/uca.xml* tutte le ultime 6 **&lt;action>...&lt;/action>** del file *.config/Thunar/uca_p7m.xml*

Vanno aggiunte prima della chiusura del tag **&lt;/actions>**
Se non sono state create in precedenza azioni personalizzate di Thunar si può semplicemente soprapporre il file con i seguenti comandi
```
  mkdir -p .config/Thunar
  mv -f .config/Thunar/uca.xml .config/Thunar/uca.xml.orig
  mv .config/Thunar/uca_p7m.xml .config/Thunar/uca.xml
  xdg-mime default p7m.desktop application/pkcs7-mime
```

#### Nota 3: Fatture elettroniche

Se il p7m corrisponde ad una fattura elettronica il programma **p7m** aprirà l'editor di default per i file xml aggiungendo, nella stessa directory, il file di foglio di style xsl per la visualizzazione come da standard SdI.

Se il default è Firefox o Chrome viene visualizzata la fattura digitale in html e non viene visualizzato l'xml.

Purtoppo (o per fortuna!), con i browser, da un po' di tempo non si può più utilizzare file esterni se si lavora in locale (sul proprio file system) per problemi di sicurezza.

Per Firefox vedi [CVE-2019-11730](https://www.mozilla.org/en-US/security/advisories/mfsa2019-21/#CVE-2019-11730). 

Se vuoi puoi provare a tuo rischio ad eludere il controllo andando all'url **about:config** e mettendo (o aggiungendo) **privacy.file_unique_origin** da **true** a **false**.

Per Chrome, invece, non credo ci sia un'opzione di configurazione ma l'unico modo è lanciarlo con l'opzione **--allow-file-access-from-files**.

Per aggiungere tale opzione, ad esempio in **kde**, basta modificare il file **/usr/share/applications/google-chrome.desktop** nella riga **Exec=** oppure, meglio, copiarlo in locale in **$HOME/.local/share/applications/** e poi modificarlo.

Nel caso in cui le fatture elettroniche sono state tutte estratte in **xml** in una cartella e si vuole vedere le fatture con il browser nel formato SdI allora basta scaricarsi il file xsl nella stessa cartella:
```
  wget -O fatturapa_v1.2.1.xsl https://www.fatturapa.gov.it/export/documenti/fatturapa/v1.2.1/Foglio_di_stile_fatturaPA_v1.2.1.xsl
```
Per funzionare, sia Firefox che Chrome, hanno bisogno del trucco visto poco sopra.

Senza utilizzare il trucco basta aprire un terminale ed andare nella cartella dove sono gli xml (fatture elettroniche), supponiamo in **$HOME/fatture_in_xml**:

```
  cd $HOME/fatture_in_xml
  python -m SimpleHTTPServer 8000
```

che lancerà un semplice server web sulla porta locale 8000.
Basterà quindi collegarsi con il browser su http://localhost:8000 e cliccare sul file xml che si vuole visualizzare.
Per chiudere il server web in python basta premere su terminale **CTRL-C**.
Ora tutti i file xml dovrebbero esser visibili con il formato SdI, tranne quelli che non hanno la riga iniziale
```
  <?xml-stylesheet type="text/xsl" href="fatturapa_v1.2.1.xsl"?>
```

## COPYRIGHT

      Copyright (c) 2018 Enio Carboni - Italy

      This file is part of p7m.

      p7m is free software: you can redistribute it and/or modify it under the 
      terms of the GNU General Public License as published by the Free Software 
      Foundation, either version 3 of the License, or (at your option) any later
      version.

      p7m is distributed in the hope that it will be useful, but WITHOUT ANY 
      WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
      FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
      details.

      You should have received a copy of the GNU General Public License along 
      with p7m.  If not, see <http://www.gnu.org/licenses/>.


