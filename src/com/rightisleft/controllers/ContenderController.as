package com.rightisleft.controllers
{
	import com.rightisleft.models.ContenderVOs;
	import com.rightisleft.vos.ContenderVO;
	
	import flash.display.BitmapData;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	public class ContenderController
	{
		private var _contenderVOs:ContenderVOs;
		
		private var _textField:TextField;
		private var _textHash:Dictionary = new Dictionary();
		private var _bevelFilter:BevelFilter;
		
		public function ContenderController(vos:ContenderVOs)
		{
			_contenderVOs = vos;

			_textField = new TextField();
			new GenericTextController('Akz', 10, 0x000000).setText('', _textField);
			
			_bevelFilter = new BevelFilter();
			_bevelFilter.blurX = 2;
			_bevelFilter.blurY = 2;
			_bevelFilter.strength = .1
		}
		
		public function paint(vo:ContenderVO):void 
		{

			//blit text
			var textValue:String = vo.text;
			var snapshot:BitmapData;
			
			//check if bitmapdata is cached so we dont have to draw a bunch of repeated text fields
			if(textValue.length) {
				if(_textHash[textValue]) {
					snapshot = _textHash[textValue]; //cached
				} else {
					_textField.text = textValue; 
					
					snapshot = new BitmapData(_textField.width, _textField.height, true, 0x00FFFFFF);
					snapshot.draw(_textField, new Matrix() );
					_textHash[textValue] = snapshot;
				}
			}
			
			//new fill
			vo.bmpd = new BitmapData(vo.width, vo.height, true, vo.color);
			
			//compose text onto square
			if(snapshot) {
				var rect:Rectangle = new Rectangle(0, 0, _textField.width, _textField.height);
				var aPoint:Point = new Point();
				vo.bmpd.copyPixels(snapshot, rect, aPoint, null, null, true);	
			}
			
			//Apply Bevel
			var bevelRect:Rectangle = new Rectangle(0,0, vo.bmpd.width,vo.bmpd.height)
			_bevelFilter.quality = BitmapFilterQuality.HIGH;
			vo.bmpd.applyFilter(vo.bmpd,bevelRect,new Point(0,0), _bevelFilter);
			vo.updated();
		}
		
		public function checkFlags(vo:ContenderVO):void {
			
			if(vo && vo.type == ContenderVO.TYPE_MINE && vo.state == ContenderVO.STATE_EXPLODED)
			{
				_contenderVOs.defeatPlayer();
				return;
			}
			
			var isAMineStillActive:Boolean = false; //could increment a count instead of looping - insignificant performance at this stage
			
			for each(var contender:ContenderVO in _contenderVOs.collectionOfMines)
			{
				if(contender.state != ContenderVO.STATE_FLAGGED)
				{
					isAMineStillActive = true;
					break;
				}
			}
			
			if(isAMineStillActive == false)
			{
				_contenderVOs.loseToPlayer();
			}
		}
	}
}
