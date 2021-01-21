# janetdocs

A community documentation site for the [janet](https://janet-lang.org) programming language

## Install janet

The first step is to get janet installed.

This uses [homebrew](https://brew.sh) for simplicity, but feel free to come up with whatever vagrant, docker or nixOS thing you'd like:

```sh
brew install janet
```

## Get Started

After janet is installed there are a few steps to get this project up and running:

1. Clone this repo

```sh
git clone https://github.com/swlkr/janetdocs.git
```

2. Move `.env.sample` to `.env`

```sh
cd janetdocs
mv `.env.sample` `.env`
```

3. Change the github client and secret ids to something real

You can create your own github oauth app or whatever it's called now to get your keys to get github sign in working

4. Install deps

```sh
# make sure you're in the janetdocs directory
jpm deps
```

5. Migrate the database

```sh
# make sure you're in the janetdocs directory
joy migrate
```

6. Seed the database with the docs

```sh
# make sure you're in the janetdocs directory
janet seed.janet
```

And that's it! You should be able to poke around at this point and see what's going on, by default the server starts on port 9001:

```sh
# make sure you're in the janetdocs directory
janet main.janet
```
