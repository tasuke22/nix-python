import httpx
from pydantic import BaseModel


class User(BaseModel):
    id: int
    name: str
    email: str


def fetch_user(user_id: int) -> User:
    response = httpx.get(f"https://jsonplaceholder.typicode.com/users/{user_id}")
    response.raise_for_status()
    data = response.json()
    return User(id=data["id"], name=data["name"], email=data["email"])


def main():
    user = fetch_user(1)
    print(f"ID:    {user.id}")
    print(f"Name:  {user.name}")
    print(f"Email: {user.email}")


if __name__ == "__main__":
    main()
