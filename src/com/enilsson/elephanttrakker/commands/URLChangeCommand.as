package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.core.Application;
	
	import org.osflash.thunderbolt.Logger;

	public class URLChangeCommand extends SequenceCommand  implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		override public function execute(event:CairngormEvent):void
		{
			if (!_model.is_parsing_url) Application.application.callLater(updateURL);
		}

		private function updateURL():void
		{
			var f : String = SWFAddress.getValue().split("/")[1];
			if(_model.debug) Logger.info('URL Change', f);
			
			_model.is_parsing_url = true;
			
			
			if(f == '' || f == 'login')
			{
				_model.screenState = ETModelLocator.LOGIN_SCREEN;
				SWFAddress.setValue('login');
			    SWFAddress.setTitle(_model.appName + ' - Login');
				
			}
			else
			{
				if (_model.session == null)
				{
					if(_model.debug) Logger.info('URL Change, check session', _model.session == null);
					_model.is_parsing_url = false;
					return;
				}

				for( var i:int=0; i< _model.viewStateList.length; i++)
				{
					if(_model.viewStateList[i] == f)
					{						
						if(_model.debug)
							Logger.info('URL Change View state', i, f);
							
						if(_model.allowedModules)
						{
							if(_model.debug)
								Logger.info('Is module allowed?', _model.allowedModules.getItemIndex(f));
							
							// if the user is attempting to access a module that is not in their config
							// return them to the overview
							if(_model.allowedModules.getItemIndex(f) == -1)
							{
								_model.mainViewState = ETModelLocator.OVERVIEW_VIEW;
								SWFAddress.setValue(_model.viewStateList[0]);
								SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[0]);
								_model.is_parsing_url = false;
								return;
							}
						}

						_model.screenState = ETModelLocator.MAIN_SCREEN;
						_model.mainViewState = i;
						SWFAddress.setValue(_model.viewStateList[i]);
						SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[i]);
						break;
					}
				}
			}
			_model.is_parsing_url = false;
		}
		
	}
}