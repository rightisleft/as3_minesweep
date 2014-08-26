package com.rightisleft.controllers
{
	import com.rightisleft.events.GameEvent;
	import com.rightisleft.models.GameOptionsVOs;
	import com.rightisleft.models.TileVOs;
	import com.rightisleft.views.LevelMenuView;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	
	public class LevelController
	{		
		private var _leveltext:Array;
		
		private var _parent:DisplayObjectContainer;
		private var _view:LevelMenuView;
		private var _gameOptions:GameOptionsVOs;

		public var dispatcher:EventDispatcher = new EventDispatcher();
		
		public function LevelController(parent:DisplayObjectContainer, view:LevelMenuView):void {
			_parent = parent;
			_view = view;			
		}
		
		public function enter():void 
		{
			_parent.addChild(_view);
			for each (var tf:TextField in _leveltext) 
			{
				tf.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		public function exit():void 
		{			
			_parent.removeChild(_view);	
			for each (var tf:TextField in _leveltext) 
			{
				tf.removeEventListener(MouseEvent.CLICK, onClick);
			}			
		}
		
		public function init(tiles:TileVOs):void 
		{
			_gameOptions = tiles.options;
			
			_view.init(GameOptionsVOs.MODES);
			
			for each(var tf:TextField in _view.rows)
			{
				tf.addEventListener(MouseEvent.CLICK, onClick);
			}
			
			
			tiles.addEventListener(GameEvent.GAME_STATE_EVENT, onTileStateChange);
			tiles.options.addEventListener(GameEvent.GAME_STATE_EVENT, onTileStateChange);
		}
		
		private function onTileStateChange(event:GameEvent):void
		{
			switch(event.result)
			{
				case GameEvent.GAME_STATE_NEW:
					enter();
					break;
				
				case GameEvent.GAME_STATE_PLAYING:
					exit();
					break;
			}
		}
		
		
		private function onClick(event:MouseEvent):void
		{
			var tf:TextField = event.currentTarget as TextField;
			
			//pass through clicked text
			_gameOptions.setMode(tf.text);
		}
	}
}