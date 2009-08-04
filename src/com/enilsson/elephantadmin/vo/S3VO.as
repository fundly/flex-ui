package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephantadmin.vo.S3VO")]
	public class S3VO implements IValueObject
	{
		public var acl:String;
		public var AWSAccessKeyId:String;
		public var bucket:String;
		public var policy:String;
		public var signature:String;
		public var s3url:String = 's3.amazonaws.com/';
		public var url:String;
		
		public function S3VO( data:Object ) 
		{
			this.acl = data.acl;
			this.AWSAccessKeyId = data.AWSAccessKeyId;
			this.bucket = data.bucket;
			this.policy = data.policy;
			this.signature = data.signature;
			this.url = data.bucket + '.' + s3url;
		}
	}
}