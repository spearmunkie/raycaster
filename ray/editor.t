
var tiles : flexible array 0 .. 0 of int

var answer : string
var totalX, totalY : int
var FileName : string := "map.txt"
var FileNo : int

fcn Array (x, y : int) : int
    result totalX * y + x     %totalY * x + y also works
end Array

put "Would you like to load or create a new map? (load/new)"
get answer

if answer = "new" then
    put "How many tiles across and down?"
    get totalX, totalY
    new tiles, totalX * totalY - 1 %total number of elements
    for x : 0 .. totalX * totalY - 1
	tiles (x) := 0
    end for
elsif answer = "load" then
    %open the file
    open : FileNo, FileName, get
    get : FileNo, totalX %how many X's
    get : FileNo, totalY %how many Y's
    new tiles, totalX * totalY - 1 %total number of elements
    %the -1 is there because we started the aray at 0
    for decreasing y : totalY - 1 .. 0 % for every y remember we started the array at 0!
	for x : 0 .. totalX - 1 %for every x
	    get : FileNo, tiles (Array (x, y)) %get the tile type at (x,y) and store it in it's 1d counter-part
	end for
    end for
    close (FileNo)
else
    put "Invalid input, now crashing"
    delay (1000)
    quit
end if

procedure reDraw
    for x : 0 .. totalX - 1
	for y : 0 .. totalY - 1
	    %array is a function and px-1,py are the parameters
	    if tiles (Array (x, y)) = 1 then
		Draw.FillBox (x * 10, y * 10, x * 10 + 10, y * 10 + 10, red)
		% the +10 is there because each tile is 10 by 10
	    elsif tiles (Array (x, y)) = 2 then
		Draw.FillBox (x * 10, y * 10, x * 10 + 10, y * 10 + 10, blue)
	    elsif tiles (Array (x, y)) = 3 then
		Draw.FillBox (x * 10, y * 10, x * 10 + 10, y * 10 + 10, green)
	    elsif tiles (Array (x, y)) = 4 then
		Draw.FillBox (x * 10, y * 10, x * 10 + 10, y * 10 + 10, yellow)
	    else
		Draw.FillBox (x * 10, y * 10, x * 10 + 10, y * 10 + 10, black)
	    end if
	end for
    end for
end reDraw

Mouse.ButtonChoose ("multibutton") %check the turing help section if you don't know what this does
cls
var mx, my, mb, left, middle, right : int
var tmp := 1
var key : array char of boolean

View.Set ("offscreenonly")
loop
    Mouse.Where (mx, my, mb)
    %how this work can be found in the turing help section under 'Mouse.ButtonChoose'
    left := mb mod 10
    middle := (mb - left) mod 100
    right := mb - middle - left
    %move the map around
    Input.KeyDown (key)
    reDraw
    %make sure that the mouse is within the grid
    %remember mx div 10,my div 10 tells us what grid we are on
    % the lower bound of the grid is 0 and the upper bound is totalX/Y
    if mx div 10 >= 0 and mx div 10 < totalX and my div 10 >= 0 and my div 10 < totalY then
	%places red tiles
	if left = 1 then
	    tiles (Array (mx div 10, my div 10)) := tmp
	end if
	%places black tiles
	if right = 100 then
	    tiles (Array (mx div 10, my div 10)) := 0
	end if
	%just makes it clearer which tile you are on
	Draw.Box (mx div 10 * 10, my div 10 * 10, mx div 10 * 10 + 10, my div 10 * 10 + 10, white)
    end if
    if key ('2') then
	tmp := 2
    elsif key ('1') then
	tmp := 1
    elsif key ('3') then
	tmp := 3
    elsif key ('4') then
	tmp := 4
    end if
    View.Update
    exit when key ('q')
end loop

open : FileNo, FileName, put
put : FileNo, totalX     %how many X's
put : FileNo, totalY     %how many Y's
%new tiles, totalX * totalY - 1     %total number of elements
%the -1 is there because we started the aray at 0
for decreasing y : totalY - 1 .. 0     % for every y remember we started the array at 0!
    for x : 0 .. totalX - 1     %for every x
	put : FileNo, tiles (Array (x, y))     %get the tile type at (x,y) and store it in it's 1d counter-part
    end for
end for
close (FileNo)
