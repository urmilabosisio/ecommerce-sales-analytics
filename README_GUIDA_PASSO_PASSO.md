# Progetto portfolio — E-commerce Sales & Profitability Analysis

**Progetto personale di apprendimento e portfolio. Dati al 100% sintetici (simulati), non provenienti da un'azienda reale.**

## 0. La storia da raccontare

**Scenario ipotetico:** un e-commerce vuole capire quali categorie generano margini più elevati, quali canali portano ricavi, dove si concentrano i resi e se gli sconti elevati comprimono la redditività.

**Domanda di business:** come utilizzare le transazioni per individuare opportunità di miglioramento della redditività?

**Output attesi:** database relazionale, query SQL, controlli qualità, analisi esplorativa Python, dashboard Power BI e 2–3 proposte operative motivate dai risultati.

L'obiettivo NON è misurare crescita reale: i dati sono artificiali. L'obiettivo è dimostrare metodo, strumenti, interpretazione e consapevolezza dei limiti.

## 1. Che cosa contiene la cartella

```text
Progetto_Data_Analyst_Ecommerce/
├── dati/
│   ├── customers.csv          (800 clienti)
│   ├── products.csv           (35 prodotti)
│   ├── orders.csv             (3200 ordini)
│   └── order_items.csv        (5019 righe d'ordine)
├── sql/
│   ├── 01_crea_tabelle.sql
│   ├── 02_controlli_qualita.sql
│   ├── 03_analisi.sql
│   └── 04_vista_powerbi.sql
├── python/
│   ├── analisi_vendite.py
│   └── requirements.txt
├── powerbi/
│   └── ISTRUZIONI_POWERBI.md
├── risultati/
│   ├── sintesi_kpi.txt        (verifica dell'esecuzione Python)
│   ├── 4 CSV riassuntivi
│   └── 4 grafici PNG
└── genera_dataset.py         (rigenera lo stesso dataset grazie al seed)
```

I file già presenti in `risultati/` sono **esempi di controllo generati dal codice**: devono essere riprodotti e interpretati personalmente prima di dichiarare di aver realizzato l'analisi.

## 2. Dizionario dati

| File | Contenuto | Chiave | Note |
|---|---|---|---|
| customers.csv | città, regione, data di iscrizione | customer_id | 1 cliente può fare diversi ordini |
| products.csv | nome, categoria, prezzo, costo unitario | product_id | prezzi e costi fissi (ipotesi) |
| orders.csv | cliente, data, canale dell'ordine | order_id | 1 ordine ha 1–4 prodotti distinti |
| order_items.csv | prodotto, quantità, prezzo, sconto, reso | order_item_id | 1 riga per prodotto in un ordine |

Nelle righe d'ordine `is_returned` indica se **l'intera riga** è stata resa. Gli sconti sono percentuali da 0 a 100, quindi 20 = 20%. Prezzi e valori sono in euro, senza ulteriore trattamento IVA. La simulazione assume che le righe rese vengano rimborsate integralmente e gli articoli tornino rivendibili; ignora il costo della spedizione e altre spese. Il margine lordo è quindi una **stima, non un utile netto**.

## 3. Fase 1 — PostgreSQL / pgAdmin: creazione database (inizia qui)

**Prerequisiti:** hai installato PostgreSQL e pgAdmin 4 su Windows e riesci ad aprire il server inserendo la tua password.

1. Scarica ed estrai lo ZIP in una cartella facile da ritrovare (per esempio il Desktop). Non eseguire file dall'interno dell'anteprima ZIP.
2. Apri **pgAdmin 4** e connettiti al tuo server locale PostgreSQL.
3. Sull'albero a sinistra, fai **tasto destro su Databases > Create > Database**.
4. Scrivi **`portfolio_ecommerce`** come nome del database e salva.
5. Seleziona il nuovo database, poi apri **Tools > Query Tool**.
6. Dal Query Tool apri il file `sql/01_crea_tabelle.sql` (icona **Apri file**) e premi **Execute** (triangolo/fulmine).
7. Sulla sinistra, espandi il database `portfolio_ecommerce` > `Schemas` > `portfolio` > `Tables`. Dovresti vedere 4 tabelle; se non appaiono, fai **Refresh**.

