#import <substrate.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>


static void (*orig_startRecordingCountdown)(id self,SEL _cmd);
static void (*orig_performSelector)(id self,SEL _cmd,SEL aSelector,id object,NSTimeInterval delay,NSArray *modes);


static void closeControlCenterNoAnimation(){
    Class ccCls = objc_getClass("SBControlCenterController");
    if (!ccCls){
        return;
    }
    id cc = ((id (*)(Class,SEL))objc_msgSend)(ccCls,@selector(sharedInstance));
    if (!cc){
        return;
    }
    ((void (*)(id,SEL,BOOL))objc_msgSend)(cc,@selector(dismissAnimated:),NO);
}


static void hook_startRecordingCountdown(id self,SEL _cmd){
    closeControlCenterNoAnimation();
    ((void (*)(id,SEL,id))objc_msgSend)(self,@selector(startRecordingWithHandler:),nil);
}


static void hook_performSelector(id self,SEL _cmd,SEL aSelector,id object,NSTimeInterval delay,NSArray *modes){
    if (aSelector == @selector(startRecord) || aSelector == @selector(startBroadcast)){
        closeControlCenterNoAnimation();
        orig_performSelector(self,_cmd,aSelector,object,0.0,modes);
        return;
    }
    orig_performSelector(self,_cmd,aSelector,object,delay,modes);
}


%ctor{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,3*NSEC_PER_SEC),dispatch_get_main_queue(), ^{
        Class clientCls = objc_getClass("RPControlCenterClient");
        if (clientCls){
            Method countdownMethod =class_getInstanceMethod(clientCls,@selector(startRecordingCountdown));
            if (countdownMethod){
                MSHookMessageEx(clientCls,@selector(startRecordingCountdown),(IMP)hook_startRecordingCountdown,(IMP *)&orig_startRecordingCountdown);
            }
        }
        Class objectCls = objc_getClass("NSObject");
        if (objectCls){
            Method performMethod =class_getInstanceMethod(objectCls,@selector(performSelector:withObject:afterDelay:inModes:));
            if (performMethod){
                MSHookMessageEx(objectCls,@selector(performSelector:withObject:afterDelay:inModes:),(IMP)hook_performSelector,(IMP *)&orig_performSelector);
            }
        }
    });
}