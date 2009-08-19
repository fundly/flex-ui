package com.enilsson.elephantadmin.views.modules.batch
{
	import com.enilsson.elephantadmin.views.common.ListGridToggle;
	
	import flash.events.Event;
	
	import mx.containers.Panel;
	
	[Event(name="stateChange", type="flash.events.Event")]

	[Bindable]
	public class TogglePanel extends Panel
	{
		public static const LIST_VIEW:String = "toggleListView";
		public static const GRID_VIEW:String = "toggleGridView";
		
		override protected function createChildren():void
		{
			super.createChildren();
						
			if(titleBar) {
				if(!toggleButton) 
				{
					toggleButton = new ListGridToggle();
					titleBar.addChild( toggleButton );
					toggleButton.addEventListener( 'stateChange', handleStateChange );
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
		
		// Handles the toggleButton state change
		protected function handleStateChange( event : Event ) : void {
			switch(toggleButton.showState)
			{
				case ListGridToggle.LIST:
					toggleState = LIST_VIEW;
					break;
				case ListGridToggle.GRID:
					toggleState = GRID_VIEW;
					break;
			}
			dispatchEvent( new Event('stateChange') );
		}

		// The toggle state of this component
		public function get toggleState() : String { return _toggleState; }
		public function set toggleState( value : String ) : void {
			
			if(_toggleState != value) { 
				_toggleState = value;
				switch(_toggleState)
				{
					case LIST_VIEW:
						toggleButton.showState = ListGridToggle.LIST;
						break;
					case GRID_VIEW:
						toggleButton.showState = ListGridToggle.GRID;
						break;
				}
			} 
		}
		private var _toggleState : String = LIST_VIEW;
	}
}