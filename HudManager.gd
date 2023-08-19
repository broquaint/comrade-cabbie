extends CanvasLayer

# Put everything into its default state.
func initialize():
	$Control/Container/TravelTime.bbcode_text = '-'
	$Control/Container/Speed.bbcode_text = '0m/s'

	$SatisfactionMeter.set_progress_meter()
	$SatisfactionMeter.set_asteroid_meter(GameState.current_asteroid)

	$FlashAnimationPlayer.play("RESET")
	# $NeedleAnimationPlayer.play()

	$MessageLog.setup()

	$BannerPanel/BannerAnimationPlayer.play("RESET")

	$CompletionPopup.hide()
