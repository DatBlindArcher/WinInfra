# Dynamic Host Configuration Protocol

In tegenstelling tot DNS is DHCP niet noodzakelijk voor het functioneren van Active Directory. DHCP kan evengoed geleverd worden door een DHCP server die niet deel is van het domein maar wel van hetzelfde netwerk. Toch is het handig om deze services op één plaats te hebben en kunnen we eveneens ook fouttolerante DHCP opzetten aangezien we 2 servers hebben.

## IPv4 adressen

Om een machine met een netwerkkaart op een netwerk te kunnen laten communiceren heeft deze een IP-adres nodig. Deze IP-adressen kunnen op 2 manieren toegekend worden:

* Statisch
* Dynamisch

Voor dit lab gaan we enkel gebruik maken van IPv4-adressering.

### Statische IPv4-adressen

Statische adressen zijn we in vorige labs al een paar keer tegen gekomen. Zo hebben we COSCIDC1 en COSCIDC2 elk een statisch IPv4-adres gegeven. Om statische adressen op te zetten, moet je dus deze manueel opzetten op de machine zelf.

Je kan op deze manier kleine netwerken opbouwen als je met minder dan 10 machines werkt, dan hoef je ook geen DHCP server op te zetten. Maar in het geval dat het er een honderdtal machines of meer zijn, zal dit eerder een lastig klusje worden. Je moet niet alleen op elke machine een IPv4-adres instellen, al deze IPv4-adressen moeten ook bijgehouden worden zodat 1 adres niet aan 2 machines wordt uitgegeven.

Nu, dit is geen opstelling van enkel statisch of dynamisch. In realiteit gaan we zowel gebruik maken van statische adressering als dynamische adressering op één netwerk. Er zijn machines die je beter wel statisch adresseerd zoals DHCP-servers, DNS-servers, webservers, mailservers, FTP-servers, file servers en nog meer. Aangezien je deze servers zou willen terugvinden in DNS, denk aan DNS-records. In het geval van domein controllers wordt er zelfs een statisch adres verplicht.

### Dynamische IPv4-adressen

Dynamische IPv4-adressen worden uitgedeeld door een server met een DHCP-functie, deze noemt men dan een DHCP-server. Het doel van deze server is om elke niet-statische geconfigureerde machine op het netwerk een uniek IPv4-adres te geven.

> Aangezien er altijd een beperkte voorraad aan IPv4-adressen zijn, kunnen deze toegekende adressen aan machines na verloop van tijd veranderen naar andere adressen. Dit is waarom je op je Windows 10 machine met het commando `ipconfig` niet altijd hetzelfde IP-adres had als daarvoor.

### DHCP-server op Routers

Bij de meesten van ons thuis, krijgen onze privé machines IP-adressen van een DHCP-server die op de modem of router staat. Dit is op dit moment ook het geval in VirtualBox, waarbij de host-only network router een DHCP-server is. Maar DHCP moet niet bepaald op een router staan op het netwerk om te functioneren.

Elk machine heeft voor elk netwerk, waarmee deze verbonden is, een apart netwerkkaart. Een router heeft 2 netwerkkaarten, één voor binnen het netwerk en één voor het internet. Een GSM heeft ook 2 netwerkkaarten, één voor WIFI en één voor datanetwerk.

Dit wilt dus zeggen dat binnen een netwerk elke machine één netwerkkaart heeft en om al deze netwerkkaarten een adres te geven, moet enkel één machine de verantwoordelijkheid nemen. Vaak is dit de router zijn, maar je kan deze verantwoordelijkheid ook aan een willekeurige machine geven op het netwerk. Zolang er maar 1 DHCP server werkt over een bepaald bereik van IP-adressen op het netwerk, het mag dus niet mogelijk zijn dat 2 DHCP servers hetzelfde adres kunnen uitdelen.

> Met een GSM kan je vaak enkel een WIFI hotspot aanzetten als jeje WIFI uitschakeld. Dit is vanwege dat de WIFI hotspot jouw WIFI-netwerkkaart in gebruik neemt voor een eigen WIFI netwerk.

## DHCP Werking

Een DHCP-server kent IP adressen toe aan DHCP-clients, maar dat gebeurt niet elke keer dat de client opstart. De client en server gaan de link tussen de client en een IP-adres onthouden met een bepaalde leaseduur. Naast de leaseduur worden er ook op de client nog enkele andere instellingen opgeslagen, zoals domain name, default gateway en DNS-servers.

