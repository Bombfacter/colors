# COLORS Web Application

A simple LAMP-stack (Linux, Apache, MySQL, PHP) web application built for COP 4331. A logged-in user can add colors to a personal list and search that list back. The project was built across three lab phases — provisioning a remote server, standing up the database, and implementing the API — and is deployed live on a DigitalOcean droplet.

**Live site:** https://cop4331c.lol

This README assumes the reader has not attended any of the lab sessions this project was built in.

## Description

COLORS is a minimal full-stack demo app that exercises the whole LAMP pipeline end to end:

- A user logs in with a username/password.
- Once logged in, they can add a new color name to their personal list.
- They can search their list of colors by (partial) name.
- Each user's colors are private to their account (scoped by `UserID` in the database).

There is no sign-up flow — user accounts are seeded directly into the database (see [Setup](#setup)).

## Technologies Used

- **Frontend:** plain HTML, CSS, and vanilla JavaScript (`XMLHttpRequest` for API calls, no framework)
- **Password hashing (client-side):** [blueimp JavaScript-MD5](https://github.com/blueimp/JavaScript-MD5)
- **Backend:** PHP (`mysqli` extension) — three standalone API endpoints, no framework
- **Database:** MySQL
- **Server:** Ubuntu (via DigitalOcean's LAMP Marketplace image), Apache 2.4
- **TLS:** [Let's Encrypt](https://letsencrypt.org/) via `certbot`, with automatic HTTP → HTTPS redirect and renewal

## Project Structure

```
colors/
├── api/                  # PHP backend endpoints
│   ├── Login.php
│   ├── AddColor.php
│   └── SearchColors.php
├── public/               # Front end, served from Apache's web root
│   ├── index.html        # login page
│   ├── color.html        # add/search page (post-login)
│   ├── css/styles.css
│   ├── js/code.js        # API calls, login/session/cookie logic
│   ├── js/md5.js         # third-party MD5 library
│   └── images/background.png
├── db/
│   └── schema.sql        # table definitions + seed data
├── LICENSE.md
└── README.md
```

## Setup

These are the high-level steps used to build and deploy this project; they assume a fresh Ubuntu server (a DigitalOcean droplet, in this case) and a domain name pointed at it.

1. **Provision the server.** Create a droplet from DigitalOcean's "LAMP on Ubuntu" Marketplace image (Apache, MySQL, and PHP come pre-installed). Point a domain's DNS `A` record at the droplet's IP address.
2. **Enable HTTPS.** Run `certbot --apache -d yourdomain.com` on the server to obtain a free Let's Encrypt certificate and configure Apache to redirect HTTP to HTTPS automatically.
3. **Create the database.** Log into MySQL (`mysql -u root -p` or `sudo mysql`) and run [`db/schema.sql`](db/schema.sql) to create the `COP4331` database, its three tables (`Users`, `Colors`, `Contacts`), and seed data.
4. **Create an application-level DB user** (separate from the MySQL root account) and grant it access to only the `COP4331` database:
   ```sql
   CREATE USER 'appuser'@'%' IDENTIFIED BY 'a-real-password';
   GRANT ALL PRIVILEGES ON COP4331.* TO 'appuser'@'%';
   ```
5. **Deploy the code.** Copy the contents of `public/` to Apache's web root (`/var/www/html/`) and `api/` into a subdirectory of it (e.g. `/var/www/html/api/`).
6. **Fill in real DB credentials.** Each file in `api/` has a placeholder connection line:
   ```php
   $conn = new mysqli("localhost", "DB_USER", "DB_PASSWORD", "COP4331");
   ```
   Replace `DB_USER` / `DB_PASSWORD` with the application-level credentials created in step 4 — **only on the deployed server**. These real values are intentionally not committed to this repository (see [Note on Credentials](#note-on-credentials)).
7. **Update the API base URL.** In `public/js/code.js`, set `urlBase` to your own domain, e.g. `https://yourdomain.com/api`.

## How to Run and Access the Application

This is a deployed server application, not a local dev project you `npm start` — it's meant to be accessed as a live website:

1. Go to **https://cop4331c.lol**.
2. Log in with a seeded test account, e.g.:
   - Username: `AYadavally`, Password: `COP4331`
   - Username: `SamH`, Password: `Test`
3. On the color page, add a new color and search for existing ones.

To run your own copy, follow [Setup](#setup) above against your own server and database.

## Note on Credentials

The `mysqli()` connection lines committed in `api/*.php` use placeholder values (`DB_USER` / `DB_PASSWORD`), and `db/schema.sql`'s `CREATE USER` statement uses `REPLACE_WITH_REAL_PASSWORD`. **No real database password, API key, or server-specific configuration is committed to this repository.** Real credentials exist only on the deployed server itself.

## Assumptions and Limitations

- Passwords are hashed with MD5 client-side before being sent to the server. MD5 is cryptographically broken by modern standards; it was used here to match the course's reference implementation and is **not** appropriate for a real production system (a modern algorithm like bcrypt/argon2, applied server-side, would be the correct approach).
- Session state is kept in a plain, non-`httpOnly` browser cookie with a 20-minute expiry — there's no server-side session store or token refresh.
- There is no CSRF protection, input sanitization beyond parameterized queries, or rate-limiting on the login endpoint.
- There is no user registration flow; accounts are seeded directly via SQL.
- The app assumes a single MySQL database shared by all three API endpoints and does not use any ORM or migration tooling — schema changes are manual, tracked only in `db/schema.sql`.
- Tested manually against Ubuntu 24.04 / Apache 2.4 / PHP 8 / MySQL 8 (DigitalOcean's LAMP Marketplace image); other LAMP versions are not verified.
- No automated tests are included.

## AI Usage Disclosure

Per this course's AI Use Policy, this section documents where and how AI assistance (Claude, by Anthropic, running as Claude Code) was used while building this project.

AI assistance was used for two kinds of work on this project: turning the "Getting Started with LAMP" instructions into concrete server-side steps (SSH into the DigitalOcean droplet, create the MySQL database/tables/seed data and an application-level DB user, lay out the `api`/`public` directories, deploy the files), and troubleshooting a handful of deployment bugs that only showed up once the app was live.

The troubleshooting followed the same pattern each time: describe the symptom, propose a hypothesis, test it, and act on whatever the test actually showed rather than guessing further. A few examples:

- The API worked when tested by hitting the droplet's IP address directly, but returned nothing over the actual domain. The hypothesis was a DNS problem; checking the registrar's DNS panel turned up a leftover "WebsiteBuilder Site" placeholder record sitting alongside the correct `A` record for the same host, which was removed.
- After that fix, the domain still wouldn't load in the browser, first with a connection timeout and then with `ERR_CONNECTION_REFUSED`. The next hypothesis was DNS caching — both the OS resolver and Chrome keep their own caches independently of the registrar's TTL — so both were flushed.
- The refusal turned out to be specific to HTTPS. Checking which ports Apache was actually listening on (`ss -tlnp`) showed only port 80 was open, and Chrome was auto-upgrading the address-bar request to `https://` and hitting a closed port 443. Since the campus network the site needed to work on appeared to require HTTPS specifically, the fix was to issue a real certificate with `certbot` and enable the HTTP→HTTPS redirect, rather than just forcing plain `http://` links.
- Separately, the course-provided starter `code.js` had its password-hashing line commented out, while the seeded `Users` table stored MD5-hashed passwords — meaning no login could ever match. This was caught by reasoning through the mismatch (hash algorithm on one side, plaintext on the other) rather than by trial and error, confirmed by hashing the known test passwords and comparing them to the stored values, then re-enabling the hashing call.
- Once HTTPS was live, the login button appeared to do nothing at all, with no visible error. Rather than guessing, the browser's own DevTools console was checked, which surfaced a "mixed content" warning — the page was being served over HTTPS but an old, browser-cached copy of `code.js` was still requesting the plain-HTTP API URL from before the certificate existed. Disabling the cache and hard-reloading confirmed that was the whole problem.

The AI also drafted the placeholder database-credential lines in the PHP files (real generated credentials were only ever placed on the live server, never in anything committed here), and helped organize this repository — restructuring files into `api/`/`public/` and drafting this README, `.gitignore`, and `LICENSE.md`.

Every fix above was verified against the live server before being trusted, not just accepted because the AI proposed it: each endpoint was tested directly with `curl` in addition to through the browser, and the full user flow — invalid login, valid login, adding a color, and searching for it again after closing the browser and logging back in — was run by hand end to end. The database schema, credential handling, and repository layout were likewise reviewed rather than taken as-is.
