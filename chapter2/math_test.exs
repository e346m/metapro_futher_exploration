defmodule MathTest do
  use Assertion
  test "integers can be added and subtracted" do
    assert 1 + 1 ==2
    assert 5 - 5 == 10
  end
  test "integers can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 5 == 5
    assert 10 / 5 == 1
  end
  test "!=, ===, !==" do
    assert 4 != 2
    assert 4 != 4
    assert 4 == 4.0
    assert 4 === 4
    assert 4 === 4.0
    assert 4 !== 4
    assert 4 !== 4.0
  end
  test ">, =>" do
    assert 4 > 2
    assert 4 > 4
    assert 4 > 5
    assert 4 >= 2
    assert 4 >= 4
    assert 4 >= 5
  end
  test "<, <=" do
    assert 4 < 2
    assert 4 < 4
    assert 4 < 5
    assert 4 <= 2
    assert 4 <= 4
    assert 4 <= 5
  end
end
