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

AI assistance was used throughout most phases of this project: interpreting the "Getting Started with LAMP" instructions and turning them into concrete commands; executing and troubleshooting the server-side setup (SSH into the DigitalOcean droplet, creating the MySQL database/tables/seed data, creating an application-level MySQL user, and setting up the `api`/`public` directory structure on the server); and diagnosing a series of live deployment bugs. Concretely, prompts used included things like *"i have the droplet set up, the domain is cop4331c.lol, now what is the next step"*, *"how do you do this for me"* (asking the assistant to run the setup commands directly via SSH rather than dictating each command back to be typed manually), and, later, debugging prompts such as *"neither login works, button does nothing"* and *"i think it needs to be https to work on the school wifi, it works on my phone"* when the deployed site was failing intermittently. The AI diagnosed and fixed several concrete issues this way: a stale/duplicate DNS `A` record in the domain registrar pointing to the wrong IP, a missing HTTPS listener on the server (resolved by provisioning a Let's Encrypt certificate with `certbot`), a hardcoded API URL and a commented-out MD5-hashing call left over in the course-provided starter `code.js` that prevented login from ever succeeding once passwords were hashed in the database, and a browser "mixed content" block caused by stale cached JavaScript. The assistant also generated the initial PHP API files' database-credential placeholders (substituting real generated credentials only on the live server, never in files intended for this repository), and helped organize this repository itself — restructuring files into `api/`/`public/`, and drafting this README, the `.gitignore`, and `LICENSE.md`.

All AI-suggested commands and code changes were run against the live server and verified manually end-to-end (valid login, invalid login, adding a color, and searching for it after closing and reopening the browser and logging back in) before being considered done, consistent with the course policy of not blindly trusting AI output. The database schema, credential handling, and repository structure choices were reviewed and confirmed by the author rather than accepted automatically.
