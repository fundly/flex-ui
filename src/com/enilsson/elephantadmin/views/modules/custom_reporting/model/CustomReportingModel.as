package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.customreporting.CustomReportingEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class CustomReportingModel extends AbstractPM
	{
		public function CustomReportingModel(mainModel:IModelLocator)
		{
			super(mainModel);
		}

		public var dataLoading:Boolean;

		public var reportList:ArrayCollection;
		public var reportListTotal:int;
		public var reportListLoading:Boolean;
		public var selectedReportID:int;

		public var detailModel:CustomReportingDetailModel;

		public function reportListUpdated(value:ArrayCollection):void
		{
			reportList = value;
		}

		override public function firstShowHandler():void
		{
			super.firstShowHandler();
			
			getReports();
		}
		
		override protected function createChildren():void
		{
			detailModel = new CustomReportingDetailModel(domainModel);
		}
		
		// Gets a list of custom reports from the server
		public function getReports():void
		{
			new CustomReportingEvent(CustomReportingEvent.GET_REPORTS).dispatch();
			getRelations();
		}
		
		public function getRelations():void
		{
			new CustomReportingEvent(CustomReportingEvent.GET_RELATIONS).dispatch();
		}

		public function loadReport(id:int):void
		{
			var event:CustomReportingEvent = new CustomReportingEvent(CustomReportingEvent.LOAD_REPORT);
			event.reportID = id;
			event.dispatch();
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(reportListUpdated, _model, ["customReporting", "reportList" ] ), "reportList");
			addWatcher( BindingUtils.bindProperty(this, "reportListTotal", _model, ["customReporting", "reportListTotal" ] ), "reportListTotal");
			addWatcher( BindingUtils.bindProperty(this, "reportListLoading", _model, ["customReporting", "reportListLoading" ] ), "reportListLoading");
			addWatcher( BindingUtils.bindProperty(this, "selectedReportID", _model, ["customReporting", "selectedReportID" ] ), "selectedReportID");
			addWatcher( BindingUtils.bindProperty(this, "dataLoading", _model, ["dataLoading" ] ), "dataLoading");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator;
	}
}