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
      Assertion.Test.assert(opr, lhs, rhs)
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    Enum.each tests, fn {test_func, description} ->
      case apply(module, test_func, []) do
        :ok -> IO.write "."
        {:fail, reason} -> IO.puts"""
          =======================
          FAILURE: #{description}
          =======================
          #{reason}
          """
      end
    end
  end
  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end
  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be equal to: #{rhs}
      """
    }
  end
  def assert(:===, lhs, rhs) when lhs === rhs do
    :ok
  end
  def assert(:===, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be exactly equal to: #{rhs}
      """
    }
  end
  def assert(:!=, lhs, rhs) when lhs != rhs do
    :ok
  end
  def assert(:!=, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      not to be equal to: #{rhs}
      """
    }
  end
  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end
  def assert(:>, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be greater than: #{rhs}
      """
    }
  end
  def assert(:>=, lhs, rhs) when lhs >= rhs do
    :ok
  end
  def assert(:>=, lhs, rhs) do
    {:fail, """
        Expected: #{lhs}
        to be equal to or greater than: #{rhs}
        """
    }
  end
  def assert(:<, lhs, rhs) when lhs < rhs do
    :ok
  end
  def assert(:<, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be less than: #{rhs}
      """
    }
  end
  def assert(:<=, lhs, rhs) when lhs <= rhs do
    :ok
  end
  def assert(:<=, lhs, rhs) do
    {:fail, """
        Expected: #{lhs}
        to be equal to or greater than: #{rhs}
        """
    }
  end
end
