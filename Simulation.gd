extends Node2D

var screenWidth = 1152
var screenHeight = 648
var red = Color(1,0,0)
var green = Color(0,1,0)
var black = Color(0,0,0)
var color

var gemStats = []

var gemStats0 = [[1.2,0.7,3.0],
	[1.2,0.7,3.0], [1.2,0.7,3.0], [1.3,0.8,3.0], [1.3,0.8,3.0], [1.3,0.8,4.0], [1.4,0.9,4.0], [1.4,0.9,4.0], [1.4,0.9,4.0], [1.5,1.0,5.0], [1.5,1.0,5.0],
 	[1.5,1.0,5.0], [1.6,1.1,5.0], [1.6,1.1,6.0], [1.6,1.1,6.0], [1.7,1.2,6.0], [1.7,1.2,6.0], [1.7,1.2,7.0], [1.8,1.3,7.0], [1.8,1.3,7.0], [1.8,1.3,7.0],
 	[1.9,1.4,8.0], [1.9,1.4,8.0], [1.9,1.4,8.0], [2.0,1.5,8.0], [2.0,1.5,8.0], [2.0,1.5,9.0], [2.1,1.6,9.0], [2.1,1.6,9.0], [2.1,1.6,9.0], [2.2,1.7,9.0],
 	[2.2,1.7,9.0], [2.2,1.7,10.0], [2.2,1.7,10.0], [2.2,1.7,10.0], [2.3,1.8,10.0], [2.3,1.8,10.0], [2.3,1.8,10.0], [2.3,1.8,10.0], [2.3,1.8,10.0], [2.3,1.8,10.0]
	]

var gemStats1 = [[3.0,0.7,3.0],
	[3.0,1.3,3.0], [3.0,1.3,3.0], [3.1,1.4,3.0], [3.1,1.4,3.0], [3.1,1.4,4.0], [3.2,1.5,4.0], [3.2,1.5,4.0], [3.2,1.5,4.0], [3.3,1.6,5.0], [3.3,1.6,5.0],
 	[3.3,1.6,5.0], [3.4,1.7,5.0], [3.4,1.7,6.0], [3.4,1.7,6.0], [3.5,1.8,6.0], [3.5,1.8,6.0], [3.5,1.8,7.0], [3.6,1.9,7.0], [3.6,1.9,7.0], [3.6,1.9,7.0],
 	[3.7,2.0,8.0], [3.7,2.0,8.0], [3.7,2.0,8.0], [3.8,2.1,8.0], [3.8,2.1,8.0], [3.8,2.1,9.0], [3.9,2.2,9.0], [3.9,2.2,9.0], [3.9,2.2,9.0], [4.0,2.3,9.0],
 	[4.0,2.3,9.0], [4.0,2.3,10.0], [4.0,2.3,10.0], [4.0,2.3,10.0], [4.1,2.4,10.0], [4.1,2.4,10.0], [4.1,2.4,10.0], [4.1,2.4,10.0], [4.1,2.4,10.0], [4.1,2.4,10.0]
	]

var enemyRadius
var secondaryRadius
var tertiaryRadius
# variation in small explosion radius variance
var radiusVariance = 0.3 
var smallExplosionNumber
var hitsPercent = 0
var hits = 0
var totalHits = 0
var totalExplosions = 0
var totalIterations = 0
var averageHits
var averageHitPercent = 100
var autothrowSpeed = 0
var enemyPos = Vector2(screenWidth/2-150,screenHeight/2)
var origin : Vector2
var trapSpread = 150
var regex = RegEx.new()
var oldtext = ""
var text = ""
var dps = 0


func _ready():
	regex.compile("^[0-9]*$")
	$Stats/AverageHit2.set_text("1")
	$Stats/Throwspeed2.set_text("1")


