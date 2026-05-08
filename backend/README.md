# Naboting API

Backend-strukturen følger opgaven:

- `db.config.js` forbinder til MySQL
- `server.js` starter Express-serveren
- `models/` indeholder database-funktioner
- `controllers/` indeholder handlinger for hver route
- `routes/` indeholder API paths

## Start

Kopier `backend/.env.example` til `backend/.env`, og tilpas database-login.

```bash
npm install
npm run api
```

## Routes

| Metode | Path | Handling |
| --- | --- | --- |
| GET | `/api/health` | Test API |
| GET | `/api/users` | Hent brugere |
| GET | `/api/users/:id` | Hent en bruger |
| POST | `/api/users` | Opret bruger |
| PUT | `/api/users/:id` | Opdater bruger |
| DELETE | `/api/users/:id` | Slet bruger |
| GET | `/api/items` | Hent genstande |
| GET | `/api/items/:id` | Hent en genstand |
| POST | `/api/items` | Opret genstand |
| PUT | `/api/items/:id` | Opdater genstand |
| DELETE | `/api/items/:id` | Slet genstand |
| GET | `/api/item-images/item/:itemId` | Hent billeder for genstand |
| POST | `/api/item-images` | Tilfoj billede |
| DELETE | `/api/item-images/:id` | Slet billede |
| GET | `/api/accessories/item/:itemId` | Hent tilbehor for genstand |
| POST | `/api/accessories` | Tilfoj tilbehor |
| DELETE | `/api/accessories/:id` | Slet tilbehor |
| GET | `/api/loans` | Hent lan |
| GET | `/api/loans/:id` | Hent et lan |
| GET | `/api/loans/borrower/:userId` | Hent brugerens lan |
| POST | `/api/loans` | Opret lan |
| PUT | `/api/loans/:id` | Opdater lan |
| DELETE | `/api/loans/:id` | Slet lan |
