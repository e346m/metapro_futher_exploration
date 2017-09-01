defmodule Assertion do
  defmacro __using__(__options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end
  defmacro __before_compile__(env) do
    quote do
      def run do
        Assertion.Test.run(@tests, __MODULE__)
      end
    end
  end
  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end
  defmacro assert({opr, _, [lhs, rhs]}) do
    quote bind_quoted: [opr: opr, lhs: lhs, rhs: rhs] do
      receive do
        {sender} -> send sender,
          Assertion.Test.assert(opr, lhs, rhs, :assert)
      end
    end
  end
  defmacro refute({opr, _, [lhs, rhs]}) do
    quote bind_quoted: [opr: opr, lhs: lhs, rhs: rhs] do
      receive do
        {sender} -> send sender,
          Assertion.Test.assert(opr, lhs, rhs, :refute)
      end
    end
  end
end

defmodule Assertion.Test do
  @fail "It must be false or nil"
  def run(tests, module) do
    Enum.each tests, fn {test_func, description} ->
      pid = spawn(module, test_func, [])
      render_via_process(pid, description)
    end
  end
  def render_via_process(pid, description) do
    send pid, {self}
    try do
      receive do
        :ok -> IO.write "."
        {:fail, reason} -> IO.puts """

          =======================
          FAILURE: #{description}
          =======================
          #{reason}
          """
        after 500 ->
          throw :break
      end
      render_via_process(pid, description)
    catch
      :break -> :ok
    end
  end
  def check(boolean, label) do
    case label do
      :assert -> boolean
      :refute -> !boolean
    end
  end
  def assert(boolean, label, message \\ @fail) do
    case check(boolean, label) do
      true -> :ok
      false -> {
        :fail,  message
      }
    end
  end
  def assert(:==, lhs, rhs, label) when lhs == rhs do
    assert(true, label)
  end
  def assert(:==, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      to be equal to: #{rhs}
      """
    )
  end
  def assert(:===, lhs, rhs, label) when lhs === rhs do
    assert(true, label)
  end
  def assert(:===, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      to be exactly equal to: #{rhs}
      """
    )
  end
  def assert(:!=, lhs, rhs, label) when lhs != rhs do
    assert(true, label)
  end
  def assert(:!=, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      not to be equal to: #{rhs}
      """
    )
  end
  def assert(:!==, lhs, rhs, label) when lhs !== rhs do
    assert(true, label)
  end
  def assert(:!==, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      not to be exactly equal to: #{rhs}
      """
    )
  end
  def assert(:>, lhs, rhs, label) when lhs > rhs do
    assert(true, label)
  end
  def assert(:>, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      to be greater than: #{rhs}
      """
    )
  end
  def assert(:>=, lhs, rhs, label) when lhs >= rhs do
    assert(true, label)
  end
  def assert(:>=, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      to be equal to or greater than: #{rhs}
      """
    )
  end
  def assert(:<, lhs, rhs, label) when lhs < rhs do
    assert(true, label)
  end
  def assert(:<, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      to be less than: #{rhs}
      """
    )
  end
  def assert(:<=, lhs, rhs, label) when lhs <= rhs do
    assert(true, label)
  end
  def assert(:<=, lhs, rhs, label) do
    assert(false, label, """
      Expected: #{lhs}
      to be equal to or greater than: #{rhs}
      """
    )
  end
end
