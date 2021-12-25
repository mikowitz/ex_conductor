defmodule ExConductor.EnsembleRegistry do
  use GenServer

  alias ExConductorWeb.Endpoint

  def start_link(_) do
    GenServer.start_link(__MODULE__, [nil], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def reset! do
    GenServer.cast(__MODULE__, :reset!)
  end

  def register(ensemble_id) do
    GenServer.cast(__MODULE__, {:register, ensemble_id})
  end

  def registered?(ensemble_id) do
    GenServer.call(__MODULE__, {:registered?, ensemble_id})
  end

  def add_instrument(ensemble_id, user_id, instrument) do
    GenServer.call(__MODULE__, {:add_instrument, ensemble_id, user_id, instrument})
  end

  def remove_instrument(ensemble_id, user_id) do
    GenServer.call(__MODULE__, {:remove_instrument, ensemble_id, user_id})
  end

  def handle_cast({:register, ensemble_id}, ensembles) do
    {:noreply, Map.put_new(ensembles, ensemble_id, %{})}
  end

  def handle_cast(:reset!, _) do
    {:noreply, %{}}
  end

  def handle_call({:registered?, ensemble_id}, _, ensembles) do
    result = ensemble_id in Map.keys(ensembles)
    {:reply, result, ensembles}
  end

  def handle_call({:add_instrument, ensemble_id, user_id, instrument}, _, ensembles) do
    case Map.get(ensembles, ensemble_id) do
      nil ->
        {:reply, :error, ensembles}

      ensemble ->
        new_ensemble = Map.put(ensemble, user_id, instrument)
        new_ensembles = Map.put(ensembles, ensemble_id, new_ensemble)

        Endpoint.broadcast!(
          "ensemble:#{ensemble_id}",
          "ensemble_changed",
          ensemble: new_ensemble
        )

        {:reply, :ok, new_ensembles}
    end
  end

  def handle_call({:remove_instrument, ensemble_id, user_id}, _, ensembles) do
    case Map.get(ensembles, ensemble_id) do
      nil ->
        {:reply, :error, ensembles}

      ensemble ->
        new_ensemble = Map.delete(ensemble, user_id)
        new_ensembles = Map.put(ensembles, ensemble_id, new_ensemble)

        Endpoint.broadcast!(
          "ensemble:#{ensemble_id}",
          "ensemble_changed",
          ensemble: new_ensemble
        )

        {:reply, :ok, new_ensembles}
    end
  end
end
