package com.enilsson.elephanttrakker.views.modules.email
{
	import flash.display.DisplayObject;
	
	import mx.containers.FormItem;

	public class MessageFormItem extends FormItem
	{
		public var labelTop : int = 0;
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w,h)
			
			itemLabel.y = labelTop;			
			resetIndicator();
		}
		
		private function resetIndicator() : void {
			
			if( !required ) return;
			
			var indicatorClass:Class = getStyle("indicatorSkin") as Class;
			
			if( !indicatorClass ) return;
			
			var num : Number = rawChildren.numChildren;
				
			for( var i : int = 0; i < num; i++ ) {
				var d : DisplayObject = rawChildren.getChildAt( i );
				
				if( d && d is indicatorClass ) {
					d.y = itemLabel.y + itemLabel.height/2 - d.height/2;
					break; 
				}
			}		
		}
	}
}