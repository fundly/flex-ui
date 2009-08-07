package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	import com.enilsson.utils.eNilssonUtils;
	
	[Bindable]
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.RssVO")]
	public class RssVO implements IValueObject
	{
		public var title:String;
		public var link:String;
		public var pubDate:String;
		public var description:String;
		
		public function RssVO( data:Object )
		{
			title = eNilssonUtils.convert_entities(data.title);
			link = data.link;
			pubDate = data.pubDate;
			description = eNilssonUtils.stripTags(eNilssonUtils.convert_entities(data.description));			
		}

	}
}