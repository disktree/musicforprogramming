
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
	static var playlist : Array<String>;
	static var index : Int;
	static var player : YouTubePlayer;
	static var controls : Element;
	static var loader : Element;

	static function init( playlistURL = 'playlist.json' ) {

		index = 0;

		fetchJson( playlistURL ).then( function(data){

			playlist = data;

			YouTube.init( function(){

				trace( "Youtube ready" );

				player = new YouTubePlayer( 'youtube-player', {
					playerVars: {
						controls: no,
						color: white,
						autoplay: 0,
						disablekb: 0,
						fs: 0,
						iv_load_policy: 3,
						//enablejsapi: 1,
						modestbranding: 1,
						showinfo: 0,
						loop: 1
					},
					events: {
						'onReady': handlePlayerReady,
						'onStateChange': handlePlayerStateChange,
						'onError': function(e){
							trace(e);
						}
					}
				});
			});
		});
	}

	static function play( ?start : Float ) {
		player.loadVideoById( playlist[index], start );
	}

	static function playNext() {
		if( ++index == playlist.length ) index = 0;
		play();
	}

	static function handlePlayerReady(e) {

		trace( "Youtube player ready" );

		var volume : InputElement = cast controls.querySelector( 'input[name=volume]' );
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
		trace(e.data );
		switch e.data {
		case unstarted:
			controls.classList.remove( 'active' );
			loader.classList.add( 'active' );
		case buffering:
		case ended:
			//controls.style.display = 'none';
			playNext();
		case playing:
			controls.classList.add( 'active' );
			loader.classList.remove( 'active' );
			//trace( player.getCurrentTime() );
		case paused:
		default:
			controls.classList.remove( 'active' );
			loader.classList.add( 'active' );
		}
	}

	static function main() {

		window.onload = function() {

			isMobileDevice = om.System.isMobile();

			controls = document.getElementById( 'controls' );
			loader = document.getElementById( 'loader' );
			loader.classList.add( 'active' );

			if( isMobileDevice ) {
				//TODO mobile devices require initial user interaction
				document.body.textContent = 'DESKTOP DEVICES ONLY';
			} else {
				init();
				window.oncontextmenu = e -> {
					e.preventDefault();
				}
			}
		}
	}

}
