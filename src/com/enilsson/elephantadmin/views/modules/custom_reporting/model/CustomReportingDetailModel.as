package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class CustomReportingDetailModel extends AbstractPM
	{
		public function CustomReportingDetailModel(mainModel:IModelLocator)
		{
			super(mainModel);
		}

		public var reportList:ArrayCollection;
		public var reportListTotal:int;
		public var reportListLoading:Boolean;
		public var selectedReportID:int;
		
		public var dataTypeTabModel:DataTypeTabModel;
		public var fieldsTabModel:FieldsTabModel;
		public var mathFieldTabModel:MathFieldTabModel;
		public var orderingTabModel:OrderingTabModel;
		public var rulesTabModel:RulesTabModel;
		public var sortingTabModel:SortingTabModel;
//		public var graphFieldsTabModel:GraphFieldsTabModel;

 		public function reportListUpdated(value:ArrayCollection):void
		{
			reportList = value;
		}

		override public function firstShowHandler():void
		{
			super.firstShowHandler();
			
			
		}
		
 		override protected function createChildren():void
		{
			dataTypeTabModel = new DataTypeTabModel(domainModel);
			fieldsTabModel = new FieldsTabModel(domainModel);
			mathFieldTabModel = new MathFieldTabModel(domainModel);
			orderingTabModel = new OrderingTabModel(domainModel);
			rulesTabModel = new RulesTabModel(domainModel);
			sortingTabModel =  new SortingTabModel(domainModel);
//			graphFieldsTabModel = new GraphFieldsTabModel(domainModel);
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(reportListUpdated, _model, ["customReporting", "reportList" ] ), "reportList");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator = EAModelLocator.getInstance();
	}
}