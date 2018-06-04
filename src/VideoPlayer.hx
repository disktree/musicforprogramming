
import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.DivElement;
import om.api.youtube.YouTubePlayer;

class VideoPlayer {

	public dynamic function onEvent( e : String ) {}

	public var volume(get,set) : Float;
	inline function get_volume() return player.getVolume();
	inline function set_volume(v) {
		player.setVolume( v );
		return v;
	}

	public var element(default,null) : Element;
	public var isPlaying(default,null) = false;
	public var playlist(default,null) : Array<String>;
	public var playlistIndex(default,null) : Int;
	public var videoId(default,null) : String;

	var player : YouTubePlayer;
	//var container : DivElement;
	//var overlay : DivElement;

	public function new( element : Element ) {

		this.element = element;
		//element = document.createDivElement();
		//element.id = elementId;
		//element.classList.add( 'youtube' );

		//container = document.createDivElement();
		//container.id = 'videoplayer-container';
		//container.classList.add( 'container' );
		//element.appendChild( container );

		//overlay = document.createDivElement();
		//overlay.id = 'videoplayer-overlay';
		////overlay.classList.add( 'overlay' );
		//element.appendChild( overlay );
	}

	public function init( playlist : Array<String>, playlistIndex = 0, callback : Void->Void ) {

		this.playlist = playlist;
		this.playlistIndex = playlistIndex;

		player = new YouTubePlayer( element.id, {
			//width: Std.string( window.screen.width ),
			//width: Std.string( window.innerWidth ),
			//width: '600',
			//height: Std.string( window.innerHeight ),
			//height: '400',
			//height: Std.string( window.screen.height ),
			//videoId: 'M7lc1UVf-VE',
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

					callback();

					/*
					trace( 'Videoplayer ready' );

					//callback();

					//player.cuePlaylist( 'PL0FskzBvijeEMwhL6MJpIdAbn5pMc6Lep' );
					//playlist = ['5QCj-YyjLKM','9ZS7eM_-jEA','MmIQ7ansrA0','lE-nHkeQSOg','drOYUXcgaeE'];
					//playlistIndex = Std.int( Math.random() * (playlist.length-1) );
					//player.loadPlaylist( playlist, playlistIndex );
					player.cuePlaylist( playlist, playlistIndex );
					//player.loadPlaylist( 'PL0FskzBvijeEMwhL6MJpIdAbn5pMc6Lep' );
					*/

					/*
					//var playlist = player.getPlaylist();
					haxe.Timer.delay( function(){
						trace(player.getPlaylist() );
					}, 2000 );
					*/
				},
				'onStateChange': handlePlayerStateChange,
				'onPlaybackQualityChange': handlePlaybackQualityChange,
				'onPlaybackRateChange': handlePlaybackRateChange,
				'onError': handlePlayerError,
				//'onApiChange': handlePlayerAPIChange
			}
		});
		//player.setPlaybackQuality(hd1080);
	}

	public function play( ) {
		//player.cuePlaylist( playlist, 0 );
		player.loadPlaylist( playlist, playlistIndex );
	}

	/*
	public function play( ) {
		player.loadPlaylist( playlist, playlistIndex );
	}

	*/
	public function playNext() {
		if( ++playlistIndex == playlist.length ) playlistIndex = 0;
		trace(playlistIndex);
		player.loadPlaylist( playlist, playlistIndex );
	}

	/*
	public inline function loadPlaylist( id : String ) {
		player.loadPlaylist( id, 0 );
	}

	public inline function load( videoId : String ) {
		player.loadVideoById( videoId );
		//player.cuePlaylist( videoId, 0, 0  );
		/*
		this.videoId = videoId;
		overlay.style.opacity = '1';
		player = new YouTubePlayer( 'videoplayer-container', {
			width: Std.string( window.innerWidth ),
			height: Std.string( window.innerHeight ),
			videoId: videoId,
			playerVars: {
				controls: no,
				color: white,
				autoplay: 1,
				disablekb:0,
				fs: 0,
				iv_load_policy: 3,
				//enablejsapi: 1,
				modestbranding: 1,
				showinfo: 0
			},
			events: {
				'onReady': handlePlayerReady,
				'onStateChange': handlePlayerStateChange,
				'onPlaybackQualityChange': handlePlaybackQualityChange,
				'onPlaybackRateChange': handlePlaybackRateChange,
				'onError': handlePlayerError,
				//'onApiChange': handlePlayerAPIChange
			}
		});
		* /
	}
	*/

	public inline function stop() {
		//overlay.style.opacity = '1';
		player.stopVideo();
	}

	public inline function setPlaybackQuality( quality : PlaybackQuality ) {
		player.setPlaybackQuality( quality );
	}

	/*
	function handlePlayerReady(e) {
        trace( "player ready "+e );
		//onEvent( 'ready' );
		//player.loadVideoById( videoId );
	}
	*/

	function handlePlayerStateChange(e) {
		trace(e);
		switch e.data {
		case unstarted:
			//isPlaying = false;
			//overlay.style.opacity = '1';
			//onEvent( 'stop' );
		case ended:
			//isPlaying = false;
			//overlay.style.opacity = '1';
			//onEvent( 'end' );
			playNext();
		case playing:
			//overlay.style.display = 'none';
			//isPlaying = true;
			//overlay.style.opacity = '0';
			//onEvent( 'play' );
		case video_cued:

		default:
			//overlay.style.display = 'inline-block';
			//overlay.style.opacity = '1';
		}
	}

	function handlePlaybackQualityChange(e) {
		//trace(e);
	}

	function handlePlaybackRateChange(e) {
		//trace(e);
	}

	function handlePlayerError(e) {
		trace(e);
		//onEvent( error( e.data ) );
	}
}
