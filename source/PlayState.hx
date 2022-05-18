package;

import flixel.text.FlxText;
import flixel.util.FlxCollision;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.tile.FlxTile;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if mobile
import flixel.ui.FlxVirtualPad;
#end

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	var titleText:FlxText;
	var menuButton:FlxButton;
	var resumeButton:FlxButton;
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var burgers:FlxTypedGroup<Burger>;
	var enemies:FlxTypedGroup<Enemy>;
	var background:FlxSprite;

	public static var fadeVar:Bool = true;
	public static var escapePressed:Bool = false;

	var touchedFlag:Bool = false;
	var hud:HUD;
	var money:Int = 0;
	var health:Int = 10;

	var inCombat:Bool = false;
	var combatHud:CombatHUD;

	var ending:Bool;
	var won:Bool;

	var coinSound:FlxSound;

	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	function fadeTiles() {
		for (i in 0...walls.totalTiles) {
			if (walls.getTileByIndex(i) == 4) {
				var point = walls.getTileCoordsByIndex(i, false);
				var fadeOutSprite = new flixel.FlxSprite(point.x, point.y).loadGraphic(AssetPaths.tiles__png, true, 16, 16);
				fadeOutSprite.animation.add("tile", [4], 1);
				fadeOutSprite.animation.play("tile");
				walls.setTileByIndex(i, 1);
				add(fadeOutSprite);
				flixel.tweens.FlxTween.tween(fadeOutSprite, {alpha: 0}, 0.5, {
					ease: flixel.tweens.FlxEase.linear,
					onComplete: function(none:flixel.tweens.FlxTween = null) {
						remove(fadeOutSprite);
						fadeOutSprite.destroy();
					}
				});
			} else if (walls.getTileByIndex(i) == 5) {
				var point = walls.getTileCoordsByIndex(i, false);
				var fadeOutSprite = new flixel.FlxSprite(point.x, point.y).loadGraphic(AssetPaths.tiles__png, true, 16, 16);
				fadeOutSprite.animation.add("tile", [5], 2);
				fadeOutSprite.animation.play("tile");
				walls.setTileByIndex(i, 2);
				add(fadeOutSprite);
				flixel.tweens.FlxTween.tween(fadeOutSprite, {alpha: 0}, 0.5, {
					ease: flixel.tweens.FlxEase.linear,
					onComplete: function(none:flixel.tweens.FlxTween = null) {
						remove(fadeOutSprite);
						fadeOutSprite.destroy();
					}
				});
			} else if (walls.getTileByIndex(i) == 6) {
				var point = walls.getTileCoordsByIndex(i, false);
				var fadeOutSprite = new flixel.FlxSprite(point.x, point.y).loadGraphic(AssetPaths.tiles__png, true, 16, 16);
				fadeOutSprite.animation.add("tile", [6], 1);
				fadeOutSprite.animation.play("tile");
				walls.setTileByIndex(i, 1);
				add(fadeOutSprite);
				flixel.tweens.FlxTween.tween(fadeOutSprite, {alpha: 0}, 0.5, {
					ease: flixel.tweens.FlxEase.linear,
					onComplete: function(none:flixel.tweens.FlxTween = null) {
						remove(fadeOutSprite);
						fadeOutSprite.destroy();
					}
				});
			} else if (walls.getTileByIndex(i) == 7) {
				var point = walls.getTileCoordsByIndex(i, false);
				var fadeOutSprite = new flixel.FlxSprite(point.x, point.y).loadGraphic(AssetPaths.tiles__png, true, 16, 16);
				fadeOutSprite.animation.add("tile", [7], 3);
				fadeOutSprite.animation.play("tile");
				walls.setTileByIndex(i, 3);
				add(fadeOutSprite);
				flixel.tweens.FlxTween.tween(fadeOutSprite, {alpha: 0}, 0.5, {
					ease: flixel.tweens.FlxEase.linear,
					onComplete: function(none:flixel.tweens.FlxTween = null) {
						remove(fadeOutSprite);
						fadeOutSprite.destroy();
					}
				});
			}
		}
	}

	function isTouchingAny(objectToCheck:FlxObject) // pass your object here (e.g. player)
	{
		var touchingArray:Array<flixel.util.FlxDirectionFlags> = [LEFT, DOWN, UP, RIGHT]; // this might not work but lets see
		return touchingArray.contains(objectToCheck.touching);
	}

	function allDeadCheck() {
		var trueFalseArray:Array<Bool> = [];
		for (enemy in enemies) {
			trueFalseArray.push(enemy.alive);
		}
		return !trueFalseArray.contains(true);
	}

	function killAll() {
		var trueFalseArray:Array<Bool> = [];
		for (enemy in enemies) {
			enemy.kill();
		}
		for (coin in coins) {
			coin.kill();
		}
	}

	function changeFadeVar() {
		fadeVar = true;
	}

	function nextLevel(Tile:FlxObject, Obj:FlxObject) {
		Main.curLevel++;
		if (Main.curLevel == Main.levelsNumbers.length) {
			Main.curLevel--;
			return;
		}
		player.kill();
		killAll();
		if (!isTouchingAny(player))
			return;
		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, "assets/data/room-" + Main.levelsNumbers[Main.curLevel] + ".json");
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		walls.setTileProperties(3, ANY, nextLevel);

		add(walls);

		burgers = new FlxTypedGroup<Burger>();
		add(burgers);

		coins = new FlxTypedGroup<Coin>();
		add(coins);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

		combatHud = new CombatHUD();
		add(combatHud);

		coinSound = FlxG.sound.load(AssetPaths.coin__wav);
		FlxG.camera.fade(FlxColor.BLACK, 1.5, true, changeFadeVar);
		fadeVar = false;
	}

	override public function create() {
		Main.curLevel = 0;
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end

		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		walls.setTileProperties(3, ANY, nextLevel);

		add(walls);

		burgers = new FlxTypedGroup<Burger>();
		add(burgers);

		coins = new FlxTypedGroup<Coin>();
		add(coins);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

		combatHud = new CombatHUD();
		add(combatHud);

		coinSound = FlxG.sound.load(AssetPaths.coin__wav);

		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	function placeEntities(entity:EntityData) {
		var x = entity.x;
		var y = entity.y;

		switch (entity.name) {
			case "player":
				player.setPosition(x, y);

			case "coin":
				coins.add(new Coin(x + 4, y + 4));

			case "burger":
				burgers.add(new Burger(x, y));

			case "enemy":
				enemies.add(new Enemy(x + 4, y, REGULAR));

			case "boss":
				enemies.add(new Enemy(x + 4, y, BOSS));
		}
	}

	function clickMenu() {
		escapePressed = false;
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() {
			FlxG.switchState(new MenuState());
		});
	}

	function clickResume() {
		FlxTween.color(background, 0.33, FlxColor.BLACK, FlxColor.TRANSPARENT, {
			onComplete: function(_) {
				background.kill();
				background = null;
				menuButton.kill();
				resumeButton.kill();
				titleText.kill();
				FlxG.mouse.visible = false;
				escapePressed = false;
			}
		});
		FlxTween.color(menuButton, 0.33, FlxColor.WHITE, FlxColor.TRANSPARENT);
		FlxTween.color(resumeButton, 0.33, FlxColor.WHITE, FlxColor.TRANSPARENT);
		FlxTween.color(titleText, 0.33, FlxColor.WHITE, FlxColor.TRANSPARENT);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (CombatHUD.wait) {
			if (FlxG.keys.justPressed.ESCAPE) {
				if (background != null)
					return;
				escapePressed = true;

				background = new FlxSprite().makeGraphic(300, 190, FlxColor.WHITE);
				background.drawRect(1, 1, 298, 188, FlxColor.BLACK);
				background.screenCenter();
				background.scrollFactor.set(0, 0);
				add(background);

				titleText = new FlxText(20, 0, 0, "Game Paused", 25);
				titleText.alignment = CENTER;
				titleText.x = (FlxG.width / 2) - 100;
				titleText.y = (FlxG.height / 2) - 45; 
				add(titleText);

				menuButton = new FlxButton(0, 0, "Menu", clickMenu);
				menuButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
				menuButton.x = (FlxG.width / 2) - 10 - menuButton.width;
				menuButton.y = FlxG.height - menuButton.height - 50;
				add(menuButton);

				resumeButton = new FlxButton(0, 0, "Resume", clickResume);
				resumeButton.x = (FlxG.width / 2) + 10;
				resumeButton.y = FlxG.height - resumeButton.height - 50;
				add(resumeButton);

				FlxG.mouse.visible = true;
				return;
			};
		}

		if (ending) {
			return;
		}

		if (inCombat) {
			if (!combatHud.visible) {
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				if (combatHud.outcome == DEFEAT) {
					ending = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
				} else {
					if (combatHud.outcome == VICTORY) {
						combatHud.enemy.kill();
						/*if (combatHud.enemy.type == BOSS) {
							won = true;
							ending = false;
							// FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
							fadeTiles();
						}*/
						if (allDeadCheck()) {
							won = true;
							ending = false;
							fadeTiles();
						}
					} else {
						combatHud.enemy.flicker();
					}
					inCombat = false;
					player.active = true;
					enemies.active = true;

					#if mobile
					virtualPad.visible = true;
					#end
				}
			}
		} else {
			FlxG.collide(player, walls);
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.overlap(player, burgers, playerTouchBurger);
			FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}

	function doneFadeOut() {
		FlxG.switchState(new GameOverState(won, money));
	}

	function playerTouchCoin(player:Player, coin:Coin) {
		if (player.alive && player.exists && coin.alive && coin.exists) {
			coin.kill();
			money++;
			hud.updateHUD(health, money);
			coinSound.play(true);
		}
	}

	function playerTouchBurger(player:Player, burger:Burger) {
		function changeVal(_) {
			touchedFlag = false;
		}
		function onFinishTweenTwo(_) {
			FlxTween.tween(burger, {x: burger.x + 2}, 0.1, {onComplete: changeVal});
		}
		function onFinishTween(_) {
			FlxTween.tween(burger, {x: burger.x - 4}, 0.1, {onComplete: onFinishTweenTwo});
		}
		if (health != 10) {
			if (player.alive && player.exists && burger.alive && burger.exists) {
				burger.kill();
				health++;
				hud.updateHUD(health, money);
				coinSound.play(true);
			}
		} else {
			if (!touchedFlag) {
				touchedFlag = true;
				FlxTween.tween(burger, {x: burger.x + 2}, 0.1, {onComplete: onFinishTween});
			};
		}
	}

	function checkEnemyVision(enemy:Enemy) {
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint())) {
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		} else {
			enemy.seesPlayer = false;
		}
	}

	function playerTouchEnemy(player:Player, enemy:Enemy) {
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering()) {
			startCombat(enemy);
		}
	}

	function startCombat(enemy:Enemy) {
		inCombat = true;
		player.active = false;
		enemies.active = false;
		combatHud.initCombat(health, enemy);

		#if mobile
		virtualPad.visible = false;
		#end
	}
}
