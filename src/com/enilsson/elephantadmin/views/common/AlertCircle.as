package com.enilsson.elephantadmin.views.common
{
	import flash.display.Graphics;
	import flash.text.TextLineMetrics;
	
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import org.osflash.thunderbolt.Logger;
	
	use namespace mx_internal;
	
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
	            StyleManager.setStyleDeclaration("AlertCircle", ComponentStyles, true);
	        }
		}	
		
		/**
		 * Set the number in the circle
		 */
		private var _number:int = 0;
		public function get number():int
		{
			return _number;
		}
		public function set number(value:int):void
		{
			_number = value;
			
			invalidateDisplayList();
		}		
		
		private var _numberText:Text;
		mx_internal var background:UIComponent;
		
		override protected function createChildren():void
		{
			super.createChildren();

	        if (!background)
	        {
	            background = new UIComponent();
	            addChild(background);
	        }
			
			if(!_numberText)
			{
				_numberText = new Text();
				_numberText.setStyle('color', getStyle('numberColor'));
				_numberText.setStyle('disabledColor', getStyle('numberColor'));
				_numberText.text = _number.toString();
				_numberText.enabled = false;
				addChild(_numberText);				
			}
		}	
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// make sure the text field has the number assigned.
			_numberText.text = _number.toString();
			
			// measure the size of the text and set the text field accordingly
			var textWidth:Number = 0;
        	var textHeight:Number = 0;
	        if (_number)
	        {
	            var lineMetrics:TextLineMetrics = measureText(_number.toString());
	            textWidth = lineMetrics.width;
	            textHeight = lineMetrics.height;
	        }
			
			// get the padding
			var padding:Number = getStyle('textPadding');
			
			// set the corner radius of the rounded rectangle to half the component height
			var cornerRadius:int = height/2;
			
			// set a width variable based on either the width of text + padding or the corner radii
			var w:int = height > (_numberText.width + 2 * padding) ? height - 3 : (_numberText.width + 2 * padding) - 3;
			
			// set the component width based on the width variable			
			width = w;

	        _numberText.setActualSize(textWidth+4, textHeight);
			
			// draw the background circle
			var g:Graphics = background.graphics;
	        g.clear();
	        g.beginFill(getStyle('circleColor'));
	        g.drawRoundRect(0, 0, w, height, cornerRadius * 2, cornerRadius * 2);
	        g.endFill();
	        
	        // position the text field so it is directly in the center of the circle
	       	_numberText.move((width/2 - textWidth/2 - 2.5), (height/2 - textHeight/2 - 1));			
		}
		
	}
}