package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
	import com.enilsson.elephantadmin.events.main.SidEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import org.osflash.thunderbolt.Logger;

	public class URLChangeCommand extends SequenceCommand implements ICommand
	{
		private static var _isParsingUrl : Boolean;
		
		private var _browserFragments : Array;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();

		
		override public function execute(event:CairngormEvent):void
		{			
			updateUrl();
		}
		
		
		private function updateUrl():void
		{			
			if(_isParsingUrl)
				return;
				
			_isParsingUrl = true;
			
			var fragment:String = SWFAddress.getValue().split('/')[1];
			
			// some debugging
			if(_model.debug) Logger.info('URL Change', fragment);
			
			// if there is no fragment or it is for the login module
			if(fragment == '' || fragment == 'login') {
				_isParsingUrl = false;
				return;
			}			
			// if there is something else proceed
			else
			{
				// do nothing if there is no session present
				if (_model.session == null) 
				{
					if(_model.debug) Logger.info('URL Change, check session', fragment, _model.session == null);
					_isParsingUrl = false;
					return;
				} 
				
				// set the screenState to the main screen in case it is not already
				if(_model.screenState != EAModelLocator.MAIN_SCREEN) {
					_model.screenState = EAModelLocator.MAIN_SCREEN;
				}
				
				var actionFlag:Boolean = false;
				
				// loop through all the modules and test the fragment
				for( var i:int=0; i< _model.viewStateList.length; i++)
				{
					if(_model.viewStateList[i] == fragment)
					{						
						if(_model.debug)
							Logger.info('URL Change View state', i, fragment);
						
						// check to see if the module is in the allowed list	
						if(_model.allowedModules)
						{
							if(_model.debug)
								Logger.info('Is module allowed?', _model.allowedModules.getItemIndex(fragment));
							
							// if the user is attempting to access a module that is not in their config
							// return them to the first module in the list
							if(_model.allowedModules.getItemIndex(fragment) == -1)
							{
								_model.mainViewState = 0;
								SWFAddress.setValue(_model.viewStateList[0]);
			   					SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[0]);
			   					_isParsingUrl = false;
			   					return;
							}					
						}
						
						actionFlag = true;
						
						// load the module that matches the fragment	
						_model.mainViewState = i;
			   			SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[i]);
			   			break;
			  		}									
				}
				
				// if the fragment doesnt match any of the listed, test to see if it is an sid.
				if(!actionFlag)
				{				
					if(_model.debug) Logger.info('Is fragment a sid?', fragment);
					
					this.nextEvent = new SidEvent ( fragment );
					this.executeNextCommand();
					this.nextEvent = null;		
				}		
			}
						
			_isParsingUrl = false;
		}
		
	}
}