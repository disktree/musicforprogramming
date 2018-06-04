
import js.Browser;
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.InputElement;
import om.Json;
import om.api.youtube.YouTube;
import om.api.youtube.YouTubePlayer;
import om.FetchTools.*;

class App {

	static var player : YouTubePlayer;
	static var playlist : Array<String>;
	static var index : Int;

	static function play( ?start : Float ) {
		player.loadVideoById( playlist[index], start );
	}

	static function playNext() {
		if( ++index == playlist.length ) index = 0;
		play();
	}

	static function main() {

		window.onload = function() {

			fetchJson( 'playlist.json' ).then( function(data){

				playlist = data;
				index = 0;

				YouTube.init( function(){

					trace( "Youtube ready" );

					var controls = document.getElementById( 'controls' );
					var loader = document.getElementById( 'loader' );

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
							showinfo: 0
						},
						events: {
							'onReady': function(e){

								trace( "Youtube player ready" );

								var volume : InputElement = cast controls.querySelector( 'input[name=volume]' );
								volume.oninput = e -> {
									player.setVolume( Std.parseFloat( volume.value ) );
								}

								var storage = Browser.getLocalStorage();
								var item = storage.getItem( 'musicforprogramming' );
								var state = { index: 0, time: 0, volume: 70 };
								if( item != null ) {
									state = Json.parse( item );
									index = state.index;
									volume.value = Std.string( state.volume );
									/*
									trace(state);
									index = state.index;
									if( index >= playlist.length ) index = 0;
									if( state.time != null ) {
										//trace("SEEK " +state.time);
										//player.seekTo( Std.parseFloat( state.time ) );
									}
									if( state.volume != null ) {
										volume.value = Std.string( state.volume );
									}
									*/
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

							},
							'onStateChange': function(e){
								trace(e.data );
								switch e.data {
								case unstarted:
									//trace(">>>>>>>>>>>>>>");
								//	controls.style.display = 'none';
								case buffering:
								case ended:
									//controls.style.display = 'none';
									playNext();
								case playing:
									controls.style.display = 'block';
									loader.style.display = 'none';
									trace( player );
									trace( player.getCurrentTime() );
								default:
									//loader.style.display = 'block';
									controls.style.display = 'none';
									loader.style.display = 'block';
								}
							},
							'onPlaybackQualityChange': function(e){
							},
							'onPlaybackRateChange': function(e){
							},
							'onError': function(e){
								trace(e);
							}
						}
					});
				});
			});

			window.oncontextmenu = e -> {
	            e.preventDefault();
	        }
		};
	}

}
