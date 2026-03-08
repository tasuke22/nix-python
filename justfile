# Install dependencies
install *extras:
    uv sync {{ extras }}

# Run all checks (type check + lint fix)
check:
    ty check
    ruff check --fix .

# Run linting and format check
lint:
    nix fmt -- --fail-on-change

# Run linting with auto-fix
fix:
    ruff check --fix .
    nix fmt

# Format and auto-fix
format:
    nix fmt

# Run all tests
test:
    uv run pytest

# Run tests with coverage
coverage:
    uv run pytest --cov --cov-report=term

# Run type checking
ty:
    ty check src

# Build package
build:
    uv build
