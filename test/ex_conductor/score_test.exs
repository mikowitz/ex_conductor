defmodule ExConductor.ScoreTest do
  use ExUnit.Case, async: true

  alias ExConductor.Score

  @ensemble_id "abcdef12345"

  setup do
    on_exit(fn ->
      for file <- Path.wildcard("scores/#{@ensemble_id}*") do
        File.rm(file)
      end
    end)
  end

  test "generating a score" do
    ensemble = %{1 => "violin", 2 => "cello"}
    ensemble_id = @ensemble_id

    score = Score.generate(ensemble_id, ensemble)

    assert length(score.pages) == 3
    assert score.current_page == 1
  end

  test "turning the page" do
    ensemble = %{1 => "violin", 2 => "cello"}
    ensemble_id = @ensemble_id

    score = Score.generate(ensemble_id, ensemble)

    score = Score.set_page(score, 2)

    assert score.current_page == 2
  end
end