> Je kan deze instellingen eens bekijken met het commando `ipconfig /all`. Dit kan zowel in de Windows 10 VM als jouw eigen computer.

Wanneer een machine zich voor het eerst op een netwerk bevindt, dan zal de machine als DHCP-client het DHCP proces starten.

* De client stuurt een (broadcast) verzoek uit om een IPv4-adres op het netwerk, dit noemt men een `DHCP-discover`.
* Elke DHCP-server antwoordt op dat verzoek door een IPv4-adres met bijhorende leasetermijn aan te bieden, namelijk een `DHCP-offer`.
* De client accepteerd het eerste aanbod en stuurt een bevestiging van ontvangst. Daarbij verzoekt (met broadcast) de client om het IPv4-adres gedurende het volledige leasetermijn te gebruiken, m.a.w. een `DHCP-request`. Ookal is deze request in broadcast, dit bericht bevat het adres van de gekozen DHCP-server waardoor andere DHCP-servers niet zullen inspringen.
* Tenslotte stuurt de DHCP-server het IPv4-adres, leaseduur en andere TCP/IP instellingen met een `DHCP-ACK` (Acknowledgement).
* De client kan vanaf nu deze instellingen gebruiken en de server registreerd de link.

Indien de client al een IPv4-adres had en het leasetermijn is verlopen dan zal de client deze proberen te vernieuwen, door meteen met het `DHCP-request` in het proces te starten, dit noemt men `lease renewal`. Clients gaan gewoonlijk niet wachten tot de leasetermijn verlopen is gaan deze tijdelijk vernieuwen, bijvoorbeeld elke keer de machine opstart.

Als de client zijn lease niet kan vernieuwen, omdat het adres niet meer gelinkt is op de server of geleased is aan een andere client, dan zal de server op het `DHCP-request` antwoorden met een `DHCP-NAK` (Negative Acknowledgement). In dit geval moet de client het hele DHCP proces starten met een `DHCP-discover`.

> Je kan ook commando's gebruiken om sommige functies op te roepen. `ipconfig /release` zal de link tussen jouw IPv4-adres en machine verwijderen. `ipconfig /renew` start het lease renewal proces. Probeer deze functies eens uit in je Windows 10 VM.

### DHCP Transportlaag

DHCP werkt volledig bovenop UDP want:

* Het zijn allemaal kleine eenmalige packetjes, een onderhouden connectie is niet nodig.
* DHCP gebruikt broadcast en broadcasting is niet mogelijk met TCP. TCP onderhoud een connectie altijd tussen 2 machines, waardoor deze geen broadcasting ondersteund.

## DHCP in Active Directory

We gaan nu een DHCP installeren op COSCIDC1. Voordat we hieraan beginnen moet je de DHCP server uitzetten van het host-only netwerk van VirtualBox.

> Je kan deze uitzetten onder `File > Host Network Manager ...`

### DHCP Installatie

Het installeren van DHCP komt neer op het installeren van de server role DHCP Server en die vervolgens configureren.

* Start COSCIDC1 op
* Log in met domein admin account
* Onder `Manage` klik `Add Roles and Features`
* Role-based or feature-based installation
* Selecteer COSCIDC1 server
* Selecteer DHCP Server
* Stap verder doorheen de wizard en instal (LET OP: sluit na installatie het venster niet)
* In het installatie venster, klik op de link `Complete DHCP configuration` onder DHCP Server

![DHCP Install](images/DHCPInstall.png)

* Onder Authorization selecteer `Skip AD authorization` en Commit
* Sluit alle vensters en herstart de server

### DHCP Configuratie

Open nu het DHCP configuratie venster, deze kan je vinden onder `DHCP > DHCP Manager` of `Tools > DHCP`. Selecter IPv4, je scherm zou er nu als volgt moeten uitzien:

![DHCP Manager](images/DHCPManager.png)

Op het info scherm lees je dat je een scope moet aanmaken en de server alsnog moet autorizeren.

#### DHCP Scope

Een DHCP scope is een bereik van IP adressen, deze worden gedefinieerd door een inclusief start-adres en inclusief eind-adres. Binnenin een scope kunnen we dan nog blokken definieren die de scope niet mag gebruiken. Een DHCP server is dan uiteindelijk opgebouwd uit één of meerdere van deze scopes.

