from hello_world import hello, howdy


def test_hello() -> None:
    assert hello() == "Hello from hello-world! 👋"


def test_howdy() -> None:
    assert howdy() == "Howdy Y'all! 🤠"
