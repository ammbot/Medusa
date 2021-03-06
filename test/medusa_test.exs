defmodule MedusaTest do
  use ExUnit.Case
  doctest Medusa

  test "not config should fallback to default" do
    Application.delete_env(:medusa, Medusa, persistent: true)
    Application.stop(:medusa)
    Application.ensure_all_started(:medusa)
    assert Application.get_env(:medusa, Medusa) ==
      [adapter: Medusa.Adapter.PG2]
  end

  test "config invalid adapter should fallback to PG2" do
    Application.put_env(:medusa, Medusa, [adapter: Wrong], persistent: true)
    Application.stop(:medusa)
    Application.ensure_all_started(:medusa)
    assert Application.get_env(:medusa, Medusa) ==
      [adapter: Medusa.Adapter.PG2]
  end

  test "Add consumers" do
    before = Medusa.ConsumerSupervisor |> Supervisor.which_children |> length
    Medusa.consume("foo.bob", &IO.puts/1)
    afters = Medusa.ConsumerSupervisor |> Supervisor.which_children |> length
    assert afters - before == 1
    assert Process.whereis(:"foo.bob")
  end

  test "Add invalid consumer" do
    assert_raise MatchError, ~r/arity/,
      fn -> Medusa.consume("foo.bob", fn -> IO.puts("blah") end) end
  end

end
