package com.enilsson.elephantadmin.views.common
{
	import flash.filters.DropShadowFilter;
	
	import mx.controls.Button;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.core.mx_internal;

	use namespace mx_internal;

	[Style(name="textDropShadow", type="Boolean", inherit="no")]
	[Style(name="textDropShadowColor", type="uint", inherit="no")]
	[Style(name="textDropShadowDistance", type="Number", inherit="no")]
	[Style(name="textDropShadowBlur", type="Number", inherit="no")]
	[Style(name="textDropShadowStrength", type="Number", inherit="no")]
	[Style(name="textDropShadowAngle", type="Number", inherit="no")]

	public class TextShadowButton extends Button
	{
		private var textDropShadow:DropShadowFilter;
		
		public function TextShadowButton()
		{
			super();
			
			setStyles();
			
			this.textDropShadow = new DropShadowFilter();
			
			this.useHandCursor = true;
			this.buttonMode = true;
		}

		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("TextShadowButton")) {
				var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				componentLayoutStyles.defaultFactory = function():void {
					this.textDropShadow = true;
					this.textDropShadowColor = 0x000000;
					this.textDropShadowDistance = 1;
					this.textDropShadowBlur = 2;
					this.textDropShadowStrength = 0.50;
					this.textDropShadowAngle = 90;	
				}
			StyleManager.setStyleDeclaration("TextShadowButton", componentLayoutStyles, true);
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			this.textDropShadow.color = this.getStyle('textDropShadowColor');
			this.textDropShadow.distance = this.getStyle('textDropShadowDistance');
			this.textDropShadow.blurX = this.getStyle('textDropShadowBlur');
			this.textDropShadow.blurY = this.getStyle('textDropShadowBlur');
			this.textDropShadow.strength = this.getStyle('textDropShadowStrength');
			this.textDropShadow.angle = this.getStyle('textDropShadowAngle');
			// add shadow to the textfield
			this.textField.filters = getStyle('textDropShadow') ? [this.textDropShadow] : [];
			// if icon exists, add shadow to the icon
			if(currentIcon)
				currentIcon.filters = getStyle('textDropShadow') ? [this.textDropShadow] : [];
		}
	}
}