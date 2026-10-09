# Petty Cash & Expense Tracker

A cloud-backed mobile app for tracking **petty cash**: the day-to-day cash payments that never get a formal invoice and so never make it into the accounting software.

## Why this exists

A friend runs a real estate business. A typical day looks like this: withdraw ₹50,000 in cash from the bank, then hand out ₹2,000 to one person, ₹5,000 to another, ₹1,500 for site material, and so on, all day long.

None of these payments come with an invoice, so they can't go into Tally. By evening it was hard to say exactly where the cash went, or who still owed money back.

So I built this app. He opens it, records each payment (or money he needs to collect from someone) as it happens, and the entry goes straight to a backend hosted on a VPS. Nothing lives only on the phone, so no data is lost.

## What it can do

- **Record cash in and out.** Log every expense, or money to be received, with date, amount, party (who it was paid to or received from) and remarks.
- **Attach proof.** Add photos or files (bills, receipts, chits) to any entry, and view PDFs, images and Excel sheets right in the app.
- **Reports**
  - **Date-wise:** daily totals of income, expense and balance.
  - **Monthly:** month-by-month summary.
  - **Party-wise:** filter everything paid to or received from one person.
- **Export to PDF** to share or file a report.
- **Document vault.** Scan documents with the camera or upload files, organised into nested folders.
- **Notes** for things that aren't transactions.
- **History.** Audit log of every transaction and file added, edited or deleted.
- **Multi-user, multi-organisation.** Each organisation sees only its own data; login uses JWT.

## Repository layout

| Folder | What it is |
|---|---|
| `Android App/` | The main client: a **Flutter** app (Android, plus iOS and web builds) |
| `Backend/` | **Spring Boot 2.2** REST API (Java 8, MySQL, JPA, Spring Security + JWT) |
| `Frontend/` | Earlier **React** PWA client |
| `Postman Collection/` | API collection and environments for testing |

## Running it locally

### Backend

Requirements: Java 8, Maven, MySQL 8.

```bash
mysql -u root -p -e "CREATE DATABASE expense_tracker"
```

```bash
cd Backend
export DB_USERNAME=root DB_PASSWORD=yourpassword
export JWT_SECRET=$(openssl rand -base64 64)
export SEED_USERNAME=admin SEED_PASSWORD=changeme
mvn spring-boot:run
```

Tables are created on first start, and the API listens on `http://localhost:8080/api`. The `local` profile is active by default; switch to `prod` (`application-prod.properties`) on a server.

| Variable | Purpose |
|---|---|
| `DB_USERNAME` / `DB_PASSWORD` | MySQL credentials |
| `JWT_SECRET` | Base64 JWT signing key, at least 256 bits (`openssl rand -base64 64`) |
| `SEED_USERNAME` / `SEED_PASSWORD` | Optional: login created on first start if it doesn't exist |

To deploy, `mvn package` builds `target/expense-tracker.war` for Tomcat.

### Flutter app

Set your server in `Android App/lib/build_config.dart`: `serverProdUrl` for your deployed backend, `serverTestUrl` for local (`10.0.2.2` is your computer as seen from the Android emulator). Then:

```bash
cd "Android App"
flutter pub get
flutter run
```

### React PWA (optional)

```bash
cd Frontend
npm install
REACT_APP_BASE_URL=http://localhost:8080/api npm start
```

### Postman

Import the collection and an environment from `Postman Collection/`, then set `servername`, `username` and `password` in the environment.
