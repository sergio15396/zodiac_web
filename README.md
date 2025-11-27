# Zodiac Web - Previsions Astrològiques Multilingües

## Descripció
Zodiac Web és una aplicació web que ofereix previsions astrològiques diàries per als 12 signes del zodíac en múltiples idiomes. L'aplicació obté les previsions en anglès i les tradueix automàticament a altres idiomes, proporcionant una experiència personalitzada per a usuaris de diferents regions.

## Característiques Principals
- Previsions diàries per als 12 signes del zodíac
- Suport multilingüe (Anglès, Polonès, Neerlandès)
- Interfície d'usuari intuïtiva i responsiva
- Actualització automàtica de les previsions
- Sistema de traducció automàtica integrat

## Requisits Tècnics
- PHP 8.1 o superior
- Composer
- MySQL 5.7 o superior
- Node.js i NPM (per a assets frontend)

## Instal·lació
1. Clona el repositori:
```bash
git clone [URL_DEL_REPOSITORI]
```

2. Instal·la les dependències de PHP:
```bash
composer install
```

3. Crea un arxiu `.env` a partir de `.env.example` i configura la base de dades:
```bash
cp .env.example .env
```

4. Genera la clau de l'aplicació:
```bash
php artisan key:generate
```

5. Executa les migracions:
```bash
php artisan migrate
```

6. Importa les previsions inicials:
```bash
php artisan zodiac:import-all
```

## Ús
L'aplicació està disponible a través de les següents URLs:
- Anglès: `http://zodiac_web.test/en/[sign]`
- Polonès: `http://zodiac_web.test/pl/[sign]`
- Neerlandès: `http://zodiac_web.test/nl/[sign]`

On `[sign]` pot ser qualsevol dels següents signes del zodíac:
- aries
- taurus
- gemini
- cancer
- leo
- virgo
- libra
- scorpio
- sagittarius
- capricorn
- aquarius
- pisces

## Per què Laravel i no WordPress?

### Avantatges de Laravel:
1. **Rendiment i Escalabilitat**
   - Laravel ofereix un millor rendiment per a aplicacions personalitzades
   - Millor gestió de la memòria i recursos del servidor
   - Optimitzat per a aplicacions amb moltes peticions

2. **Desenvolupament Eficient**
   - Framework MVC modern i ben estructurat
   - Sistema de migracions per a la gestió de la base de dades
   - ORM Eloquent per a una gestió eficient de les dades
   - Sistema de coles per a tasques en segon pla

3. **Seguretat**
   - Protecció CSRF integrada
   - Validació de dades robusta
   - Gestió segura de sessions
   - Menys vulnerabilitats que WordPress

4. **Manteniment**
   - Codi més net i organitzat
   - Millor control de versions
   - Més fàcil de mantenir i actualitzar
   - Menys dependències externes

5. **API i Integracions**
   - Millor suport per a APIs RESTful
   - Integració més senzilla amb serveis externs
   - Sistema de traducció automàtica més eficient

### Desavantatges de WordPress per a aquest projecte:
1. **Sobrecàrrega**
   - WordPress inclou moltes funcionalitats innecessàries
   - Base de dades més complexa del necessari
   - Consum excessiu de recursos

2. **Flexibilitat Limitada**
   - Menys control sobre l'estructura de l'aplicació
   - Més difícil d'implementar funcionalitats personalitzades
   - Limitacions en la gestió de dades

3. **Rendiment**
   - WordPress requereix més recursos del servidor
   - Menys eficient per a aplicacions específiques
   - Més lent en la gestió de peticions

## Tecnologies Utilitzades
- **Backend**: Laravel 10.x
- **Frontend**: Blade, TailwindCSS
- **Base de Dades**: MySQL
- **APIs**:
  - Zodiac API (https://www.zodiacsign.com/api)
  - Google Translate API

## Contribució
Les contribucions són benvingudes! Si us plau, segueix aquests passos:
1. Fes un fork del projecte
2. Crea una branca per a la teva feature (`git checkout -b feature/AmazingFeature`)
3. Fes commit dels teus canvis (`git commit -m 'Add some AmazingFeature'`)
4. Fes push a la branca (`git push origin feature/AmazingFeature`)
5. Obre un Pull Request

## Llicència
Aquest projecte està llicenciat sota la Llicència MIT - veure l'arxiu [LICENSE.md](LICENSE.md) per més detalls.
