# therianthrophy

Mod that allows players to turn themselves (or with privs, others) into animals.

https://en.wikipedia.org/wiki/Therianthropy

## API

To determine if a player is transformed:

```lua
therianthropy.transformed(player_name)
```

Returns the shortened animal name if true, otherwise `false`.

To transform a player:

```lua
therianthropy.transform(player, short_name)
```

`short_name` must have already been registered by the mod as an animal.
