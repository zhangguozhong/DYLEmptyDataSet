# DYLEmptyDataSet
集成UITableView等视图无数据界面

1、本例主要是运用在UITableView、UICollectionView无数据的情况下，在reloadData方法中嵌入显示无数据的界面逻辑。通过Method Swillize实现方法交换的，
整个核心在于
void dyl_new_implementation(id self, SEL _cmd)
{
    Class baseClass = dyl_baseClassToSwizzleForTarget(self);
    NSString *key = dyl_implementationKey(baseClass, _cmd);
    
    NSDictionary *swizzleInfo = _impLookupTable[key];
    
    NSValue *valuePointer = [swizzleInfo objectForKey:DYLSwizzleInfoPointerKey];
    IMP originalImpPointor = [valuePointer pointerValue];
    
    // 执行是否显示无数据界面
    [self dyl_reloadEmptyDataSet];
    
    // 如果已保存，执行系统原本的implementation
    if (originalImpPointor) {
        ((void(*)(id,SEL))originalImpPointor)(self, _cmd);
    }
}
先执行显示无数据界面的逻辑，再执行原本的reloadData逻辑。


2、可以通过DYLEmptyDataSetSource、DYLEmptyDataSetDelegate增加协议方法，配置无数据界面，支持自定义视图。
