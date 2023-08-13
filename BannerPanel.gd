extends Panel

func on_announce(msg):
	$BannerText.bbcode_text = msg
	$BannerAnimationPlayer.play("BannerSlide")
