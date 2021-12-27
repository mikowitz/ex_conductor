defmodule ExConductor.ScoreTest do
  use ExUnit.Case, async: true

  alias ExConductor.Score

  test "generating a score" do
    ensemble = %{1 => "violin", 2 => "cello"}
    ensemble_id = "abcdef12345"

    score = Score.generate(ensemble_id, ensemble)

    assert length(score.pages) == 2
    assert score.current_page == 1
  end
end
