import haxe.Timer;
import js.Browser;
import js.Browser.console;
import js.Browser.document;
import js.Browser.navigator;
import js.Browser.window;
import js.html.Element;
import js.html.InputElement;
import js.lib.Promise;
import om.AbstractEnumTools;
import om.Json;
import om.FetchTools.*;
import om.api.youtube.YouTube;
import om.api.youtube.YouTubePlayer;
import om.api.youtube.YouTubePlayer.PlayerState;

using om.ArrayTools;

typedef State = {
	index:Int,
	time:Int,
	volume:Int
}

class App {
	static var isMobileDevice = om.System.isMobile();

	static var playlist:Array<String>;
	static var state:State;

	static var player:YouTubePlayer;
	static var controls:Element;
	static var loader:Element;
	static var startElement:Element;

	static var volume:InputElement;

	static function play(?startSeconds:Int) {
		var id = playlist[state.index];
		console.info('Play: ${state.index} → $id');
		controls.classList.remove('active');
		loader.classList.add('active');
		player.cueVideoById(id, startSeconds, 'small');
	}

	static function playNext() {
		if (++state.index >= playlist.length)
			state.index = 0;
		play();
	}

	static function playPrev() {
		if (--state.index <= -1)
			state.index = playlist.length - 1;
		play();
	}

	static function playRand() {
		state.index = getRandomIndex();
		play();
	}

	static function getRandomIndex():Int {
		return Std.int(Math.random() * (playlist.length - 1));
	}

	static function initPlayer() {
		return new Promise((resolve, reject) -> {
			YouTube.init(() -> {
				player = new YouTubePlayer('youtube-player', {
					playerVars: {
						controls: no,
						disablekb: 1,
						fs: 0,
						iv_load_policy: 3,
						loop: 1,
						showinfo: 0,
					},
					events: {
						'onReady': e -> {
							resolve(null);
						},
						'onStateChange': e -> {
							console.log(AbstractEnumTools.getNames(PlayerState)[AbstractEnumTools.getValues(PlayerState).findIndex(v -> return v == e.data)]);
							switch e.data {
								case ended:
									playNext();
								case video_cued:
									player.playVideo();
								case playing:
									controls.classList.add('active');
									loader.classList.remove('active');
								default:
							}
						},
						'onError': e -> {
							console.error('Failed to play [${state.index}][${playlist[state.index]}]');
							// playlist.splice( index, 1 ); //TODO report to server
							Timer.delay(playNext, 1000);
						}
					}
				});
			});
		});
	}

	static function start() {
		var overlay = document.getElementById('overlay');
		loader.classList.remove('active');
		var btn = document.createDivElement();
		btn.classList.add('startbutton');
		btn.textContent = 'START';
		btn.onclick = function() {
			btn.remove();
			play(state.time);
			overlay.onclick = e -> playNext();
		}
		document.body.appendChild(btn);
		window.addEventListener('mousewheel', e -> {
			var vol = player.getVolume() + ((e.wheelDelta < 0) ? -10 : 10);
			player.setVolume(vol);
			volume.value = Std.string(vol);
		}, false);
		window.onkeydown = handleKeyDown;
	}

	static function handleKeyDown(e) {
		switch e.keyCode {
			case 39, 'K'.code:
				playNext();
			case 37, 'J'.code:
				playPrev();
			case 38, 187, 'I'.code: // up: arrow,+
				var vol = Math.min(player.getVolume() + 10, 100);
				player.setVolume(vol);
				volume.value = Std.string(vol);
			case 40, 189, 'N'.code: // down: arrow,-
				var vol = Math.max(player.getVolume() - 10, 0);
				player.setVolume(vol);
				volume.value = Std.string(vol);
			case 'R'.code:
				playRand();
		}
	}

	static function main() {
		window.oncontextmenu = e -> e.preventDefault();

		window.onload = e -> {
			controls = document.getElementById('controls');
			volume = cast controls.querySelector('input[name=volume]');
			loader = document.getElementById('loader');
			loader.classList.add('active');

			Promise.all([fetchJson('playlist.json'), initPlayer()]).then(result -> {
				playlist = cast result[0];

				var storage = Browser.getLocalStorage();
				var item = Browser.getLocalStorage().getItem('musicforprogramming');
				state = (item == null) ? {index: getRandomIndex(), time: 0, volume: 50} : Json.parse(item);

				console.info('State: ' + state);

				player.setVolume(state.volume);
				player.setPlaybackQuality(small);

				volume.value = Std.string(state.volume);

				volume.oninput = e -> {
					var vol = Std.parseFloat(volume.value);
					player.setVolume(vol);
					if (vol == 0) {
						player.pauseVideo();
					} else {
						player.playVideo();
					}
				}

				window.onbeforeunload = e -> {
					state.time = Std.int(player.getCurrentTime());
					state.volume = Std.parseInt(volume.value);
					storage.setItem('musicforprogramming', Json.stringify(state));
					return null;
				}

				start();
			}).catchError(e -> {
				console.error(e);
			});

			window.oncontextmenu = e -> e.preventDefault();

			/*
				var deferredPrompt : Dynamic;
				window.addEventListener('beforeinstallprompt', e -> {
					trace(e);
					deferredPrompt = e;
					deferredPrompt.prompt();
				});
			 */

			navigator.serviceWorker.register('sw.js').then(function(reg) {
				trace(reg);
			});
		}
	}
}
