package com.enilsson.elephantadmin.views.modules.app_options.view.components
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.containers.ControlBar;
	import mx.controls.RichTextEditor;
	import mx.controls.VRule;
	import mx.core.IUITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	use namespace mx_internal;

	[Style(name="textAreaHeight", type="Number", inherit="no")]


	public class AppOptionsRTE extends RichTextEditor
	{
		public function AppOptionsRTE()
		{
			super();
			
			setStyles();
			setStyle('headerHeight', 0);
			setStyle('dropShadowEnabled', false);
			setStyle('backgroundAlpha', 0);
			
			showToolTips = true;
		}

		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("AppOptionsRTE")) {
	            var ComponentStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            ComponentStyles.defaultFactory = function():void {
					
	            }
	            StyleManager.setStyleDeclaration("AppOptionsRTE", ComponentStyles, true);
	        }
		}
		
		
		/**
		 * Create array of the allowed formatting buttons
		 */
		private var btns:Array;
		public function set buttons ( value:String ):void { 
			_buttons = value;
			btns = value.split('|');
		}
		private var _buttons:String;
		public function get buttons ():String { return _buttons; }


		/**
		 * Create array of the allowed align buttons
		 */
		private var alignBtnArray:Array;
		public function set alignBtns ( value:String ):void { 
			_alignButtons = value;
			alignBtnArray = value.split('|');
		}
		private var _alignButtons:String;
		public function get alignBtns ():String { return _alignButtons; }

/* 		private var alignBtnProvider:Array = [
			{ icon : "@Embed('assets/icon_align_left.png')", action : "left" },
			{ icon : "@Embed('assets/icon_align_center.png')", action : "center" },
			{ icon : "@Embed('assets/icon_align_right.png')", action : "right" },
			{ icon : "@Embed('assets/icon_align_justify.png')", action : "justify" }
		];
 */
		/**
		 * Set the allowed variables that can be inserted into the text
		 */
		public function set variables( value:ICollectionView ) : void
		{
			_variables = value;
			_variablesChanged = true;
			invalidateProperties();
		}
		private var _variables : ICollectionView;
		public function get variables() : ICollectionView { return _variables; }
		private var _variablesChanged : Boolean

		private var _variableSelector : VariableSelector;
		private var _textField : IUITextField;		
		override protected function createChildren():void
		{
			super.createChildren();


			if ( textArea )
			{
				textArea.setStyle('focusAlpha', 0);
				textArea.setStyle('dropShadowEnabled', false);
				textArea.styleName = getStyle('textAreaStyleName');
				_textField = textArea.getTextField() as IUITextField;
			}
			
			if ( toolbar )
			{
				var controlBar:ControlBar = toolbar.parent as ControlBar;
				controlBar.setStyle('paddingTop', getStyle('verticalGap') );
				controlBar.setStyle('paddingBottom', 0);
				controlBar.setStyle('paddingLeft', 0);
				controlBar.setStyle('borderStyle', 'none');
				controlBar.setStyle('horizontalAlign', 'center');
			}
			
			if ( toolBar2 )
			{
				toolBar2.setStyle('paddingLeft', 0);
				toolBar2.setStyle('paddingRight', 0);
			}

			if( btns.indexOf('variables') > -1 ) 
			{
				_variableSelector = new VariableSelector();
				_variableSelector.addEventListener( VariableSelector.ADD_VARIABLE, handleAddVar, false, 0 ,true );
				toolbar.addChildAt(_variableSelector, 0);
			}
			
			if ( btns )
			{
				if ( btns.indexOf('fontFamily') == -1 )
					toolbar.removeChild(fontFamilyCombo);
				if ( btns.indexOf('fontSize') == -1 )
					toolbar.removeChild(fontSizeCombo);
				if ( btns.indexOf('bold') == -1 )
					toolBar2.removeChild(boldButton);	
				if ( btns.indexOf('italic') == -1 )
					toolBar2.removeChild(italicButton);	
				if ( btns.indexOf('underline') == -1 )
					toolBar2.removeChild(underlineButton);	
				if ( btns.indexOf('color') == -1 )
					toolbar.removeChild(colorPicker);
				if ( btns.indexOf('bullet') == -1 )
					toolbar.removeChild(bulletButton);
				if ( btns.indexOf('link') == -1 )
					toolbar.removeChild(linkTextInput);
			}
			
 			if ( alignBtnArray )
			{				
				var alignButtonsDataProvider:ArrayCollection = new ArrayCollection();
				var dp:ArrayCollection = alignButtons.dataProvider as ArrayCollection;	
				
				for ( var i:int=0; i < dp.length; i++ )
				{
					var item:Object = dp.getItemAt(i);
					
					if ( alignBtnArray.indexOf(item.action) > -1 )
						alignButtonsDataProvider.addItem(item);
				}
				
				if ( alignButtonsDataProvider.length == 1 )
				{
					textArea.setStyle('textAlign', alignButtonsDataProvider[0].action);
					toolbar.removeChild(alignButtons);
				}
				else						
					alignButtons.dataProvider = alignButtonsDataProvider;
			} 
			
			for ( var t:int = 0; t<toolbar.numChildren; t++ )
			{
				var child:* = toolbar.getChildAt(t);
				if ( child != textArea )
					child.tabEnabled = false;
				if ( child is VRule )
					toolbar.removeChild(child);
			}

			for ( t = 0; t<toolBar2.numChildren; t++ )
			{
				child = toolBar2.getChildAt(t);
				child.tabEnabled = false;
			}

		}

		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if(_variablesChanged && _variableSelector)
			{
				_variablesChanged = false;
				_variableSelector.dataProvider = _variables;
			}
		} 
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ( getStyle('textAreaHeight') > 0 )
			{
				textArea.height = getStyle('textAreaHeight');
				height = textArea.height + toolbar.parent.height + 5;
			}
		}

		private function handleAddVar( event : Event ) : void
		{
			addSelectedVar();
		}
		
		private function addSelectedVar() : void
		{
			if(_variableSelector && _variableSelector.variablesCb.selectedItem)
			{
				_textField.setFocus();				
				_textField.replaceSelectedText(_variableSelector.variablesCb.selectedItem.toString());
				htmlText = _textField.htmlText;
				textArea.addEventListener(FlexEvent.VALUE_COMMIT, handleVarAdded );	
			}
		}
		
		private function handleVarAdded( event : FlexEvent ) : void
		{
			textArea.removeEventListener(FlexEvent.VALUE_COMMIT, handleVarAdded);
			dispatchEvent( new Event(Event.CHANGE) );
		}
		
	}
}