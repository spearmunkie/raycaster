fcn tangent (angle : real) : real
    result sind (angle) / cosd (angle)
end tangent

type Ray :
    record
	Xa, Ya, Ax, Ay : real
    end record

var wallSlice : array 0 .. 4, 0 .. 63 of int

for x : 0 .. 63
    wallSlice (0, x) := Pic.New (x * 1, 0, x * 1, 63)
end for

wallSlice (1, 1) := Pic.FileNew ("Mossy.bmp")
Pic.Draw (wallSlice (1, 1), 0, 0, picCopy)
for x : 0 .. 63
    wallSlice (1, x) := Pic.New (x * 1, 0, x * 1, 63)
end for

wallSlice (2, 1) := Pic.FileNew ("Mossy Big Brick.bmp")
Pic.Draw (wallSlice (2, 1), 0, 0, picCopy)
for x : 0 .. 63
    wallSlice (2, x) := Pic.New (x * 1, 0, x * 1, 63)
end for

wallSlice (3, 1) := Pic.FileNew ("Twin Stones.bmp")
Pic.Draw (wallSlice (3, 1), 0, 0, picCopy)
for x : 0 .. 63
    wallSlice (3, x) := Pic.New (x * 1, 0, x * 1, 63)
end for

wallSlice (4, 1) := Pic.FileNew ("Metal.bmp")
Pic.Draw (wallSlice (4, 1), 0, 0, picCopy)
for x : 0 .. 63
    wallSlice (4, x) := Pic.New (x * 1, 0, x * 1, 63)
end for
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
    if angle + 30 > 359 then
	ang := angle + 30 - 360
    else
	ang := angle + 30
    end if
    if angle - 34 < 0 then
	maxAngle := angle - 34 + 360
    else
	maxAngle := angle - 34
    end if
    var Vertical, Horizontal : Ray
    var wallX, wallY, drawHeight : int := 0
    var wallCount : int := 0
    Draw.FillBox (0, maxy div 2, maxx, maxy, brightblue)
    Draw.FillBox (0, 0, maxx, maxy div 2, grey)
    loop
	exit when ceil (ang) = maxAngle
	horizontalInit (ang, x, y, Horizontal)
	verticalInit (ang, x, y, Vertical)
	var pic1, pic2 : int
	loop
	    exit when world (Array (round (Horizontal.Ax) div 64, round (Horizontal.Ay div 64))).property = 1
	    Horizontal.Ax += Horizontal.Xa
	    Horizontal.Ay += Horizontal.Ya
	end loop
	pic1 := world (Array (round (Horizontal.Ax) div 64, round (Horizontal.Ay div 64))).Pic
	loop
	    exit when world (Array (round (Vertical.Ax) div 64, round (Vertical.Ay div 64))).property = 1
	    Vertical.Ax += Vertical.Xa
	    Vertical.Ay += Vertical.Ya
	end loop
	pic2 := world (Array (round (Vertical.Ax) div 64, round (Vertical.Ay div 64))).Pic
	ang -= .1875
	if ang < 0 then
	    ang := 359
	end if
	var dist : array 1 .. 2 of real
	var portionToDraw : int
	dist (1) := distance (x, y, Horizontal.Ax, Horizontal.Ay)
	dist (2) := distance (x, y, Vertical.Ax, Vertical.Ay)

	if dist (1) < dist (2) and ang not= 359 and ang not= 179 then
	    dist (1) := dist (1) * cosd (angle - ang)
	    drawHeight := round (64 / dist (1) * 277)
	    wallY := 100 - drawHeight div 2
	    %if drawHeight < 10 then
	      %  drawHeight := 5
	    %end if
	   % if drawHeight >= 4000 then
	   %     drawHeight := 4000
	   % end if
	    wallCount := round (Horizontal.Ax) mod 64
	    portionToDraw := wallSlice (pic1, wallCount)
	    portionToDraw := Pic.Scale (portionToDraw, 1, drawHeight)

	    Pic.Draw (portionToDraw, wallX, wallY, picCopy)
	    Pic.Free (portionToDraw)
	else
	    if angle not= ang then
		dist (2) := dist (2) * cosd (angle - ang)
	    end if
	    drawHeight := round (64 / dist (2) * 277)
	    wallY := 100 - drawHeight div 2
	   % if drawHeight < 5 then
	   %     drawHeight := 5
	   % end if
	    %if drawHeight >= 4000 then
	    %    drawHeight := 4000
	   % end if
	    wallCount := round (Vertical.Ay) mod 64
	    portionToDraw := wallSlice (pic2, wallCount)
	    portionToDraw := Pic.Scale (portionToDraw, 1, drawHeight)
	    Pic.Draw (portionToDraw, wallX, wallY, picCopy)
	    Pic.Free (portionToDraw)
	end if
	wallX += 1
    end loop
end Raycast
type player :
    record
	x, y, angle : real
    end record
var human : player
human.angle := 0
human.x := 64 * 2 + 10
human.y := 64 * 2 + 10
var mx, my, mb : int
var key : array char of boolean

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

setscreen ("graphics:320;200;offscreenonly;nobuttonbar")
loop
    Input.KeyDown (key)

    if key (KEY_LEFT_ARROW) then
	human.angle += 25
    end if
    if key (KEY_RIGHT_ARROW) then
	human.angle -= 25
    end if
    if key (KEY_UP_ARROW) and not collide (human.x + cosd (human.angle) * 30, human.y + sind (human.angle) * 30, 25) then
	human.x += cosd (human.angle) * 30
	human.y += sind (human.angle) * 30
    end if
    if key (KEY_DOWN_ARROW) and not collide (human.x - cosd (human.angle) * 15, human.y - sind (human.angle) * 30, 25) then
	human.x -= cosd (human.angle) * 30
	human.y -= sind (human.angle) * 30
    end if
    if human.angle < 0 then
	human.angle := 359
    end if
    if human.angle > 359 then
	human.angle := 0
    end if
    Raycast (human.angle, human.x, human.y)
    View.Update
end loop
