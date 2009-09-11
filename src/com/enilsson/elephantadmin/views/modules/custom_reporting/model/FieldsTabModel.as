package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class FieldsTabModel extends AbstractPM
	{
		public var tableBoxHts:Object;
		public var loadedData:Object;
		public var dataType:String;
		public var relationships:Object;
		public var reportData:Object;
		public var layout:Object;
		
		public function FieldsTabModel(model:IModelLocator):void
		{
			super(model);
		}
		
		public function initReportData():void
		{
			// initialise the reportData object
			_model.customReporting.reportData['reportID'] = null,
			_model.customReporting.reportData['fields'] = {};
			_model.customReporting.reportData['math_fields'] = {};
			_model.customReporting.reportData['sortby_fields'] = {};
			_model.customReporting.reportData['rules'] = {};
			_model.customReporting.reportData['ordering'] = {};
			_model.customReporting.reportData['graph_fields'] = {};
		}
		
		public function setDataType(type:String):void
		{
			dataType = type;
			_model.customReporting.reportData['dataType'] = type;
		}
		
		public function setDataTypeDataProvider(value:ArrayCollection):void
		{
			_model.customReporting.dataTypeDataProvider = value;
		}

		/**
		 * Handle the clicks of the field checkboxes
		 */
		public function cbClickHandler(e:MouseEvent):void
		{
			_model.customReporting.reportData.fields[e.currentTarget.id] = e.currentTarget.selected;
			
			var _loadedData:Object = _model.customReporting.loadedData;
			if(_loadedData){
				_loadedData.fields[e.currentTarget.id] = e.currentTarget.selected;
			}
			
//			buildFieldsObj();
//			buildReportingWizard();
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindProperty(this, "reportData", _model, ["customReporting", "reportData" ] ), "reportData");
			addWatcher( BindingUtils.bindProperty(this, "loadedData", _model, ["customReporting", "loadedData" ] ), "loadedData");
			addWatcher( BindingUtils.bindProperty(this, "tableBoxHts", _model, ["customReporting", "tableBoxHts" ] ), "tableBoxHts");
			addWatcher( BindingUtils.bindProperty(this, "relationships", _model, ["customReporting", "relationships" ] ), "relationships");
			addWatcher( BindingUtils.bindProperty(this, "layout", _model, ["customReporting", "layout" ] ), "layout");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator = EAModelLocator.getInstance();

	}
}