//
//  ViewController.m
//  ViewController
//
//  Created by Jacky Hu on 07/14/14.
//

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "Pingpp.h"

#define KBtn_width        200
#define KBtn_height       40
#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2
#define KYOffSet          20

#define kWaiting          @"creating payment order..."
#define kNote             @"Payment result"
#define kConfirm          @"Confirm"
#define kErrorNet         @"Network error"
#define kResult           @"Payment result: %@"

#define kPlaceHolder      @"Amount to pay"
#define kMaxAmount        9999999

#define kUrlScheme      @"demoapp001" // Your app's custom URL scheme, needed by Alipay, WeChat Pay
#define kUrl            @"http://localhost:8080/charge" // This is the demo backend https://github.com/zhengyue/pingpp-java

@interface ViewController ()

@end

@implementation ViewController
@synthesize channel;
@synthesize mTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect viewRect = self.view.frame;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:viewRect];
    [scrollView setScrollEnabled:YES];
    [self.view addSubview:scrollView];
    
    CGRect windowRect = [[UIScreen mainScreen] bounds];
    UIImage *headerImg = [UIImage imageNamed:@"home.png"];
    CGFloat imgViewWith = windowRect.size.width * 0.9;
    CGFloat imgViewHeight = headerImg.size.height * imgViewWith / headerImg.size.width;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:headerImg];
    [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    CGFloat imgx = windowRect.size.width/2-imgViewWith/2;
    [imgView setFrame:CGRectMake(imgx, KYOffSet, imgViewWith, imgViewHeight)];
    [scrollView addSubview:imgView];
    
    mTextField = [[UITextField alloc]initWithFrame:CGRectMake(imgx, KYOffSet+imgViewHeight+40, imgViewWith-40, 40)];
    mTextField.borderStyle = UITextBorderStyleRoundedRect;
    mTextField.backgroundColor = [UIColor whiteColor];
    mTextField.placeholder = kPlaceHolder;
    mTextField.keyboardType = UIKeyboardTypeNumberPad;
    mTextField.returnKeyType =UIReturnKeyDone;
    mTextField.delegate = self;
    [mTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:mTextField];
    
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"OK" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(imgx+imgViewWith-35, KYOffSet+imgViewHeight+40, 40, 40)];
    [doneButton.layer setMasksToBounds:YES];
    [doneButton.layer setCornerRadius:8.0];
    [doneButton.layer setBorderWidth:1.0];
    [doneButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [scrollView addSubview:doneButton];
    
    UIButton* wxButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [wxButton setTitle:@"WeChat" forState:UIControlStateNormal];
    [wxButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [wxButton setFrame:CGRectMake(imgx, KYOffSet+imgViewHeight+90, imgViewWith, KBtn_height)];
    [wxButton.layer setMasksToBounds:YES];
    [wxButton.layer setCornerRadius:8.0];
    [wxButton.layer setBorderWidth:1.0];
    [wxButton.layer setBorderColor:[UIColor grayColor].CGColor];
    wxButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [wxButton setTag:1];
    [scrollView addSubview:wxButton];
    
    UIButton* alipayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [alipayButton setTitle:@"AliPay" forState:UIControlStateNormal];
    [alipayButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [alipayButton setFrame:CGRectMake(imgx, KYOffSet+imgViewHeight+140, imgViewWith, KBtn_height)];
    [alipayButton.layer setMasksToBounds:YES];
    [alipayButton.layer setCornerRadius:8.0];
    [alipayButton.layer setBorderWidth:1.0];
    [alipayButton.layer setBorderColor:[UIColor grayColor].CGColor];
    alipayButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [alipayButton setTag:2];
    [scrollView addSubview:alipayButton];
    
    UIButton* upmpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [upmpButton setTitle:@"UnionPay" forState:UIControlStateNormal];
    [upmpButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [upmpButton setFrame:CGRectMake(imgx, KYOffSet+imgViewHeight+190, imgViewWith, KBtn_height)];
    [upmpButton.layer setMasksToBounds:YES];
    [upmpButton.layer setCornerRadius:8.0];
    [upmpButton.layer setBorderWidth:1.0];
    [upmpButton.layer setBorderColor:[UIColor grayColor].CGColor];
    upmpButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [upmpButton setTag:3];
    [scrollView addSubview:upmpButton];
    
    [scrollView setContentSize:CGSizeMake(viewRect.size.width, KYOffSet+imgViewHeight+260+KBtn_height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertWait
{
    mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(mAlert.frame.size.width / 2.0f - 15, mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [mAlert addSubview:aiv];
}

- (void)showAlertMessage:(NSString*)msg
{
    mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:nil cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [mAlert show];
}

- (void)hideAlert
{
    if (mAlert != nil)
    {
        [mAlert dismissWithClickedButtonIndex:0 animated:YES];
        mAlert = nil;
    }
}

- (void)normalPayAction:(id)sender
{
    /*-------------------------------------------------------------------------------------
     
     Payment provider identifiers:
     
     "wx" - WeChat Pay
     "alipay" - AliPay
     "upacp" - UnionPay
     
     "bfb" - Baidu Wallet (we don't use this)
     
     -------------------------------------------------------------------------------------*/
    NSInteger tag = ((UIButton*)sender).tag;
    if (tag == 1) {
        self.channel = @"wx";
        [self normalPayAction:nil];
    } else if (tag == 2) {
        self.channel = @"alipay";
    } else if (tag == 3) {
        self.channel = @"upacp";
    } else if (tag == 4) {
        self.channel = @"bfb";
    } else {
        return;
    }
    
    [mTextField resignFirstResponder];
    long long amount = [[self.mTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""] longLongValue];
    if (amount == 0) {
        return;
    }
    NSString *amountStr = [NSString stringWithFormat:@"%lld", amount];
    NSURL* url = [NSURL URLWithString:kUrl];
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];

    /*
    NSDictionary* dict = @{
        @"channel" : self.channel,
        @"amount"  : amountStr
    };
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    */
    
    NSString *bodyData = [NSString stringWithFormat:@"channel=%@&amount=%@", self.channel, amountStr];
    
    /*-------------------------------------------------------------------------------------------------------------
     
     Step 1:
     
     call the demo backend to create a payment order. This demo backend accept 2 parameters:
     
      - channel        // payment provider identifier
      - amount         // amount to pay, should be an integer, in cents

     for example:
     
       $ curl -d "channel=wx&amount=100" http://localhost:8080/charge
     
     the response is a JSON object returned from Ping++ server, which will be needed in the next step.
     
     Note: in a real app, the backend is developed by us, so the format of the request message
     is also decided by us. The calling process is like:
     
        our app (with Ping++ client sdk) --> our backend (with Ping++ server sdk) --> Ping++ server --> payment providers
     
     --------------------------------------------------------------------------------------------------------------*/
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setHTTPMethod:@"POST"];
    
    ViewController * __weak weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self showAlertWait];
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            [weakSelf hideAlert];
            if (httpResponse.statusCode != 200) {
                NSLog(@"statusCode=%ld error = %@", (long)httpResponse.statusCode, connectionError);
                [weakSelf showAlertMessage:kErrorNet];
                return;
            }
            if (connectionError != nil) {
                NSLog(@"error = %@", connectionError);
                [weakSelf showAlertMessage:kErrorNet];
                return;
            }
            NSString* charge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"charge = %@", charge);
            
            /*-------------------------------------------------------------------------------------
             
               Step 2:
             
               call ping++ SDK to open the selected payment provider, could be another app or
               a native UI control, or a webview, depending on which payment provider is selected,
               and what app has been already installed on the phone.
             
               parameters:
                 charge: the JSON object returned from the ping++ server
                 appURLScheme: app's url scheme, for switching back from payment app.
                     For example, when using WeChat Pay, this method will open WeChat app to do the payment. 
                     And after payment is finished, WeChat has a "Return to Merchant" button which will call
                     openURL with this scheme, to switch back to our app.
             
               Note: since this is a demo app, calling this method will NOT open the real payment app,
               but will open the browser to display a test page to simulate the real app. The page contains
               3 buttons to simulate 3 different payment results, which are, from top to bottom,
               "Payment Succeed", "Payment Canceled", "Payment Failed"
             
             -------------------------------------------------------------------------------------*/
            
            [Pingpp createPayment:charge viewController:weakSelf appURLScheme:kUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                
                /*-------------------------------------------------------------------------------------
                 
                   Step 3:
                 
                   handle payment result.
                 
                   Note: if user selected UnionPay or if user selected AliPay but does NOT
                   have the AliPay app installed, the result will be passed to this block directly.
                 
                   But, if user selected WeChat Pay or AliPay and does have these app installed, then,
                   the payment result will be passed to [UIApplicationDelegate application:openURL:****:],
                   so we need to call [Pingpp handleOpenURL:] there in order to receive the proper result here.
                   See AppDelegate.m for more details.
                 
                 -------------------------------------------------------------------------------------*/
                
                NSLog(@"completion block: %@", result);
                if ([result isEqualToString:@"success"]) {
                    // payment is succeeded
                    NSLog(@"Payment succeeded");
                } else {
                    // payment is failed or cancelled
                    NSLog(@"PingppError: code=%lu msg=%@", (unsigned  long)error.code, [error getMsg]);
                }
                [weakSelf showAlertMessage:result];
            }];
        });
    }];
}

- (void)okButtonAction:(id)sender
{
    [mTextField resignFirstResponder];
}

- (void) textFieldDidChange:(UITextField *) textField
{
    NSString *text = textField.text;
    NSUInteger index = [text rangeOfString:@"."].location;
    if (index != NSNotFound) {
        double amount = [[text stringByReplacingOccurrencesOfString:@"." withString:@""] doubleValue];
        text = [NSString stringWithFormat:@"%.02f", MIN(amount, kMaxAmount)/100];
    } else {
        double amount = [text doubleValue];
        text = [NSString stringWithFormat:@"%.02f", MIN(amount, kMaxAmount)/100];
    }
    textField.text = text;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    if (self.view.frame.size.height > 480) {
        return;
    }
    int offset = frame.origin.y + 45 - (self.view.frame.size.height - 216.0);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

@end
