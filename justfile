# Auto-fix + type check
fix:
    ruff check --fix .
    ty check src

# Run all tests
test:
    uv run pytest

# Run all checks (fix + test)
check:
    just fix
    just test

