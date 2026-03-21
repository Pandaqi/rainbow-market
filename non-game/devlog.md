# Rainbow Market

I wanted to explore if it was possible to create educational puzzle games, even for very young players or somewhat odd topics. 

Years ago I made several puzzle games and learned some crucial lessons.

* How to randomly generate puzzles (instead of handcrafting them), and how to do it _fast_ and _well_.
* The importance of a "command" system to get do/undo, solution checking, and more for free.
* And ... that you need a very fast programming language to be able to _do this at all_.

I had to stop developing such games because my old laptop just could not run it anymore. I had to use _Rust_ for generating the puzzles, but used different software (e.g. _Godot Game Engine_) to make games, which meant I had to code all the logic _twice_. That was, obviously, frustrating and a big time sink. My laptop was closer and closer to crashing randomly too. So I stopped.

Now that I've launched my educational store, however, I realized education was _the perfect place_ for my puzzle ideas. A puzzle is basically the most efficient way to teach people to problem solve (following specific rules)! I could hyperfocus a puzzle on _colors_, or _shapes_, or _counting_, and get something good.

Then I discovered that, in the mean time, someone created a plugin that allowed writing _Rust_ right inside _Godot_. I could write my puzzle logic only _once_ and get randomly generated puzzles for free!

And so I returned to puzzle game development with my simplest idea (at the time): a puzzle to teach **colors**.

## What's the idea?

Random animals appear. Each "turn", you **tap an animal to give the current color to them**. 

Each animal

* Wants some colors
* Is a color itself too

Once all their desires are fulfilled, the animal leaves happily ... and **gives you its color**.

That's how it becomes a puzzle, instead of just a homework exercise. You need to be smart about the order of giving colors, because you need the "reward" from happy animals at the right time.

> Example: Two animals both want PINK. One animal will give you "BLUE" upon completion, another gives you nothing. You need that BLUE to make another animal happy, so you give the PINK tot he first animal.

That's all. It needs to stay extremely simple to be playable by kids still learning about colors, of course.

## Generating Puzzles

For such a simple puzzle, we _don't need_ the power of Rust. I feel very silly for dropping my puzzle games entirely all those years ago, because there are obviously loads of ideas that are "simple enough" to generate with a "slower language" (like the `GDScript` built into Godot). I could've made all of those!

But, well, you live and you learn.

How do we generate these puzzles?

* Start with X random colors and Y blank animals (who aren't assigned anything yet).
* Repeat the following loop.
  * Pick a random animal that isn't done yet.
    * If none exists, or with a slight random chance (say 5%), add a new blank animal.
  * Give our current color to that animal. _(We pretend it "wanted" that color all along!)_
  * Decide if the animal is "done". (It's full, random chance, or we're out of colors and need its reward.)
    * Add its reward color to the end of our color list.
    * Mark it as "done".
    * (If we're out of colors, guarantee at least 1 reward, so we)
* Repeat until all animals are done.

We simply save the "animal" picked in every iteration of that loop. That list is our exact solution in the end.

This is quite quick and simple. It's also not entirely correct yet. 

It took me a bit---after implementing the visuals to show what happens---to realize the logic mistakes here.

* **Mistake #1:** The final animal's "reward" is pointless. It just adds colors you won't use anymore, ruining our "perfect finish".
  * So ... just remove the reward from that final animal once done. 
* **Mistake #2:** To control difficulty, I need to control the min/max number of animals and colors.
  * So, check if the end result is _valid_. If not, just throw away and try again.

The issue is that the puzzle will often fail these bound checks. It might need hundreds of retries---thousands if you're unlucky---because it keeps adding too many or too few animals, for example. That's why you generally want to be a bit smarter in the generation itself.

The extra checks below changed it so that the generation always found perfect puzzles within 1--5 attempts.

* We don't add a blank animal if we're already at max. 
  * If we NEED to add an animal (because we have colors left), but we're already at max, just fail the puzzle and retry.
* Check if the simulation "needs to continue" (too few animals, animals that are not done, or unused colors left).
  * If we do NOT need to continue, always finish our current animal, which finishes the simulation.
  * If we do NOT need to continue, strip the reward from this final animal. (Set the reward to nothing + remove those added colors from the final list.)
  * If we DO need to continue, ensure our animal has a reward (so >0 reward colors). Otherwise continuing won't actually help us, because nothing changes.

Now we get nice puzzles about clicking a few animals and giving them colors ;) _And_ we can control their difficulty by changing those boundaries (how many animals, how many colors, etcetera).

{{% remark %}}
This does not guarantee that it's the _only_ solution. Because of how we generated it, it's only guaranteed to be _the most efficient solution_. That's absolutely fine by me.
{{% /remark %}}

## That's it, really

I added a simple button to automatically _play_ this solution, which was a godsend for checking and debugging this. I made the generation _seeded_, so I could actually create a little campaign with saved seeds, and allow you to replay exact levels you struggled with.

Then I added the basic menus, sound effects, and some tweens/animations, and we had a color-focused puzzle game! One that's absolutely playable by 4-year-olds, as all you do is tap an animal (which matches color with the background). I can even remove the "reward" entirely for the first few levels, removing the puzzle aspect but making it easier to get started.

Because it was such a tiny test game (to check the viability of puzzle games at my online educational store), I used free asset packs for the few images needed and did not add any other bells and whistles.

Until the next game,

Pandaqi








## Original Idea

Random cute animals are scattered around the map (no grid or anything needed).

Each animal ...

* **Wants some stuff** (one or more specific colors, in a thought bubble overhead)
* **Has a color** (and is standing in a general area of that color below their feet)

Each "turn", the game gives you the next color in line. (You can see the whole row + the whole background turns that color to be obvious.)

You _tap one animal_ to give it to them. If this finishes their order, the animal disappears, and _their color is added to the end of your list_!

In this way, you need to be smart about the order in which you fulfill orders.

COLOR-INSPIRED IDEAS: <https://minireview.io/puzzle/i-love-hue-too/games-like>



## TODO

* Settings?? Fullscreen?
* TUTORIAL / SAY NAME OF COLOR
  * Flash color shown in row
  * Flash color shown by animal that requests it
  * Then _only_ show a finger tapping that animal that wants it.
  * (Only show this on EASIEST mode, and only keep it around for the first one or two steps?)
  * => Create general library for "flash/highlight this element"? For "point finger at this thing"? For programming the sequence of tutorial steps?
    * NAH WRITE IT HARDCODED FIRST, we can always make it generic later

* Game Icon / Header
* Webshop Page
* Export