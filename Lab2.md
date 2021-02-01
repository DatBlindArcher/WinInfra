# Active Directory Continued

Wat we vorig labo eigenlijk hebben gedaan is het opstellen van een Single Domain Active Directory. Er zijn echter een aantal gevallen waarin we misschien naar meer gecompliceerde setups willen gaan.

## Fouttolerante Active Directory Domain Services

Een domain waarin maar één DC draait, is niet fouttolerant. Zodra die DC uitvalt, is Active Directory niet meer beschikbaar voor het hele netwerk van de organisatie. Daarom is altijd minimaal twee DC's te laten draaien nodig in een domain voor de noodzakelijke bedrijfszekerheid.

Vanaf we 2 DC's hebben op het domain kunnen we de informatie op beide servers gelijk houden met een proces dat replicatie heet. Valt één van de twee DC's weg, dan kan het netwerk alsnog verder functioneren. We laten backup tweede server ook DNS installeren waardoor deze ook DNS zal repliceren.

### ServerBU - COSCIDC2

Hiervoor ga je eerst je ServerBU machine moet opzetten en instellen.

Eerst en vooral gaan we de server een logische naam geven. Open **Server Manager** en ga naar **Local Server**. Klik op de computernaam, vervolgens op 'Change...'. Geef de server de naam 'COSCIDC2'. Om die wijzigingen door te voeren moet je de server opnieuw opstarten.

Stel ook een statisch IP in. Hiervoor neem je best het IP dat door de DHCP-server van VirtualBox is toegekend aan je server, samen met het subnet-mask en de default-gateway. Je zal ook je DNS moeten aanpassen zodat deze de andere server kan vinden.

