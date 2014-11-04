//
//  LSUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationViewController.h"
#import "LSConversationDetailViewController.h"
#import "LYRUIMessagingUtilities.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LYRUIParticipantPickerController.h"
#import "LSMessageDetailTableViewController.h"

static NSDateFormatter *LYRUIConversationDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, hh:mma";
    }
    return dateFormatter;
}

@interface LSUIConversationViewController () <LYRUIConversationViewControllerDataSource, LYRUIConversationViewControllerDelegate, LSConversationDetailViewControllerDelegate, LYRUIAddressBarControllerDataSource, LYRUIParticipantPickerControllerDelegate>

@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;

@end

@implementation LSUIConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationContoller.persistenceManager];
    
    if (self.conversation) {
        [self addDetailsButton];
    }
    [self markAllMessagesAsRead];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.addressBarController.dataSource = self;
}

#pragma mark - Conversation View Controller Data Source

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if (participantIdentifier) {
        NSSet *set = [self.applicationContoller.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
        return [[set allObjects] firstObject];
    }
    return nil;
}

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSString *dateString;
    if (date) {
        dateString = [LYRUIConversationDateFormatter() stringFromDate:date];
    } else {
        dateString = [LYRUIConversationDateFormatter() stringFromDate:[NSDate date]];
    }
    
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:dateString];
    NSRange range = [dateString rangeOfString:@","];
    NSRange boldedRange = NSMakeRange(0, range.location);
    [dateAttributedString beginEditing];
    
    [dateAttributedString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:12]
                       range:boldedRange];
    
    [dateAttributedString endEditing];
    return dateAttributedString;
}

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSMutableArray *recipients = [[recipientStatus allKeys] mutableCopy];
    [recipients removeObject:self.applicationContoller.layerClient.authenticatedUserID];
    
    NSAttributedString *attributedString;
    
    NSInteger status = [[recipientStatus valueForKey:[recipients lastObject]] integerValue];
    switch (status) {
        case LYRRecipientStatusInvalid:
            attributedString = [[NSAttributedString alloc] initWithString:@"Not Sent"];
            break;
            
        case LYRRecipientStatusSent:
            attributedString = [[NSAttributedString alloc] initWithString:@"Sent"];
            break;
            
        case LYRRecipientStatusDelivered:
            attributedString = [[NSAttributedString alloc] initWithString:@"Delivered"];
            break;
            
        case LYRRecipientStatusRead:
            attributedString = [[NSAttributedString alloc] initWithString:@"Read"];
            break;
            
        default:
            break;
    }
    return attributedString;
}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController pushNotificationTextForMessage:(LYRMessage *)message
{
    if (!self.applicationContoller.shouldSendPushText) return nil;
    LYRMessagePart *messagePart = [message.parts objectAtIndex:0];
    NSString *pushText = [NSString new];
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        pushText = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        pushText = @"Has sent a new image";
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        pushText = @"Has sent a new location";
    }
    return pushText;
}

- (BOOL)conversationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message
{
    return YES;
}

#pragma mark - Conversation View Controller Delegate

- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Successful Message Send");
}

- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessageWithError:(NSError *)error
{
    NSLog(@"Message Send Failed with Error: %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Converation View Controler Delegate

- (id<LYRUIParticipant>)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [self.dataSource conversationViewController:self participantForIdentifier:participantIdentifier];
}

- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didShareLocation:(CLLocation *)location
{
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[LYRUIMessagePartWithLocation(location)]];
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message sent!");
    } else {
        NSLog(@"Message send failed with error: %@", error);
    }
}

- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    if (self.applicationContoller.debugModeEnabled) {
        LSMessageDetailTableViewController *controller = [LSMessageDetailTableViewController initWithMessage:message applicationController:self.applicationContoller];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - Adress Bar View Controller Data Source

- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion
{
    [self.applicationContoller.persistenceManager performContactSearchWithString:searchText completion:^(NSSet *contacts, NSError *error) {
        if (!error) {
            completion(contacts);
        }
    }];
}


#pragma mark - Contact Button Actions

- (void)addDetailsButton
{
    UIBarButtonItem *contactsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(contactsButtonTapped)];
    contactsButtonItem.accessibilityLabel = @"Contacts";
    self.navigationItem.rightBarButtonItem = contactsButtonItem;
}

- (void)contactsButtonTapped
{
    LSConversationDetailViewController *detailViewController = [LSConversationDetailViewController conversationDetailViewControllerLayerClient:self.layerClient conversation:self.conversation];
    detailViewController.detailDelegate = self;
    detailViewController.applicationController = self.applicationContoller;
    [self.navigationController pushViewController:detailViewController animated:TRUE];
}

#pragma mark - Address Bar View Controller Delegate

- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                            sortType:LYRUIParticipantPickerControllerSortTypeFirst];
    controller.participantPickerDelegate = self;
    controller.allowsMultipleSelection = NO;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Participant Picker Delegate Methods

- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants
{
    if (participants.count) {
        [self.addressBarController selectParticipant:[[participants allObjects] lastObject]];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Mark All Messages Read Method

- (void)markAllMessagesAsRead
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSOrderedSet *messages = [self.layerClient messagesForConversation:self.conversation];
        for (LYRMessage *message in messages) {
            LYRRecipientStatus status = [[message.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID] integerValue];
            switch (status) {
                case LYRRecipientStatusDelivered:
                    [self.layerClient markMessageAsRead:message error:nil];
                    NSLog(@"Message marked as read");
                    break;
                    
                default:
                    break;
            }
        }
    });
}

@end
