package com.enilsson.elephantadmin.views.modules.dashboard
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import mx.containers.TitleWindow;
	import mx.controls.LinkButton;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.styles.ISimpleStyleClient;

	[Event(name="refreshEvent", type="flash.events.Event")]		

	public class DashboardHeader extends UIComponent
	{

		protected var headerSkin	: IFlexDisplayObject;
		protected var textField		: UITextField;
		protected var button		: LinkButton;
		
		private var _updateText : Boolean;
		private var _updateButton : Boolean;
		
		private static const PADDING_LEFT : Number  = 5;
		private static const PADDING_RIGHT : Number  = 5;
		private static const PADDING_TOP : Number   = 5;

		[Bindable]
		public function set showRefreshButton( value : Boolean ) : void
		{
			_showRefreshButton = value;
			_updateButton = true;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get showRefreshButton() : Boolean { return _showRefreshButton; } 
		private var _showRefreshButton : Boolean;


		[Bindable]
		public function set text( value : String ) : void
		{
			_text = value; TitleWindow
			_updateText = true;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get text() : String { return _text; } 
		private var _text : String;
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( _updateText )
			{
				_updateText = false;
				textField.text = text;
				invalidateSize();
			}
			if( _updateButton && showRefreshButton)
			{
				button.visible = true;
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			
			measuredHeight = measuredMinHeight = textField.getExplicitOrMeasuredHeight() + 2 * PADDING_TOP;
			measuredWidth = measuredMinWidth = textField.getExplicitOrMeasuredWidth() + 2 * PADDING_LEFT;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			if( headerSkin )
			{
				headerSkin.setActualSize( w, h );
			}

			if( _showRefreshButton )
			{
				button.x = w - button.width - PADDING_RIGHT;
				button.y = h/2 - button.height / 2;
			}
			textField.x = PADDING_LEFT;
			textField.y = h/2 - textField.getExplicitOrMeasuredHeight()/2 + 1;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			// create the skin
			var newSkinClass : Class = Class(getStyle('skin'));
			var newSkin : IFlexDisplayObject = getChildByName( 'skin' ) as IFlexDisplayObject;  
			
			if(newSkinClass && !newSkin)
			{
				newSkin = new newSkinClass() as IFlexDisplayObject;
				
				if(newSkin is ISimpleStyleClient)
				{
					ISimpleStyleClient(newSkin).styleName = this;
				}
				
				headerSkin = newSkin;
				headerSkin.name = 'skin';
				addChild(headerSkin as DisplayObject);
			}
			
			if( ! textField )
			{
				textField 				= new UITextField();
				textField.autoSize 		= TextFieldAutoSize.LEFT;
				addChild(textField);
			}

			if( ! button)
			{
				button					= new LinkButton();
				button.styleName		= this.getStyle('buttonStyle');
				button.label			= 'refresh';
				button.width			= 50;
				button.height			= 15;
				button.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				button.visible			= false;
				addChild(button);
			}
		}
		
		private function buttonClickHandler(event:MouseEvent):void
		{
			this.dispatchEvent( new Event("refreshEvent") );
		}
	}
}