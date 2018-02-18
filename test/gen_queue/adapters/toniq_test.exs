defmodule GenQueue.Adapters.ToniqTest do
  use ExUnit.Case

  import GenQueue.Test
  import GenQueue.ToniqTestHelpers

  defmodule Enqueuer do
    Application.put_env(:gen_queue_toniq, __MODULE__, adapter: GenQueue.Adapters.Toniq)

    use GenQueue, otp_app: :gen_queue_toniq
  end

  defmodule Job do
    use Toniq.Worker

    def perform(arg1) do
      send_item(Enqueuer, {:performed, arg1})
    end

    def perform(arg1, arg2) do
      send_item(Enqueuer, {:performed, arg1, arg2})
    end
  end

  setup_all do
    Application.put_env(:toniq, :redis_url, "redis://127.0.0.1:6379")
  end

  setup do
    setup_global_test_queue(Enqueuer, :test)
  end

  describe "push/2" do
    test "enqueues and runs job from module" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push(Job)
      assert_receive({:performed, []})
      assert %GenQueue.Job{module: Job, args: []} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module tuple" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job})
      assert_receive({:performed, []})
      assert %GenQueue.Job{module: Job, args: []} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module and args" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, ["foo", "bar"]})
      assert_receive({:performed, ["foo", "bar"]})
      assert %GenQueue.Job{module: Job, args: ["foo", "bar"]} = job
      stop_process(pid)
    end

    test "enqueues a job with millisecond based delay" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, []}, delay: 0)
      assert_receive({:performed, []})
      assert %GenQueue.Job{module: Job, args: [], delay: 0} = job
      stop_process(pid)
    end

    test "enqueues a job with datetime based delay" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, []}, delay: DateTime.utc_now())
      assert_receive({:performed, []})
      assert %GenQueue.Job{module: Job, args: [], delay: %DateTime{}} = job
      stop_process(pid)
    end
  end

  test "enqueuer can be started as part of a supervision tree" do
    {:ok, pid} = Supervisor.start_link([{Enqueuer, []}], strategy: :one_for_one)
    {:ok, _} = Enqueuer.push(Job)
    assert_receive({:performed, []})
    stop_process(pid)
  end
end

