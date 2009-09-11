package com.enilsson.elephantadmin.views.modules.custom_reporting.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import flash.events.FocusEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class RulesTabModel extends AbstractPM
	{
		private var rules:Object;
		
		public var rulesDataProvider:ArrayCollection;
		public const INT_FILTER:Array = [
			{ value: 'G_THAN', label : 'is greater than'}, 
			{ value: 'L_THAN', label : 'is less than' },
			{ value: 'E_TO', label : 'is equal to' },
			{ value: 'N_TO', label : 'is not equal to' }
		];
		public const STRING_FILTER:Array = [
			{ value: 'LIKE', label : 'is kind of like'}, 
			{ value: 'MATCHES', label : 'exactly matches the field' },
			{ value: 'E_TO', label : 'is equal to' },
			{ value: 'N_TO', label : 'is not equal to' }
		];
		public const INT_TYPE:Array = [
			{ value: 'INT', label : 'the number'},
			{ value: 'FIELD', label : 'the field' } 
		];

		public var fields:ArrayCollection;

		public function RulesTabModel(model:IModelLocator):void
		{
			super(model);
		}
		
 		public function reportUpdated(value:Object):void
		{
			var _fieldsObj:Array = _model.customReporting.fieldsObj;
		}

		public function reportLoaded(value:Object):void
		{
			var _fieldsObj:Array = _model.customReporting.fieldsObj;
			fields = new ArrayCollection(_fieldsObj);
		}

		public function updateAdvancedFilter(e:FocusEvent):void
		{
			_model.customReporting.reportData['adv_rule'] = e.currentTarget.text;
		}

		public var selectedFilterItem:Object = {};
		public var selectedDate:Object;
		public var selectedDateCondition:Object;
		public var selectedIntType:Object;
		public var selectedIntValue:Object;
		public var selectedIntIndex:int;
		public var selectedIntLabel:String;
		public var selectedTextCondition:Object = STRING_FILTER[0];
		public var selectedTextConditionIndex:int = 0;
		public var selectedTextItem:Object;
		public var selectedTextValue:String;

		public function addFilter(operator:String):void
		{
			var rulesDP:*;
			var currRulesID:int;
			if(rulesDataProvider){
				rulesDP = rulesDataProvider;
				currRulesID = rulesDP[rulesDP.length-1].ruleID;
			} else {
				rulesDP = new ArrayCollection();
				currRulesID = 0;
			}
			if(!selectedFilterItem)
			{
				return;
			}
			else
			switch(selectedFilterItem.type){
				case 'date' :
					rulesDP.addItem({
						'ruleID': currRulesID+1,
						'operator': operator,
						'field': selectedFilterItem.value,
						'label' : selectedFilterItem.label,
						'conditions': selectedDateCondition.value,
						'value': (selectedDate.getTime()/1000)
					});
				break;
				case 'number' :
				case 'currency' :
					rulesDP.addItem({
						'ruleID': currRulesID+1,
						'operator': operator,
						'field': selectedFilterItem.value,
						'label' : selectedFilterItem.label,
						'conditions': selectedDateCondition.value,
						'value': selectedIntIndex == 0 ? selectedIntValue : selectedIntLabel
					});
				break;
				default :
					rulesDP.addItem({
						'ruleID': currRulesID+1,
						'operator': operator,
						'field': selectedFilterItem.value,
						'label' : selectedFilterItem.label,
						'conditions': selectedTextCondition.value,
						'value': selectedTextConditionIndex != 1 ? selectedTextValue : selectedTextItem.label
					});
				break;
			}
			
			rulesDataProvider = rulesDP;
			_model.customReporting.reportData.rules = rulesDP.list.source;
		}

		public function deleteRule(data:Object):void
		{
			for( var i:String in rulesDataProvider){
				if(data.ruleID == rulesDataProvider[i].ruleID){
					rulesDataProvider.removeItemAt(parseInt(i));
				}
			}
			_model.customReporting.reportData.rules = rulesDataProvider.source;
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