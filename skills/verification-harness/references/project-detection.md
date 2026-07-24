# Project Detection

Read this file during Phase 0. Populate:

```text
PROJECT_TYPE: python | java-gradle | java-maven | node | go | rust | ruby | php | dotnet | mixed
BUILD_CMD: <command or empty>
TEST_CMD: <command or empty>
LINT_CMD: <command or empty>
TYPE_CHECK_CMD: <command or empty>
ARCH_TEST_CMD: <command or empty>
INTEGRATION_CMD: <command or empty>
E2E_CMD: <command or empty>
RUNTIME_DEPS: <commands or empty>
```

Project instructions and configured scripts override these defaults. Never invent a command when the repository provides one.

| Signal | Type | Build | Test | Lint | Type / Architecture |
|--------|------|-------|------|------|---------------------|
| `pyproject.toml`, `setup.py`, `requirements.txt` | Python | configured installer, `pip install -e .`, or `poetry install` | `pytest` | `ruff check` | `mypy`/`pyright`; `import-linter`/`lint-imports` |
| `pom.xml` | Java/Maven | `mvn compile` | `mvn test` | `mvn checkstyle:check` | configured ArchUnit task/tests |
| `build.gradle`, `build.gradle.kts` | Java/Gradle | `./gradlew build` | `./gradlew test` | `./gradlew checkstyleMain` | configured ArchUnit task/tests |
| `package.json` | Node | `npm run build` | `npm test` | `npm run lint` | `npm run typecheck` |
| `go.mod` | Go | `go build ./...` | `go test ./...` | `golangci-lint run` | configured architecture checks |
| `Cargo.toml` | Rust | `cargo build` | `cargo test` | `cargo clippy` | configured architecture checks |
| `Gemfile` | Ruby | `bundle install` | `bundle exec rspec` | `rubocop` | configured architecture checks |
| `composer.json` | PHP | `composer install` | `vendor/bin/phpunit` | `vendor/bin/phpstan` | configured architecture checks |
| `*.csproj`, `*.sln` | .NET | `dotnet build` | `dotnet test` | `dotnet format --verify-no-changes` | configured architecture checks |

If no row matches, infer commands from project instructions, a `Makefile`, CI, or existing scripts. Leave unavailable commands empty and report them as `SKIP`.

## Runtime Dependencies

Detect and run applicable setup before the build:

| Signal | Default |
|--------|---------|
| `docker-compose.yml`, `docker-compose.yaml` | `docker-compose up -d`; wait for configured health checks |
| `alembic.ini` | `alembic upgrade head` |
| `flyway.conf` | `flyway migrate` |
| `prisma/schema.prisma` | `npx prisma migrate deploy` |

If setup fails, report an environmental `FAIL` and stop later phases for that project.

## Monorepos

Discover projects from `pnpm-workspace.yaml`, `lerna.json`, Nx project files, Maven `<modules>`, Gradle `include` declarations, or independent build manifests in subdirectories.

Run Phases 1-4 per project. Continue checking unaffected projects after one fails. Run adversarial review only for changed projects based on the version-control diff. Report `N projects, M PASS, K FAIL`; any failed project makes the aggregate verdict `FAIL`.
