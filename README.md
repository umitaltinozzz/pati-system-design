# Pati — System Design

**Complete system design package for a pet-care super app — architecture, PostgreSQL, OpenAPI and AI/3D**

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.1-6BA539?style=for-the-badge&logo=openapiinitiative&logoColor=white)](https://www.openapis.org/)
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/docs/Web/HTML)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](./LICENSE)
![Status](https://img.shields.io/badge/Status-Completed-blue?style=for-the-badge)

---

## Overview

A developer-ready design package for Pati, a pet-care super app. It covers product scope, backend architecture, the PostgreSQL schema, a validated OpenAPI contract, security, operations and the AI / 3D components — everything a development team needs to start building, in a defined order with a Definition of Done.

## Project Status

Completed design package, handed off to development. Start with `YAZILIMCI-HANDOFF.md` (Turkish).

## Features

- 60 UML views in six sections, browsable in `index.html`
- Architecture decisions summary (`PATI-MIMARI.md`)
- Validated OpenAPI 3.1.2 contract (`pati-api/openapi.yaml`)
- Module ownership and transaction boundaries
- PostgreSQL migration set (`pati-sql/migrations/`)
- Postman collection with a parallel Newman load-test runner

## Tech Stack

| Layer | Technology |
|---|---|
| API contract | OpenAPI 3.1.2 |
| Database | PostgreSQL (PL/pgSQL migrations) |
| Diagrams | UML, static HTML viewer |
| Load testing | Postman, Newman |

## Getting Started

Open `index.html` for the diagrams, or read the documents in this order:

1. `YAZILIMCI-HANDOFF.md` — implementation order and Definition of Done
2. `PATI-MIMARI.md` — architecture decisions
3. `pati-api/openapi.yaml`, `pati-api/SERVIS-SINIRLARI.md`, `pati-api/TEKNOLOJI-YIGINI.md`
4. `pati-sql/migrations/`

## Project Structure

```
pati-system-design/
├── pati/
├── pati-api/
├── pati-load-test/
├── pati-sql/
│   ├── migrations/
├── PATI-MIMARI.md
├── README.md
├── YAZILIMCI-HANDOFF.md
├── index.html
```

## License

[MIT License](./LICENSE)