func _physics_process(delta):
	if $Stats/GemType2.selected == 0:
		gemStats = gemStats0
	else:
		gemStats = gemStats1
	
	enemyRadius = ($Stats/EnemySize2.value-1) * 10
	secondaryRadius = gemStats[$Stats/GemLevel2.value][0] * 100
	tertiaryRadius = gemStats[$Stats/GemLevel2.value][1] * 100
	smallExplosionNumber = gemStats[$Stats/GemLevel2.value][2] + floor($Stats/GemQuality2.value/10)
	autothrowSpeed = max(1, $Stats/Autothrow2.value)
	dps = int($Stats/Throwspeed2.get_text()) * int($Stats/AverageHit2.get_text()) * (smallExplosionNumber * $Stats/TrapsThrown2.value * (float(averageHitPercent)/100)+1)
	
	$Stats/GemType.set_text("Gem type:")
	$Stats/GemLevel.set_text("Gem Level: " + str($Stats/GemLevel2.value))
	$Stats/GemQuality.set_text("Gem Quality: " + str($Stats/GemQuality2.value))
	$Stats/EnemySize.set_text("Enemy Size: " + str($Stats/EnemySize2.value))
	$Stats/TrapsThrown.set_text("Traps per throw: " + str($Stats/TrapsThrown2.value))
	$Stats/Hits2.set_text(str(hits) + "/" + str(smallExplosionNumber*$Stats/TrapsThrown2.value) + " (" + str(hitsPercent) + "%)")
	$Stats/TotalIterations2.set_text(str(totalIterations))
	$Stats/TotalHits2.set_text(str(totalHits) + "/" + str(totalExplosions))
	$Stats/TotalHitPercentage2.set_text(str(averageHitPercent) + "%")
	$Stats/Autothrow.set_text("Autothrows per second: " + str($Stats/Autothrow2.value))
	$Stats/DPS2.set_text(str(dps))


func _draw():
	# draw enemy
	draw_circle(enemyPos, enemyRadius, black)
	# draw traps
	var trapPositions = []
	var i = 0
	hits = 0
	while i < $Stats/TrapsThrown2.value:
		var validPos = false
		if $Stats/TrapsThrown2.value == 1:
			origin = enemyPos
		else:
			while !validPos:
				origin = enemyPos + Vector2(randf_range(-trapSpread,trapSpread),randf_range(-trapSpread,trapSpread))
				if origin.distance_to(enemyPos) <= trapSpread:
					if trapPositions.size() > 0:
						var temp = 0
						for item in trapPositions:
							if origin.distance_to(item) > 20:
								temp += 1
						if temp == trapPositions.size():
							trapPositions.append(origin)
							validPos = true
					else:
						trapPositions.append(origin)
						validPos = true
		draw_arc(origin,secondaryRadius,0,360,100,black,3)
		draw_circle(origin,5,black)
		# draw small explosions
		var j = 0
		while j < smallExplosionNumber:
			var origin2 = Vector2(origin.x + randf_range(-secondaryRadius,secondaryRadius),origin.y + randf_range(-secondaryRadius,secondaryRadius))
			var radius = floor((tertiaryRadius * randf_range(1-radiusVariance,1+radiusVariance))*10) / 10
			if origin2.distance_to(origin) <= secondaryRadius:
				if origin2.distance_to(enemyPos) - enemyRadius + 1 <= radius:
					color = green
					hits += 1
				else:
					color = red
				draw_circle(origin2,2,color)
				draw_arc(origin2,radius,0,360,100,color,1)
				j += 1
		if hits == smallExplosionNumber * $Stats/TrapsThrown2.value:
			hitsPercent = "100.0"
		else:
			hitsPercent = str("%.2f" % snapped(hits/(smallExplosionNumber*$Stats/TrapsThrown2.value) * 100, 0.01))
		i += 1
	totalHits += hits
	totalExplosions += smallExplosionNumber * $Stats/TrapsThrown2.value
	totalIterations += 1
	averageHitPercent = str("%.2f" % snapped(totalHits / totalExplosions * 100, 0.01))


func _on_button_button_up():
	queue_redraw()


func _on_timer_timeout():
	queue_redraw()
	$Timer.start(1/autothrowSpeed)


func _on_button_2_toggled(toggled_on):
	if toggled_on:
		$Timer.start(1/autothrowSpeed)
	else:
		$Timer.stop()


func _on_reset_button_up():
	totalHits = 0
	totalExplosions = 0
	averageHitPercent = 0
	totalIterations = 0


func _on_average_hit_2_text_changed(new_text):
	if regex.search(new_text):
		text = new_text   
		oldtext = text
	else:
		text = oldtext
	$Stats/AverageHit2.set_text(text)
	$Stats/AverageHit2.set_caret_column(text.length())


func _on_throwspeed_2_text_changed(new_text):
	if regex.search(new_text):
		text = new_text   
		oldtext = text
	else:
		text = oldtext
	$Stats/Throwspeed2.set_text(text)
	$Stats/Throwspeed2.set_caret_column(text.length())


func _on_statistics_button_up():
	$Statistics.visible = true
	get_tree().paused = true


func _on_close_statistics_button_up():
	$Statistics.visible = false
	get_tree().paused = false
