//
//  XXAboutTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "XXAboutTableViewController.h"
#ifdef DEBUG
#import <FLEX/FLEXManager.h>
#endif

enum {
    kInformationSection = 0,
    kOptionSection      = 1,
    kFeedbackSection    = 2,
};

// Index - kInformationSection
enum {
    kInformationIndex = 0,
};

// Index - kOptionSection
enum {
    kOptionOfficialSiteIndex   = 0,
    kOptionUserAgreementIndex  = 1,
    kOptionThirdPartyIndex     = 2,
};

enum {
    kOptionMailFeedbackIndex   = 0,
    kOptionOnlineUpdateIndex   = 1,
    kOptionAddQQGroupIndex     = 2,
};

@interface XXAboutTableViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *appLabel;

@end

@implementation XXAboutTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"About", nil);
    _appLabel.text = [NSString stringWithFormat:@"%@\nV%@ (%@)", APP_NAME_EN, VERSION_STRING, VERSION_BUILD];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

// Action - kOptionMailFeedbackIndex

- (void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) return;
    picker.mailComposeDelegate = self;
    [picker setSubject:[NSString stringWithFormat:@"[%@] %@\nV%@ (%@)", NSLocalizedString(@"Feedback", nil), APP_NAME_CN, VERSION_STRING, VERSION_BUILD]];
    NSArray *toRecipients = [NSArray arrayWithObject:SERVICE_EMAIL];
    [picker setToRecipients:toRecipients];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case kOptionSection:
            switch (indexPath.row) {
                case kOptionOfficialSiteIndex:
                    [self openOfficialSite];
                    break;
                case kOptionUserAgreementIndex:
                    [self openUserAgreement];
                    break;
                case kOptionThirdPartyIndex:
                    [self openThirdParty];
                    break;
                default:
                    break;
            }
            break;
        case kFeedbackSection:
            switch (indexPath.row) {
                case kOptionMailFeedbackIndex:
                    [self displayComposerSheet];
                    break;
                case kOptionOnlineUpdateIndex:
                    [self openCydia];
                    break;
                case kOptionAddQQGroupIndex:
                    [self openQQGroup];
                    break;
                default:
                    break;
            }
        default:
            break;
    }
}

- (void)openOfficialSite {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = NSLocalizedString(@"Official Site", nil);
    viewController.url = [NSURL URLWithString:OFFICIAL_SITE];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openUserAgreement {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = NSLocalizedString(@"User Agreement", nil);
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tos" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openThirdParty {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = NSLocalizedString(@"Third Party Credits", nil);
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"open" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openCydia {
    NSURL *cydiaURL = [NSURL URLWithString:@"cydia://url/https://cydia.saurik.com/api/share#?source=http://apt.xxtouch.com/&package=com.1func.xxtouch.ios"];
    if ([[UIApplication sharedApplication] canOpenURL:cydiaURL]) {
        [[UIApplication sharedApplication] openURL:cydiaURL];
    } else {
        [self.navigationController.view makeToast:NSLocalizedString(@"Cannot open Cydia", nil)];
    }
}

- (void)openQQGroup {
    NSURL *qqURL = [NSURL URLWithString:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=40898074&card_type=group&source=external"];
    if ([[UIApplication sharedApplication] canOpenURL:qqURL]) {
        [[UIApplication sharedApplication] openURL:qqURL];
    } else {
        [self.navigationController.view makeToast:NSLocalizedString(@"Cannot open Mobile QQ", nil)];
    }
}

- (IBAction)flexDebugging:(UIBarButtonItem *)sender {
#ifdef DEBUG
    [[FLEXManager sharedManager] setNetworkDebuggingEnabled:YES];
    [[FLEXManager sharedManager] showExplorer];
    [self.navigationController.view makeToast:NSLocalizedString(@"Debug Mode", nil)];
#endif
}

- (void)dealloc {
    CYLog(@"");
}

@end
