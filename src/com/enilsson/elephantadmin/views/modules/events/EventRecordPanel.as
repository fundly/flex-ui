package com.enilsson.elephantadmin.views.modules.events
{
	import com.enilsson.elephantadmin.views.manage_record_base.RecordPanel;
	import com.enilsson.elephantadmin.views.modules.events.model.EventsModel;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.core.Container;
	import mx.core.UIComponent;

	public class EventRecordPanel extends RecordPanel
	{
		private static const SOURCE_CODES_CB_WIDTH : int = 180;
		
		[Bindable] public var sourceCodeCb : ComboBox;
		
		override protected function createChildren() : void {
			super.createChildren();
			
			if(! sourceCodeCb ) {
				sourceCodeCb = new ComboBox();
				sourceCodeCb.width = SOURCE_CODES_CB_WIDTH;
				sourceCodeCb.styleName = 'struktorInput';
				sourceCodeCb.prompt = '--Pending Source Codes--';
				sourceCodeCb.visible = false; 
				sourceCodeCb.includeInLayout = false;
				sourceCodeCb.addEventListener( Event.CHANGE, handleSourceCodeChange );
				
				// bind the tempSourceCodes property on the model to the Source Codes combo box dataprovider
				BindingUtils.bindSetter( setSourceCodes, this, ['presentationModel','tempSourceCodes'] );
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(_getSourceCodes && presentationModel) {
				_getSourceCodes = false;
				(presentationModel as EventsModel).getTempSourceCodes();
			}
			
			if(_addListeners && form ) {
				_addListeners = false;
				form.addEventListener( 'formBuildComplete', handleFormBuildComplete, false, 0, true );
			}
		}
		private var _getSourceCodes : Boolean = true;
		private var _addListeners : Boolean = true;
		
		
		private function handleFormBuildComplete( event : Event ) : void {
			addSourceCodes();
		}
		
		private function handleSourceCodeChange( event : Event ) : void {
			var field : TextInput = getSourceCodeField();
			if(! field) return;
			
			field.text = sourceCodeCb.selectedLabel;
		}
		
		private function getSourceCodeField() : TextInput {
			return form.getField('source_code') as TextInput;
		}
				
		private function addSourceCodes() : void 
		{
			var field : UIComponent = getSourceCodeField(); 
			
			if( field ) 
			{
				var c : Container = field.parent as Container;
				
				try {
					c.getChildIndex(sourceCodeCb);
				}
				catch( e : Error ) {
					field.width = NaN;
					field.percentWidth = 100;
					c.addChild( sourceCodeCb );
				}
			}
		}
		
		private function setSourceCodes( value : ArrayCollection ) : void {
			sourceCodeCb.selectedIndex = -1;
			sourceCodeCb.dataProvider = value;
			sourceCodeCb.visible = sourceCodeCb.includeInLayout = ( value && value.length > 0 ); 
		}
	}
}