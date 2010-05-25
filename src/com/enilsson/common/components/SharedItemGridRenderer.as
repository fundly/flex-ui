package com.enilsson.common.components
{
	import com.enilsson.common.utils.SharedCreditUtil;
	
	import mx.controls.Label;

	public class SharedItemGridRenderer extends Label
	{
		private var _color : Number = NaN;
		private var _sharedColor : Number = 0xA5A5A5;
		private var _isShared : Boolean;
				
		override public function set data(value:Object):void {
			super.data = value;
			if( ! data ) return;
			
			_isShared = SharedCreditUtil.isSharedCreditPledge(data);
			invalidateDisplayList();		
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w,h);
			
			if( isNaN(_color) )
				_color = getStyle('color'); 
			
			if(	_isShared )
				setStyle( 'color', _sharedColor );
			else
				setStyle( 'color', _color );
		}
	}
}