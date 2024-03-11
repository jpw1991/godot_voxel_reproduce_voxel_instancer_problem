# reproduce

Here you see the inconsistency between what's shown correctly in the editor (min/max height = 20/25) and what is there when you run the scene (some value beyond 25).

## Editor

You see, in the editor the correct min/max range is displayed:

![](editor.jpg)

But when running the game, it is different:

![](game.jpg)

## Workaround

I've discovered that a workaround is to reset the min/max height after a delay using a timer. This might be a clue as to what is going on internally:

![](workaround.jpg)