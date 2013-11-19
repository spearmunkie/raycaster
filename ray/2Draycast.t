fcn tangent (angle : real) : real
    result sind (angle) / cosd (angle)
end tangent

type Ray :
    record
	Xa, Ya, Ax, Ay : real
    end record

proc horizontalInit (k, x, y : real, var Horizontal : Ray)
    if k > 0 and k < 180 then
	Horizontal.Ay := y div 64 * 64 + 64
	Horizontal.Ya := 64
    else
	Horizontal.Ay := y div 64 * 64 - 1
	Horizontal.Ya := -64
    end if
    if k not= 0 and k not= 180 then
	Horizontal.Ax := x + (Horizontal.Ay - y) / tangent (k)
	if k = 90 or k = 270 then
	    Horizontal.Xa := 0
	elsif k = 0 then
	    Horizontal.Xa := 64
	elsif k = 180 then
	    Horizontal.Xa := -64
	else
	    Horizontal.Xa := 64 / tangent (k)
	end if
	if k >= 90 and k <= 270 then
	    if Horizontal.Xa > 0 then
		Horizontal.Xa *= -1
	    end if
	else
	    if Horizontal.Xa < 0 then
		Horizontal.Xa *= -1
	    end if
	end if
    else
	Horizontal.Ax := x + Horizontal.Ay - y
	Horizontal.Ya := 0
	if k >= 90 and k <= 270 then
	    Horizontal.Xa := -64
	else
	    Horizontal.Xa := 64
	end if
    end if
end horizontalInit

proc verticalInit (k, x, y : real, var vertical : Ray)

    if k > 90 and k < 270 then
	vertical.Ax := x div 64 * 64 - 1
	vertical.Xa := -64
    else
	vertical.Ax := x div 64 * 64 + 64
	vertical.Xa := 64
    end if
    if k = 90 then
	vertical.Xa := 0
	vertical.Ax := x
	vertical.Ay := y
	vertical.Ya := 64
    elsif k = 270 then
	vertical.Xa := 0
	vertical.Ax := x
	vertical.Ay := y
	vertical.Ya := -64
    elsif k = 180 or k = 0 then
	vertical.Ay := y
	vertical.Ya := 0
    else
	vertical.Ay := y + (vertical.Ax - x) * tangent (k)
	vertical.Ya := 64 * tangent (k)
	if k > 0 and k < 180 then
	    if vertical.Ya < 0 then
		vertical.Ya *= -1
	    end if
	else
	    if vertical.Ya > 0 then
		vertical.Ya *= -1
	    end if
	end if
    end if
end verticalInit
type grid :
    record
	Pic, property : int
    end record

var FileName : string := "map.txt"
var FileNo : int

var totalX, totalY : int := 0

var world : flexible array 0 .. 0 of grid

fcn Array (x, y : int) : int
    if totalX * y + x >= 0 and totalX * y + x <= upper (world) then
	result totalX * y + x
    else
	result totalX * totalY - 1
    end if
end Array
var cx, cy : int := 0
procedure reDraw
    for x : 0 .. totalX - 1
	for y : 0 .. totalY - 1
	    if world (Array (x, y)).Pic = 1 then
		Draw.FillBox (x * 64 + cx, y * 64 + cy, x * 64 + cx + 64, y * 64 + 64 + cy, red)
	    elsif world (Array (x, y)).Pic = 2 then
		Draw.FillBox (x * 64 + cx, y * 64 + cy, x * 64 + 64 + cx, y * 64 + 64 + cy, blue)
	    elsif world (Array (x, y)).Pic = 3 then
		Draw.FillBox (x * 64 + cx, y * 64 + cy, x * 64 + 64 + cx, y * 64 + 64 + cy, green)
	    elsif world (Array (x, y)).Pic = 4 then
		Draw.FillBox (x * 64 + cx, y * 64 + cy, x * 64 + 64 + cx, y * 64 + 64 + cy, yellow)
	    else
		Draw.FillBox (x * 64 + cx, y * 64 + cy, x * 64 + 64 + cx, y * 64 + 64 + cy, black)
	    end if
	end for
    end for
end reDraw

open : FileNo, FileName, get
get : FileNo, totalX
get : FileNo, totalY
new world, totalX * totalY - 1
for decreasing y : totalY - 1 .. 0
    for x : 0 .. totalX - 1
	get : FileNo, world (Array (x, y)).Pic
	if world (Array (x, y)).Pic = 1 or world (Array (x, y)).Pic = 2 or world (Array (x, y)).Pic = 3 or world (Array (x, y)).Pic = 4 then
	    world (Array (x, y)).property := 1
	else
	    world (Array (x, y)).property := 0
	end if
    end for
end for
close (FileNo)

fcn distance (x1, y1, x2, y2 : real) : real
    result sqrt ((x1 - x2) ** 2 + (y1 - y2) ** 2)
end distance

