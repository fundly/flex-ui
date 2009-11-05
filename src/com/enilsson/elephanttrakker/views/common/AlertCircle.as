package com.enilsson.elephanttrakker.views.common
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextLineMetrics;
	
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	[Style(name="circleColor", type="uint", format="Color", inherit="no")]
	[Style(name="numberColor", type="uint", format="Color", inherit="no")]
	[Style(name="textPadding", type="Number", inherit="no")]

	public class AlertCircle extends UIComponent
	{		
		public function AlertCircle()
		{
			super();
			setStyles();
		}

		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("AlertCircle")) {
	            var ComponentStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            ComponentStyles.defaultFactory = function():void {
					this.circleColor = 0xFF0000;
					this.numberColor = 0xFFFFFF;
					this.textPadding = 4;
	            }
	            StyleManager.setStyleDeclaration("AlertCircle", ComponentStyles, false);
	        }
		}	
		
		/**
		 * Set the number in the circle
		 */
		public function get number():int { return _number; }
		public function set number(value:int):void {
			_number = value;
			invalidateProperties();
			invalidateDisplayList();
		}	
		private var _number:int = 0;	
		
		private var _numberText:UITextField;
		private var _background:Sprite;
		
		override protected function createChildren():void
		{
			super.createChildren();

	        if (!_background)
	        {
	            _background = new Sprite();
	            addChild(_background);
	        }
			
			if(!_numberText)
			{
				_numberText = new UITextField();
				_numberText.setColor( getStyle('numberColor') );
				addChild(_numberText);				
			}
		}
		
		override protected function commitProperties() : void {
			super.commitProperties();
			
			// make sure the text field has the number assigned.	
			_numberText.text = _number.toString();
		}
		
		override protected function updateDisplayList( w:Number, h:Number ):void {
			
			super.updateDisplayList(w, h);
			
			// measure the size of the text and set the text field accordingly
			var textWidth:Number = 0;
        	var textHeight:Number = 0;
	        if (_number)
	        {
	            var lineMetrics:TextLineMetrics = _numberText.getUITextFormat().measureText(_number.toString());
	            textWidth = lineMetrics.width;
	            textHeight = lineMetrics.height;
	        }
			
			// get the padding
			var padding:Number = getStyle('textPadding');
			padding = isNaN(padding) ? 0 : padding;
			
			var tfWidth 	: Number = textWidth + 4;
			var tfHeight 	: Number = textHeight;
			_numberText.setActualSize( tfWidth, tfHeight );

			// set the explicit width of the component to include the padding
			width	= tfWidth + padding*2;
			height	= tfHeight;
			
			// position the text field so it is directly in the center of the circle
			var ntX : Number = Math.floor(width/2 - tfWidth/2);
			var ntY : Number = Math.floor(height/2 - tfHeight/2) - 1;
			_numberText.move( ntX, ntY );
			
			// draw the background circle
			var cornerRadius:int = height;
			var g:Graphics = _background.graphics;
	        g.clear();
	        g.beginFill(getStyle('circleColor'));
	        g.drawRoundRect(0, 0, width, height, cornerRadius, cornerRadius);
	        g.endFill();
		}
		
	}
}