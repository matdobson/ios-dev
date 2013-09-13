

#import "Device.h"
#import "itheftRestHttp.h"
#import "IphoneInformationHelper.h"
#import "itheftConfig.h"

@implementation Device

@synthesize deviceKey, name, type, vendor, model, os, version, macAddress, uuid;


+(Device*) newDeviceForApiKey: (NSString*) apiKey{

	Device *newDevice = [[Device alloc] init];
	IphoneInformationHelper *iphoneInfo = [IphoneInformationHelper initializeWithValues];
	[newDevice setOs: [iphoneInfo os]];
	[newDevice setVersion: [iphoneInfo version]];
	[newDevice setType: [iphoneInfo type]];
	[newDevice setMacAddress: [iphoneInfo macAddress]];
	[newDevice setName: [iphoneInfo name]];
    [newDevice setVendor: [iphoneInfo vendor]];
    [newDevice setModel: [iphoneInfo model]];
    [newDevice setUuid: [iphoneInfo uuid]];
	
	itheftRestHttp *http = [[itheftRestHttp alloc] init];
	@try {
		[newDevice setDeviceKey:[http createDeviceKeyForDevice:newDevice usingApiKey:apiKey]];
	}
	@catch (NSException * e) {
		@throw;
	}
	[http release];
			
	return newDevice;
}

+(Device*) allocInstance{
	itheftConfig* itheftConfig = [itheftConfig instance];
	Device* dev = [[Device alloc]init];
	[dev setDeviceKey:[itheftConfig deviceKey]];
	return dev;
}

-(void) detachDevice {
	itheftRestHttp *http = [[itheftRestHttp alloc] init];
	[http deleteDevice: self];
	[http release];
	//[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
}

@end
