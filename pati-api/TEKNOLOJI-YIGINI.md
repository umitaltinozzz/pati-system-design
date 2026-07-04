# Pati — Kesin Teknoloji Yığını

Bu karar seti MVP ve ilk ölçeklenme dönemi için bağlayıcıdır. Değişiklik ADR ile yapılır.

## Uygulamalar

| Alan | Seçim |
|---|---|
| Mobil | React Native + Expo, TypeScript |
| Web / İşletme / Admin | Next.js App Router, React, TypeScript |
| 3D Web/Mobil | Three.js + React Three Fiber; glTF/GLB, KTX2/Basis, Meshopt |
| İstemci state | TanStack Query; yerel UI state için Zustand |
| Form / doğrulama | React Hook Form + Zod |
| Tasarım sistemi | Storybook, design token, WCAG 2.2 AA |

## Backend

| Alan | Seçim |
|---|---|
| Runtime | Node.js 24 LTS |
| API framework | NestJS, TypeScript, REST/OpenAPI 3.1.2 |
| Mimari | Modüler monolit; domain sınırları package + DB sahipliği ile korunur |
| ORM / SQL | Drizzle ORM + elle yazılmış performans kritik SQL |
| Ana veritabanı | PostgreSQL 18 güncel minor |
| Cache / kilit | Redis |
| Async iş | NATS JetStream; transactional outbox |
| Workflow | Temporal: rezervasyon timeout, ödeme, payout ve veri silme workflow'ları |
| Arama | İlk sürüm PostgreSQL full-text + geo; ölçek kapısında OpenSearch |
| Object storage | S3 uyumlu obje deposu + CDN |

## AI ve 3D

| Alan | Seçim |
|---|---|
| AI Gateway | Python 3.13 + FastAPI |
| Model serving | NVIDIA Triton; küçük modeller ONNX Runtime |
| Batch/GPU job | Kubernetes Job + NATS job kuyruğu |
| Model registry | MLflow |
| Deney / veri lineage | MLflow + object storage immutable artefact |
| Vector store | PostgreSQL pgvector; ayrı vector DB başlangıçta yok |
| 3D pipeline | PyTorch, Open3D, Blender headless, glTF Transform |
| Gözlem | OpenTelemetry + Prometheus + Grafana + Loki + Tempo |

## Platform

| Alan | Seçim |
|---|---|
| Container | Docker |
| Orkestrasyon | Kubernetes; API ve worker ayrı deployment |
| IaC | Terraform |
| GitOps | Argo CD |
| CI | GitHub Actions |
| Secret / key | Cloud KMS + external secret operator |
| Edge | CDN + WAF + rate limit |
| Hata izleme | Sentry |

Node.js 24 üretim için LTS hattıdır. PostgreSQL 18 desteklenen güncel majördür. API sözleşmesi OpenAPI 3.1.2 olarak sabitlenmiştir; 3.2 özellikleri kullanılmaz.

