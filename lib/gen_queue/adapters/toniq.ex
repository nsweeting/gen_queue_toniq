defmodule GenQueue.Adapters.Toniq do
  @moduledoc """
  An adapter for `GenQueue` to enable functionaility with `Exq`.
  """

  use GenQueue.JobAdapter

  alias GenQueue.Job

  def start_link(_, _) do
    Toniq.start(nil, nil)
  end

  @doc """
  Push a `GenQueue.Job` for `Toniq` to consume.

  ## Parameters:
    * `gen_queue` - A `GenQueue` module
    * `job` - A `GenQueue.Job`

  ## Returns:
    * `{:ok, job}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @spec handle_job(gen_queue :: GenQueue.t(), job :: GenQueue.Job.t()) ::
          {:ok, GenQueue.Job.t()} | {:error, any}
  def handle_job(_gen_queue, %Job{delay: %DateTime{} = delay} = job) do
    ms_delay = DateTime.diff(DateTime.utc_now(), delay, :millisecond)
    Toniq.enqueue_with_delay(job.module, job.args, [delay_for: ms_delay])
    {:ok, job}
  end

  def handle_job(_gen_queue, %Job{delay: offset} = job) when is_integer(offset) do
    Toniq.enqueue_with_delay(job.module, job.args, [delay_for: offset])
    {:ok, job}
  end

  def handle_job(_gen_queue, job) do
    Toniq.enqueue(job.module, job.args)
    {:ok, job}
  end
end
