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

open : FileNo, FileName, get
get : FileNo, totalX
get : FileNo, totalY
new world, totalX * totalY - 1
for decreasing y : totalY - 1 .. 0
    for x : 0 .. totalX - 1
	get : FileNo, world (Array (x, y)).Pic
	if world (Array (x, y)).Pic = 1 or world (Array (x, y)).Pic = 2
		or world (Array (x, y)).Pic = 3 or world (Array (x, y)).Pic = 1 or world (Array (x, y)).Pic = 4 then
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
    cls
    loop
	exit when ang = maxAngle
	horizontalInit (ang, x, y, Horizontal)
	verticalInit (ang, x, y, Vertical)
	var wall1, wall2 : int
	loop
	    exit when world (Array (round (Horizontal.Ax) div 64, round (Horizontal.Ay div 64))).property = 1
	    Horizontal.Ax += Horizontal.Xa
	    Horizontal.Ay += Horizontal.Ya
	end loop
	wall1 := world (Array (round (Horizontal.Ax) div 64, round (Horizontal.Ay div 64))).Pic
	loop
	    exit when world (Array (round (Vertical.Ax) div 64, round (Vertical.Ay div 64))).property = 1
	    Vertical.Ax += Vertical.Xa
	    Vertical.Ay += Vertical.Ya
	end loop
	wall2 := world (Array (round (Vertical.Ax) div 64, round (Vertical.Ay div 64))).Pic
	ang -= 1
	if ang < 0 then
	    ang := 359
	end if
	var dist : array 1 .. 2 of real
	dist (1) := distance (x, y, Horizontal.Ax, Horizontal.Ay)
	dist (2) := distance (x, y, Vertical.Ax, Vertical.Ay)

	if dist (1) < dist (2) and ang not= 359 and ang not= 179 then
	    dist (1) := dist (1) * cosd (angle - ang)
	    drawHeight := round (64 / dist (1) * 277)
	    wallY := 100 - drawHeight div 2
	    if wall1 = 1 then
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, grey)
	    elsif wall1 = 3 then
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, red)
	    elsif wall1 = 4 then
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, yellow)
	    else
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, green)
	    end if
	else
	    if angle not= ang then
		dist (2) := dist (2) * cosd (angle - ang)
	    end if
	    drawHeight := round (64 / dist (2) * 277)
	    wallY := 100 - drawHeight div 2
	    if wall2 = 1 then
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, grey)
	    elsif wall2 = 3 then
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, red)
	    elsif wall2 = 4 then
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, yellow)
	    else
		Draw.FillBox (wallX, wallY, wallX + 5, wallY + drawHeight, green)
	    end if
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
human.x := 64 * 1 + 10
human.y := 64 * 1 + 10
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

setscreen ("graphics:320;200;offscreenonly")
loop
    Input.KeyDown (key)

    if key ('a') then
	human.angle += 1
    end if
    if key ('d') then
	human.angle -= 1
    end if
    if key ('w') and not collide (human.x + cosd (human.angle) * 15, human.y + sind (human.angle) * 15, 10) then
	human.x += cosd (human.angle) * 15
	human.y += sind (human.angle) * 15
    end if
    if key ('s') and not collide (human.x - cosd (human.angle) * 15, human.y - sind (human.angle) * 15, 10) then
	human.x -= cosd (human.angle) * 15
	human.y -= sind (human.angle) * 15
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
