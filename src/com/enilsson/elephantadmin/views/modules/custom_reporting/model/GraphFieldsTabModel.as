package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	
	public class GraphFieldsTabModel extends AbstractPM
	{
		public const LOADED:String = "loaded";
		public var fields:Array = [];
		
		public function GraphFieldsTabModel(mainModel:IModelLocator)
		{
			super(mainModel);
		}

		public function reportLoaded(value:Object):void
		{
			if(!value.graph_fields) return;

			fields = _model.customReporting.fieldsObj;
			dispatchEvent(new Event(LOADED));

			// initialise the _rData variable
			_model.customReporting.reportData.graph_fields['chart_type'] = 'noChart';
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(reportLoaded, _model, ["customReporting", "loadedData" ] ), "loadedData");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator;
	}
}