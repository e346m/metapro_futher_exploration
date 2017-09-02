defmodule MathTest do
  use Assertion
  test "normal: integers can be added and subtracted" do
    assert 1 + 1 == 2
    assert 5 + 5 == 0
  end
  test "integers can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 5 == 5
    assert 10 / 5 == 1
  end
end
