package com.enilsson.elephantadmin.views.common
{
	import com.enilsson.elephantadmin.events.session.PingEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.graphics.enDropShadows;
	
	import flash.display.Graphics;
	
	import mx.containers.Canvas;
	import mx.containers.utilityClasses.CanvasLayout;
	import mx.controls.Image;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.utils.GraphicsUtil;
	
	import org.osflash.thunderbolt.Logger;

	use namespace mx_internal;

	public class LabeledContainer extends Canvas
	{		
		public static const LABEL_WIDTH : Number = 32;
		
		[Bindable] public var padding:int = 7;

		public function set runInit(value:Boolean):void
		{
			if(value && _model.mainViewState == moduleID)
				init();
		}

		[Bindable]
		public function get moduleID():int
		{
			return _moduleID;
		}
		private var _moduleID:int = -1;
		public function set moduleID(id:int):void
		{
			_moduleID = id;
			this.label = String(_model.viewStateNames.getItemAt(moduleID));
		}

		private var layoutObject:CanvasLayout = new CanvasLayout();

		public function LabeledContainer()
		{
			layoutObject.target = this;

			horizontalScrollPolicy 	= "off";
			verticalScrollPolicy 	= "off";

			addEventListener(FlexEvent.SHOW, handleShow);
		}

		private var _model : EAModelLocator = EAModelLocator.getInstance();
		
		protected var logoImage		: Image;
		protected var textField		: UITextField;		
		
		 
		protected function handleShow( e : FlexEvent ) : void
		{
			init();
		}
		
		protected function init():void
		{
			if(_model.debug) Logger.info('Init ' + label );
			
			// ping the server to see all is well
			new PingEvent().dispatch();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();			
			
			if( ! textField )
			{
				textField 				= new UITextField();
				textField.rotation 		= 90;
				textField.filters		= [enDropShadows.textDS(0)];
				textField.tabEnabled	= false;
				textField.autoSize		= "left";
				textField.styleName = "contentTitle"; 
				addChild( textField );
			}
			
			if( ! logoImage )
			{
				logoImage = new Image();
				logoImage.tabEnabled = false;
				addChild( logoImage );
			} 
		}
		
		override public function set label(value:String):void
		{
			super.label = value;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			textField.text = label ? label.toUpperCase() : "";
			logoImage.source = icon;

		}

		override protected function measure():void
		{
			super.measure();
	
			layoutObject.measure();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{	
			super.updateDisplayList( unscaledWidth, unscaledHeight );

			layoutObject.updateDisplayList(unscaledWidth - LABEL_WIDTH - padding, unscaledHeight);

			var g : Graphics = graphics;
			g.clear();
			g.beginFill(0x999999);
			GraphicsUtil.drawRoundRectComplex(g, unscaledWidth - LABEL_WIDTH, 0, LABEL_WIDTH, unscaledHeight, 0, padding, 0, padding );
			g.endFill();
			
			//logoImage.width = LABEL_WIDTH;
			logoImage.x = unscaledWidth - LABEL_WIDTH/2 - logoImage.width/2;
			logoImage.y = 8;
			
			textField.x = unscaledWidth-2;
			textField.y = logoImage.y + logoImage.height + 5;
		}
	}
}