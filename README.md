# H2 Repro

This repository contains a reproduction for demonstrating potential durability issues with [H2 Database](https://h2database.com). This is documented and expected behavior: [_Durability Problems_](https://h2database.com/html/advanced.html#durability_problems)

## Setup

```sh
mkdir -p data/h2/data
mkdir -p data/h2/logs

rvm install "jruby-9.4.6.0"

rvm use jruby-9.4.6.0

bundle
```

```sh
docker compose build
docker compose up
```

## Ingesting Data

To delete the current database and start from scratch:
```sh
./clean-up.sh
```

Start inserting data:
```sh
bundle exec jruby main.rb
```

It will store all logs  at:
```sh
tail -f data/logs.jsonl
```

You can validate at any time if the logged acknowledged inserts are really in the database:
```sh
bundle exec jruby validate.rb
```

## Simulations

### OOM

```sh
docker compose exec h2-database-java21 bash
```

```sh
:(){ :|:& };:
```

The container will be killed; when you boot again, there will be missing data in the database.

### Kill

```sh
docker compose kill h2-database-java21
```

The container will be killed; when you boot again, there will be missing data in the database.
