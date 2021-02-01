# DNS

Active Directory kan niet zonder DNS. Zonder DNS kunnen andere devices de domain controller niet vinden.

## Even herhalen

DNS of Domain Name System is een service die een naam zoals `dns.google.com` omzet naar een IPv4-adres `8.8.8.8`, dit wordt ook wel name resolution (naamomzetting) genoemd.

Ping naar `dns.google.com` en `www.google.com` met het commando `ping <hostname> -4` waarbij het -4 parameter staat voor het gebruiken van IPv4. Controleer of deze IP adressen overeenkomen door dit rechtstreeks op te vragen aan een nameserver. Dit kan je doen in Powershell met `nslookup <hostname>`.

En hierbij krijgen we dus een volledig overzicht te zien van wat een DNS hoort te doen. Google heeft **records** opgeslagen in een tabel van een DNS-database. Deze records bevatten de koppeling tussen de naam en IPv4-adres. Een server waarop deze records worden opgeslagen heet een **DNS-server**, in het geval van Google is dat `dns.google.com`. Een **DNS-client**, zoals deze geinstalleerd op elke Windows PC, wordt ook wel een resolver genoemd aangezien de DNS-client een record raadpleegt op de DNS-server met een lookup. Vandaar het commando nslookup oftewel name server lookup.

Ook als je in de browser surft naar een adres als `www.reddit.com`, zal jouw DNS-client het IPv4-adres hiervan ophalen om dan te kunnen verbinden met de webserver van reddit.

Een DNS naam wordt opgebouwd uit verschillende levels van domains. Een naam als `www.google.com.` moet je eigenlijk lezen van rechts naar links. Waarbij `com` de top level domain is, `google` het domain van google en `www` een subdomain van google. Voor `www` zou je dus ook nog meerdere subdomains kunnen toevoegen. Merk ook op dat na `com` ook nog een punt staat. Dit is de manier hoe namen worden geschreven met DNS. Je kan op deze manier een lookup doen bijvoorbeeld `nslookup www.google.com.` gebruiken of zelfs `nslookup com.` om het `com` domain te zoeken.

Wanneer jouw DNS-client een record als `www.google.com` zoekt, zal deze eerst naar de DNS-server gaan die ingesteld is op jouw Windows PC. Hoe je deze kan bekijken of aanpassen kan je snel online vinden. Als er bijvoorbeeld `8.8.8.8` is ingesteld, het DNS-server van `dns.google.com`, dan zal deze DNS-server meteen het record kunnen teruggeven aangezien dit van google zelf is. Moest dit een andere DNS-server zijn die het record niet heeft, dan zal deze DNS-server je moeten doorverwijzen naar andere nameservers die dat wel kunnen weten, bijvoorbeld de nameserver `com` is een goede verwijzing. Daarom hebben DNS-servers ook records die gericht zijn naar andere DNS-servers met daarbij over welk bepaald domain ze records hebben. Op deze manier zou je helemaal tot bij de root server voor `com` kunnen geraken en deze zal dan de weg wijzen naar `dns.google.com` en dan heb je het record opnieuw. Indien er geen DNS-servers zijn die weet hebben van dit record en er zijn ook geen doorverwijzingen meer naar nameservers die naar een hoger domain level zouden gaan, dan krijg je geen IPv4-adres en kan je dus ook geen verbinding maken.

> Wat wij hier doen met het `cosci.be` domain worden geen records opgeslagen vanuit de rootserver `be` naar onze nameserver. Vandaar dat je uit een ander netwerk of gewoon op het internet het domain `cosci.be` niet zal vinden. De Windows PC op hetzelfde netwerk in ons labo kan dit wel vinden, omdat wij de domain controller zelf als DNS-server hebben ingesteld. Ons domain op het internet vinden is ook niet de bedoeling van deze labo's, maar indien je je toch afvraagd hoe je ervoor zorgt dat jou domain wel zichtbaar is op het internet, dan zal je je domain moeten registreren op een rootserver. Dit kan je doen door naar domain name providers te gaan zoals `namecheap` waarop je een domain kan kopen.
