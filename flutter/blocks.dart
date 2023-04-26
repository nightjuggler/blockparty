final List<List<List<List<int>>>> blockSpec = () {
  const heart = 0;
  const circle = 1;
  const square = 2;
  const triangle = 3;

  const red = 0;
  const blue = 1;
  const black = 2;
  const orange = 3;

  const emptyFill = 0;
  const solidFill = 1;
  const halfFill = 2;
  const gridFill = 3;

  return [
[//Block0
// left, front, right, bottom, back, top
[[circle, orange, gridFill], [square, red, solidFill], [heart, blue, emptyFill], [triangle, black, halfFill]],
[[triangle, orange, emptyFill], [heart, blue, gridFill], [circle, red, solidFill], [heart, orange, emptyFill]],
[[triangle, red, halfFill], [heart, orange, gridFill], [triangle, black, solidFill], [circle, blue, emptyFill]],
[[circle, blue, gridFill], [heart, red, halfFill], [square, red, halfFill], [triangle, blue, emptyFill]],
[[heart, black, halfFill], [triangle, red, solidFill], [circle, black, solidFill], [square, blue, gridFill]],
[[square, orange, gridFill], [square, black, halfFill], [circle, orange, emptyFill], [square, black, solidFill]],
],
[//Block1
[[heart, black, solidFill], [circle, orange, solidFill], [triangle, blue, halfFill], [square, black, gridFill]],
[[heart, red, gridFill], [triangle, orange, halfFill], [circle, black, emptyFill], [circle, black, halfFill]],
[[heart, black, gridFill], [square, blue, solidFill], [triangle, black, emptyFill], [circle, blue, solidFill]],
[[circle, red, emptyFill], [triangle, orange, gridFill], [square, blue, emptyFill], [square, orange, solidFill]],
[[heart, blue, halfFill], [triangle, blue, gridFill], [heart, orange, halfFill], [heart, red, solidFill]],
[[square, red, gridFill], [circle, red, halfFill], [triangle, red, emptyFill], [square, orange, emptyFill]],
],
[//Block2
[[triangle, orange, halfFill], [triangle, black, emptyFill], [heart, black, emptyFill], [square, orange, solidFill]],
[[circle, blue, solidFill], [circle, black, emptyFill], [square, blue, solidFill], [heart, red, gridFill]],
[[heart, red, emptyFill], [heart, orange, halfFill], [circle, orange, solidFill], [heart, blue, halfFill]],
[[triangle, blue, solidFill], [heart, black, gridFill], [square, black, gridFill], [circle, red, gridFill]],
[[square, orange, halfFill], [triangle, blue, halfFill], [square, red, gridFill], [triangle, red, emptyFill]],
[[square, blue, halfFill], [circle, red, emptyFill], [triangle, orange, solidFill], [circle, black, gridFill]],
],
[//Block3
[[circle, black, halfFill], [heart, black, solidFill], [circle, red, halfFill], [square, blue, solidFill]],
[[square, black, halfFill], [square, orange, solidFill], [square, orange, emptyFill], [triangle, red, solidFill]],
[[circle, red, emptyFill], [triangle, orange, halfFill], [circle, blue, gridFill], [heart, black, gridFill]],
[[circle, orange, gridFill], [heart, blue, emptyFill], [triangle, blue, halfFill], [square, blue, emptyFill]],
[[heart, red, solidFill], [square, red, halfFill], [circle, black, emptyFill], [triangle, black, solidFill]],
[[triangle, blue, gridFill], [triangle, orange, gridFill], [heart, red, gridFill], [heart, orange, emptyFill]],
],
[//Block4
[[circle, blue, emptyFill], [triangle, black, halfFill], [circle, orange, emptyFill], [square, red, emptyFill]],
[[circle, red, solidFill], [heart, black, halfFill], [square, red, solidFill], [square, black, emptyFill]],
[[heart, orange, solidFill], [heart, red, halfFill], [square, black, solidFill], [triangle, blue, emptyFill]],
[[circle, black, solidFill], [triangle, black, gridFill], [square, blue, gridFill], [heart, blue, solidFill]],
[[circle, orange, halfFill], [triangle, red, halfFill], [triangle, red, gridFill], [heart, orange, gridFill]],
[[triangle, orange, emptyFill], [heart, blue, gridFill], [circle, blue, halfFill], [square, orange, gridFill]],
],
[//Block5
[[square, red, emptyFill], [square, red, solidFill], [heart, blue, gridFill], [circle, blue, emptyFill]],
[[square, blue, halfFill], [heart, orange, solidFill], [triangle, blue, solidFill], [heart, blue, solidFill]],
[[heart, red, emptyFill], [circle, black, gridFill], [circle, orange, halfFill], [square, black, emptyFill]],
[[circle, red, gridFill], [triangle, orange, solidFill], [heart, orange, gridFill], [triangle, black, halfFill]],
[[square, orange, halfFill], [triangle, red, halfFill], [square, black, solidFill], [circle, orange, emptyFill]],
[[circle, blue, halfFill], [triangle, black, gridFill], [triangle, red, gridFill], [heart, black, emptyFill]],
],
[//Block6
[[circle, black, solidFill], [triangle, blue, emptyFill], [circle, orange, gridFill], [triangle, red, solidFill]],
[[square, red, halfFill], [heart, black, halfFill], [triangle, blue, gridFill], [circle, blue, gridFill]],
[[circle, black, halfFill], [circle, red, halfFill], [heart, blue, emptyFill], [heart, red, halfFill]],
[[heart, black, solidFill], [heart, red, solidFill], [square, blue, emptyFill], [triangle, orange, gridFill]],
[[square, blue, gridFill], [square, orange, gridFill], [triangle, black, solidFill], [square, orange, emptyFill]],
[[circle, red, solidFill], [square, black, halfFill], [triangle, orange, emptyFill], [heart, orange, emptyFill]],
],
[//Block7
[[circle, orange, halfFill], [circle, red, gridFill], [square, red, gridFill], [triangle, blue, solidFill]],
[[square, red, emptyFill], [heart, black, emptyFill], [circle, blue, solidFill], [heart, blue, halfFill]],
[[circle, orange, solidFill], [heart, blue, solidFill], [square, black, gridFill], [square, blue, halfFill]],
[[triangle, black, gridFill], [heart, red, emptyFill], [square, orange, halfFill], [heart, orange, halfFill]],
[[triangle, red, emptyFill], [triangle, black, emptyFill], [triangle, orange, solidFill], [heart, orange, solidFill]],
[[triangle, red, gridFill], [circle, blue, halfFill], [square, black, emptyFill], [circle, black, gridFill]],
]
];
}();