**Che cosa hai fatto?** Hai creato uno schema relazionale con chiavi primarie, chiavi esterne e vincoli di validità.

## 4. Fase 2 — Import dei CSV in pgAdmin

Le istruzioni seguenti usano la finestra di importazione di pgAdmin, **non** il comando `COPY` con percorsi Windows, che può richiedere permessi lato server.

**Ordine obbligatorio:** `customers` → `products` → `orders` → `order_items`.

Per ogni tabella:

1. In pgAdmin, espandi `Schemas > portfolio > Tables` e fai **tasto destro sulla tabella**.
2. Clicca **Import/Export Data**.
3. Imposta **Import**, formato **CSV**, file corrispondente nella cartella `dati/`, **Encoding UTF8**, **Header Yes**, separatore `,` e quote `"`.
4. Premi **OK** e attendi l'esito nella notifica di pgAdmin.
5. Ripeti per la tabella successiva.

Documentazione ufficiale: https://www.pgadmin.org/docs/pgadmin4/9.19/import_export_data.html

**Verifica immediata (Query Tool):**

```sql
SELECT COUNT(*) AS numero_ordini
FROM portfolio.orders;
```

Deve risultare **3200**. Poi prova:

```sql
SELECT *
FROM portfolio.orders
LIMIT 10;
```

Se compare `relation "portfolio.orders" does not exist`, controlla di aver selezionato il database `portfolio_ecommerce`, non il database predefinito `postgres`.

## 5. Fase 3 — Verifica qualità dei dati

Apri `sql/02_controlli_qualita.sql`. **Seleziona una query alla volta** ed eseguila. Confronta i conteggi con quelli indicati nei commenti del file.

Annota cosa verificano i vincoli (integrità referenziale, intervalli di sconto, quantità positive) e perché un'analisi basata su dati incoerenti sarebbe poco affidabile.

## 6. Fase 4 — Calcolo KPI e analisi SQL

1. Apri ed esegui **tutto** `sql/04_vista_powerbi.sql` per creare `portfolio.v_sales_lines`.
2. Apri `sql/03_analisi.sql` e lancia **una query alla volta** (selezionandola): in questo modo puoi osservare il risultato di ogni domanda.
3. Riporta in un quaderno o file di testo questi KPI: ricavi netti, margine lordo, margine percentuale, scontrino medio, categoria con più ricavi, categoria con più resi, andamento mensile.

**Definizioni:**
- **Ricavi netti** = somma di quantità × prezzo × (1 − sconto/100), escludendo le righe completamente rese.
- **COGS** = costo unitario × quantità sulle righe non rese.
- **Margine lordo** = ricavi netti − COGS.
- **Margine lordo %** = margine lordo / ricavi netti.
- **Scontrino medio netto** = ricavi netti / numero di ordini, compresi quelli interamente resi.
- **Tasso resi %** = unità rese / unità ordinate.

**Punto di attenzione:** conoscere il fatturato di un canale non basta per affermare che sia il più efficiente: non abbiamo né la spesa pubblicitaria né il numero di visitatori, quindi NON possiamo calcolare ROI o conversion rate.

## 7. Fase 5 — Python + Pandas + Matplotlib

### A. Installazione librerie

Da **Prompt dei comandi Windows, PowerShell o Anaconda Prompt**, non dalla console Python `>>>`, esegui:

```bat
python -m pip install pandas matplotlib
```

Se usi un ambiente Conda, è anche possibile eseguire da **Anaconda Prompt**:

```bat
conda install pandas matplotlib
```

Se Spyder usa un ambiente diverso da quello nel quale installi i pacchetti, configura l'interprete corretto o installa i pacchetti in quello di Spyder.

### B. Esegui il codice

Apri `python/analisi_vendite.py` in **Spyder** e premi F5, oppure dal Prompt dei comandi, nella cartella principale del progetto, esegui:

```bat
python python\analisi_vendite.py
```

