I basically ended up translating the code from here into ARM7 -> https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
Mode4 draws 2 by 2 pixels so had to make a function to mask it so it only paints one. (Inlining would be more efficient, but this is really just a few lines)

It also uses the interruptions to handle the screen refresh so we can redraw the lines each frame.
It comes with another file for the addresses, though there are surely more complete ones out there, I made that one myself just to get the hang of how everything works.

What it does! :
![image](https://github.com/user-attachments/assets/cf31017c-8db5-4f14-a53c-9c0fd869d567)
