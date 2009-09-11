package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class MathFieldTabModel extends AbstractPM
	{
		private var math_fields:Object;
		
		public var fieldDataProvider:ArrayCollection;
		public var fieldVisible:Boolean = true;
		
		public function MathFieldTabModel(model:IModelLocator):void
		{
			super(model);
		}
		
		public function reportUpdated(value:Object):void
		{
			if(value.math_fields)
				math_fields = value.math_fields;
			else
				math_fields = {};
			
			var _layout:Object = _model.customReporting.layout;
			var _fieldsObj:Object = _model.customReporting.fieldsObj;
			var _loadedData:Object = _model.customReporting.loadedData;
			var mfDP:ArrayCollection = new ArrayCollection();

			// loop through the listed fields and then the layout to grab which ones are math fields
			for( var fo:String in _fieldsObj){
				if(_fieldsObj[fo].type =='number' || _fieldsObj[fo].type == 'currency'){
					// list the math fields
					math_fields[_fieldsObj[fo].field] = { 
						'sum' : false, 
						'average' : false, 
						'lowest' : false, 
						'highest' : false, 
						'std_dev' : false 
					};
					// create the elements of the math field datagrid provider inserting the loaded data if present
					var values:Object = new Object();
					if(_loadedData){
						values = _loadedData.math_fields[_fieldsObj[fo].field] ? _loadedData.math_fields[_fieldsObj[fo].field] : math_fields[_fieldsObj[fo].field];
					} else {
						values = math_fields[_fieldsObj[fo].field];
					}
					mfDP.addItem({ 
						'field' : _fieldsObj[fo].field, 
						'table' : _fieldsObj[fo].table, 
						'fieldname' : _fieldsObj[fo].title,
						'values' : values
					});
				}
			}
			// assign the dataprovider and show the datagrid if there is mathfields present
			if(mfDP.length > 0){
				fieldDataProvider = mfDP;
				fieldVisible = true;
			} else {
				fieldVisible = false;
			}
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(reportUpdated, _model, ["customReporting", "loadedData" ] ), "loadedData");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator = EAModelLocator.getInstance();

	}
}