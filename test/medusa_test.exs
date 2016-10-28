defmodule MedusaTest do
  use ExUnit.Case
  doctest Medusa

  test "not config should fallback to default" do
    Application.delete_env(:medusa, Medusa, persistent: true)
    Application.stop(:medusa)
    Application.ensure_all_started(:medusa)
    assert Application.get_env(:medusa, Medusa) ==
      [adapter: Medusa.Adapter.Local]
  end

  test "config invalid adapter should fallback to Local" do
    Application.put_env(:medusa, Medusa, [adapter: Wrong], persistent: true)
    Application.stop(:medusa)
    Application.ensure_all_started(:medusa)
    assert Application.get_env(:medusa, Medusa) ==
      [adapter: Medusa.Adapter.Local]
  end

  test "Add consumers" do
    assert {:ok, _pid} = Medusa.consume("foo.bob", &IO.puts/1)
  end

  test "Add invalid consumer" do
    assert_raise MatchError, ~r/arity/,
      fn -> Medusa.consume("foo.bob", fn -> IO.puts("blah") end) end
  end

end
