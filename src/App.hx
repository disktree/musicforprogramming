import haxe.Timer;
import js.Browser;
import js.Browser.console;
import js.Browser.document;
import js.Browser.navigator;
import js.Browser.window;
import js.html.Element;
import js.html.IFrameElement;
import js.html.InputElement;
import js.lib.Promise;
import om.AbstractEnumTools;
import om.api.youtube.YouTube;
import om.api.youtube.YouTubePlayer;
import om.api.youtube.YouTubePlayer.PlayerState;
import om.FetchTools.*;
import om.Json;

using om.ArrayTools;

typedef State = {
	index:Int,
	time:Int,
	volume:Int
}

class App {

	static var isMobileDevice = om.System.isMobile();

	static var playlist : Array<String>;
	static var state : State;

	static var iframe : IFrameElement;
	static var player : YouTubePlayer;
	static var overlay : Element;
	static var controls : Element;
	static var button : Element;
	static var loader : Element;
	static var startElement : Element;
	static var volume : InputElement;

	static function play(?startSeconds:Int) {
		var id = playlist[state.index];
		console.info('Play: ${state.index} → $id');
		controls.classList.remove('active');
		loader.classList.add('active');
		player.cueVideoById(id, startSeconds, small );
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
					width: Std.string( window.innerWidth),
					height: Std.string( window.innerHeight),
					playerVars: {
						controls: no,
						disablekb: 1,
						fs: 0,
						iv_load_policy: 3,
						cc_load_policy: 0,
						loop: 1,
						//showinfo: 0,
						modestbranding: 1,
					},
					events: {
						'onReady': e -> {
							resolve(null);
						},
						'onStateChange': e -> {
							//console.log(AbstractEnumTools.getNames(PlayerState)[AbstractEnumTools.getValues(PlayerState).findIndex(v -> return v == e.data)]);
							//iframe.style.opacity = '1';
							switch e.data {
								case ended:
									//button.textContent = '///';
									playNext();
								case video_cued:
									button.textContent = '';
									player.playVideo();
								case playing:
									button.textContent = '';
									controls.classList.add('active');
									loader.classList.remove('active');
									window.top.postMessage('playing', '*');
								//	overlay.classList.add('hidden');
									//overlay.classList.add('hidden');
									//trace("REMOVE HIDDEN");
									//trace(iframe.classList.length);
									//iframe.style.opacity = '1';
									//iframe.classList.add('show');
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
		loader.classList.remove('active');
		button.textContent = 'MUSICFORPROGRAMMING';
		window.addEventListener('mousewheel', e -> {
			var vol = player.getVolume() + ((e.wheelDelta < 0) ? -10 : 10);
			player.setVolume(vol);
			volume.value = Std.string(vol);
		}, false);
		window.onkeydown = handleKeyDown;
	}

	static function handleKeyDown(e) {
		switch e.keyCode {
			case 39, 'L'.code:
				playNext();
			case 37, 'H'.code:
				playPrev();
			case 38, 187, 'I'.code, 'J'.code: // up: arrow,+
				var vol = Math.min(player.getVolume() + 10, 100);
				player.setVolume(vol);
				volume.value = Std.string(vol);
			case 40, 189, 'N'.code, 'K'.code: // down: arrow,-
				var vol = Math.max(player.getVolume() - 10, 0);
				player.setVolume(vol);
				volume.value = Std.string(vol);
			case 32, 'P'.code, 'R'.code:
				playRand();
		}
	}

	static function handleWindowResize(e) {
		iframe.width = window.innerWidth;
		iframe.height = window.innerHeight;
		if( player != null ) {
			player.setSize( window.innerWidth, window.innerHeight );
		}
	}

	static function main() {

		console.info('MUSICFORPROGRAMMING™');

		window.addEventListener( 'load', e -> {
			
			iframe = cast document.getElementById('youtube-player');

			overlay = document.getElementById('overlay');
			controls = document.getElementById('controls');

			button = document.getElementById('start');
			button.textContent = '';
			
			volume = cast controls.querySelector('input[name=volume]');
			
			loader = document.getElementById('loader');
			loader.classList.add('active');

			button.onclick = function() {
				//button.remove();
				play(state.time);
				overlay.onclick = e -> playNext();
			}

			Promise.all([fetchJson('playlist.json'), initPlayer()]).then( result -> {

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

			/* 	function showPlayer() {
					overlay.classList.add('hidden');
				}
				function hidePlayer() {
					overlay.classList.remove('hidden');
				}

				//document.onmouseenter = e -> hidePlayer();
				//document.onmouseleave = e -> showPlayer();

				window.addEventListener( 'resize', handleWindowResize, false );

				window.oncontextmenu = e -> e.preventDefault();

				window.onbeforeunload = e -> {
					state.time = Std.int(player.getCurrentTime());
					state.volume = Std.parseInt(volume.value);
					storage.setItem('musicforprogramming', Json.stringify(state));
					return null;
				}

				window.onmessage = function(e){
					switch e.data {
					case 'start','next':
						playNext();
					}
				}; */

				//window.onfocus = e -> trace(e);

				start();

			}).catchError( e -> {
				console.error(e);
			});

			/*
				var deferredPrompt : Dynamic;
				window.addEventListener('beforeinstallprompt', e -> {
					trace(e);
					deferredPrompt = e;
					deferredPrompt.prompt();
				});
			 */

			/*
			navigator.serviceWorker.register('sw.js').then(function(reg) {
				trace(reg);
			});
			*/
		});
	}
}