proc Raycast (angle, x, y : real)
    var increment : int := -1
    var ang : real
    var maxAngle : real
    if angle + 29 > 359 then
	ang := angle + 29 - 360
    else
	ang := angle + 29
    end if
    if angle - 31 < 0 then
	maxAngle := angle - 31 + 360
    else
	maxAngle := angle - 31
    end if
    var Vertical, Horizontal : Ray
    var wallX, wallY, drawHeight : int := 0
    reDraw
    %cls
    loop
	exit when ang = maxAngle
	horizontalInit (ang, x, y, Horizontal)
	verticalInit (ang, x, y, Vertical)
	loop
	    exit when world (Array (round (Horizontal.Ax) div 64, round (Horizontal.Ay div 64))).property = 1
	    Horizontal.Ax += Horizontal.Xa
	    Horizontal.Ay += Horizontal.Ya
	end loop
	loop
	    exit when world (Array (round (Vertical.Ax) div 64, round (Vertical.Ay div 64))).property = 1
	    Vertical.Ax += Vertical.Xa
	    Vertical.Ay += Vertical.Ya
	end loop
	ang -= 1
	if ang < 0 then
	    ang := 359
	end if
	var dist : array 1 .. 2 of real
	dist (1) := distance (x, y, Horizontal.Ax, Horizontal.Ay)
	dist (2) := distance (x, y, Vertical.Ax, Vertical.Ay)

	if dist (1) < dist (2) and ang not= 359 and ang not= 179 then
	    %dist (1) := dist (1) * cosd (angle - ang)
	    %drawHeight := round (64 / dist (1) * 277)
	    %wallY := 100 - drawHeight div 2
	    %Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, grey)
	    drawline (round (x) + cx, round (y) + cy, round (Horizontal.Ax) + cx, round (Horizontal.Ay) + cy, yellow)
	else
	    %if angle not= ang then
	    %    dist (2) := dist (2) * cosd (angle - ang)
	    %end if
	    %drawHeight := round (64 / dist (2) * 277)
	    %wallY := 100 - drawHeight div 2
	    %Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, grey)
	    drawline (round (x) + cx, round (y) + cy, round (Vertical.Ax) + cx, round (Vertical.Ay) + cy, yellow)
	end if
	wallX += 6
    end loop
end Raycast
type player :
    record
	x, y, angle : real
    end record
var human : player
human.angle := 0
human.x := 64 * 2
human.y := 64 * 2
var mx, my, mb : int
var key : array char of boolean
var blah : real

fcn collide (x, y, box : real) : boolean
    if world (Array ((x + box) div 64, (y + box) div 64)).property = 1 then
	result true
    elsif world (Array ((x + box) div 64, (y - box) div 64)).property = 1 then
	result true
    elsif world (Array ((x - box) div 64, (y - box) div 64)).property = 1 then
	result true
    elsif world (Array ((x - box) div 64, (y + box) div 64)).property = 1 then
	result true
    end if
    result false
end collide
proc snapGrid
    %if the grid is too far left
    if (cx + totalX * 64) < maxx then
	cx := maxx - totalX * 64 %we use 10 because that is the size of each tile
	%if the grid is too far right
    elsif (cx + 0 * 64) > 0 then
	cx := 0 - 0 * 64 %or just zero
    end if
    %if the map is too far down, move it up
    if (cy + totalY * 64) < maxy then
	cy := maxy - totalY * 64
	% if the map is too far up move it down
    elsif (cy + 0 * 64) > 0 then
	cy := 0 - 0 * 64 %or just zero
    end if
end snapGrid
setscreen ("graphics:max;max;offscreenonly")
loop
    Input.KeyDown (key)

    if key ('a') then
	human.angle += 10
    end if
    if key ('d') then
	human.angle -= 10
    end if
    if key ('w') and not collide (human.x + cosd (human.angle) * 30, human.y + sind (human.angle) * 30, 10) then
	human.x += cosd (human.angle) * 30
	human.y += sind (human.angle) * 30
    end if
    if key ('s') and not collide (human.x - cosd (human.angle) * 30, human.y - sind (human.angle) * 30, 10) then
	human.x -= cosd (human.angle) * 30
	human.y -= sind (human.angle) * 30
    end if
    if human.angle < 0 then
	human.angle := 359
    end if
    if human.angle > 359 then
	human.angle := 0
    end if
    if human.x + cx > maxx div 2 then
	cx -= 30
    end if
    if human.y + cy > maxy div 2 then
	cy -= 30
    end if
    if human.x + cx < maxx div 2 then
	cx += 30
    end if
    if human.y + cy < maxy div 2 then
	cy += 30
    end if
    snapGrid
    Raycast (human.angle, human.x, human.y)
    drawfillbox (round (human.x - 10) + cx, round (human.y - 10) + cy, round (human.x + 10) + cx, round (human.y + 10) + cy, blue)
    View.Update
end loop
