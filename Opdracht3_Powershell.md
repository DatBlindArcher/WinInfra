# Opdracht Powershell

## Opdracht 3: Powershell

Maak een PDF document op in jouw text editor naar keuze waarin de gevraagde scripts te zien zijn. Bijvoorbeeld: maak een Word document, copy-paste de probleemstelling, copy-paste jouw scripts eronder, exporteer (of print) naar PDF.

Dien dit PDF document in met als naam van het document `VoornaamAchternaam_rnummer.pdf`, bv `RobbeDecraemer_r0661608.pdf`.

## Opdracht

Aangezien de beste manier om shell scripting te leren is om hiermee mee te werken van tijd tot tijd. Is de opdracht deze keer aan jullie om zelf eerst probleemstellingen voor scripting te bedenken die jullie willen oplossen en er dan een scriptoplossing voor te schrijven. Op deze manier zouden jullie dit ook verder kunnen zetten om jullie skill in scripting verder te oefenen na de opleiding.

Om te voorzien dat er wat variate van skills worden gebruikt moet je 4 scripts maken voor deze opdracht met volgende structuren:

1. Een script met een ketting zonder argumenten.
2. Een script met één of meerdere argumenten en één of meerdere berekeningen.
3. Een script met zowel een foreach als if-else statements.
4. Een script die een commando van active directory bevat. (Bekijk Microsoft AD Documentatie link uit lab7)

Voorzie dus voor elk van de scripts hierboven eerst een probleemstelling dat je wilt oplossen en deze dan op te lossen met een script. Je mag cmdlets hergebruiken van de labs maar niet volledige probleemstellingen. De eerste 3 scripts kan je dus op je PC maken, de 4e kan je alleen testen op je Windows Server VM.

Enkele voorbeelden van probleem stellingen die je kan gebruiken om een script te schrijven, je kan er ook zelf bedenken:

* Stellingen voor kettingen
  * Services Oplijsten/Filteren/Sorteren
  * Recursief alle files oplijsten met extentie .txt
  * Inhoud van het environment variable Path oplijsten
  * Nakijken of een bepaald commando onlangs is uitgevoerd
* Stellingen voor berekeningen
  * Bereken hoe langt het duurt om een file te downloaden aan een gegeven bestandsgrootte en downloadsnelheid
  * Bereken hoe lang het duurt om de afstand tussen Brussel en Oostende af te leggen met een gegeven snelheid
  * Bereken hoeveel euro je verdient over 10 jaar met een gegeven maandloon
* Stellingen voor foreach en if-else statements
  * Bereken de som van een reeks gehele getallen en controller of het resultaat positief is
  * Bereken voor een lijst van getallen of ze priem zijn
  * Filter namen uit een CSV bestand waarbij een bepaald eigenschap kan gevonden worden
  * Voor een gegeven getal les, geef alle namen van labs die tem die les gegeven zijn
* Stellingen voor Active Directory
  * Enable or Disable a user account
  * Create or Remove group
  * Edit an user account
  * Reset password of a user

Om cmdlets te vinden om je probleem op te lossen kan je best googlen met Powershell als keyword, Microsoft documentatie blijft de beste resource naar mijn bevindingen. Als je vast zit met een cmdlet dat niet werkt zoals verwacht of je begrijpt niet goed hoe het werkt, aarzel niet om te mailen.
