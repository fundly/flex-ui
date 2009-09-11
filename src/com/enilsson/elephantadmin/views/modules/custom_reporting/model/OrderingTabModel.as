package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class OrderingTabModel extends AbstractPM
	{
		private var ordering:Object;
		
		public var orderDataProvider:ArrayCollection;
		
		public function OrderingTabModel(model:IModelLocator):void
		{
			super(model);
		}
		
 		public function reportUpdated(value:Object):void
		{
			var _fieldsObj:Array = _model.customReporting.fieldsObj;

			if(_fieldsObj)
				orderDataProvider = new ArrayCollection( _fieldsObj.slice(1) );

			updateOrdering()
		}

		public function reportLoaded(value:Object):void
		{
			var _fieldsObj:Array = _model.customReporting.fieldsObj;
//			var _loadedData:Object = value.ordering;
			if(_fieldsObj)
				orderDataProvider = new ArrayCollection( _fieldsObj.slice(1) );

			updateOrdering()
		}

		public function updateOrdering():void
		{
			ordering = {};

 			for(var i:String in orderDataProvider){
				ordering[parseInt(i)] = orderDataProvider[i].value;
			}
			_model.customReporting.reportData.ordering = ordering;
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(reportLoaded, _model, ["customReporting", "loadedData" ] ), "loadedData");
			addWatcher( BindingUtils.bindSetter(reportUpdated, _model, ["customReporting", "reportData" ] ), "reportData");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator = EAModelLocator.getInstance();
	}
}