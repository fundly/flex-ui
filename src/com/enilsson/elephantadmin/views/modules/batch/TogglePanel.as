package com.enilsson.elephantadmin.views.modules.batch
{
	import com.enilsson.elephantadmin.views.common.ListGridToggle;
	
	import flash.events.Event;
	
	import mx.containers.Panel;
	
	[Event(name="stateChange", type="flash.events.Event")]

	[Bindable]
	public class TogglePanel extends Panel
	{
		override protected function createChildren():void
		{
			super.createChildren();
						
			if(titleBar) {
				if(!toggleButton) 
				{
					toggleButton = new ListGridToggle();
					titleBar.addChild( toggleButton );
					toggleButton.addEventListener( 'stateChange', handleStateChange );
					toggleState = toggleButton.showState;
				}		
			}
		}
		
		override protected function layoutChrome(w:Number, h:Number):void
		{
			super.layoutChrome(w,h);
			
			toggleButton.setActualSize( 45, 20 );
			
			var tbarW : Number = titleBar.width;
			var tbarH : Number = titleBar.height;
			
			var tbuttonX : Number = tbarW - toggleButton.width - 8;
			var tbuttonY : Number = tbarH/2 - toggleButton.height/2;
			
			toggleButton.move(tbuttonX, tbuttonY);
		}
		
		protected var toggleButton : ListGridToggle;
		
		private function handleStateChange( event : Event ) : void {
			toggleState = toggleButton.showState;
			dispatchEvent( new Event('stateChange') );			
		}
		
		public function get toggleState() : String { return _toggleState; }
		public function set toggleState( value : String ) : void {
			
			if(_toggleState != value) { 
				_toggleState = value;
				toggleButton.showState = value;
			} 
		}
		private var _toggleState : String;
	}
}