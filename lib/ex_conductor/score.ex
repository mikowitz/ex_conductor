defmodule ExConductor.Score do
  defstruct [:pages, :current_page]

  alias Satie.{Duration, Pitch, Staff, Measure, Note}

  def generate(ensemble_id, ensemble) do
    ly_score = build_score(ensemble)

    IO.inspect(Satie.Lilypond.lilypond_version())

    File.mkdir_p("scores")
    Satie.Lilypond.save(ly_score, "scores/" <> ensemble_id)
    System.cmd("lilypond", ["-o", "scores", "--png", "scores/#{ensemble_id}.ly"])

    {:ok, pages} = File.ls("scores")

    pages =
      pages
      |> Enum.filter(&String.ends_with?(&1, ".png"))
      |> Enum.map(fn file ->
        {:ok, png} = File.read("scores/" <> file)
        Base.encode64(png)
      end)

    %__MODULE__{
      pages: pages,
      current_page: 1
    }
  end

  def current_page(%__MODULE__{pages: pages, current_page: current_page}) do
    Enum.at(pages, current_page - 1)
  end

  defp build_score(ensemble) do
    c = Note.new(Duration.new(1, 4), Pitch.new(0, 4))
    m = Measure.new({4, 4}, [c, c, c, c])
    staff = Staff.new([m, m, m, m])

    staves = Stream.cycle([staff]) |> Enum.take(Enum.count(ensemble))

    Satie.Score.new(staves)
  end
end