> TIP: Je kan uiteraard altijd [op het internet rekenen](https://lmgtfy.com/?q=windows+server+2019+set+static+ip) om te ontdekken hoe dit moet.

### Mebmer Server

Nu gaan we van COSCIDC2 een member server maken van het domain COSCI. Open **Server Manager** en ga naar **Local Server**. Klik op de computernaam, vervolgens op 'Change...'. Geef dan het domain COSCI in en login met je administrator account. Vanaf nu is deze server deel van het COSCI domain en is het een member server.

### Active Directory

De volgende stap is om van COSCIDC2 een domain controller te maken door ADDS erop te installeren.

1. Klik in Server Manager op "Manage" rechtsbovenaan en selecteer "Add Roles and Features".
2. Bij Installation Type kies je voor "Role-based or feature-based installation".
3. Onder "Server Roles" kies je voor "Active Directory Domain Services", het belangrijkste onderdeel van Active Directory. Pas als dit onderdeel op de server geïnstalleerd is, spreken we van een Domain Controller.
4. Loop verder door de installatie. Deze begint vanzelf. Wanneer de installatie gedaan is krijg je de melding "Configuration required". Klik door op "Promote this server to Domain Controller". Je krijgt een venster "Deployement configuration."
5. Gezien dit onze tweede Domain Controller is, willen we deze toevoegen aan een bestaand domain. Er wordt gevraagd om een "domain name". Die is in ons geval `cosci.be`.
6. In Domain Controller laten we Domain Name System (DNS) server aangevinkt. Dit zal automatisch een DNS-server installeren voor het domein `cosci.be`. Global Catalog GC laat je ook aangevinkt, dit is de database van Active Directory. Read Only Domain Controller (RODC) laten we uit.
7. Bij Additional Options moet je bij Replicate from je primaire server selecteren, COSCIDC1.
8. Loop verder door de installer. De server moet herstart worden nadat de installatie voltooid is.

### Controle

Vanaf nu heb je 2 Domain Controllers op je netwerk die ADDS en DNS naar elkaar repliceren.

Kijk na of het replicatie proces werkt. COSCIDC2 zou nu ook de user Test en de groep System Administrators moeten hebben overgenomen.

Maak nu een nieuwe user aan op COSCIDC2 en kijk of deze repliceerd naar COSCID1. Maak ook een nieuwe user aan op COSCIDC1 en kijk of deze repliceerd naar COSCID2. Dit kan tot 20 seconden duren voordat deze aanpassingen doorkomen.

Als COSCIDC2 niet repliceerd naar COSCIDC1 wilt dit zeggen dat COSCIDC1 COSCIDC2 niet kan vinden. Waarschijnlijk is dit omdat je de sharingoptions nog niet goed hebt gezet. Zorg ervoor dat beide servers discoverable zijn op het netwerk en maak aanpassingen aan de user om nog eens het replicatie process te triggeren.

- TODO test dit
Zet nu COSCIDC1 af en kijk of je met je Windows 10 machine nog steeds kan inloggen op COSCI.

## Trees en forests

![ad](images/AD_design.png)

In bovenstaande afbeelding stelt iedere blauwe driehoek een Domain Controller (DC) voor. Zo zie je dat het bedrijf blue.com een DC heeft voor hun domeinnaam. Hun bedrijf is echter zo groot dat ze ervoor gekozen hebben dit nog verder op te splitsen in subdomeinen. Voor deze subdomeinen hebben ze ook een aparte DC gemaakt, en deze gekoppeld aan de bestaande DC voor het blue.com domein. (Herinner je een van de eerste stappen van de installatie van Active Directory, waar je moet kiezen tussen een nieuw domein aan te maken of een DC koppelen aan een bestaand domein). Hierdoor krijg je een soort hiërarchische verhouding en spreken we van een Domain Tree.

Alle resources (PC's, Users, ...) die in een van de subdomeinen worden toegevoegd, zijn in alle subdomeinen beschikbaar dankzij de automatische verbindingen die door de tree wordt gelegd. De voornaamste redenen dat men dit soort architectuur hanteert is als men zeer grote organisaties heeft, trafiek wilt verminderen naar de root DC.

Daarnaast is het ook mogelijk om verschillende trees van verschillende domeinen aan elkaar te koppelen via een trust. Stel bijvoorbeeld dat `blue.com` beslist te gaan samenwerken met `red.com`, dan kan men een trust tussen de 2 trees leggen, waardoor de resources van de ene tree "gekend zijn" in de andere tree. Zo gaan gebruikers van `blue.com` zich zelfs in de gebouwen van `red.com` kunnen aanmelden op de PC's. Voor meer info over design van een Active Directory, lees je dit [artikel](https://mcpmag.com/articles/2010/09/29/ad-design-know-your-domains.aspx).

## Organizational units & groups

Wat echter veel meer voorkomt zijn **organizational units & groups**.

### Organizational Units

Deze reflecteren vaak de structuur van de organisatie, bijvoorbeeld de OU "Werknemers", waaronder dan de OU "HR", de OU "Sales" en de OU "Engineering" terug te vinden zijn. Ze werken van een grote groep, naar steeds specifiekere groepjes, in een omgekeerd hiërarchisch model. OU's erven altijd de rechten en configuratie over van hun parent, maar kunnen verder gespecificeerd worden. **Ze worden vooral gebruikt om Group Policies op te configureren**. Een gebruiker kan ook maar in 1 van de OU's zitten, en heeft dus alleen effect van de OU waar hij in zit en degene die erboven liggen.

### Groepen

Deze hebben minder sterk die hiërarchie, en dienen vooral voor het rechten geven op bepaalde bedrijfsresources (Printers, Mailboxen, ...). Een gebruiker kan wel in meerdere groepen zitten. Ook kunnen groepen genest worden, simpelweg door een groep lid te maken van een andere groep. Alle leden zullen bijgevolg ook door de configuratie van die groep beïnvloed worden.

## User Oefeningen

### Guest & Administrator

Als eerste gaan we 2 Users aanpassen. De guest en administrator users.

Guest is een account die automatisch in ADDS zit als je dit voor het eerst installeerd. Deze is bedoeld om gebruikers zonder login toch te kunnen laten inloggen op het systeem met minimale rechten. Op onze hogeschool willen we wel een guest account. Hier moeten we het guest account zetten op enabled.

Administrator is het omgekeerde van een guest account, dit account heeft alle rechten op het domain en kan overal inloggen. Daarom staan hier vaak ook policies op om bijvoorbeeld paswoorden tijdig te moeten vernieuwen. Als voorbeeld willen we in de hogeschool het paswoord van Administator tijdig vernieuwen, dus gaan we de expiration date van ons paswoord aanpassen.

Zet nu de guest account op enabled en zet de paswoord expiration van het administrator account aan.

Kijk na of je nog kan inloggen met het guest account.

### Other Users

Het volgende dat we doen is 2 users aanmaken: Bob Jansens en xtoledo. Bob Jansens is een interim lector bij cosci. xtoledo is een account waarmee studenten hun examens mee kunnen afleggen.

Maak beide users aan. Zorg ervoor dat xtoledo geen paswoord expiration heeft en niet aangepast kan worden en dat Bob zijn paswoord moeten zetten op de volgende login.

- Geef Bob een job title van `Interim Lecturer` in de afdeling `Teaching` bij het bedrijf `Cosci`.
- Vul het telefoon nummer an adres in van Bob Jansens.
- Pas de login aan van Bob zodat hij inlogd met bob2@cosci.be want we hebben al een andere Bob bij cosci.
- Zet de logon hours van Bob zodat hij enkel kan inloggen tussen 7u en 18u en dit enkel van maandag to vrijdag.
- Zorg ervoor dat het account van Bob expires op 31 augustus, vanwege dat dan zijn contract dan stopt bij Cosci.

## Organizational Units en Groepen Oefeningen

Probeer nu op de root van het domein de volgende structuur aan te maken met behulp van OU's.

![ou](images/OUOrganigram.png)

> NOTE: Ga naar *Group Policy Management* onder Windows Administrative Tools, selecteer het domein "cosci.be" en verifieer dat deze structuur nu ook daar aanwezig is.

Maak daarnaast in de OU=Users ook de volgende groepen aan.

1. IT-admins
2. Wifi-users
3. BadgeReader-users
4. Employee-administration

En voeg IT-Admins als een groep toe aan Wifi-users. Voeg jezelf ook toe aan de IT-admins groep en controleer of je daarmee ook toegevoegd bent aan de Wifi-users groep.

### Organizational Units Locaties

De hoofdlocatie van de hogeschool Cosci is gelegen in Brussel. Kies een adres in Brussel en configureer de Organizational Units HR, ICT en Lectoren zodat zij zich bevinden op deze locatie.

De research & expertise department bevind zich echter niet op de hoofdlocatie maar bevind zich in Noord-Mechelen. Configureer de Organizational Unit Research & Expertise zodat deze zich bevind in Noord-Mechelen. Maak ook een user Marc aan en maak Marc het hoofd in Research.

## Wat moet je na dit labo minstens kennen/kunnen

- Je weet en kan aan de hand van een duidelijk schema uitleggen wat een domein tree en domein forest is (onthouden, begrijpen)
- Je kan de eigenschappen van gebruikers en groepen binnen AD DS aanpassen (begrijpen, toepassen)
- Je weet en kan uitleggen wat een OU is (onthouden, begrijpen)
- Je kan OU's aanmaken in AD DS (toepssen)
