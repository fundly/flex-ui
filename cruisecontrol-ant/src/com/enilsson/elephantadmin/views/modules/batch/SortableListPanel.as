package com.enilsson.elephantadmin.views.modules.batch
{
	import flash.events.Event;
	
	import mx.controls.ComboBox;
	
	[Event(name="sortChange", type="flash.events.Event")]

	public class SortableListPanel extends ListPanel
	{
		
		public function get selectedSortField() : String
		{
			if(_sortFieldsCb && _sortFieldsCb.selectedItem && _sortFieldsCb.selectedItem.hasOwnProperty('value'))
				return String(_sortFieldsCb.selectedItem.value);
			return null; 
		}
		
		public function get selectedSortOption() : String
		{
			if(_sortOptionsCb && _sortOptionsCb.selectedItem && _sortOptionsCb.selectedItem.hasOwnProperty('value'))
				return String(_sortOptionsCb.selectedItem.value);
			return null;
		}
		
		public function set sortFields( value : Array ) : void {
			_sortFields = value;
			_sortFieldsChanged = true;
			
			invalidateProperties(); 	
		}
		
		public function set sortOptions( value : Array ) : void {
			_sortOptions = value;
			_sortOptionsChanged = true;
			invalidateProperties();
		}
		
		public function set sortFieldsPrompt( value : String ) : void {
			_sortFieldsPrompt = value;
			_sortFieldsPromptChanged = true;
			invalidateProperties();		
		}
		
		public function set sortOptionsPrompt( value : String ) : void {
			_sortOptionsPrompt = value;
			_sortOptionsPromptChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(_sortFieldsChanged) {
				_sortFieldsChanged = false;
				_sortFieldsCb.dataProvider = _sortFields;
				_sortFieldsCb.selectedIndex = 0;
			}
			if(_sortOptionsChanged) {
				_sortOptionsChanged = false;
				_sortOptionsCb.dataProvider = _sortOptions;
				_sortOptionsCb.selectedIndex = 0;
			}
			if(_sortFieldsPromptChanged) {
				_sortFieldsPromptChanged = false;
				_sortFieldsCb.prompt = _sortFieldsPrompt;
			}
			if(_sortOptionsPromptChanged) {
				_sortOptionsPromptChanged = false;
				_sortOptionsCb.prompt = _sortOptionsPrompt;
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
						
			if(titleBar && toggleButton) {
				if(!_sortFieldsCb) 
				{
					_sortFieldsCb 	= new ComboBox();
					_sortFieldsCb.setStyle("fontSize", 10);
					_sortFieldsCb.prompt = _sortFieldsPrompt;
					_sortFieldsCb.addEventListener( Event.CHANGE, handleSortChange );
					
					_sortOptionsCb	= new ComboBox();
					_sortOptionsCb.setStyle("fontSize", 10);
					_sortOptionsCb.prompt = _sortOptionsPrompt;
					_sortOptionsCb.addEventListener( Event.CHANGE, handleSortChange );
					
					titleBar.addChild( _sortFieldsCb );
					titleBar.addChild( _sortOptionsCb );
				}		
			}
		}
		
		override protected function layoutChrome(w:Number, h:Number):void
		{
			super.layoutChrome(w,h);
			
			var tbarW : Number = titleBar.width;
			var tbarH : Number = titleBar.height;
			
			var tbuttonX : Number = toggleButton.x;
			
			_sortOptionsCb.setActualSize( 100, 18 );
			_sortFieldsCb.setActualSize( 100, 18 );
			
			_sortOptionsCb.move( toggleButton.x - _sortOptionsCb.width - 12, tbarH/2 - _sortOptionsCb.height/2 );
			_sortFieldsCb.move( _sortOptionsCb.x - _sortFieldsCb.width -4, tbarH/2 - _sortFieldsCb.height/2 );
		}
		
		
		private function handleSortChange( event : Event ) : void {
			dispatchEvent( new Event('sortChange') );
		}
		
		protected var _sortFieldsCb		: ComboBox;
		protected var _sortOptionsCb	: ComboBox;
		
		private var _sortFields					: Array = [];
		private var _sortFieldsChanged			: Boolean = true;
		private var _sortFieldsPrompt			: String = "-- Sort by --";
		private var _sortFieldsPromptChanged	: Boolean = true;
		
		private var _sortOptions				: Array = [ {label:'ascendig', value:'ASC'}, {label:'descending', value:'DESC'} ];
		private var _sortOptionsChanged			: Boolean = true;;
		private var _sortOptionsPrompt			: String = "-- Sort order --";
		private var _sortOptionsPromptChanged 	: Boolean = true;
	}
}