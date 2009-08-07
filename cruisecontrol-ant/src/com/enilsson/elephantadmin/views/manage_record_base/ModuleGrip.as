package com.enilsson.elephantadmin.views.manage_record_base
{
	import com.enilsson.effects.AnimateColorProperty;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.StateChangeEvent;
	import mx.states.State;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	[Style(name="onColor",type="Number",format="Color")]
	[Style(name="offColor",type="Number",format="Color")]	

	public class ModuleGrip extends Canvas
	{
		protected var gripLogo:Image;
		protected var gripLabel:UITextField;
		protected var dottedLine:UIComponent;

		private static var classConstructed:Boolean = classConstruct();

		private var onState:State;
		private var offState:State;

		private var _fromColor:uint;
		private var _toColor:uint;
		private var _lineColor:uint = 0x666666;

		public function ModuleGrip()
		{
			super();
			
			onState = new State();
			onState.name = 'on';
			offState = new State();
			offState.name = 'off';
			
			this.states = [ onState, offState ];
			
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseChildren = false;
			
			this.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, stateChangeHandler)
		}
				
		private static function classConstruct():Boolean 
		{
		    if (!StyleManager.getStyleDeclaration("ModuleGrip")) 
		    {
		        // no CSS definition for StyledRectangle, so create and set default values
		        var defaultStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
		        defaultStyles.defaultFactory = function():void {
		            this.onColor = 0xCCCCCC;
		            this.offColor = 0xFFFFFF;
		        }
		        StyleManager.setStyleDeclaration("ModuleGrip", defaultStyles, true);
		    }
		    return true;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if( !gripLogo )
			{
				gripLogo = new Image();
				gripLogo.tabEnabled = false;
				addChild ( gripLogo );				
			}
			
			if( !gripLabel )
			{
				gripLabel = new UITextField();
				gripLabel.tabEnabled = false;
				gripLabel.selectable = false;
				gripLabel.styleName = 'gripLabel';
				gripLabel.rotation = 90;
				gripLabel.autoSize = 'left';
				addChild ( gripLabel );
			}
			if( !dottedLine )
			{
				_lineColor = gripLabel.getStyle('color');
				dottedLine = new UIComponent();
				addChild(dottedLine);
			}
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			gripLogo.source = icon;
			gripLabel.text = label ? label.toUpperCase() : "";
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			gripLogo.x = unscaledWidth/2 - gripLogo.width/2;
			gripLogo.y = 5;
			
			gripLabel.x = unscaledWidth/2 + gripLabel.width/2 - 1.5;
			gripLabel.y = gripLogo.y + gripLogo.height + 4;
			
			var lineY:int = gripLabel.y + gripLabel.height + 4;
			dottedLine.graphics.clear();
			
			var lineColor:uint = this.currentState == 'on' ? getStyle('offColor') : getStyle('onColor');

			while ( lineY < height )
			{
				dottedLine.graphics.lineStyle(1, lineColor, 1);
				dottedLine.graphics.moveTo( unscaledWidth/2, lineY );
				lineY = lineY + 5;
				dottedLine.graphics.lineTo( unscaledWidth/2, lineY );
				lineY = lineY + 5;
			}
		}
		
		public function toggleState():void
		{
			this.currentState = this.currentState == 'on' ? 'off' : 'on';
		}

		private function stateChangeHandler ( event:StateChangeEvent ):void
		{
			_fromColor = this.currentState == 'on' ? getStyle('offColor') : getStyle('onColor');
			_toColor = this.currentState == 'on' ? getStyle('onColor') : getStyle('offColor');

			var colorTransition:AnimateColorProperty = new AnimateColorProperty( this );
			colorTransition.property = 'backgroundColor';
			colorTransition.isStyle = true;
			colorTransition.fromValue = _fromColor;
			colorTransition.toValue = _toColor;
			colorTransition.duration = 300;
			colorTransition.play();

			invalidateDisplayList();
		}
	}
}