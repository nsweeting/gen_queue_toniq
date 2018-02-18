# GenQueue Toniq
[![Build Status](https://travis-ci.org/nsweeting/gen_queue_toniq.svg?branch=master)](https://travis-ci.org/nsweeting/gen_queue_toniq)
[![GenQueue Exq Version](https://img.shields.io/hexpm/v/gen_queue_toniq.svg)](https://hex.pm/packages/gen_queue_toniq)

This is an adapter for [GenQueue](https://github.com/nsweeting/gen_queue) to enable
functionaility with [Toniq](https://github.com/joakimk/toniq).

## Installation

The package can be installed by adding `gen_queue_toniq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_queue_toniq, "~> 0.1.0"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/gen_queue_toniq) for additional documentation.

## Configuration

Before starting, please refer to the [Toniq](https://github.com/joakimk/toniq) documentation
for details on configuration. This adapter handles zero `Toniq` related config.

## Creating Enqueuers

We can start off by creating a new `GenQueue` module, which we will use to push jobs to
`Toniq`.

```elixir
defmodule Enqueuer do
  use GenQueue, otp_app: :my_app
end
```

Once we have our module setup, ensure we have our config pointing to the `GenQueue.Adapters.Toniq`
adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.Toniq
]
```

## Starting Enqueuers

By default, `gen_queue_toniq` does not start `Toniq` on application start. So we must add
our new `Enqueuer` module to our supervision tree.

```elixir
  children = [
    supervisor(Enqueuer, []),
  ]
```

## Creating Jobs

Jobs are simply modules with a `perform` method. With `Toniq` we must add `use Toniq.Worker`
to our jobs.

```elixir
defmodule MyJob do
  use Toniq.Worker

  def perform(arg1) do
    IO.inspect(arg1)
  end
end
```

## Enqueuing Jobs

We can now easily enqueue jobs to `Toniq`. The adapter will handle a variety of argument formats.

```elixir
# Please note that zero-arg jobs default to using [], as per Toniq requirements.

# Push MyJob to with [] arg.
{:ok, job} = Enqueuer.push(MyJob)

# Push MyJob with [] arg.
{:ok, job} = Enqueuer.push({MyJob})

# Push MyJob with ["foo"] arg.
{:ok, job} = Enqueuer.push({MyJob, "foo"})

# Push MyJob with [] arg.
{:ok, job} = Enqueuer.push({MyJob, []})

# Push MyJob with ["foo"] arg.
{:ok, job} = Enqueuer.push({MyJob, ["foo"]})

# Schedule MyJob [] arg in 10 seconds
{:ok, job} = Enqueuer.push({MyJob, []}, [delay: 10_000])

# Schedule MyJob with [] arg at a specific time
date = DateTime.utc_now()
{:ok, job} = Enqueuer.push({MyJob, []}, [delay: date])
```

## Testing

Optionally, we can also have our tests use the `GenQueue.Adapters.MockJob` adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.MockJob
]
```

This mock adapter uses the standard `GenQueue.Test` helpers to send the job payload
back to the current processes mailbox (or another named process) instead of actually
enqueuing the job to rabbitmq.

```elixir
defmodule MyJobTest do
  use ExUnit.Case, async: true

  import GenQueue.Test

  setup do
    setup_test_queue(Enqueuer)
  end

  test "my enqueuer works" do
    {:ok, _} = Enqueuer.push(Job)
    assert_receive(%GenQueue.Job{module: Job, args: []})
  end
end
```

If your jobs are being enqueued outside of the current process, we can use named
processes to recieve the job. This wont be async safe.

```elixir
import GenQueue.Test

setup do
  setup_global_test_queue(Enqueuer, :my_process_name)
end
```