Il programma importa i CSV, li unisce (`merge`), controlla la qualità, calcola indicatori, genera tabelle CSV aggregate e salva quattro grafici in `risultati/`.

**Non serve** `psycopg` per questa fase: è un confronto indipendente dei risultati SQL sugli stessi file sorgente. La catena completa si chiude collegando Power BI direttamente al database PostgreSQL.

### C. Domande di interpretazione

- Quale categoria porta più ricavi? È anche quella con il margine percentuale maggiore?
- Quando aumentano i ricavi mensili? È necessariamente sinonimo di maggiore efficienza?
- In quali categorie si concentrano i resi?
- Che relazione descrittiva emerge fra livello di sconto e margine? Quali variabili confondenti potrebbero incidere?
- Quali altre variabili vorresti raccogliere per sostenere una decisione reale?

## 8. Fase 6 — Power BI

Segui la guida dettagliata `powerbi/ISTRUZIONI_POWERBI.md`.

L'obiettivo è ottenere una dashboard con i KPI, andamento mensile, margine per categoria, resi per categoria, performance per canale e filtri interattivi. Il file `.pbix` sarà realizzato da te.

## 9. Fase 7 — Raccomandazioni per il business

Prepara **tre** proposte, ciascuna con formato:

> Evidenza nei dati → Interpretazione possibile → Azione suggerita → Indicatore da monitorare.

Esempio di metodo (non una conclusione già dimostrata):

> Se un gruppo di prodotti presenta resi superiori alla media, potrebbe essere utile analizzare le motivazioni di reso e sperimentare descrizioni prodotto più dettagliate, misurando poi il tasso resi a parità di categoria.

Evita frasi come "gli sconti causano i resi" senza un disegno sperimentale.

## 10. Risposta al colloquio: scheletro (da completare DOPO le analisi)

**Obiettivo iniziale.** "Ho realizzato un progetto personale di analisi delle vendite di un e-commerce, per comprendere le determinanti della redditività e formulare raccomandazioni operative. Ho utilizzato un dataset sintetico, costruito per simulare transazioni realistiche."

**Tipologia di dati.** "Ho analizzato le tabelle relative a clienti, catalogo prodotti, ordini e righe d'ordine del 2025: ..." [aggiungi volumi verificati]

**Strumenti.** "Ho utilizzato PostgreSQL per modellare e interrogare i dati, Python e Pandas per l'analisi esplorativa e Power BI per la dashboard." [dichiara solo le fasi che hai davvero svolto]

**Metodologia.** "Ho verificato la qualità e l'integrità dei dati, unito le tabelle tramite chiavi, calcolato KPI economici, analizzato segmenti e stagionalità, quindi confrontato i risultati su due strumenti." [personalizza]

**Risultati.** "Dall'analisi è emerso ...; ho proposto ...; monitorerei ..." [inserisci evidenze CHE HAI VERIFICATO e limiti del dataset simulato]

**Non dire** di aver lavorato per un e-commerce reale, né di aver prodotto un incremento delle performance effettivo: non sarebbe verificabile. Puoi invece dimostrare un caso completo con procedure riproducibili e decisioni ipotetiche sensate.

## 11. Checklist personale

- [ ] Ho creato le 4 tabelle in PostgreSQL
- [ ] Ho importato i 4 file CSV senza errori
- [ ] Ho fatto i controlli qualità
- [ ] So spiegare almeno 5 query SQL e il JOIN fra le tabelle
- [ ] So spiegare come si calcola margine lordo e tasso resi
- [ ] Ho eseguito personalmente lo script Python
- [ ] Ho costruito e salvato una dashboard Power BI
- [ ] Ho formulato 3 proposte supportate dai dati
- [ ] So discutere almeno 2 limiti del progetto
- [ ] Ho preparato la mia risposta orale in meno di 2 minuti

---

**Prossimo checkpoint da inviare in chat:** dopo le fasi 3 e 4, riporta il risultato di `SELECT COUNT(*) FROM portfolio.orders;` e il KPI dei ricavi netti. Possiamo quindi interpretare le query insieme, senza saltare la parte di apprendimento.
