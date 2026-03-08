# Install dependencies
install *extras:
	uv sync {{ extras }}

# Run linting and format check
lint:
	nix fmt -- --fail-on-change

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
	uv run ty check src

# Build package
build:
	uv build
