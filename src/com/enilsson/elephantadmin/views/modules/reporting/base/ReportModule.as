package com.enilsson.elephantadmin.views.modules.reporting.base
{
	import com.enilsson.elephantadmin.interfaces.IReportModule;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.modules.Module;

	[Event(name="dataLoadingStart", type="RecordModuleEvent")]
	[Event(name="dataLoadingStop", type="RecordModuleEvent")]

	public class ReportModule extends Module implements IReportModule
	{
		[Bindable] 
		public function get presentationModel():ReportModuleModel { return _presentationModel; }
		public function set presentationModel(value:ReportModuleModel):void
		{
			if( ! value || value == _presentationModel ) return;
			
			_presentationModel = value;
			_presentationModel.allGroups = _allGroups;
			_presentationModel.userGroups = _userGroups;
			_presentationModel.itemsPerPage = _itemsPerPage;
			_presentationModel.gatewayURL = _gatewayURL;
			_presentationModel.instanceID = _instanceID;
			_presentationModel.recordID = _recordID;
			_presentationModel.exportAllowed = _exportAllowed;
			if(_gatewayURL)
			{
				var gSegs:Array = _gatewayURL.split('/');
				_presentationModel.gatewayBaseURL = gSegs[0] + '//' + gSegs[2] + '/';
			}
				
			if( ! _dataLoadingWatcher )
				_dataLoadingWatcher = BindingUtils.bindProperty(this,'dataLoading',_presentationModel,'dataLoading');
			else
				_dataLoadingWatcher.reset( _presentationModel );
		}
		private var _presentationModel:ReportModuleModel;
		private var _dataLoadingWatcher : ChangeWatcher;

		public function set instanceID(value:int):void
		{
			_instanceID = value;
		}
		private var _instanceID:int;

		public function set itemsPerPage(value:int):void
		{
			_itemsPerPage = value;
		}
		private var _itemsPerPage:int;

		public function set gatewayURL(value:String):void
		{
			_gatewayURL = value;
		}
		private var _gatewayURL:String;

		public function set allGroups(value:ArrayCollection):void
		{
			_allGroups = value;
		}
		private var _allGroups:ArrayCollection;

		public function set userGroups(value:Array):void
		{
			_userGroups = value;
		}
		private var _userGroups:Array;
		public function set recordID(value:int):void
		{
			if(_presentationModel)
				_presentationModel.recordID = value;
			else
				_recordID = value;
		}
		private var _recordID:int;
		public function get recordID():int
		{
			if(_presentationModel)
				return _presentationModel.recordID
			else
				return _recordID;
		}
		
		public function set exportAllowed( value : Boolean ) : void {
			_exportAllowed = value;
		}
		private var _exportAllowed : Boolean;


		[Bindable] public var dataLoading:Boolean;

		public function ReportModule()
		{
			super();
		}
	}
}