Voordat we deze gaan configureren moeten we eerst eens nadenken over welke scopes we willen definieren. We moeten het bereik van ons subnetwerk opdelen in stukjes. Op deze manier kunnen we een stukje geven aan servers, printers, computers en reserve.

Deel nu je subnetwerk op, hieronder een voorbeeld van het subnetwerk 10.10.10.0 /24.

* Domain Controllers: 10.10.10.1 - 10.10.10.10
* (Web, FTP, ...) Servers: 10.10.10.11 - 10.10.10.30
* Printers: 10.10.10.31 - 10.10.10.40
* Computers: 10.10.10.41 - 10.10.10.250
* Reserve: 10.10.10.251 - 10.10.10.254

Nadat je deze opstelling hebt gemaakt, kunnen we deze scopes nu gaan configureren. Onder IPv4 gaan we de scope voor computers aanmaken:

* Ga van start met `New Scope`
* Geef een naam in zoals `ComputerScopeDC1`
* Het start en eind adres zoals je deze opgelijst had (10.10.10.41 - 10.10.10.250)
* Vul het subnet mask in doormiddel van length (/24) of de mask zelf (255.255.255.0)
* Vervolgens komen we aan het exclusions gedeelte

![DHCP Excl](images/DHCPExcl.png)

#### DHCP Fouttolerantie

Hierbij willen we even stilstaan omdat we exclusions gaan moeten maken. Maar waarom? Tot nu toe is alles makkelijk op te zetten, maar we gaan in een latere stap fouttolerantie willen verbeteren voor DHCP net zoals we dat gedaan hebben voor het domein en DNS.

DHCP is jammerlijk niet zo geintigreerd in active directory als DNS. DHCP servers gaan elkaar niet up to date houden en gaan ook niet dezelfde settings overnemen. De twee DHCP servers die we dus gaan installeren zullen ook 2 echte DHCP servers zijn en active directory gaat hiet verder niets mee doen.

Het is dus aan ons om de problemen op te lossen indien we 2 DHCP servers opzetten op 1 netwerk. Het gevaar met meerdere DHCP servers op te zetten is dat 2 DHCP servers éénzelfde IP-adres kunnen uitdelen aan 2 verschillende machines. De oplossing hiervoor is om te voorkomen dat éénzelfde adres kan uitgedeeld worden met behulp van scopes en exclusies.

We gaan op beide DHCP servers dezelfde scopes configureren, maar we gaan exclusies maken op welk deel elke DHCP server mag uitdelen. Door het configureren van een exlcusie zal de DHCP server deze adressen niet uitdelen en kan de andere DHCP server dat wel doen.

Ik ga mijn scope opdelen in ongeveer 2 gelijke delen: 10.10.10.41 - 10.10.10.150 en 10.10.10.151 - 10.10.10.250. Het eerste deel wil ik gebruiken voor COSCIDC1 dus het tweede deel zal ik een exclusie van moeten maken.

* Voeg de exlcusie toe met inclusief begin-adres en inclusief eind-adres (10.10.10.151 - 10.10.10.250)
* Stel het leaseduur in op 7 dagen
* DHCP options om TCP/IP instellingen te beheren willen we configureren, `Yes, I want to configure these options now`
* Het host-only network van VirtualBox voorziet ons van een router. Het adres van deze router heb je ingesteld in VirtualBox, gebruik deze als default gateway (10.10.10.1)
* In het volgende venster staat het domein al juist. Maar de DNS servers nog niet. Maak eerst deze lijst leeg. Start COSCIDC2 op, wanneer deze opgestart is voeg de IP-adressen toe van zowel COSIDC1 als COSCIDC2 (10.10.10.2, 10.10.10.3). De wizard gaat proberen een connectie te maken, als er geen waarschuwing komt is deze gelukt en dan ben je zeker dat dit de juiste adressen zijn. Indien niet moet je de status van je servers en hun adressen nakijken.

![DHCP DNS](images/DHCPDNS.png)

