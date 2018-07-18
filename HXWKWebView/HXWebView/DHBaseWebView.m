//
//  DHBaseWebView.m
//  DaHai_iOS
//
//  Created by TAL on 2018/7/18.
//  Copyright © 2018年 DaHai. All rights reserved.
//

#import "DHBaseWebView.h"

typedef NSString * DHWKWebViewKVOName;

DHWKWebViewKVOName const DHWKWebViewURL = @"URL";
DHWKWebViewKVOName const DHWKWebViewTitle = @"title";
DHWKWebViewKVOName const DHWKWebViewLoading = @"loading";
DHWKWebViewKVOName const DHWKWebViewEstimatedProgress = @"estimatedProgress";

@interface DHBaseWebView () <WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, copy) NSArray <DHOCFunctionName>* functions;
@property (nonatomic, strong) WKWebViewConfiguration * webViewConfiguration;
@property (nonatomic, strong) WKUserContentController * userContentController;

@end

@implementation DHBaseWebView

#pragma mark   init 

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self dh_observer];
        [self dh_webViewConfig];
    }
    return self;
}

- (instancetype)init
{
    return [[DHBaseWebView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self dh_observer];
        [self dh_webViewConfig];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.webView.frame = self.bounds;
}

- (void)dh_webViewConfig
{
    [self addSubview:self.webView];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)dh_observer
{
    [self.webView addObserver:self forKeyPath:DHWKWebViewURL options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:DHWKWebViewTitle options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:DHWKWebViewLoading options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:DHWKWebViewEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark  WKNavigationDelegate 

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self dh_webView:webView didCommitNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self dh_webView:webView didFinishNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self dh_webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self dh_webView:webView didFailProvisionalNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString * scheme = navigationAction.request.URL.scheme;
    if ([scheme rangeOfString:@"itms"].location != NSNotFound ||
        [scheme rangeOfString:@"itmss"].location != NSNotFound) {
        //open App Store
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        }
    }
    [self dh_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential * credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark  CallFunction 

- (void)dh_addUserScript:(WKUserScript *)script
{
    [self.webView.configuration.userContentController addUserScript:script];
}

- (void)dh_jsCallOCFunction:(NSArray<DHOCFunctionName> *)functions
{
    for (DHOCFunctionName name in functions) {
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:name];
    }
    self.functions = functions;
}

#pragma mark  WKScriptMessageHandler 

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self dh_userContentController:userContentController didReceiveScriptMessage:message];
}

#pragma mark  KVO 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:DHWKWebViewTitle] && object == self.webView) {
        [self dh_webView:self.webView title:change[NSKeyValueChangeNewKey]];
    } else if ([keyPath isEqualToString:DHWKWebViewLoading] && object == self.webView) {
        [self dh_webView:self.webView loading:[change[NSKeyValueChangeNewKey] boolValue]];
    } else if ([keyPath isEqualToString:DHWKWebViewEstimatedProgress] && object == self.webView) {
        [self dh_webView:self.webView estimatedProgress:[change[NSKeyValueChangeNewKey] doubleValue]];
    } else if ([keyPath isEqualToString:DHWKWebViewURL] && object == self.webView) {
        [self dh_webView:self.webView url:change[NSKeyValueChangeNewKey]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark  DHBaseWebViewDelegate 

- (void)dh_webView:(WKWebView *)webView title:(NSString *)title
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView title:title];
    }
}

- (void)dh_webView:(WKWebView *)webView loading:(BOOL)loading
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView loading:loading];
    }
}

- (void)dh_webView:(WKWebView *)webVeiew estimatedProgress:(double)estimatedProgress
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webVeiew estimatedProgress:estimatedProgress];
    }
}

- (void)dh_webView:(WKWebView *)webView url:(NSURL *)url
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView url:url];
    }
}

- (void)dh_webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView didCommitNavigation:navigation];
    }
}

- (void)dh_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView didFinishNavigation:navigation];
    }
}

- (void)dh_webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)dh_webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (void)dh_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

- (void)dh_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate dh_userContentController:userContentController didReceiveScriptMessage:message];
    }
}

#pragma mark  lazy 

- (WKWebViewConfiguration *)webViewConfiguration
{
    if (!_webViewConfiguration) {
        _webViewConfiguration = [[WKWebViewConfiguration alloc] init];
        _webViewConfiguration.userContentController = self.userContentController;
    }
    return _webViewConfiguration;
}

- (WKUserContentController *)userContentController
{
    if (!_userContentController) {
        _userContentController = [[WKUserContentController alloc] init];
    }
    return _userContentController;
}

- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webViewConfiguration];
        _contentWebView = _webView;
    }
    return _webView;
}

#pragma mark  dealloc 

- (void)dealloc
{
    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView removeObserver:self forKeyPath:DHWKWebViewURL];
    [self.webView removeObserver:self forKeyPath:DHWKWebViewTitle];
    [self.webView removeObserver:self forKeyPath:DHWKWebViewLoading];
    [self.webView removeObserver:self forKeyPath:DHWKWebViewEstimatedProgress];
    for (DHOCFunctionName name in self.functions) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
    }
}

@end
