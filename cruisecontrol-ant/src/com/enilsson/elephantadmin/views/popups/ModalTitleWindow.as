package com.enilsson.elephantadmin.views.popups
{
	import flash.display.DisplayObject;
	
	import mx.containers.TitleWindow;
	import mx.core.Application;
	import mx.managers.PopUpManager;

	public class ModalTitleWindow extends TitleWindow
	{
		private static var _instance : ModalTitleWindow;
		
		protected function close() : void
		{
			if(_instance) {
				try {
					PopUpManager.removePopUp( _instance );
				} catch( e : Error ) { }
			}
		}
		
		public static function show( title : String, width : Number = 400, height : Number = NaN ) : ModalTitleWindow
		{
			_instance = PopUpManager.createPopUp( Application.application as DisplayObject, ModalTitleWindow, true ) as ModalTitleWindow;
			_instance.title = title;
			
			if(!isNaN(width))
				_instance.width = width;
			
			if(!isNaN(height))
				_instance.height = height;
			
			PopUpManager.centerPopUp( _instance );			
			
			return _instance;
		}	
	}
}