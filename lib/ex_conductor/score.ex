defmodule ExConductor.Score do
  defstruct [:pages, :current_page, :ensemble_id]

  alias Satie.{Duration, Pitch, Staff, Measure}

  def generate(ensemble_id, ensemble) do
    ly_score = build_score(ensemble)

    start_time = :os.system_time(:seconds)

    File.mkdir_p("scores")

    Satie.Lilypond.save(ly_score, "scores/" <> ensemble_id)
    System.cmd("lilypond", ["-o", "scores", "--png", "scores/#{ensemble_id}.ly"])

    {:ok, pages} = File.ls("scores")

    pages =
      pages
      |> Enum.filter(&String.ends_with?(&1, ".png"))
      |> Enum.filter(&String.contains?(&1, ensemble_id))
      |> Enum.filter(fn path ->
        {:ok, stats} = File.stat("scores/" <> path, time: :posix)
        stats.ctime > start_time
      end)
      |> Enum.map(fn file ->
        {:ok, png} = File.read("scores/" <> file)
        Base.encode64(png)
      end)

    %__MODULE__{
      pages: pages,
      current_page: 1,
      ensemble_id: ensemble_id
    }
  end

  def set_page(%__MODULE__{} = score, page_number) do
    %__MODULE__{score | current_page: page_number}
  end

  def clear!(%__MODULE__{ensemble_id: ensemble_id}) do
    for file <- Path.wildcard("scores/#{ensemble_id}*") do
      File.rm(file)
    end
  end

  def current_page(%__MODULE__{pages: pages, current_page: current_page}) do
    Enum.at(pages, current_page - 1)
  end

  @callback build_score(map()) :: Satie.Score.t()
  def build_score(ensemble) do
    measure_count =
      case Mix.env() do
        :test -> 70
        _ -> Enum.random(50..100)
      end

    measure_beats = for _ <- 0..measure_count, do: Enum.random(2..4)

    staves =
      for {_, instrument} <- ensemble do
        measures = for b <- measure_beats, do: build_measure(b)

        Staff.new(measures, name: instrument)
      end

    Satie.Score.new([Satie.StaffGroup.new(staves)])
  end

  def build_measure(beats) do
    Measure.new(
      {beats, 4},
      Stream.repeatedly(&build_beat/0) |> Enum.take(beats) |> List.flatten()
    )
  end

  defp build_beat do
    durations =
      if :rand.uniform() > 0.5 do
        [1, 2, 1]
      else
        [2, 2]
      end

    beat =
      Enum.map(durations, fn d ->
        if :rand.uniform() > 0.75 do
          Satie.Rest.new(Duration.new(d, 16))
        else
          Satie.Note.new(Duration.new(d, 16), Pitch.new(:rand.uniform(11), 4))
        end
      end)

    case Enum.all?(beat, fn x -> x.__struct__ == Satie.Rest end) do
      true -> Satie.Rest.new(Duration.new(1, 4))
      false -> beat
    end
  end
end
