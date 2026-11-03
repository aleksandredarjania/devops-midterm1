"""Business logic - ცალკე ფუნქციები, რომლებიც ადვილად ტესტირდება."""


def add(a: float, b: float) -> float:
    return a + b


def is_palindrome(text: str) -> bool:
    cleaned = "".join(ch.lower() for ch in text if ch.isalnum())
    return cleaned == cleaned[::-1] and len(cleaned) > 0
