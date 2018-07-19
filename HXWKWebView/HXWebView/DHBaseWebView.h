//
//  DHBaseWebView.h
//  DaHai_iOS
//
//  Created by TAL on 2018/7/18.
//  Copyright © 2018年 DaHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol DHBaseWebViewDelegate;

typedef NSString * DHOCFunctionName;

@interface DHBaseWebView : UIView

@property (nonatomic, strong, readonly) WKWebView * contentWebView;
@property (nonatomic, weak, nullable) id <DHBaseWebViewDelegate> delegate;

/**
 注入js

 @param script script
 */
- (void)dh_addUserScript:(WKUserScript *)script;

/**
 js调取oc函数

 example:
 [self.baseWebView dh_jsCallOCFunction:@[@"example"]];
 @"example" 为OC函数名
 js 端按照如下方式即可调取
 window.webkit.messageHandlers.example.postMessage(<messageBody>)
 允许传递的参数类型
 NSNumber, NSString, NSDate, NSArray
 
 @param functions oc函数名
 */
- (void)dh_jsCallOCFunction:(NSArray <DHOCFunctionName>*)functions;

/**
 清理缓存
 */
- (void)dh_cleanCache;

@end

#pragma mark  DHBaseWebViewDelegate 

@protocol DHBaseWebViewDelegate <NSObject>

@optional;

/**
 js调取oc的回调

 @param userContentController WKUserContentController
 @param message 传递的参数
 */
- (void)dh_userContentController:(WKUserContentController *)userContentController
         didReceiveScriptMessage:(WKScriptMessage *)message;

/**
 webView 的加载状态

 @param webView 当前的webView
 @param loading 加载状态
 */
- (void)dh_webView:(WKWebView *)webView loading:(BOOL)loading;

/**
 webView 的title

 @param webView 当前的webView
 @param title title
 */
- (void)dh_webView:(WKWebView *)webView title:(NSString *)title;

/**
 正在加载的url

 @param webView 当前的webView
 @param url url
 */
- (void)dh_webView:(WKWebView *)webView url:(NSURL *)url;

/**
 webView 的加载进度

 @param webVeiew 当前的webView
 @param estimatedProgress 加载进度
 */
- (void)dh_webView:(WKWebView *)webVeiew estimatedProgress:(double)estimatedProgress;

/**
 main frame 完成

 @param webView 当前的webView
 @param navigation navigation
 */
- (void)dh_webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

/**
 webView 加载完成

 @param webView 当前的webView
 @param navigation navigation
 */
- (void)dh_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

/**
 webView 加载失败

 @param webView 当前的webView
 @param navigation navigation
 @param error error
 */
- (void)dh_webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error;

/**
 开始加载时出错

 @param webView 当前的webView
 @param navigation navigation
 @param error error
 */
- (void)dh_webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;

/**
 动作策略

 @param webView 当前的webView
 @param navigationAction navigation
 @param decisionHandler decisionHandler
 */
- (void)dh_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;


@end
