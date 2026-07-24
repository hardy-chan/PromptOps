# PromptOps: AI-Assisted Full-Stack Code Reviewer

An automated code review hub that performs asynchronous code architecture audits using modern LLMs. Built to demonstrate senior-level software architecture, clean separation of concerns, relational database schema integrity, and background task orchestration.

## 🚀 Tech Stack & Core Architecture

The platform is split into decoupled layers optimized for performance, scalability, and asynchronous execution:

- **Frontend**: Single Page Application (SPA) built with **React**, **TypeScript**, and **Vite** for typed component state management and snappy user interactions.
- **Backend API**: Pure REST API built with **Ruby on Rails 8** exposing secure, resource-based endpoints.
- **Relational Database**: **PostgreSQL** managing data relationships across multiple tables with transaction integrity and JSONB payloads.
- **Task Queue**: **Redis** serving as the high-throughput message broker.
- **Background Worker**: **Sidekiq** handling non-blocking, multi-threaded LLM integration requests to protect the web server's event loop.

## 🛠️ System Architecture Flow

[ React + TS Frontend ] ---> POST /api/v1/projects ---> [ Rails API ]
|
(Write Record & Queue Task)
v
[ Sidekiq Worker ] <--- Pull Worker Job <--- [ Redis Message Broker ]
|
+---> Fetch OpenRouter AI API ---> Update PostgreSQL Record (Completed)


## ⚙️ Quick Start (Local Development)

### Prerequisites
- Docker Desktop running
- Node.js (v20+)
- Ruby (v3.3+)

### 1. Database Infrastructure Setup
Launch your containerized PostgreSQL and Redis databases via Docker Compose from the root directory:
```bash
docker compose up -d
```

### 2. Backend Initialization
Navigate to the backend directory, install gems, initialize your schema, and launch the API and worker processes:
```bash
cd promptops-backend
bundle install
rails db:create db:map
rails server

# In a separate terminal window:
bundle exec sidekiq
```

### 3. Frontend Initialization
Navigate to the frontend directory, install dependencies, and run the development server:
```bash
cd ../promptops-frontend
npm install
npm run dev
```
Open `http://localhost:5174/` to interact with the system.

## 🧪 Testing and CI/CD
Quality assurance is enforced automatically on every commit:
- **Backend Testing**: `bundle exec rspec` for integration and service unit tests.
- **Linter Formatting**: `bundle exec rubocop` to maintain strict community style conventions.
- **Automated Actions**: GitHub Actions workflow configuration handles containerized compilation and environment verification on pull requests.