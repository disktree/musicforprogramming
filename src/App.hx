
import js.Browser;
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.InputElement;
import om.api.youtube.YouTube;

class App {

	//static var PLAYLIST = ['5QCj-YyjLKM','9ZS7eM_-jEA','MmIQ7ansrA0','lE-nHkeQSOg','drOYUXcgaeE'];
	static var PLAYLIST = [
		'-WejD5fPTBE',
		'9ZS7eM_-jEA',
		'MmIQ7ansrA0',
		'1WbloLnhkOY',
		't1UTeTcGd5I',
		'NPVdAAzwtg0',
		'9sYsXyU77E0',
		'I1z3Uf4Zu0o',
		'WEh9k0xNoMY',
		'eu2169itPM0',
		'VK5uG2fN6HE',
		'mDVEOXR4rIc',
		'A97qEuIopYw',
		'QIXcng9Nu_M',
		'9fThCJ5S9OU',
		'pX_jySkFIK4',
		'1D587yc-8V0',
	];

	static var video : VideoPlayer;

	//static function handleVideoPlayerEvent() {}

	static function handleClick(e) {
		trace(e);
		video.playNext();
	}

	static function main() {

		window.onload = function() {

			/*
			var storage = Browser.getLocalStorage();
			var _playlistIndex = storage.getItem( 'playlist_index' );
			var playlistIndex = (_playlistIndex == null) ? 0 : Std.parseInt( _playlistIndex );
			if( playlistIndex >= PLAYLIST.length ) playlistIndex = PLAYLIST.length-1;
			*/

			//var playlistIndex = Std.int( Math.random() * (PLAYLIST.length-1));
			var playlistIndex = 0;

			trace( 'Playlist index: $playlistIndex' );

			YouTube.init( function(){

				trace( 'Youtube ready' );

				var overlay = document.getElementById( 'overlay' );

				video = new VideoPlayer( document.getElementById( 'youtube-player' ) );
				//video.onEvent = handleVideoPlayerEvent;

				video.init( PLAYLIST, playlistIndex, function(){

						trace( 'Videoplayer ready' );

						//video.element.addEventListener( 'click', handleClick, false );
						overlay.addEventListener( 'click', handleClick, false );

						//video.playNext();
						video.play();

				});
			});

			var controls = document.getElementById( 'controls' );
			var volume : InputElement = cast controls.querySelector( 'input[name=volume]' );
			volume.oninput = e -> {
				video.volume = Std.parseFloat( volume.value );
			}
		};
	}

}
