//
//  ViewController.m
//  AnimationOC
//
//  Created by Shaoting Zhou on 2017/8/31.
//  Copyright © 2017年 Shaoting Zhou. All rights reserved.
//

#import "ViewController.h"
#import "WLBallView.h"
#import "WLBallTool.h"


#define SCRCCEWH [UIScreen mainScreen].bounds.size
#define IMAGE_COUNT 2   //蝴蝶图片个数

@interface ViewController ()
@property (nonatomic,strong) CALayer * leafLayer;   //叶子
@property (nonatomic,strong) CALayer * butterflyLayer;   //蝴蝶
@property (nonatomic,strong) CALayer * carLayer;   //小汽车
@property (nonatomic,strong) CALayer * wood; //树林
@property (nonatomic,strong) UIImageView *  bgImg;  //背景图片
@property (nonatomic,assign) int currentIndex;   //当前第几个蝴蝶图片
@property (nonatomic,strong) NSMutableArray * images;  //蝴蝶图片数组
@property (nonatomic, strong) NSArray * ballAry;   //球体数组

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //背景
    UIImage * bgImg = [UIImage imageNamed:@"树林"];
    self.bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCRCCEWH.width, SCRCCEWH.height)];
    self.bgImg.image = bgImg;
    [self.view addSubview:self.bgImg];
    
    self.currentIndex = 1; //默认第一张图片
    self.ballAry = @[@"大师球",@"高级球",@"超级球",@"精灵球"];  //先准备4个球体
    
    //晴天娃娃摇摆动画
    [self sunChildAniamtion];    //基础动画   CABasicAnimation
    //制作树叶layer
    [self makeLeafLayer];
    //制作小汽车
    [self makeCarLayer];
    //落叶下落动画
    [self fallLeafAnimation];   //关键帧动画  CAKeyframeAnimation    通过贝塞尔曲线绘制下路路径  CGPathCreateMutable
    //落叶旋转动画
    [self leafOverturnAnimation];   //基础动画  CABasicAnimation
   //落叶生长动画
    [self leafGrowAnimation];    //UIView动画
    //蝴蝶飞舞动画
    [self butterflyAnimation];   //逐帧动画:振翅   飞翔:关键帧动画  路径:keyframeAnimation

}
//MARK:点击屏幕
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //制作球体
    WLBallView * ballView = [[WLBallView alloc] initWithFrame:CGRectMake(0, 80, 50, 50) AndImageName:self.ballAry[arc4random_uniform(4)]];
    [self.view addSubview:ballView];
    [ballView starMotion];
    //系统转场动画
    CATransition *transition = [CATransition animation];
    transition.type = @"rippleEffect";   //部分动画类型是未公开的,但仍然可以使用
    transition.duration = 2;
    [self.bgImg.layer addAnimation:transition forKey:nil];
    //组合动画
    [self groupAnimation];   //组合动画(汽车)
}
/*---------------------------------------------------------------------------------------*/
//MARK:制作小汽车
-(void)makeCarLayer{
    self.carLayer = [[CALayer alloc]init];
    self.carLayer.bounds = CGRectMake(0, 0, 100, 100);
    self.carLayer.position = CGPointMake(SCRCCEWH.width - 100, SCRCCEWH.height - 50);
    self.carLayer.contents = (id)[UIImage imageNamed:@"小汽车"].CGImage;
    [self.view.layer addSublayer:self.carLayer];
}
//MARK:组合动画
-(void)groupAnimation{
//    1.创建动画组
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
//    2.设置组中的动画和其他属性
    CABasicAnimation * basicAnimation = [self carBasicAnimation];
    CAKeyframeAnimation * keyframeAnimation = [self carKeyFrameAnimation];
    animationGroup.animations = @[keyframeAnimation,basicAnimation];
    
    animationGroup.duration=10.0;//设置动画时间，如果动画组中动画已经设置过动画属性则不再生效
    animationGroup.beginTime=CACurrentMediaTime()+2;//延迟五秒执行
  
    //3.给图层添加动画
    [self.carLayer addAnimation:animationGroup forKey:nil];
}
//小汽车加速动画
-(CABasicAnimation *)carBasicAnimation{
    CABasicAnimation *basicAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    CGFloat toValue=  M_PI_2 / 2.5;
    basicAnimation.toValue=[NSNumber numberWithFloat:  M_PI_2/2.5];
    [basicAnimation setValue:[NSNumber numberWithFloat:toValue] forKey:@"carTransform"];
    return basicAnimation;
}
//MARK:小汽车移动动画
-(CAKeyframeAnimation *)carKeyFrameAnimation{
    CAKeyframeAnimation *keyframeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGPoint endPoint= CGPointMake(-100, SCRCCEWH.height - 50);
    CGPathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.carLayer.position.x, self.carLayer.position.y);
    CGPathAddCurveToPoint(path, NULL, endPoint.x/2, endPoint.y, endPoint.x/3, endPoint.y, endPoint.x, endPoint.y);
    
    keyframeAnimation.path=path;
    CGPathRelease(path);
    
    [keyframeAnimation setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"carRunAnimation"];
    
    return keyframeAnimation;
}
/*---------------------------------------------------------------------------------------*/
//MARK:制作落叶Layer
-(void)makeLeafLayer{
    self.leafLayer = [[CALayer alloc]init];
    self.leafLayer.bounds = CGRectMake(0, 0, 30, 30);
    self.leafLayer.position = CGPointMake(145, 145);
    self.leafLayer.anchorPoint = CGPointMake(0.5, 0.6); //锚点,便于旋转动画
    self.leafLayer.contents = (id)[UIImage imageNamed:@"落叶"].CGImage;
    [self.view.layer addSublayer:self.leafLayer];
}
//MARK:落叶生长动画
-(void)leafGrowAnimation{
    UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    imgView.image = [UIImage imageNamed:@"落叶"];
    imgView.layer.position = CGPointMake(145, 145);
    [self.view addSubview:imgView];
    
    [UIView animateWithDuration:8.5 animations:^{
        imgView.frame = CGRectMake(0, 0, 30, 30);
        imgView.layer.position = CGPointMake(145, 145);
    } completion:^(BOOL finished) {
        [imgView removeFromSuperview];
        [self leafGrowAnimation];
    }];

}
//MARK: 落叶下落动画
-(void)fallLeafAnimation{
    //1.创建关键帧动画并设置动画属性
    CAKeyframeAnimation *keyframeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置路径
    //绘制贝塞尔曲线
    CGPathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.leafLayer.position.x, self.leafLayer.position.y);//移动到起始点
    CGPathAddCurveToPoint(path, NULL, 160, 190, -20, 150, 55,SCRCCEWH.height);//绘制二次贝塞尔曲线
    
    keyframeAnimation.path=path;//设置path属性
    CGPathRelease(path);//释放路径对象
    keyframeAnimation.repeatCount = HUGE_VALF; //重复次数
    keyframeAnimation.calculationMode = kCAAnimationCubicPaced;  //动画的计算模式
    keyframeAnimation.keyTimes = @[@0.0,@0.5,@0.7,@1.0]; //控制各个帧的时间
    //设置其他属性
    keyframeAnimation.duration=8.0;
    keyframeAnimation.beginTime=CACurrentMediaTime()+1;//设置延迟执行
    
    
    //3.添加动画到图层，添加动画后就会执行动画
    [self.leafLayer addAnimation:keyframeAnimation forKey:@"fallLeaf"];
}
//MARK:落叶旋转动画
-(void)leafOverturnAnimation{
    //    1.创建动画并制定动画属性
    CABasicAnimation * basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //    2.设置动画属性结束值
    basicAnimation.toValue = [NSNumber numberWithFloat:M_PI_2*3];
    basicAnimation.repeatCount = HUGE_VALF;
    //    3.设置动画属性的属性
    basicAnimation.duration = 6.0;
    basicAnimation.autoreverses = YES;  //旋转后再旋转回原来的位置
    
    //    4.添加动画到图层,注意key仅仅相当于给动画命名,以后获取动画可以采用该名字获取
    [self.leafLayer addAnimation:basicAnimation forKey:@"leafOverturn"];
}
/*---------------------------------------------------------------------------------------*/
//MARK: 晴天娃娃摇摆动画
-(void)sunChildAniamtion{
    UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 80)];
    imgView.center = CGPointMake(SCRCCEWH.width/2, 0);
    imgView.image = [UIImage imageNamed:@"娃娃"];
    imgView.layer.anchorPoint = CGPointMake(28.5/40, 16/80);
    [self.view addSubview:imgView];
    
    id fromValue = [NSNumber numberWithFloat:-M_PI/ 10.0];
    id toValue = [NSNumber numberWithFloat:M_PI/ 10.0];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1.5; // 持续时间
    
    CAMediaTimingFunction *mediaTiming = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.timingFunction = mediaTiming;
    animation.repeatCount = HUGE_VALF; // 重复次数
    animation.fromValue =  fromValue;// 起始角度
    animation.toValue = toValue; // 终止角度
    animation.autoreverses = YES;
    [imgView.layer addAnimation:animation forKey:nil];
}
/*---------------------------------------------------------------------------------------*/
//得到蝴蝶当前图片
- (UIImage *)getImage:(BOOL)isNext{
    if(isNext){
        self.currentIndex = (self.currentIndex + 1)%IMAGE_COUNT;
    }else{
        self.currentIndex = (self.currentIndex - 1 + IMAGE_COUNT)%IMAGE_COUNT;
    }
    NSString * imageName = [NSString stringWithFormat:@"%i.jpg",self.currentIndex];
    return [UIImage imageNamed:imageName];
}
//蝴蝶飞舞动画
-(void)butterflyAnimation{
    self.butterflyLayer = [[CALayer alloc]init];
    self.butterflyLayer.bounds = CGRectMake(0, 0, 60, 60);
    self.butterflyLayer.position = CGPointMake(SCRCCEWH.width, SCRCCEWH.height/2);
    [self.view.layer addSublayer:self.butterflyLayer];
    
    self.images = [NSMutableArray array];
    for (int i = 1; i <= 2; i++){
        NSString * imageName = [NSString stringWithFormat:@"fly%i.png",i];
        UIImage * image = [UIImage imageNamed:imageName];
        [self.images addObject:image];
    }
    
    //    定义时钟对象
    CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
    //    添加时钟对象到主队列循环
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    //    蝴蝶飞舞路径
    [self butterflypath];
}
//MARK:蝴蝶飞舞路径
-(void)butterflypath{
    //1.创建关键帧动画并设置动画属性
    CAKeyframeAnimation *keyframeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置关键帧
    NSValue * key1 = [NSValue valueWithCGPoint:self.butterflyLayer.position];  //对于关键帧动画初始值不能省略
    NSValue * key2 = [NSValue valueWithCGPoint:CGPointMake(80, 220)];
    NSValue * key3 = [NSValue valueWithCGPoint:CGPointMake(55, 200)];
    NSValue * key4 = [NSValue valueWithCGPoint:CGPointMake(60, 78)];
    NSValue * key5 = [NSValue valueWithCGPoint:CGPointMake(88, 0)];
    NSArray * values = @[key1,key2,key3,key4,key5];
    keyframeAnimation.values = values;
    
    
    keyframeAnimation.repeatCount = HUGE_VALF; //重复次数
    keyframeAnimation.calculationMode = kCAAnimationCubicPaced;  //动画的计算模式
    keyframeAnimation.keyTimes = @[@0.0,@0.5,@0.7,@1.0]; //控制各个帧的时间
    //设置其他属性
    keyframeAnimation.duration=15;
    keyframeAnimation.beginTime=CACurrentMediaTime()+1;//设置延迟执行
    //3.添加动画到图层，添加动画后就会执行动画
    [self.butterflyLayer addAnimation:keyframeAnimation forKey:@"butterfly"];
    
}
//MARK: 每次屏幕刷新就会执行一次此方法
-(void)step{
    //定义一个变量记录执行次数
    static int s = 1;
    if(++s % 25 == 0){
        UIImage * image = self.images[self.currentIndex];
        self.butterflyLayer.contents = (id)image.CGImage;
        self.currentIndex = (self.currentIndex + 1)%IMAGE_COUNT;
    }
    
}
/*---------------------------------------------------------------------------------------*/
- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[WLBallTool shareBallTool] stopMotionUpdates];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
