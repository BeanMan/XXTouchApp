//
//  XXSettingsTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSettingsTableViewController.h"
#import "XXWebViewController.h"
#import "XXLocalNetService.h"

#define commonHandler(command) \
^(SIAlertView *alertView) { \
    self.navigationController.view.userInteractionEnabled = NO; \
    [self.navigationController.view makeToastActivity:CSToastPositionCenter]; \
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ \
        BOOL result = command; \
        dispatch_async_on_main_queue(^{ \
            self.navigationController.view.userInteractionEnabled = YES; \
            [self.navigationController.view hideToastActivity]; \
            if (!result) { \
                [self.navigationController.view makeToast:[[[XXLocalNetService sharedInstance] lastError] localizedDescription]]; \
            } \
        }); \
    }); \
}

enum {
    kServiceSection = 0,
    kAuthSection    = 1,
    kConfigSection  = 2,
    kSystemSection  = 3,
    kHelpSection    = 4,
};

// Index - kServiceSection
enum {
    kServiceRemoteSwitchIndex  = 0,
    kServiceRestartIndex = 1,
};

// Index - kAuthSection
enum {
    kAuthStatusIndex = 0,
};

// Index - kConfigSection
enum {
    kConfigActivationIndex = 0,
    kConfigRecordingIndex  = 1,
    kConfigLaunchingIndex  = 2,
    kConfigPreferenceIndex = 3,
};

// Index - kSystemSection
enum {
    kSystemApplicationListIndex = 0,
    kSystemCleanGPSStatusIndex  = 1,
    kSystemCleanUICachesIndex   = 2,
    kSystemCleanAllCachesIndex  = 3,
    kSystemDeviceRespringIndex  = 4,
    kSystemDeviceRestartIndex   = 5,
};

// Index - kHelpSection
enum {
    kHelpReferencesIndex = 0,
    kHelpAboutIndex      = 1,
};

@interface XXSettingsTableViewController ()

@end

@implementation XXSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = XXLString(@"More"); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case kServiceSection:
            switch (indexPath.row) {
                case kServiceRemoteSwitchIndex:
                    break;
                case kServiceRestartIndex:
                    break;
                default:
                    break;
            }
            break;
        case kAuthSection:
            switch (indexPath.row) {
                case kAuthStatusIndex: // Next controller
                default:
                    break;
            }
            break;
        case kConfigSection:
            switch (indexPath.row) {
                case kConfigActivationIndex: // Next controller
                case kConfigRecordingIndex: // Next controller
                case kConfigLaunchingIndex: // Next controller
                case kConfigPreferenceIndex: // Next controller
                default:
                    break;
            }
            break;
        case kSystemSection:
            switch (indexPath.row) {
                case kSystemCleanGPSStatusIndex:
                    [self cleanGPSCachesSelected];
                    break;
                case kSystemCleanUICachesIndex:
                    [self cleanUICachesSelected];
                    break;
                case kSystemCleanAllCachesIndex:
                    [self cleanAllCachesSelected];
                    break;
                case kSystemDeviceRespringIndex:
                    [self respringIndexSelected];
                    break;
                case kSystemDeviceRestartIndex:
                    [self rebootIndexSelected];
                    break;
                case kSystemApplicationListIndex: // Next controller
                default:
                    break;
            }
            break;
        case kHelpSection:
            switch (indexPath.row) {
                case kHelpReferencesIndex: // Next Controller
                case kHelpAboutIndex: // Next controller
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)cleanGPSCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Clean GPS Caches")
                                                     andMessage:XXLString(@"This operation will reset location caches.")];
    [alertView addButtonWithTitle:XXLString(@"Clean Now")
                             type:SIAlertViewButtonTypeDestructive
                          handler:commonHandler([[XXLocalNetService sharedInstance] localCleanGPSCaches])];
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanUICachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Clean UI Caches")
                                                     andMessage:XXLString(@"This operation will kill all applications and reset icon caches.\nIt may cause icons to disappear.")];
    [alertView addButtonWithTitle:XXLString(@"Clean Now")
                             type:SIAlertViewButtonTypeDestructive
                          handler:commonHandler([[XXLocalNetService sharedInstance] localCleanUICaches])];
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanAllCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Clean All Caches")
                                                     andMessage:XXLString(@"This operation will kill all applications, and remove all documents and caches of them.")];
    [alertView addButtonWithTitle:XXLString(@"Clean Now")
                             type:SIAlertViewButtonTypeDestructive
                          handler:commonHandler([[XXLocalNetService sharedInstance] localCleanAllCaches])];
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)respringIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Respring Confirm")
                                                     andMessage:XXLString(@"Tap \"Respring Now\" to continue.")];
    [alertView addButtonWithTitle:XXLString(@"Respring Now")
                             type:SIAlertViewButtonTypeDestructive
                          handler:commonHandler([[XXLocalNetService sharedInstance] localRespringDevice])];
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)rebootIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Reboot Confirm")
                                                     andMessage:XXLString(@"Tap \"Reboot Now\" to continue.")];
    [alertView addButtonWithTitle:XXLString(@"Reboot Now")
                             type:SIAlertViewButtonTypeDestructive
                          handler:commonHandler([[XXLocalNetService sharedInstance] localRestartDevice])];
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)openReferencesUrl {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = XXLString(@"Documents");
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end