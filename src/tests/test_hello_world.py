from hello_world import hello, howdy


def test_hello() -> None:
    assert hello() == 0


def test_howdy() -> None:
    assert howdy() == 0
