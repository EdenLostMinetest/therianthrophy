# therianthrophy

Mod that allows players to turn themselves (or with privs, others) into animals.

https://en.wikipedia.org/wiki/Therianthropy

## API

To register an animal that players can transform into:

```
therianthropy.register_animal(short_name, {
    model = <mesh file>,
    texture = <texture file>,
    collisionbox = <collisionbox list>,
    visual_size = <visual size vector>,
    eye_height = <eye height>,
    hear_distance = <sound hear distance>,
    sounds = {
        random = <sound to be played occasionally>,
        attack = <sound to be played when punching other player>
    },
    animations = {
        anim_speed = <animation speed>,
        stand_start = <stand animation start frame>,
        stand_end = <stand animation end frame>,
        walk_start = <walk animation start frame>,
        walk_end = <walk animation end frame>,
        mine_start = <mine animation start frame>,
        mine_end = <mine animation end frame>,
        walk_mine_start = <walking/mining animation start frame>,
        walk_mine_end = <walking/mining animation end frame>
    }
})
```

`model` and `texture` are the only required fields. Defaults:
- `collisionbox`: `{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}`
- `visual_size`: `{x = 1, y = 1}`
- `eye_height`: 1 node
- `hear_distance`: 10 nodes
- `sounds`: no sounds
- `animations`: no animations

To determine if a player is transformed:

```
therianthropy.transformed(player_name)
```

Returns the shortened animal name if true, otherwise `false`.

To transform a player:

```
therianthropy.transform(player, short_name)
```

`short_name` must have already been registered by the mod as an animal.