* Het volgende is WINS, dit is een verouderd systeem van Windows, rond de tijd van Windows 95, die hetzelfde doel had als DHCP maar met een andere werkwijze. WINS zorgt voor de omzetting van een machine's NetBIOS-name naar een IPv4-adres. Dit gaan we niet nodig hebben dus laat deze zoals het is. Weet gewoon dat dit bestaat en dat sommige oudere systemen hierop zouden kunnen werken.
* We gaan de scope nog <ins>niet</ins> activeren omdat we nog de eigenschappen willen bekijken voordat we dat doen en we moeten nog autoriseren.
* Finish

Voor nu dezelfde stappen uit om DHCP Server te installeren op COSCIDC2, het enige verschil is de exclusie onder je DHCP scope en de naam van deze scope is dan `ComputerScopeDC2`.

### DHCP Eigenschappen

Voordat we DHCP activeren, kunnen we eens zonder zorgen rondkijken naar wat de DHCP Manager te bieden heeft.

In je DHCP Manager:

* Rechtermuisklik op je server (coscidc1.cosci.be) > properties, hier zie je waar alles van je DHCP server wordt opgeslagen. Er worden automatische backups gemaakt, deze kan je dus hier ook vinden.
* Vouw je scope open en je ziet 5 folders:
  * Address Pool: hier ze je jouw geconfigureerde bereiken, inclusief en exclusief
  * Address Leases: hier zie ja alle adressen die door deze scope momenteel zijn uitgeleend, momenteel zal deze leeg blijven
  * Reservations: hier kan je specifieke adressen reserveren aan machines op basis van het MAC-adres. Open eens New Reservation en dan kan je zien wat hiervoor nodig is. Anulleer deze acite.
  * Scope Options: hier zie je allerlei opties die wel al geconfigureerd hebben bij het aanmaken. Deze opties worden meegegeven aan de client voor TCP/IP instellingen. Er zijn echter nog veel meer opties, deze kan je eens bekijken onder Configure options.
  * Policies: bij deze kan je policies aanmaken waarmee je DHCP settings kan instellen op basis van bijvoorbeeld een MAC adres.
* Rechtermuisklik op je scope > properties:
  * Onder General zie je nogmaals de instellingen die je geconfigureerd had.
  * Onder DNS kan je zien hoe DHCP en DNS samenwerken, wanneer een client een adres krijgt, zullen de A en PTR records hiervoor geupdate worden.

### DHCP Autoriseren

Door een DHCP server te autorisen neem je DHCP op in active directory. Vanaf dan zal DHCP service geleverd worden aan computers van het domein. Windows Server 2019 voorkomt hiermee ook dat vreemde DHCP-servers van derden IP-adressen uitdeeld aan computers van het domein. En niet-geautoriseerde DHCP server op Windows schakelt zichzelf uit.

Op COSCIDC1 in DHCP Manager, rechtermuisklik op je server (coscidc1.cosci.be) en dan Authorize. Deze knop wordt dan vervangen door Unauthorize indien je deze wilt uitzetten.

Nu dat je DHCP server geautoriseerd is, activeer de scope. Er zou dan een groene checkmark moeten komen bovenop je DHCP server.

![DHCP Check](images/DHCPCheck.png)

Autoriseer en activeer nu ook op COSCIDC2.

### DHCP Troubleshooting

Om snel DHCP te kunnen troubleshooten kan je gebruiken maken van de commando's `ping` en `ipconfig`.

Start je Windows 10 VM op en en ping naar `127.0.0.1`, indien dit mislukt zullen de TCP/IP waarschijnlijk fout staan. Kijk ook `ipconfig /all` na, hierin kan je alle settings vinden, verder kan je met `ipconfig` ook acties gebruiken als `release` en `renew` indien nodig.

Normaal heeft je machine nu een adres gekregen vanuit de scope. Kijk ook eens na of in de scope nu het uitgeleende adres voorkomt. Deze kan uitgeleend zijn door één van de servers, kijk dus in beide.

## Wat moet je na dit labo kennen/kunnen

* Je weet het verschil tussen statische en dynamische IPv4-adressering.
* Je kent de werking van dynamische IPv4-adressering via DHCP.
* Je kan het hele proces van DHCP in eigen woorden uitleggen met proces benamingen.
* Je weet hoe je een DHCP server kan opzetten.
* Je weet hoe je de fouttolerantie van DHCP kan verbeteren.
* Je kan een DHCP server autoriseren in active directory.
* Je weet hoe je DHCP scopes kan opzetten.
* Je begrijpt de eigenschappen van een DHCP server.
* Je kan met het `ipconfig` commando werken.
