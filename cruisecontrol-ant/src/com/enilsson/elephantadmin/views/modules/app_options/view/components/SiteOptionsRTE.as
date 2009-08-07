package com.enilsson.elephantadmin.views.modules.app_options.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.RichTextEditor;
	import mx.controls.VRule;
	import mx.core.IUITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	use namespace mx_internal;

	public class SiteOptionsRTE extends RichTextEditor
	{
		import mx.collections.ICollectionView;
		
		public function SiteOptionsRTE()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(toolbar && toolBar2)
			{
				if(fontFamilyCombo)
					toolbar.removeChild(fontFamilyCombo);			
			 	if(italicButton)
			 		toolBar2.removeChild(italicButton);
			
				if(!_variableSelector) {
					_variableSelector = new VariableSelector();
					_variableSelector.addEventListener( VariableSelector.ADD_VARIABLE, handleAddVar, false, 0 ,true );
					toolbar.addChildAt(_variableSelector, 0);
				}
				if(!_vrule) {
					_vrule = new VRule();
					toolbar.addChildAt(_vrule,1);
				}				
				if(textArea)
				{
					_textField = textArea.getTextField() as IUITextField;
				} 
			}
		}
		
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if(_variablesChanged)
			{
				_variablesChanged = false;
				_variableSelector.dataProvider = _variables;
			}
		} 
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			_vrule.height = _variableSelector.height;
		}
		
		public function set variables( value : ICollectionView ) : void
		{
			_variables = value;
			_variablesChanged = true;
			invalidateProperties();
		}
		public function get variables() : ICollectionView { return _variables; }
		private var _variables : ICollectionView;
		private var _variablesChanged : Boolean
		
		private var _vrule : VRule;
		private var _variableSelector : VariableSelector;
		private var _textField : IUITextField;
		
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