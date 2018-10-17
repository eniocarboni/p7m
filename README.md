## P7M

[![GPL License](https://img.shields.io/badge/license-GPL-blue.svg)](https://www.gnu.org/licenses/)
[![Release v 0.2](https://img.shields.io/badge/release-v.0.2-green.svg)](https://github.com/eniocarboni/p7m)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/EnioCarboni/5)

**p7m** è un p7m viewer e uno script per la gestione dei file con [firma digitale nel formato CADES](https://quoll.it/firma-digitale-p7m-come-estrarre-il-contenuto/).
Permette di:
* verificare e visualizzare la firma digitale, 
* estrarre l'allegato e visualizzarlo (p7m viewer),
* scaricare il i certificati dei certificatori (CA dal [CNIPA](http://archivio.cnipa.gov.it/site/it-IT/))
* ispezionare il contenuto del file (debug per esperti)

Questo script funziona sotto linux sia in modalità testuale che grafica (usare l'opzione -g)

## SINOSSI
```
  p7m [-g] [-v | -c | -d] file.p7m
  p7m [-g] -p 
```

**dove**
* -p
  serve per scaricare la versione aggiornata del portafoglio dei [CA](https://it.wikipedia.org/wiki/Certificate_authority) registrati al [CNIPA](http://archivio.cnipa.gov.it/site/it-IT/).
  Il portafoglio originale in xml verrà salvato in *$HOME/.p7m/cnipa_signed.xml* mentre la versione convertita e valida per openssl sarà salvata nel file *$HOME/.p7m/ca.pem*.
  Il portafoglio servirà per verificare la firma nel file *file.p7m*
* -v
  verifica se la firma è valida
* -c
  estrae e visualizza il certificato utente sia in forma testuale che in formato .pem
* -x
  estrae l'allegato nella stessa cartella del file .p7m
* -d
  Visualizza il debug (solo per esperti) del contenuto del file *file.p7m*.
  In tal modo si riesce a capir meglio se il file ha dei problemi e cosa contiene.
* -g
  con questo flag tutti i risultati vengono visualizzati su finestre grafiche altrimenti tutto finisce sullo standard output.
  Come finestre di dialogo vengono prese in considerazione i comandi **kdialog** se presente, altrimenti **zenity** ed infine **xmessage**.
  L'ordine di ricerca può essere modificato tramite file di configurazione impostando la variabile *DIALOG_ORDER*

Se nessuno dei parametri ==-v, -c o -d== viene utilizzato **p7m** controlla e verifica la firma ed estrae l'allegato visualizzandolo con il programma associato dal suo mime-type (p7m viewer).
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
cd $HOME/p7m && cp -a {bin, .local, .config} $HOME
# la directory p7m non serve più e si può eliminare
# rmdir -rf p7m
```
dove p7m è la directory dei file dell'archivio p7m come scaricato da github.

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
## COPYRIGHT

      Copyright (c) 2018 Enio Carboni - Italy

      This file is part of p7m.

p7m is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

p7m is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with p7m.  If not, see <http://www.gnu.org/licenses/>.



