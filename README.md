# Block Party

This is an implementation of [Three Pixel Heart's Block Party](http://3pxh.com/) using JavaScript, SVG, and CSS 3D transforms.

See [https://nightjuggler.com/blockparty/](https://nightjuggler.com/blockparty/)

This project was originally written between December 2014 and January 2015.

To play this game, the only file you need from this repository is [`index.html`](index.html). It contains all the JavaScript, SVG, CSS, and HTML for Block Party 3D. An older, much more primitive 2D version of the game is in [`BlockParty2D.html`](BlockParty2D.html). My implementation notes for Block Party 3D are in the [`notes`](notes) folder.

## How To Play

Drag and rotate the blocks to make a party.

A party is a collection of four icons (on different blocks) where all of the following are true:

* They are all the same color or there is one of each color.
* They are all the same shape or there is one of each shape.
* They are all the same fill or there is one of each fill.

To rotate the most recently clicked block:

* Use the left and right arrow keys to rotate around the Z axis.
* Use the up and down arrow keys to rotate around the X axis.
* Use shift + left and shift + right to rotate around the Y axis.

Press the space bar to check whether you've made a party.

Click "Play" to start the timer, and try to make as many parties as you can before the time runs out. When you've found a party, press the space bar to get points. Then click "Keep Playing" to turn over the blocks involved in a party, and try to find more parties. Points are awarded as follows:

* 4 points for a party where all three traits (color, shape, and fill) are all different.
* 3 points for a party where two traits are all different and one is all the same.
* 2 points for a party where one trait is all different and two are all the same.
* 1 point for a party where all three traits are all the same. This is not possible with the current set of blocks.
