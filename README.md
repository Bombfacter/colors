# COLORS Web Application

A LAMP-stack web app for COP 4331, built across three labs:

- **Lab 1** — Remote Ubuntu server on DigitalOcean running LAMP (Apache, MySQL, PHP), with a custom domain (`cop4331c.lol`) and HTTPS via Let's Encrypt.
- **Lab 2** — MySQL database (`COP4331`) with `Users`, `Colors`, and `Contacts` tables, seeded with test data.
- **Lab 3** — PHP API endpoints (`Login`, `AddColor`, `SearchColors`) and a front end for logging in, adding colors, and searching them.

Live site: https://cop4331c.lol

## Structure
- `index.html`, `color.html` — front end pages
- `css/`, `js/`, `images/` — front-end assets
- `LAMPAPI/` — PHP API endpoints
- `db/schema.sql` — database schema and seed data

## Note on credentials
The MySQL credentials in `LAMPAPI/*.php` are placeholders (`DB_USER` / `DB_PASSWORD`). Replace them with real values when deploying — do not commit real database credentials.
