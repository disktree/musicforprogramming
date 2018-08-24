
import haxe.Timer;
import js.Browser;
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.InputElement;
import om.Json;
import om.FetchTools.*;
import om.api.youtube.YouTube;
import om.api.youtube.YouTubePlayer;

class App {

	static var isMobileDevice : Bool;

	static var player : YouTubePlayer;
	static var playlist : Array<String>;
	static var index : Int;

	static var controls : Element;
	static var loader : Element;
	static var volume : InputElement;

	static function init( playlistURL = 'playlist.json', ?onReady : Void->Void ) {

		loader.classList.add( 'active' );

		index = 0;

		fetchJson( playlistURL ).then( function(data){

			playlist = data;

			YouTube.init( function(){

				trace( "Youtube ready" );

				player = new YouTubePlayer( 'youtube-player', {
					playerVars: {
						controls: no,
						color: white,
						autoplay: 1,
						disablekb: 1,
						fs: 0,
						iv_load_policy: 3,
						//enablejsapi: 1,
						modestbranding: 1,
						showinfo: 0,
						loop: 1
					},
					events: {
						'onReady': function(e){
							handlePlayerReady();
							if( onReady != null ) onReady();
						},
						'onStateChange': handlePlayerStateChange,
						'onError': function(e){
							console.error( 'Failed to play [$index][${playlist[index]}]' );
							//playlist.splice( index, 1 ); //TODO report to server
							Timer.delay( playNext, 1000 );
						},
						'onPlaybackQualityChange': function(e) trace(e),

					}
				});
			});
		});
	}

	static function play( ?start : Float ) {
		var id = playlist[index];
		console.info( 'Play [$index][$id]' );
		player.loadVideoById( id, start );
	}

	static function playNext() {
		if( ++index >= playlist.length ) index = 0;
		play();
	}

	static function playPrev() {
		if( --index <= -1 ) index = playlist.length-1;
		play();
	}

	static function playRand() {
		index = Std.int( Math.random() * (playlist.length-1) );
		play();
	}

	static function handlePlayerReady(?e) {

		trace( "Youtube player ready" );

		player.setPlaybackQuality( small );

		volume.oninput = e -> {
			var vol = Std.parseFloat( volume.value );
			player.setVolume( vol );
			if( vol == 0 ) {
				player.pauseVideo();
			} else {
				player.playVideo();
			}
		}

		var storage = Browser.getLocalStorage();
		var item = storage.getItem( 'musicforprogramming' );
		var state = { index: 0, time: 0, volume: 70 };
		if( item != null ) {
			state = Json.parse( item );
			console.log( state );
			index = state.index;
			volume.value = Std.string( state.volume );
			player.setVolume( state.volume );
		} else {
			state = { index: 0, time: 0, volume: 70 };
		}

		play( state.time );

		var overlay = document.getElementById( 'overlay' );
		overlay.addEventListener( 'click', function(e) {
			playNext();
		}, false );

		window.onbeforeunload = function(e){
			storage.setItem( 'musicforprogramming', Json.stringify( {
				index: index,
				time: player.getCurrentTime(),
				volume: Std.parseFloat( volume.value )
			} ) );
			return null;
		}
	}

	static function handlePlayerStateChange(e) {
		trace( e.data );
		switch e.data {
		case unstarted:
			controls.classList.remove( 'active' );
			loader.classList.add( 'active' );
		case buffering:
			controls.classList.remove( 'active' );
			loader.classList.add( 'active' );
		case ended:
			playNext();
		case playing:
			controls.classList.add( 'active' );
			loader.classList.remove( 'active' );
		case paused:
			//controls.classList.remove( 'active' );
		default:
			controls.classList.remove( 'active' );
			loader.classList.add( 'active' );
		}
	}

	static function handleKeyDown(e) {
		switch e.keyCode {
		case 39,'K'.code:
			playNext();
		case 37,'J'.code:
			playPrev();
		case 38,187,'I'.code: //up: arrow,+
			var vol = Math.min( player.getVolume() + 10, 100 );
			player.setVolume( vol );
			volume.value = Std.string( vol );
		case 40,189,'N'.code: //down: arrow,-
			var vol = Math.max( player.getVolume() - 10, 0 );
			player.setVolume( vol );
			volume.value = Std.string( vol );
		case 'R'.code:
			playRand();
		}
	}

	static function main() {

		window.onload = function() {

			isMobileDevice = om.System.isMobile();

			console.info( 'musicforprogramming [mobile:$isMobileDevice]' );

			controls = document.getElementById( 'controls' );
			volume = cast controls.querySelector( 'input[name=volume]' );
			loader = document.getElementById( 'loader' );

			if( isMobileDevice ) {
				var btn = document.createDivElement();
				btn.classList.add( 'startbutton' );
				btn.textContent = '{PLAY}';
				btn.onclick = function() {
					btn.remove();
					init();
				}
				document.body.appendChild( btn );
			} else {

				init( function() {
					window.onkeydown = handleKeyDown;
				});

				window.oncontextmenu = e -> {
					e.preventDefault();
				}
			}
		}
	}

}
