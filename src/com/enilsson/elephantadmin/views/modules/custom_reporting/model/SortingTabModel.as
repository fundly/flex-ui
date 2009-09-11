package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class SortingTabModel extends AbstractPM
	{
		public const DIRECTION_FILTER:Array = new Array(
			{ value: 'ASC', label : 'Ascending [A to Z, 0 to 9]'}, 
			{ value: 'DESC', label : 'Decending [Z to A, 9 to 0]' }
		);

		public function SortingTabModel(model:IModelLocator):void
		{
			super(model);
		}
		
		public var fields:ArrayCollection = new ArrayCollection();
		
		public var sortingOptionsVisible:Boolean = false;
		public var sortingErrorVisible:Boolean = true;
		
		
 		public function reportUpdated(value:Object):void
		{
 			if(!value['sortby_fields'])
				return;
 			var _fieldsObj:Array = _model.customReporting.fieldsObj;
			// use the _fieldsObj to decide if the sorting options should be shown
			if(_fieldsObj.length > 0){
				sortingOptionsVisible = true;
				sortingErrorVisible = false;
			} else {
				sortingOptionsVisible = false;
				sortingErrorVisible = true;
			}
			// sort the dataprovider by the label
			_fieldsObj.sortOn('label');
			_fieldsObj.unshift({ value: '', label: '[-- Please a select a field --]' });
			
			fields = new ArrayCollection(_fieldsObj);
		}

		public function reportLoaded(value:Object):void
		{
 			if(!value['sortby_fields'])
				return;
			var _fieldsObj:Array = _model.customReporting.fieldsObj;
			// use the _fieldsObj to decide if the sorting options should be shown
			if(_fieldsObj.length > 0){
				sortingOptionsVisible = true;
				sortingErrorVisible = false;
			} else {
				sortingOptionsVisible = false;
				sortingErrorVisible = true;
			}
			// sort the dataprovider by the label
			_fieldsObj.sortOn('label');
			_fieldsObj.unshift({ value: '', label: '[-- Please a select a field --]' });
			// if loaded data is present

			var _loadedData:Object = value;
			if(_loadedData){
				if(_loadedData.sortby_fields){
					_model.customReporting.reportData['sortby_fields'] = _loadedData.sortby_fields;
					for(var i:String in _loadedData.sortby_fields)
					{
						switch(i){
							case '1' :
								sortFieldIndex1 = _loadedData.sortby_fields[i].field;
								sortDirectionIndex1 = _loadedData.sortby_fields[i].direction;
							break;
							case '2' :
								sortFieldIndex2 = _loadedData.sortby_fields[i].field;
								sortDirectionIndex2 = _loadedData.sortby_fields[i].direction;
							break;
							case '3' :
								sortFieldIndex3 = _loadedData.sortby_fields[i].field;
								sortDirectionIndex3 = _loadedData.sortby_fields[i].direction;
							break;
						}
					}
				}
			}

			fields = new ArrayCollection(_fieldsObj);
		}

		public var sortFieldIndex1:int;
		public var sortDirectionIndex1:int;
		public var sortFieldIndex2:int;
		public var sortDirectionIndex2:int;
		public var sortFieldIndex3:int;
		public var sortDirectionIndex3:int;

		public function updateSorting(value:Object,index:int):void
		{
			_model.customReporting.reportData.sortby_fields[index] = value;
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