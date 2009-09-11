package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class DataTypeTabModel extends AbstractPM
	{
	
		public var dataTypeDataProvider:ArrayCollection
		public var layout:Object;
		
		public function DataTypeTabModel(model:IModelLocator):void
		{
			super(model);
		}

		public function init():void
		{
		}

		public function reportLoaded(value:Object):void
		{
			if(!value.fields) return;

		}
		
		public function selectDataType(value:String):void
		{
			_model.customReporting.dataType = value;
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(reportLoaded, _model, ["customReporting", "loadedData" ] ), "loadedData");
			addWatcher( BindingUtils.bindProperty(this, "dataTypeDataProvider", _model, ["customReporting", "dataTypeDataProvider" ] ), "dataTypeDataProvider");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator = EAModelLocator.getInstance();

	}
}